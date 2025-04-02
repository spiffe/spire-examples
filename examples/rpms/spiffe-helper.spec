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

Summary:    SPIFFE Helper
Name:       spiffe-helper
Version:    0.10.0
Release:    1
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
#FIXME grab binaries once they are available
Source0:    https://github.com/spiffe/spiffe-helper/releases/download/v%{version}/spiffe-helper_v%{version}_Linux-%{ARCH}.tar.gz

%global __strip /bin/true

%description
SPIFFE Helper

%global _missing_build_ids_terminate_build 0
%global debug_package %{nil}

%prep

%setup -c

%build

%install
mkdir -p %{buildroot}/usr/bin
cp spiffe-helper %{buildroot}/usr/bin

%clean
rm -rf %{buildroot}

%files
/usr/bin/spiffe-helper
