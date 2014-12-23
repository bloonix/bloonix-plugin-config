Summary: Bloonix configuration files for plugins
Name: bloonix-plugin-config
Version: 0.12
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
