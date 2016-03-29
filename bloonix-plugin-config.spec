Summary: Bloonix configuration files for plugins
Name: bloonix-plugin-config
Version: 0.33
Release: 1%{dist}
License: Commercial
Group: Utilities/System
Distribution: RHEL and CentOS

Packager: Jonny Schulz <js@bloonix.de>
Vendor: Bloonix

BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

Source0: http://download.bloonix.de/sources/%{name}-%{version}.tar.gz
Requires: bloonix-core
Requires: bloonix-dbi
Requires: perl-JSON-XS
Requires: perl(Params::Validate)
AutoReqProv: no

%description
bloonix-plugin-config provides configuration files
for all plugins to import into the database.

%define blxdir /usr/lib/bloonix
%define docdir %{_docdir}/%{name}-%{version}

%prep
%setup -q -n %{name}-%{version}

%build
%{__perl} Configure.PL --prefix /usr --without-perl
%{__make}
cd perl;
%{__perl} Build.PL installdirs=vendor
%{__perl} Build

%install
rm -rf %{buildroot}
%{__make} install DESTDIR=%{buildroot}
mkdir -p ${RPM_BUILD_ROOT}%{docdir}/
install -c -m 0444 LICENSE ${RPM_BUILD_ROOT}%{docdir}/
install -c -m 0444 ChangeLog ${RPM_BUILD_ROOT}%{docdir}/

cd perl;
%{__perl} Build install destdir=%{buildroot} create_packlist=0
find %{buildroot} -name .packlist -exec %{__rm} {} \;

%post
if [ -e "/usr/lib/bloonix/etc/plugins/plugin-nagios-wrapper" ] ; then
    rm -f /usr/lib/bloonix/etc/plugins/plugin-nagios-wrapper
fi
if [ -e "/usr/lib/bloonix/etc/plugins/import/basic/plugin-nagios-wrapper" ] ; then
    rm -f /usr/lib/bloonix/etc/plugins/import/basic/plugin-nagios-wrapper
fi
/usr/bin/bloonix-load-plugins --load-all

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)

%{_bindir}/bloonix-create-plugin
%{_bindir}/bloonix-load-plugins

%dir %{blxdir}
%dir %{blxdir}/etc
%dir %{blxdir}/etc/plugins
%dir %{blxdir}/etc/plugins/import
%dir %{blxdir}/etc/plugins/import/*
%{blxdir}/etc/plugins/import/*/*

%{_mandir}/man3/*
%dir %{perl_vendorlib}/Bloonix
%{perl_vendorlib}/Bloonix/*.pm

%dir %attr(0755, root, root) %{docdir}
%doc %attr(0444, root, root) %{docdir}/ChangeLog
%doc %attr(0444, root, root) %{docdir}/LICENSE

%changelog
* Tue Mar 29 2016 Jonny Schulz <js@bloonix.de> - 0.33-1
- Extra release because the gpg key of bloonix is updated.
* Sat Mar 19 2016 Jonny Schulz <js@bloonix.de> - 0.32-1
- New plugin check-proc-status.
* Wed Mar 02 2016 Jonny Schulz <js@bloonix.de> - 0.31-1
- Plugin check-logfile: permit non existent logfile.
* Thu Jan 07 2016 Jonny Schulz <js@bloonix.de> - 0.30-1
- Plugin check-mysql-slave: new parameter verbose-error.
* Tue Dec 29 2015 Jonny Schulz <js@bloonix.de> - 0.29-1
- Plugin check-memstat: new key memavailable and a new chart.
* Wed Dec 16 2015 Jonny Schulz <js@bloonix.de> - 0.28-1
- Just changed the option order of check-http.
* Mon Nov 30 2015 Jonny Schulz <js@bloonix.de> - 0.27-1
- New desc for plugin check-wtrm.
* Thu Nov 26 2015 Jonny Schulz <js@bloonix.de> - 0.26-1
- New param per-cpu for plugin check-loadavg.
* Sat Nov 21 2015 Jonny Schulz <js@bloonix.de> - 0.25-1
- New param authkey for plugin check-by-satellite.
* Mon Sep 28 2015 Jonny Schulz <js@bloonix.de> - 0.24-1
- Infos updates for plugin check-linux-updates.
* Wed Sep 16 2015 Jonny Schulz <js@bloonix.de> - 0.23-1
- New plugin check-bloonix-satellite.
- New plugin check-ntp-time.
* Sat Aug 15 2015 Jonny Schulz <js@bloonix.de> - 0.22-1
- Updated example of check-lm-sensors.
* Tue Jun 16 2015 Jonny Schulz <js@bloonix.de> - 0.21-1
- Fixed description of cpu field "nice"
* Tue Jun 16 2015 Jonny Schulz <js@bloonix.de> - 0.20-1
- New key "other" in bloonix-plugins-linux/check-cpustat.
* Thu May 07 2015 Jonny Schulz <js@bloonix.de> - 0.19-1
- Set string "{}" as default for column "info" in table "plugin".
- Plugin check-bloonix-server added.
* Thu Apr 23 2015 Jonny Schulz <js@bloonix.de> - 0.18-1
- Different plugin changes.
* Mon Apr 06 2015 Jonny Schulz <js@bloonix.de> - 0.17-1
- All snmp plugins has new options.
* Mon Mar 09 2015 Jonny Schulz <js@bloonix.de> - 0.16-1
- Some new options. check-mdadm has a new parameter.
* Mon Jan 26 2015 Jonny Schulz <js@bloonix.de> - 0.15-1
- Delete logger section in bloonix-load-plugins to prevent
  the creation of the file bloonix-server.log as user root.
* Tue Jan 13 2015 Jonny Schulz <js@bloonix.de> - 0.14-1
- Fixed datatype for plugin-rbl.
* Tue Jan 13 2015 Jonny Schulz <js@bloonix.de> - 0.13-1
- New plugin check-rbl.
* Tue Dec 23 2014 Jonny Schulz <js@bloonix.de> - 0.12-1
- Replaced nagios-wrapper with simple-wrapper.
* Thu Dec 04 2014 Jonny Schulz <js@bloonix.de> - 0.11-1
- New plugin check-snmp-walk.
* Tue Dec 02 2014 Jonny Schulz <js@bloonix.de> - 0.10-1
- New plugin check-snmp.
* Sun Nov 30 2014 Jonny Schulz <js@bloonix.de> - 0.9-1
- Different updates for linux and postfix plugins.
* Fri Nov 28 2014 Jonny Schulz <js@bloonix.de> - 0.8-1
- Kicked plugins for Windows.
* Wed Nov 26 2014 Jonny Schulz <js@bloonix.de> - 0.7-1
- Updates for bloonix-wtrm.
* Tue Nov 25 2014 Jonny Schulz <js@bloonix.de> - 0.6-1
- Added plugin plugin-lsi-raid.
- Added snmp plugins.
* Sat Nov 08 2014 Jonny Schulz <js@bloonix.de> - 0.5-1
- Kicked deprecated base plugins.
* Thu Nov 06 2014 Jonny Schulz <js@bloonix.de> - 0.4-1
- Added PluginLoader.pm and bloonix-load-plugins to
  load the plugins into the database.
* Wed Nov 05 2014 Jonny Schulz <js@bloonix.de> - 0.3-1
- Update of check-linux-updates, check-smart-health
* Mon Nov 03 2014 Jonny Schulz <js@bloonix.de> - 0.2-1
- Updated the license information.
* Wed Sep 10 2014 Jonny Schulz <js@bloonix.de> - 0.1-1
- Initial release.
