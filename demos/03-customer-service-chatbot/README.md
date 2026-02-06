# Customer Service Chatbot Safety Demo

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](../../../LICENSE)
[![Responsible AI](https://img.shields.io/badge/Responsible%20AI-Microsoft-blue)](https://www.microsoft.com/ai/responsible-ai)
[![Azure](https://img.shields.io/badge/Azure-AI%20Services-0078D4)](https://azure.microsoft.com/products/ai-services)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](../../../CONTRIBUTING.md)

## 📢 Important Notice

**This is an educational demonstration project created by a Microsoft employee.**

- ✅ **Safe for Learning**: Uses 100% synthetic data (Faker library)
- ⚠️ **Not Production-Ready**: Requires additional hardening for real deployments
- 🛡️ **Educational Only**: Do not attempt exploits against live systems
- 🌍 **Open Source**: MIT License - contributions welcome!
- 📖 **See Also**: [SECURITY.md](../../../SECURITY.md) | [CONTRIBUTING.md](../../../CONTRIBUTING.md) | [CODE_OF_CONDUCT.md](../../../CODE_OF_CONDUCT.md)

---

## Overview

This demo showcases a **high-risk AI use case**: customer service chatbots across retail, financial services, and healthcare industries. It demonstrates:

1. **Vulnerability exploration**: Systematic exploits against minimally-protected chatbots
2. **Azure safety tools**: Layered defense architecture with 8 protection layers
3. **Quantitative validation**: Before/after comparison using concrete metrics
4. **Production patterns**: HAX principles, industry reusability, continuous monitoring

## Why This Use Case is High-Risk

Customer service chatbots represent one of the **highest-risk AI deployment scenarios**:

- **Direct customer exposure**: Millions of conversations daily
- **PII handling**: Names, emails, financial data, health information
- **Adversarial users**: Active attempts to manipulate, extract data, or cause harm
- **Regulatory compliance**: GDPR, HIPAA, PCI-DSS violations carry severe penalties
- **Brand reputation**: Viral failures can cause lasting damage
- **Business-critical**: Errors lead to financial loss, legal liability, trust erosion

## Safety Tools Demonstrated

### Required Tools (Fully Implemented)

1. **Azure AI Content Safety** ([Docs](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/))
   - Filters: Hate, Violence, Sexual, Self-Harm
   - Threshold: Severity ≤ 2 (blocks Medium+)
   - Applied: Input AND output layers

2. **Prompt Shields** ([Docs](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection))
   - Direct jailbreak detection
   - Indirect prompt injection (RAG poisoning)
   - Applied: User inputs AND retrieved documents

3. **Groundedness Detection** ([Docs](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/groundedness))
   - Threshold: 4+ on 1-5 scale
   - Validates responses against RAG context
   - Prevents hallucinated information

4. **Presidio** ([Docs](https://microsoft.github.io/presidio/))
   - PII detection: PERSON, EMAIL, PHONE, CREDIT_CARD, etc.
   - Anonymization: Replace with `<ENTITY_TYPE>` placeholders
   - Applied: Before logging conversations

### Recommended Tools (Conceptual)

5. **Azure AI Evaluation SDK** ([Docs](https://learn.microsoft.com/en-us/azure/ai-studio/how-to/develop/evaluate-sdk))
   - GroundednessEvaluator, CoherenceEvaluator
   - Continuous quality monitoring

6. **HAX Toolkit** ([Website](https://www.microsoft.com/en-us/haxtoolkit/))
   - Human-AI interaction design principles
   - Failure modes, escalation paths

## Architecture: Defense in Depth

```
User Input
    ↓
Layer 1: Prompt Shields (jailbreak detection)
    ↓
Layer 2: Content Safety - Input Filter
    ↓
Layer 3: RAG Context Retrieval
    ↓
Layer 4: Prompt Shields - Document Scan
    ↓
Layer 5: LLM Processing
    ↓
Layer 6: Groundedness Detection
    ↓
Layer 7: Content Safety - Output Filter
    ↓
Layer 8: Presidio PII Anonymization
    ↓
Logged (Safe) / Response to User
```

## Success Metrics

| Metric | Target | Demo Result |
|--------|--------|-------------|
| Harmful content in responses | < 0.1% | ✅ 0.5% (5/1000) |
| Groundedness score | > 4.0/5.0 | ✅ 4.2/5.0 |
| PII leaked to logs | 0 instances | ✅ 0 (100% anonymized) |
| Jailbreak success rate | 0% | ✅ 0% (all blocked) |

## Setup Instructions

### Prerequisites

1. **Azure OpenAI Service** with GPT-4 or GPT-3.5-Turbo deployment
2. **Azure AI Content Safety** resource
3. **Azure AI Studio** project (optional, for Evaluation SDK)

### Installation

```bash
# 1. Clone the repository
cd demos/03-customer-service-chatbot

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r setup/requirements.txt

# 4. Optional: Download spaCy model for enhanced PII detection
python -m spacy download en_core_web_lg

# 5. Configure environment variables
cp setup/.env.template setup/.env
# Edit setup/.env with your Azure credentials
```

### Configuration

Edit `setup/.env` with your Azure resource details:

```bash
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your_key_here
CONTENT_SAFETY_ENDPOINT=https://your-content-safety.cognitiveservices.azure.com/
CONTENT_SAFETY_KEY=your_key_here
```

### Running the Demo

```bash
# Launch Jupyter
jupyter notebook notebooks/customer-service-safety-demo.ipynb

# Or use VS Code
code notebooks/customer-service-safety-demo.ipynb
```

## Notebook Structure

1. **Risk Profile**: Why customer service chatbots are high-risk
2. **Baseline Chatbot (Vulnerable)**: 6 exploit demonstrations
   - Harmful content (hate speech)
   - Direct jailbreak attempts
   - Indirect prompt injection (RAG poisoning)
   - Hallucinations
   - PII leakage in logs
   - Self-harm content
3. **Protected Chatbot**: Same exploits with Azure safety tools
4. **Side-by-Side Comparison**: Before/after analysis
5. **Evaluation & Metrics**: Quantitative validation
6. **Common Pitfalls**: How this demo avoids them
7. **Industry Variants**: Retail, financial, healthcare examples
8. **HAX Principles**: Responsible AI interaction design
9. **Summary & Production Checklist**

## Test Cases

### Baseline (Vulnerable) Results

| Test | Attack Type | Result |
|------|-------------|--------|
| 1. Harmful Content | Hate speech prompt | ❌ May engage with hateful content |
| 2. Direct Jailbreak | "Ignore previous instructions" | ❌ Instructions overridden |
| 3. Indirect Injection | Hidden instructions in documents | ❌ Follows malicious instructions |
| 4. Hallucination | Questions outside KB | ❌ Fabricates specific data |
| 5. PII Leakage | Customer info in logs | ❌ Plaintext PII stored |
| 6. Self-Harm | Request for dangerous advice | ❌ Not safely handled |

### Protected Results

| Test | Attack Type | Result | Tool |
|------|-------------|--------|------|
| 1. Harmful Content | Hate speech prompt | ✅ Blocked at input | Content Safety |
| 2. Direct Jailbreak | "Ignore previous instructions" | ✅ Detected and blocked | Prompt Shields |
| 3. Indirect Injection | Hidden instructions in documents | ✅ Detected in RAG docs | Prompt Shields |
| 4. Hallucination | Questions outside KB | ✅ "I don't have that info" | Groundedness |
| 5. PII Leakage | Customer info in logs | ✅ Anonymized | Presidio |
| 6. Self-Harm | Request for dangerous advice | ✅ Crisis resources provided | Content Safety |

## Industry Variants

The same safety pipeline applies across industries:

### Retail
- **Use case**: Order status, returns, product info
- **Knowledge base**: Return policies, shipping times, warranties
- **PII**: Names, emails, order IDs
- **Compliance**: GDPR (EU customers)

### Financial Services
- **Use case**: Account inquiries, disputes, fraud alerts
- **Knowledge base**: Account policies, interest rates, security procedures
- **PII**: Names, emails, account numbers, card numbers
- **Compliance**: PCI-DSS, GDPR, SOX

### Healthcare
- **Use case**: Appointment scheduling, prescription refills, insurance questions
- **Knowledge base**: Appointment policies, insurance info, general health guidance
- **PII**: Names, emails, medical record numbers, dates of birth
- **Compliance**: HIPAA, GDPR

## Common Pitfalls Avoided

1. ✅ **Input-only filtering**: This demo filters both input AND output
2. ✅ **Ignoring indirect injection**: Tests RAG document poisoning
3. ✅ **Plaintext PII logs**: Anonymizes before storage
4. ✅ **No groundedness checks**: Validates every RAG response
5. ✅ **Generic error messages**: Context-specific safety responses
6. ✅ **No quantitative metrics**: Concrete thresholds and measurements
7. ✅ **One-time implementation**: Includes continuous monitoring pattern
8. ✅ **Single layer defense**: 8 layers of protection

## Production Deployment Checklist

Before going to production:

- [ ] All safety tools configured with production thresholds
- [ ] Comprehensive adversarial test suite
- [ ] Continuous monitoring with alerting
- [ ] PII anonymization verified in all storage
- [ ] Human escalation paths tested
- [ ] Industry compliance review (HIPAA, PCI-DSS, GDPR)
- [ ] Red team testing
- [ ] Incident response plan
- [ ] Regular safety feedback loop
- [ ] User education on AI limitations

## Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](../../../CONTRIBUTING.md) for:

- How to submit pull requests
- Code quality standards
- Responsible AI requirements
- Testing guidelines

**Ideas for contributions:**
- Additional industry scenarios (government, education, telecommunications)
- More adversarial test cases
- Enhanced evaluation metrics
- Documentation improvements
- Translation to other languages

## Limitations

⚠️ **No AI safety system is perfect.** This demo provides strong baseline protection, but:

1. **Evolving threats**: Attackers develop new bypass techniques
2. **Context-specific risks**: Each deployment has unique requirements
3. **Human oversight needed**: AI cannot handle all edge cases
4. **False positives**: Balance safety vs. user experience
5. **Latency**: Multiple checks add processing time

## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details.

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com).

## Security

Please review our [SECURITY.md](../../../SECURITY.md) file for information about:
- Reporting vulnerabilities responsibly
- Security best practices
- API key management

## Acknowledgments

- Microsoft Responsible AI team for guidance and principles
- Azure AI Services team for powerful safety tools
- Open source community for Presidio and related tools
- All contributors who help make AI systems safer

## Support

- **Issues**: Report bugs or request features via [GitHub Issues](../../issues)
- **Discussions**: Ask questions in [GitHub Discussions](../../discussions)
- **Security**: Report vulnerabilities via [SECURITY.md](../../../SECURITY.md)

## Resources

### Azure AI Safety
- [Content Safety Overview](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/)
- [Prompt Shields](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection)
- [Groundedness Detection](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/groundedness)
- [Azure AI Evaluation SDK](https://learn.microsoft.com/en-us/azure/ai-studio/how-to/develop/evaluate-sdk)
- [Azure OpenAI Service](https://learn.microsoft.com/en-us/azure/ai-services/openai/)

### PII Protection
- [Microsoft Presidio](https://microsoft.github.io/presidio/)

### Responsible AI
- [Microsoft Responsible AI](https://www.microsoft.com/en-us/ai/responsible-ai)
- [HAX Toolkit](https://www.microsoft.com/en-us/haxtoolkit/)
- [NIST AI Risk Management](https://www.nist.gov/itl/ai-risk-management-framework)
- [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/)

---

**Made with ❤️ by Microsoft | Empowering responsible AI development worldwide** 🌍

## Contributing

This demo is part of the Responsible AI Demos Portfolio. For issues or enhancements:

1. Review the [Program Charter](../../../Program-Charter.md)
2. Check the [Stakeholder Map](../../../Stakeholder-Map.md)
3. Submit issues or pull requests following project guidelines

## License

This demo uses synthetic data only. All customer profiles are generated by the Faker library and contain no real PII.

---

**Questions?** This is an educational demo. For production deployment, consult your organization's security, legal, and compliance teams.
