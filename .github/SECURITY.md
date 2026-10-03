# Security Policy

We take the security of **BoardPort — EDL Container** and automated deployment workflows seriously.

---

## Supported Versions

Please check the table below for supported versions regarding security updates.

| Version | Supported |
| :--- | :--- |
| `main` | :white_check_mark: |
| Latest release (`v*`) | :white_check_mark: |
| Legacy / untagged | :x: |

---

## Reporting a Vulnerability

If you discover a security vulnerability or potential risk (such as unsafe command injections in entrypoints,
insecure container privilege escalations, or malicious payload execution), please **do not** open a public issue.

Instead, report the vulnerability confidentially by contacting:

- **Email**: **BoardPort Security <boardport@proton.me>**

### What to Include in Your Report

- A detailed description of the vulnerability.
- Affected component (`Dockerfile`, `docker-entrypoint.sh`, `.make/*.mk`, `Makefile`).
- Steps to reproduce the issue (including proof-of-concept commands or parameters).
- The potential impact of the vulnerability.

### Response Timeline

- We will acknowledge receipt of your report within 48 hours.
- We will provide a status update and remediation timeline within 7 business days.

Thank you for helping keep the BoardPort ecosystem secure!
