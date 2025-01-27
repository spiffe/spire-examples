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

Summary:    SPIFFE Step SSH
Name:       spiffe-step-ssh
Version:    0.0.6
Release:    1
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
Source0:    https://github.com/spiffe/spiffe-step-ssh/archive/refs/tags/v%{version}.tar.gz
Requires:   step-cli
Requires:   spiffe-helper

%description
SPIFFE Step SSH

%global _missing_build_ids_terminate_build 0
%global debug_package %{nil}

%prep

%setup -c

%build

%install
cd spiffe-step-ssh-%{version}
make install DESTDIR="%{buildroot}"

%clean
rm -rf %{buildroot}

%files
/usr/libexec/spiffe-step-ssh/*
/usr/lib/systemd/system/sshd.service.d/10-spiffe-step-ssh.conf
/usr/lib/systemd/system/spiffe-step-ssh@.service
/usr/lib/systemd/system/spiffe-step-ssh-cleanup.service
%config(noreplace) /etc/spiffe/step-ssh
