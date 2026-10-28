# Security

Neptunium is an experimental browser. There are no supported stable releases or
security-update guarantees yet. The pinned Servo version has no Windows renderer
sandbox. Do not rely on this preview for sensitive browsing.

## Reporting a vulnerability

Use GitHub's **Report a vulnerability** option if private vulnerability reporting
is enabled on the repository. Otherwise, open an issue requesting a private
contact method without including exploit details, private data, or credentials.

Include the affected commit, operating system, impact, and a minimal reproduction
when sharing details privately. For bugs in unmodified Servo code, coordinate
with the Servo maintainers as well.

## Current boundaries

Web content must not gain access to native settings files, arbitrary local files,
the terminal, IDE projects, or operating-system tools. The built-in Neptunium
protocol serves fixed local pages without access to privileged engine APIs.

Site isolation, sandboxing, dependency updates, download handling, and background
network traffic all need ongoing review. An encrypted connection indicator does
not establish that a website is trustworthy.
