%global service_name %{name}

Name:             %{name}
Version:          %{ver}
Release:          %{rel}%{?dist}
Summary:          picfit for RHEL/CENTOS %{os_rel}
BuildArch:        %{arch}
Group:            Application/Internet
License:          commercial
URL:              https://github.com/thoas/picfit
BuildRoot:        %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires(pre):    /usr/sbin/useradd, /usr/bin/getent
Requires(postun): /usr/sbin/userdel

Source1:        picfit.bin
Source2:        config.json
Source3:        picfit.service

%define appdir /opt/%{name}
%define systemd_dest /usr/lib/systemd/system/
%description
picfit for RHEL/CENTOS %{os_rel}

%prep

%build

%pre
/usr/bin/getent group %{name} || /usr/sbin/groupadd -r %{name}
/usr/bin/getent passwd %{name} || /usr/sbin/useradd -g %{name} -r -d %{appdir} -s /sbin/nologin %{name}

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{appdir}
mkdir -p $RPM_BUILD_ROOT/%{systemd_dest}
%{__install} -p -m 0755 %{SOURCE1} $RPM_BUILD_ROOT/%{appdir}/picfit
%{__install} -p -m 0750 %{SOURCE2} $RPM_BUILD_ROOT/%{appdir}/config.json
%{__install} -p -m 0755 %{SOURCE3} $RPM_BUILD_ROOT/%{systemd_dest}/picfit.service

%postun
/usr/sbin/userdel %{name}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,%{name},%{name})
%attr(0755,%{name},%{name}) %{appdir}
%attr(0755,%{name},%{name}) %{appdir}/*
%attr(0755,%{name},%{name}) %{systemd_dest}/picfit.service
%config(noreplace) %{appdir}/config.json

%changelog
* Thu Jan 05 2015 Daniel Menet <daniel.menet@swisstxt.ch> - 1-1
Initial creation
