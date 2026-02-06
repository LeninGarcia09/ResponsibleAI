# Security Policy

## Supported Versions

This project is maintained as an educational demonstration of Responsible AI practices using Azure AI services. We recommend always using the latest version.

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| < Latest| :x:                |

## Reporting a Vulnerability

Microsoft takes the security of our software products and services seriously, including all open-source code repositories managed through our GitHub organizations.

### Microsoft Security Response Center (MSRC)

If you believe you have found a security vulnerability in this repository that meets [Microsoft's definition of a security vulnerability](https://docs.microsoft.com/en-us/previous-versions/tn-archive/cc751383(v=technet.10)), please report it to us as described below.

**Please DO NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them to the Microsoft Security Response Center (MSRC) at [https://msrc.microsoft.com/create-report](https://msrc.microsoft.com/create-report).

If you prefer to submit without logging in, send email to [secure@microsoft.com](mailto:secure@microsoft.com). If possible, encrypt your message with our PGP key; please download it from the [Microsoft Security Response Center PGP Key page](https://www.microsoft.com/en-us/msrc/pgp-key-msrc).

You should receive a response within 24 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

### Reporting Format

Please include the requested information listed below (as much as you can provide) to help us better understand the nature and scope of the possible issue:

* Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
* Full paths of source file(s) related to the manifestation of the issue
* The location of the affected source code (tag/branch/commit or direct URL)
* Any special configuration required to reproduce the issue
* Step-by-step instructions to reproduce the issue
* Proof-of-concept or exploit code (if possible)
* Impact of the issue, including how an attacker might exploit the issue

This information will help us triage your report more quickly.

## Preferred Languages

We prefer all communications to be in English.

## Policy

Microsoft follows the principle of [Coordinated Vulnerability Disclosure](https://www.microsoft.com/en-us/msrc/cvd).

## Additional Security Guidance

### API Keys and Secrets

- **NEVER** commit API keys, connection strings, or other secrets to this repository
- All `.env` files are gitignored by default
- Use Azure Key Vault for production deployments
- Rotate keys regularly

### Responsible AI

This project demonstrates AI safety tools. When deploying AI systems:

- Always implement defense-in-depth with multiple safety layers
- Monitor for adversarial attacks and prompt injections
- Comply with GDPR, HIPAA, and other relevant data protection regulations
- Implement proper audit logging and incident response procedures
- Follow Microsoft's [Responsible AI principles](https://www.microsoft.com/en-us/ai/responsible-ai)

### Synthetic Data Only

- All demo data in this repository is 100% synthetic
- Do NOT use real customer data with this demo code
- Ensure PII anonymization in production systems

## Resources

- [Microsoft Security](https://www.microsoft.com/security)
- [Azure Security Documentation](https://docs.microsoft.com/azure/security/)
- [Responsible AI at Microsoft](https://www.microsoft.com/ai/responsible-ai)
