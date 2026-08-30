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

Summary:    SLURM SPIRE Syncer
Name:       slurm-spire-syncer
Version:    0.1.0
Release:    1
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
Source0:    https://github.com/spiffe/slurm-spire-syncer/releases/download/v%{version}/slurm-spire-syncer_Linux_%{ARCH}.tar.gz

%global __strip /bin/true

%description
Syncs running SLURM jobs into SPIRE registration entries, so workloads attested
by the SPIRE slurm workload attestor are issued an SVID.

Requires the SLURM client tools at runtime: it polls "squeue --json". SLURM is
not expressed as a package dependency because it is not carried in the base
distribution repositories.

%global _missing_build_ids_terminate_build 0
%global debug_package %{nil}

%prep

%setup -c

%build

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/lib/systemd/system
mkdir -p %{buildroot}/etc/spire/slurm-syncer
cp -a slurm-spire-syncer %{buildroot}/usr/bin
cp -a systemd/slurm-spire-syncer@.service %{buildroot}/usr/lib/systemd/system
cp -a config/slurm-syncer/default.conf %{buildroot}/etc/spire/slurm-syncer/
cp -a config/slurm-syncer/default.env %{buildroot}/etc/spire/slurm-syncer/

%clean
rm -rf %{buildroot}

%files
/usr/bin/slurm-spire-syncer
/usr/lib/systemd/system/slurm-spire-syncer@.service
%config(noreplace) /etc/spire/slurm-syncer/default.conf
%config(noreplace) /etc/spire/slurm-syncer/default.env
