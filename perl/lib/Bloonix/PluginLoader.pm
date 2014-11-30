package Bloonix::PluginLoader;

=head1 NAME

Bloonix::PluginLoader - Import bloonix plugins.

=head1 SYNOPSIS

    Bloonix::PluginLoader->run
        config_file => $config,
        plugin_file => $plugin,
    );

=head1 DESCRIPTION

Import a plugin into the bloonix database.

=head1 COPYRIGHT

Copyright (C) 2009-2014 by Jonny Schulz. All rights reserved.

=cut

use strict;
use warnings;
use JSON;
use Bloonix::DBI;
use Bloonix::Config;
use Params::Validate qw();
use base qw(Bloonix::Accessor);

__PACKAGE__->mk_accessors(qw/dbi sql json/);

our $VERSION = "0.9";

sub run {
    my ($class, %argv) = @_;
    my $self = bless \%argv, $class;
    my @plugins;

    if ($argv{plugin_file}) {
        push @plugins, split /,/, $argv{plugin_file};
    } elsif ($argv{plugin_path}) {
        $argv{plugin_path} =~ s!/\s*\z!!;
        push @plugins, <$argv{plugin_path}/plugin-*>;
        chomp @plugins;
    } elsif ($argv{load_all}) {
        foreach my $dir ("/usr", "/usr/local") {
            my $plugin_path = "$dir/lib/bloonix/etc/plugins/import";
            if (-d $plugin_path) {
                foreach my $dir ($self->get_files($plugin_path)) {
                    if (-d "$plugin_path/$dir") {
                        foreach my $plugin ($self->get_files("$plugin_path/$dir")) {
                            if (-f "$plugin_path/$dir/$plugin" && $plugin =~ /^plugin-/) {
                                push @plugins, "$plugin_path/$dir/$plugin";
                            }
                        }
                    }
                }
            }
        }
    }

    if (!@plugins) {
        die "no plugin-* files found\n";
    }

    my $config = Bloonix::Config->parse($self->{config_file});
    $self->{config} = $config;
    $self->{dbi} = Bloonix::DBI->new($config->{database});
    $self->{sql} = $self->dbi->sql;
    $self->{json} = JSON->new();

    $self->dbi->connect;

    foreach my $plugin (@plugins) {
        eval{
            print "Load plugin $plugin\n";
            open my $fh, "<", $plugin
                or die "unable to open plugin '$plugin' for reading: $!";
            my $plugin_config = do { local $/; <$fh> };
            close $fh;
            $plugin_config = JSON->new->decode($plugin_config);
            if (ref $plugin_config->{plugin}->{info} eq "HASH") {
                $plugin_config->{plugin}->{info} = JSON->new->encode($plugin_config->{plugin}->{info});
            }
            $self->{plugin} = $self->validate($plugin_config);
            $self->update_plugin;
            $self->update_statistics;
            $self->update_charts;
        };
        warn $@ if $@;
    }
}

sub get_files {
    my ($self, $path) = @_;

    opendir my $dh, $path
        or die "unable to open directory '$path' for reading: $!";
    my @files = grep /^[a-z]/, readdir $dh;
    closedir $dh;

    return @files;
}

sub update_plugin {
    my $self = shift;
    my $data = $self->{plugin}->{plugin};

    my $plugin = $self->dbi->unique(
        $self->sql->select(
            table  => "plugin",
            column => "*",
            condition => [ id => $data->{id} ]
        )
    );

    if ($plugin) {
        $self->dbi->do(
            $self->sql->update(
                table  => "plugin",
                column => $data,
                condition => [ id => $data->{id} ],
            )
        );
    } else {
        $self->dbi->do(
            $self->sql->insert(
                table  => "plugin",
                column => $data,
            )
        );
    }
}

sub update_statistics {
    my $self = shift;
    my $plugin = $self->{plugin}->{plugin};
    my $data = $self->{plugin}->{statistic};
    my %stats = ();

    my $temp = $self->dbi->fetch(
        $self->sql->select(
            table => "plugin_stats",
            column => "*",
            condition => [ plugin_id => $plugin->{id} ]
        )
    );

    foreach my $stat (@$temp) {
        my $key = $stat->{statkey};

        if (exists $data->{$key}) {
            $stats{$key} = $stat;
        } else {
            $self->dbi->do(
                $self->sql->delete(
                    table => "plugin_stats",
                    condition => [
                        plugin_id => $plugin->{id},
                        statkey => $key
                    ]
                )
            );
        }
    }

    foreach my $key (keys %$data) {
        if (exists $stats{$key}) {
            $self->dbi->do(
                $self->sql->update(
                    table  => "plugin_stats",
                    column => $data->{$key},
                    condition => [
                        plugin_id => $plugin->{id},
                        statkey => $key
                    ]
                )
            );
        } else {
            $self->dbi->do(
                $self->sql->insert(
                    table => "plugin_stats",
                    column => $data->{$key},
                )
            );
        }
    }
}

sub update_charts {
    my $self = shift;
    my $plugin = $self->{plugin}->{plugin};
    my $data = $self->{plugin}->{chart};
    my %charts = ();

    foreach my $id (keys %$data) {
        my $chart = $self->dbi->unique(
            $self->sql->select(
                table => "chart",
                column => "*",
                condition => [ id => $id ]
            )
        );

        if (ref $data->{$id}->{options}->{series} eq "HASH") {
            $data->{$id}->{options}->{series} = [ $data->{$id}->{options}->{series} ];
        }

        $data->{$id}->{options} = $self->json->encode($data->{$id}->{options});

        if ($chart) {
            $self->dbi->do(
                $self->sql->update(
                    table  => "chart",
                    column => $data->{$id},
                    condition => [ id => $id ]
                )
            );
        } else {
            $self->dbi->do(
                $self->sql->insert(
                    table  => "chart",
                    column => $data->{$id}
                )
            );
        }
    }
}

sub validate {
    my $self = shift;

    my %options = Params::Validate::validate(@_, {
        plugin => {
            type => Params::Validate::HASHREF,
        },
        statistic => {
            type => Params::Validate::HASHREF | Params::Validate::ARRAYREF,
            default => [ ],
        },
        chart => {
            type => Params::Validate::HASHREF | Params::Validate::ARRAYREF,
            default => [ ],
        },
    });

    $options{plugin} = $self->validate_plugin($options{plugin});

    my $stats = ref $options{statistic} eq "HASH"
        ? [ $options{statistic} ]
        : $options{statistic};

    my $charts = ref $options{chart} eq "HASH"
        ? [ $options{chart} ]
        : $options{chart};

    $options{statistic} = { };
    $options{chart} = { };

    foreach my $stat (@$stats) {
        my $validated = $self->validate_statistic($stat);
        $validated->{plugin_id} = $options{plugin}{id};
        if (!$validated->{stattype}) {
            if ($validated->{datatype} =~ /varchar/) {
                $validated->{stattype} = "string";
            } else {
                $validated->{stattype} = "gauge";
            }
        }
        my $statkey = $validated->{statkey};
        $options{statistic}{$statkey} = $validated;
    }

    foreach my $chart (@$charts) {
        my $validated = $self->validate_chart($chart);
        $validated->{id} = sprintf("%d%04d", $options{plugin}{id}, $validated->{id});
        $validated->{plugin_id} = $options{plugin}{id};
        my $id = $validated->{id};
        $options{chart}{$id} = $validated;
    }

    return \%options;
}

sub validate_plugin {
    my $self = shift;

    my %options = Params::Validate::validate(@_, {
        id => {
            type => Params::Validate::SCALAR,
            regex => qr/^[1-9]\d*\z/
        },
        plugin => {
            type => Params::Validate::SCALAR,
            regex => qr/^[A-Za-z_0-9\-\.]+\z/
        },
        command => {
            type => Params::Validate::SCALAR,
            regex => qr/^check-[a-z0-9\-]{1,30}(\.[a-zA-Z]+){0,1}\z/
        },
        datatype => {
            type => Params::Validate::SCALAR,
            regex => qr/^(?:statistic|table|logfile|none)\z/
        },
        category => {
            type => Params::Validate::SCALAR,
            regex => qr/^[A-Za-z0-9,]{3,100}\z/
        },
        description => {
            type => Params::Validate::SCALAR,
            regex => qr/^[^<>]{3,500}\z/
        },
        abstract => {
            type => Params::Validate::SCALAR,
            regex => qr/^[^<>]{3,100}\z/
        },
        subkey => {
            type => Params::Validate::SCALAR,
            regex => qr/^\w{1,20}\z/,
            default => 0
        },
        company_id => {
            type => Params::Validate::SCALAR,
            regex => qr/^\d+\z/,
            default => 1
        },
        netaccess => {
            type => Params::Validate::SCALAR,
            regex => qr/^(yes|no)\z/,
            default => "no"
        },
        prefer => {
            type => Params::Validate::SCALAR,
            regex => qr/^(localhost|localnet|remote)\z/,
            default => "localhost"
        },
        worldwide => {
            type => Params::Validate::SCALAR,
            regex => qr/^(yes|no)\z/,
            default => "no"
        },
        info => {
            type => Params::Validate::SCALAR
        }
    });

    $options{netaccess} = $options{netaccess} eq "yes" ? 1 : 0;
    $options{worldwide} = $options{worldwide} eq "yes" ? 1 : 0;

    return \%options;
}

sub validate_statistic {
    my $self = shift;

    my %options = Params::Validate::validate(@_, {
        statkey => {
            type => Params::Validate::SCALAR,
            regex => qr/^\w{1,25}\z/
        },
        stattype => {
            type => Params::Validate::SCALAR,
            regex => qr/^(?:gauge|counter|string)\z/,
            optional => 1
        },
        datatype => {
            type => Params::Validate::SCALAR,
            regex => qr/^(?:smallint|integer|bigint|float|varchar\(\d+\))\z/
        },
        description => {
            type => Params::Validate::SCALAR,
            regex => qr/^[^<>]{3,500}\z/
        },
        substr => {
            type => Params::Validate::SCALAR,
            regex => qr/^\d+\z/,
            default => 0
        },
        units => {
            type => Params::Validate::SCALAR,
            regex => qr/^((kilo|mega|giga|tera|peta|exa|zetta|yotta){0,1}(bytes|bits)|ms|percent|null|temperature|unixtime|default)+\z/,
            default => "default"
        },
        alias => {
            type => Params::Validate::SCALAR,
            regex => qr/^.{0,100}\z/,
            optional => 1
        }
    });

    return \%options;
}

sub validate_chart {
    my $self = shift;

    my %options = Params::Validate::validate(@_, {
        id => {
            type => Params::Validate::SCALAR,
            regex => qr/^[1-9]\d{0,2}\z/
        },
        title => {
            type => Params::Validate::SCALAR,
            regex => qr/^[^<>]{3,50}\z/
        },
        options => {
            type => Params::Validate::HASHREF
        }
    });

    return \%options;
}

1;
