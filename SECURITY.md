# Security Policy

## Scope

This policy applies to the Sloth project: the dotfiles framework, its shell
libraries under `scripts/core/src/`, the `bin/dot` CLI, and the CI workflows
under `.github/workflows/`.

Sloth deliberately runs arbitrary code from the user's own dotfiles and shells.
Shell snippets that execute user-provided commands (e.g. `eval`, `source`) are
expected behavior, not security issues. Similarly, options that run user
configured commands are designed to be unsafe. These must be documented and are
not considered vulnerabilities.

There are no hard and fast rules to determine if a bug is worth reporting as a
security issue or a "regular" issue. When in doubt, please send us a report.

## Supported versions

Security fixes are applied to the default branch and released with the next
release. There is no separate LTS channel.

## How to submit a report

Report severe security issues privately before disclosing them publicly, with
all details you know. Give maintainers a reasonable time to review and reply
before publishing.

Any other security issues use issues in the project to report it.

## Safe harbor

Sloth supports safe harbor for security researchers who:

*   Make a good faith effort to avoid privacy violations, destruction of data,
    and interruption or degradation of our services
*   Only interact with accounts you own or with explicit permission of the
    account holder. If you do encounter Personally Identifiable Information
    (PII) contact us immediately, do not proceed with access, and immediately
    purge any local information
*   Provide us with a reasonable amount of time to resolve vulnerabilities prior
    to any disclosure to the public or a third party
*   We will consider activities conducted consistent with this policy to
    constitute "authorised" conduct and will not pursue civil action or initiate
    a complaint to law enforcement. We will help to the extent we can if legal
    action is initiated by a third party against you

Please submit a report to us before engaging in conduct that may be inconsistent
with or unaddressed by this policy.

## Preferences

*   Please provide detailed reports with reproducible steps and a clearly
    defined impact
*   Submit one vulnerability per report
*   Social engineering (such as phishing, vishing, smishing) is prohibited
