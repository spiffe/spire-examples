##############################################################################
#
# To you, dear reader:
#
# If you are a normal user, we recommend not reading further. Its probably not
# the file your looking for.
#
# If you are looking at using this file as a base for your own work, please
# don't. It is a horrible example. Please look elsewhere.
#
# If you are a package maintainer, please read on. We recognize this spec file
# is blasphemous, a terrible abomination, a crime against nature, and more. We
# regret needing to produce it, but had to in order to attract enough users to
# find you. We beseech thee, kind and generous package maintainer, please help
# us mend our wicked ways by joining us and help us produce proper packaging.
# You are our only hope.
#
##############################################################################

Summary:    SPIRE components
Name:       spire-common
Version:    1.9.4
Release:    1
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
Source0:    https://github.com/spiffe/spire/releases/download/v%{version}/spire-%{version}-linux-amd64-musl.tar.gz

%description
SPIRE Common

%package -n spire-server
Summary: SPIRE Server
Requires: spire-common
%description -n spire-server
SPIRE Server

%preun -n spire-server
%if 0%{?suse_version}
%service_del_preun spire-server@\*.service spire-server.target
%endif
%if 0%{?fedora} || 0%{?rhel} || 0%{?openEuler}
%systemd_preun spire-server@\*.service spire-server.target
%endif

%postun -n spire-server
%systemd_postun spire-server@\*.service spire-server.target

%package -n spire-agent
Summary: SPIRE Agent
Requires: spire-common
%description -n spire-agent
SPIRE Agent

%preun -n spire-agent
%if 0%{?suse_version}
%service_del_preun spire-agent@\*.service spire-agent.target
%endif
%if 0%{?fedora} || 0%{?rhel} || 0%{?openEuler}
%systemd_preun spire-agent@\*.service spire-agent.target
%endif

%postun -n spire-agent
%systemd_postun spire-agent@\*.service spire-agent.target

%global _missing_build_ids_terminate_build 0
%global debug_package %{nil}

%prep

%setup -c

%build

%install

mkdir -p "%{buildroot}/bin"
cp "spire-%{version}"/bin/* "%{buildroot}/bin"
git clone https://github.com/kfox1111/spire-examples
cd spire-examples
git checkout systemd
cd examples/systemd
make install DESTDIR="%{buildroot}"

%clean
rm -rf %{buildroot}

%files
/usr/lib/systemd/system/*.target

%files -n spire-server
/usr/lib/systemd/system/spire-server@.service
/bin/spire-server
%config(noreplace) /etc/spire/server/main.conf

%files -n spire-agent
/usr/lib/systemd/system/spire-agent@.service
/bin/spire-agent
%config(noreplace) /etc/spire/agent/main.conf
