# Contributing to Responsible AI Demos

Thank you for your interest in contributing to this project! This repository contains educational demonstrations of Responsible AI practices using Azure AI services.

## How to Contribute

We welcome contributions in the following areas:

### 💡 Content Contributions

- **New demo scenarios**: Additional industry verticals (government, education, telecommunications)
- **Enhanced test cases**: More adversarial examples or edge cases
- **Evaluation metrics**: Additional safety measurements or benchmarks
- **Documentation improvements**: Clearer explanations, better examples, or fixed typos

### 🐛 Bug Reports

- Report bugs through [GitHub Issues](../../issues)
- Include reproduction steps, expected vs. actual behavior
- Specify your environment (Python version, OS, Azure SDK versions)

### 🔧 Code Contributions

- Follow the existing code style (PEP 8 for Python)
- Add comments explaining complex logic
- Include docstrings for all functions
- Test your changes before submitting

## Pull Request Process

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** with clear, descriptive commits
3. **Update documentation** if you've added or changed functionality
4. **Test thoroughly**:
   - Ensure the notebook runs end-to-end
   - Verify all safety checks work as expected
   - Check that no real credentials are included
5. **Submit a pull request** with:
   - Clear description of what changed and why
   - Link to any related issues
   - Screenshots or examples if applicable

## Development Guidelines

### Code Quality

- **Responsible AI First**: All contributions must align with [Microsoft's Responsible AI principles](https://www.microsoft.com/ai/responsible-ai)
- **Security**: Never commit API keys, credentials, or real customer data
- **Privacy**: Use only synthetic data (Faker library) for demonstrations
- **Clarity**: Code should be educational and easy to understand

### Responsible AI Requirements

When adding new features, ensure:

- ✅ Defense-in-depth approach (multiple safety layers)
- ✅ Fail-closed behavior (block on errors)
- ✅ Audit logging for safety events
- ✅ Clear documentation of risks and mitigations
- ✅ Appropriate warnings for sensitive content (self-harm, etc.)

### Testing Checklist

Before submitting:

- [ ] Code runs without errors
- [ ] All safety checks function correctly
- [ ] No real credentials or PII in code
- [ ] Documentation is updated
- [ ] Comments explain complex logic
- [ ] Synthetic data only (Faker library)
- [ ] Follows Microsoft Responsible AI guidelines

## Documentation Standards

- Use **Markdown** for all documentation
- Include **code examples** with explanations
- Link to **official Microsoft documentation** where applicable
- Add **diagrams or visuals** for complex concepts (use ASCII art in Markdown)

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Questions?

- **Technical questions**: Open a [GitHub Issue](../../issues)
- **Security concerns**: See [SECURITY.md](SECURITY.md)
- **General inquiries**: Contact the repository maintainers

## Resources

- [Azure AI Documentation](https://learn.microsoft.com/azure/ai-services/)
- [Responsible AI at Microsoft](https://www.microsoft.com/ai/responsible-ai)
- [Azure AI Content Safety](https://learn.microsoft.com/azure/ai-services/content-safety/)
- [Azure OpenAI Service](https://learn.microsoft.com/azure/ai-services/openai/)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for helping make AI systems safer and more responsible!** 🛡️
