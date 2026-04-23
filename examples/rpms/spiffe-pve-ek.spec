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

Summary:    SPIFFE PVE EK Service
Name:       spiffe-pve-ek
Version:    1.11.3
Release:    1
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
Source0:    https://github.com/spiffe/spire-tpm-plugin/releases/download/v%{version}/spiffe-pve-ek_linux_%{ARCH}_v%{version}.tar.gz
Source1:    https://github.com/spiffe/spire-tpm-plugin/archive/refs/tags/v%{version}.tar.gz

%global __strip /bin/true

%description
SPIFFE PVE EK Servie used to integrate Proxmox and SPIFFE

%global _missing_build_ids_terminate_build 0
%global debug_package %{nil}

%prep

%setup -c
%setup -T -D -a 1

%build

%install
mkdir -p "%{buildroot}/usr/bin"
mkdir -p "%{buildroot}/etc/spiffe/pve-ek"
mkdir -p "%{buildroot}/usr/lib/systemd/system"
mkdir -p "%{buildroot}/var/lib/vz/snippets/"
cp -a spiffe-pve-ek %{buildroot}/usr/bin/
cp -a spire-tpm-plugin-%{version}/pve/conf/* %{buildroot}/etc/spiffe/pve-ek/
cp -a spire-tpm-plugin-%{version}/pve/systemd/* %{buildroot}/usr/lib/systemd/system/
cp -a spire-tpm-plugin-%{version}/pve/hook/tpm-attestor.pl %{buildroot}/var/lib/vz/snippets/

%clean
rm -rf %{buildroot}

%files
/usr/bin/spiffe-pve-ek
/var/lib/vz/snippets/tpm-attestor.pl
/usr/lib/systemd/system/spiffe-pve-ek@.service
%config(noreplace) /etc/spiffe/pve-ek/a.env
%config(noreplace) /etc/spiffe/pve-ek/b.env
%config(noreplace) /etc/spiffe/pve-ek/default.env
