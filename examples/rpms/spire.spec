##############################################################################
#
# To you, dear reader:
#
# If you are a normal user, we recommend not reading further. Its probably not
# the file your looking for.
#
# If you are looking at using this file as a base for your own work, please
# don't. It is a horrible example. Please look elsewhere,
#
# If you are a package maintainer, please read on. We recognize this spec file
# is blasphemous, an terrible abomination, a crime against nature, and more. We
# regret needing to produce it in order to attract enough users to find you. We
# beseech thee, kind and generous package maintainer, please help us mend our
# wicked ways by joining is us and help us produce proper packaging. Your our
# only hope.
#
##############################################################################

Summary:    SPIRE components
Name:       spire-common
Version:    1.9.4
Release:    1
Group:      Applications/Internet
License:    Apache-2.0
URL:        https://spiffe.io
Source0:    https://github.com/spiffe/spire/releases/download/v%{version}/spire-%{version}-linux-amd64-musl.tar.gz

%description
SPIRE Common

%package -n spire-server
Summary: SPIRE Server
Requires: spire-common
%description -n spire-server
SPIRE Server

%package -n spire-agent
Summary: SPIRE Agent
Requires: spire-common
%description -n spire-agent
SPIRE Agent

%global debug_package %{nil}

%prep

%setup -c

%build

%install

mkdir -p "%{buildroot}/bin"
cp "spire-%{version}"/bin/* "%{buildroot}/bin"
git clone https://github.com/kfox1111/spire-examples
cd spire-examples
git checkout systemd
cd examples/systemd
make install DESTDIR="%{buildroot}"

%clean
rm -rf %{buildroot}

%files
/usr/lib/systemd/system/*.target

%files -n spire-server
/usr/lib/systemd/system/spire-server@.service
/bin/spire-server

%files -n spire-agent
/usr/lib/systemd/system/spire-agent@.service
/bin/spire-agent
