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

Summary:    SPIRE Server Attestor TPM Sign
Name:       spire-server-attestor-tpm-sign
Version:    0.0.3
Release:    1
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
Source0:    https://github.com/spiffe/spire-server-attestor-tpm/releases/download/v%{version}/spire-server-attestor-tpm-sign_Linux_%{ARCH}.tar.gz
Source1:    https://github.com/spiffe/spire-server-attestor-tpm/releases/download/v%{version}/spire-server-attestor-tpm-signer-http_Linux_%{ARCH}.tar.gz
Source2:    https://github.com/spiffe/spire-server-attestor-tpm/releases/download/v%{version}/spire-server-attestor-tpm-signer-unix_Linux_%{ARCH}.tar.gz
Source3:    https://github.com/spiffe/spire-server-attestor-tpm/releases/download/v%{version}/spire-server-attestor-tpm-verifier_Linux_%{ARCH}.tar.gz

%global __strip /bin/true

%description
SPIRE Server Attestor TPM Sign

%package -n spire-server-attestor-tpm-signer-http
Summary: SPIRE Server Attestor TPM Signer HTTP service
Requires: spire-server-attestor-tpm-signer-unix
%description -n spire-server-attestor-tpm-signer-http
SPIRE Server Attestor TPM Signer HTTP service

%package -n spire-server-attestor-tpm-signer-unix
Summary: SPIRE Server Attestor TPM Signer Unix service
%description -n spire-server-attestor-tpm-signer-unix
SPIRE Server Attestor TPM Signer Unix service

%package -n spire-server-attestor-tpm-verifier
Summary: SPIRE Server Attestor TPM Verifier service
%description -n spire-server-attestor-tpm-verifier
SPIRE Server Attestor TPM Verifier service

%global _missing_build_ids_terminate_build 0
%global debug_package %{nil}

%prep

%setup -c
%setup -T -D -a 1
%setup -T -D -a 2
%setup -T -D -a 3

%build

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/lib/systemd/system
mkdir -p %{buildroot}/etc/spire/server-attestor-tpm
cp -a spire-server-attestor-tpm-sign %{buildroot}/usr/bin
cp -a spire-server-attestor-tpm-signer-http %{buildroot}/usr/bin
cp -a spire-server-attestor-tpm-signer-unix %{buildroot}/usr/bin
cp -a spire-server-attestor-tpm-verifier %{buildroot}/usr/bin
cp -a systemd/spire-server-attestor-tpm-signer-http.service %{buildroot}/usr/lib/systemd/system
cp -a systemd/spire-server-attestor-tpm-signer-unix.service %{buildroot}/usr/lib/systemd/system
cp -a systemd/spire-server-attestor-tpm-verifier.service %{buildroot}/usr/lib/systemd/system
cp -a conf/signer-http.conf %{buildroot}/etc/spire/server-attestor-tpm/
cp -a conf/signer-unix.conf %{buildroot}/etc/spire/server-attestor-tpm/
cp -a conf/verifier.conf %{buildroot}/etc/spire/server-attestor-tpm/

%clean
rm -rf %{buildroot}

%files
/usr/bin/spire-server-attestor-tpm-sign

%files -n spire-server-attestor-tpm-signer-http
/usr/bin/spire-server-attestor-tpm-signer-http
/usr/lib/systemd/system/spire-server-attestor-tpm-signer-http.service
%config(noreplace) /etc/spire/server-attestor-tpm/signer-http.conf

%files -n spire-server-attestor-tpm-signer-unix
/usr/bin/spire-server-attestor-tpm-signer-unix
/usr/lib/systemd/system/spire-server-attestor-tpm-signer-unix.service
%config(noreplace) /etc/spire/server-attestor-tpm/signer-unix.conf

%files -n spire-server-attestor-tpm-verifier
/usr/bin/spire-server-attestor-tpm-verifier
/usr/lib/systemd/system/spire-server-attestor-tpm-verifier.service
%config(noreplace) /etc/spire/server-attestor-tpm/verifier.conf
