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

%define ARCH %(echo %{_arch} | sed s/aarch64/arm64/)

Summary:    SPIRE HA Agent
Name:       spire-ha-agent
Version:    0.0.12
Release:    2
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
Source0:    https://github.com/spiffe/spire-ha-agent/releases/download/v%{version}/spire-ha-agent_Linux_%{ARCH}.tar.gz
Source1:    https://github.com/spiffe/spire-ha-agent/releases/download/v%{version}/spire-trust-sync-helper_Linux_%{ARCH}.tar.gz

%global __strip /bin/true

%description
SPIRE HA Agent

%package -n spire-trust-sync
Summary: SPIRE Trust Sync
Requires: spiffe-helper
%description -n spire-trust-sync
SPIRE Trust Sync

%package -n spire-socat
Summary: SPIRE socat
Requires: socat
%description -n spire-socat
SPIRE socat

%global _missing_build_ids_terminate_build 0
%global debug_package %{nil}

%prep

%setup -c
%setup -T -D -a 1

%build

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/lib/systemd/system
mkdir -p %{buildroot}/etc/spire/socat
mv spire-ha-agent %{buildroot}/usr/bin
cp -a systemd/spire-ha-agent@.service %{buildroot}/usr/lib/systemd/system
cp -a systemd/spire-socat@.service %{buildroot}/usr/lib/systemd/system
cp -a config/socat/* %{buildroot}/etc/spire/socat/
mkdir -p %{buildroot}/usr/libexec/spire/trust-sync/
mkdir -p %{buildroot}/etc/spire/trust-sync
cp -a spire-trust-sync-helper %{buildroot}/usr/libexec/spire/trust-sync
cp -a systemd/spire-trust-sync@.service %{buildroot}/usr/lib/systemd/system
cp -a config/trust-sync/default.conf %{buildroot}/etc/spire/trust-sync

%clean
rm -rf %{buildroot}

%files
/usr/bin/spire-ha-agent
/usr/lib/systemd/system/spire-ha-agent@.service

%files -n spire-socat
/usr/lib/systemd/system/spire-socat@.service
%config(noreplace) /etc/spire/socat/*

%files -n spire-trust-sync
/usr/libexec/spire/trust-sync
/usr/lib/systemd/system/spire-trust-sync@.service
%config(noreplace) /etc/spire/trust-sync/default.conf
