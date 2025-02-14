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

Summary:    K8s SPIFFE Workload JWT Exec Auth Plugin
Name:       k8s-spiffe-workload-jwt-exec-auth
Version:    0.0.5
Release:    1
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
Source0:    https://github.com/spiffe/k8s-spiffe-workload-jwt-exec-auth/releases/download/v%{version}/k8s-spiffe-workload-jwt-exec-auth_Linux_%{ARCH}.tar.gz

%description
K8s SPIFFE Workload JWT Exec Auth Plugin

%global _missing_build_ids_terminate_build 0
%global debug_package %{nil}

%prep

%setup -c

%build

%install
mkdir -p "%{buildroot}/usr/bin"
cp -a k8s-spiffe-workload-jwt-exec-auth %{buildroot}/usr/bin

%clean
rm -rf %{buildroot}

%files
/usr/bin/k8s-spiffe-workload-jwt-exec-auth
