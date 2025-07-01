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

%define ARCH %(echo %{_arch} | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

Summary:    SPIRE components
Name:       spire-common
Version:    1.12.4
Release:    1
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
Source0:    https://github.com/spiffe/spire/releases/download/v%{version}/spire-%{version}-linux-%{ARCH}-musl.tar.gz
Source1:    https://github.com/spiffe/spire/releases/download/v%{version}/spire-extras-%{version}-linux-%{ARCH}-musl.tar.gz
Source2:    spire-extras-systemd.tar.gz

%global __strip /bin/true

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

%package -n spiffe-oidc-discovery-provider
Summary: SPIFFE OIDC Discovery Provider
Requires: spire-common
%description -n spiffe-oidc-discovery-provider
SPIFFE OIDC Discovery Provider

%global _missing_build_ids_terminate_build 0
%global debug_package %{nil}

%prep

%setup -c
%setup -T -D -a 1
%setup -T -D -a 2

%build

%install

mkdir -p "%{buildroot}/bin"
cp "spire-%{version}"/bin/* "%{buildroot}/bin"
cp "spire-extras-%{version}"/bin/oidc-discovery-provider "%{buildroot}/bin/spiffe-oidc-discovery-provider"
cd systemd
make install DESTDIR="%{buildroot}"
rm -f "%{buildroot}/etc/spire/controller-manager/default.conf"
rm -f "%{buildroot}/usr/lib/systemd/system/spire-controller-manager@.service"
rm -f "%{buildroot}/usr/libexec/spire/controller-manager/start.sh"

%clean
rm -rf %{buildroot}

%files
/usr/lib/systemd/system/*.target
%config(noreplace) /etc/spiffe/default-trust-domain.env

%files -n spire-server
/usr/lib/systemd/system/spire-server@.service
/bin/spire-server
/usr/libexec/spire/server/start.sh
%config(noreplace) /etc/spire/server/default.conf
%config(noreplace) /etc/spire/server/default.env

%files -n spire-agent
/usr/lib/systemd/system/spire-agent@.service
/bin/spire-agent
%config(noreplace) /etc/spire/agent/default.conf

%files -n spiffe-oidc-discovery-provider
/bin/spiffe-oidc-discovery-provider
