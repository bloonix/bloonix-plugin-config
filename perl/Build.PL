use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    create_makefile_pl => 'traditional',
    module_name => 'Bloonix::PluginLoader',
    dist_author => 'Jonny Schulz',
    dist_abstract => 'Bloonix Plugin Loader',
    sign => 0,
    requires => {
        "Bloonix::Core" => 0,
        "Bloonix::DBI" => 0,
        "JSON" => 0,
        "Params::Validate" => 0
    },
);

$build->create_build_script;
