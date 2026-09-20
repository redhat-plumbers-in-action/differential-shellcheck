# SPDX-License-Identifier: GPL-3.0-or-later

Name:           differential-shellcheck
Version:        5.6.0
Release:        1%{?dist}
Summary:        Differential static analysis for shell scripts

License:        GPL-3.0-or-later
URL:            https://github.com/redhat-plumbers-in-action/%{name}
Source0:        %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:      noarch

BuildRequires:  pandoc
BuildRequires:  make

Requires:       ShellCheck
Requires:       csdiff
Requires:       jq
Requires:       git-core
Requires:       bash

Recommends:     sarif-fmt

%description
Differential ShellCheck performs differential ShellCheck scans on shell
scripts in a git repository. It identifies new defects introduced by
recent changes and fixes that were resolved, making it easy to focus on
newly introduced issues without being overwhelmed by pre-existing problems.

It can be used as a standalone CLI tool, a pre-commit hook, or a GitHub
Action.

%prep
%autosetup -n %{name}-%{version}

%build
%make_build man

%install
%make_install PREFIX=%{_prefix}

%check
# Run unit tests if bats is available
%if 0%{?fedora} || 0%{?rhel} >= 9
bats test/*.bats
%endif

%files
%license LICENSE
%doc README.md
%doc VERSION
%{_bindir}/%{name}
%{_libexecdir}/%{name}/
%{_mandir}/man1/%{name}.1*

%changelog
* Thu Apr 17 2026 Jan Macku <jamacku@redhat.com> - 5.6.0-1
- Add CLI interface for standalone usage outside GitHub Actions
- Add pre-commit hook support
- Add man page
