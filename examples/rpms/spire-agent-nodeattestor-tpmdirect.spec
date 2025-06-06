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

Summary:    SPIRE Agent Node Attestor TPM Direct
Name:       spire-agent-nodeattestor-tpmdirect
Version:    1.9.0
Release:    1
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
Source0:    https://github.com/spiffe/spire-tpm-plugin/releases/download/v%{version}/spire_tpm_plugin_tpm_attestor_agent_linux_%{ARCH}_v%{version}.tar.gz
Source1:    https://github.com/spiffe/spire-tpm-plugin/releases/download/v%{version}/spire_tpm_plugin_get_tpm_pubhash_linux_%{ARCH}_v%{version}.tar.gz

%global __strip /bin/true

%description
SPIRE Agent Node Attestor TPM Direct

%global _missing_build_ids_terminate_build 0
%global debug_package %{nil}

%prep

%setup -c
%setup -T -D -a 1

%build

%install
mkdir -p "%{buildroot}/usr/bin"
mkdir -p "%{buildroot}/usr/libexec/spire/plugins"
cp -a tpm_attestor_agent %{buildroot}/usr/libexec/spire/plugins/agent-nodeattestor-tpmdirect
cp -a get_tpm_pubhash %{buildroot}/usr/bin/get-tpm-pubhash

%clean
rm -rf %{buildroot}

%files
/usr/bin/get-tpm-pubhash
/usr/libexec/spire/plugins/agent-nodeattestor-tpmdirect
