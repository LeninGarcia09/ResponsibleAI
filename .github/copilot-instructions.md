# GitHub Copilot Instructions for ResponsibleAI Project

## Project Overview
This project focuses on Responsible AI principles, including fairness, accountability, transparency, and ethical AI development.

## Critical: Information Accuracy
- **NEVER fabricate information, URLs, or references**
- Always validate that information provided is accurate and current
- Include official URLs for all tools, libraries, and frameworks
- If uncertain about a fact, explicitly state the uncertainty
- Verify documentation links before suggesting them
- When referencing standards or guidelines, provide official sources

## Coding Standards

### General Principles
- Prioritize code transparency and explainability
- Include comprehensive documentation for AI/ML models and algorithms
- Add clear comments explaining decision-making processes
- Follow ethical AI guidelines and best practices

### Code Style
- Use descriptive variable and function names that clearly indicate purpose
- Prefer explicit over implicit implementations
- Document assumptions and limitations
- Include type hints (Python) or strong typing where applicable

### Documentation Requirements
- Every AI model or algorithm must include:
  - Purpose and use case
  - Input/output specifications
  - Limitations and potential biases
  - Validation metrics used
  - Ethical considerations

### Testing
- Include unit tests for all core functionality
- Add bias and fairness testing for AI models
- Implement data validation checks
- Document edge cases and failure modes

## Responsible AI Specific Guidelines

### Fairness & Bias
- Always consider potential biases in data and models
- Include fairness metrics in model evaluation
- Document demographic considerations
- Implement bias mitigation strategies where applicable

### Privacy & Security
- Minimize data collection to necessary information only
- Implement proper data anonymization techniques
- Follow GDPR/privacy best practices: https://gdpr.eu/
- Use secure coding practices for data handling

### Transparency
- Provide clear explanations of model behavior
- Document data sources and preprocessing steps
- Make model limitations explicit
- Include interpretability features where possible

### Accountability
- Log important decisions and model predictions
- Implement audit trails for critical operations
- Include versioning for models and datasets
- Document responsible parties and review processes

## Code Review Checklist
When suggesting code, ensure:
- [ ] Ethical implications are considered
- [ ] Bias mitigation is addressed
- [ ] Privacy concerns are handled
- [ ] Code is well-documented
- [ ] Tests include fairness metrics
- [ ] Error handling is comprehensive
- [ ] Limitations are clearly stated

## Preferred Libraries & Tools
- Prefer well-maintained, ethical AI libraries
- Use fairness-aware ML libraries:
  - **Fairlearn**: https://fairlearn.org/
  - **AI Fairness 360 (AIF360)**: https://aif360.res.ibm.com/
- Include explainability tools:
  - **SHAP**: https://shap.readthedocs.io/
  - **LIME**: https://github.com/marcotcr/lime
- Follow responsible AI frameworks:
  - **Microsoft Responsible AI**: https://www.microsoft.com/en-us/ai/responsible-ai
  - **Google AI Principles**: https://ai.google/responsibility/principles/
  - **IBM AI Ethics**: https://www.ibm.com/artificial-intelligence/ethics

## Response Style
- Explain reasoning behind suggestions
- Highlight potential ethical concerns proactively
- Provide alternatives when trade-offs exist
- Reference relevant responsible AI principles
- Include warnings for sensitive operations
- **Always provide official URLs when referencing external resources**
- State uncertainty explicitly rather than guessing
- Verify information accuracy before presenting it

## Additional Resources
- **OECD AI Principles**: https://oecd.ai/en/ai-principles
- **EU AI Act**: https://digital-strategy.ec.europa.eu/en/policies/regulatory-framework-ai
- **Partnership on AI**: https://partnershiponai.org/
- **ACM Code of Ethics**: https://www.acm.org/code-of-ethics
