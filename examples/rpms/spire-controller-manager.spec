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

Summary:    SPIRE Controller Manager
Name:       spire-controller-manager
Version:    0.6.2
Release:    1
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
Requires:   spire-common
#FIXME Switch to binaries once released
Source0:    https://github.com/spiffe/spire-controller-manager/archive/refs/tags/v%{version}.tar.gz
Source1:    spire-extras-systemd.tar.gz

%global __strip /bin/true

%description
SPIRE Controller Manager

%global _missing_build_ids_terminate_build 0
%global debug_package %{nil}

%prep

%setup
%setup -T -D -a 1

%build
curl -L -o go.tar.gz https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
tar -xvf go.tar.gz
export PATH=$PATH:$(pwd)/go/bin
export CGO_ENABLED=0
go build -o spire-controller-manager cmd/main.go

%install
mkdir -p %{buildroot}/usr/bin
cp spire-controller-manager %{buildroot}/usr/bin
cd systemd
make install DESTDIR="%{buildroot}"
rm -f "%{buildroot}/etc/spiffe/default-trust-domain.env"
rm -f "%{buildroot}/etc/spire/agent/default".*
rm -f "%{buildroot}/etc/spire/server/default".*
rm -f "%{buildroot}/usr/lib/systemd/system/spire-agent"*
rm -f "%{buildroot}/usr/lib/systemd/system/spire-server"*
rm -f "%{buildroot}/usr/lib/systemd/system/spire.target"
rm -f "%{buildroot}/usr/libexec/spire/server/start.sh"

%clean
rm -rf %{buildroot}

%files
/usr/lib/systemd/system/spire-controller-manager@.service
/usr/bin/spire-controller-manager
/usr/libexec/spire/controller-manager/start.sh
%config(noreplace) /etc/spire/controller-manager/default.conf
