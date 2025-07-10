# 🚀 Enhanced Onyx (Danswer) - Enterprise AI Search Platform

This is an enhanced and secured version of Onyx (formerly Danswer), a comprehensive AI platform for enterprise search and chat capabilities.

## 🔧 Recent Enhancements

### Security Improvements
- ✅ Removed suspicious binary files (`hello-vmlinux.bin`)
- ✅ Enhanced `.gitignore` to prevent binary and temporary files
- ✅ Added comprehensive security configuration
- ✅ Implemented security scanning and vulnerability checks
- ✅ Fixed npm security vulnerabilities

### Code Quality
- ✅ Added automated cleanup and improvement scripts
- ✅ Enhanced development environment setup
- ✅ Improved dependency management
- ✅ Added comprehensive deployment scripts

### New Tools and Scripts
- 📁 `scripts/cleanup_and_improve.py` - Automated security and quality checks
- 📁 `scripts/setup_and_deploy.sh` - Comprehensive setup and deployment
- 📁 `security/security-config.yaml` - Security configuration and guidelines
- 📁 `CLEANUP_REPORT.md` - Detailed cleanup and security analysis

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- Node.js 18+ and npm
- Python 3.8+
- Git

### 1. Clone and Setup
```bash
git clone <your-repo-url>
cd danswer
./scripts/setup_and_deploy.sh setup
```

### 2. Development Deployment
```bash
./scripts/setup_and_deploy.sh deploy dev
```

### 3. Production Deployment
```bash
./scripts/setup_and_deploy.sh deploy prod
```

### 4. Health Check
```bash
./scripts/setup_and_deploy.sh health
```

## 🔒 Security Features

### Authentication & Authorization
- **Multi-factor Authentication** support
- **OIDC/SAML/OAuth2** integration
- **Role-based Access Control (RBAC)**
- **Document-level permissions**

### Data Protection
- **End-to-end encryption** (AES-256-GCM)
- **PII detection and masking**
- **Data retention policies**
- **GDPR compliance** features

### Network Security
- **HTTPS enforcement** with HSTS
- **CORS protection**
- **Rate limiting**
- **Security headers** implementation

### Monitoring & Auditing
- **Comprehensive audit logging**
- **Security event monitoring**
- **Vulnerability scanning**
- **Compliance reporting**

## 📊 Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Frontend  │    │   API Server    │    │   Background    │
│   (Next.js)     │◄──►│   (FastAPI)     │◄──►│   Workers       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌─────────────────┬─────┴─────┬─────────────────┐
         │                 │           │                 │
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   PostgreSQL    │ │     Vespa       │ │     Redis       │
│   (Database)    │ │   (Search)      │ │    (Cache)      │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

## 🛠️ Development

### Environment Setup
```bash
# Setup development environment
./scripts/setup_and_deploy.sh dev

# Install pre-commit hooks
pre-commit install

# Run security checks
python scripts/cleanup_and_improve.py
```

### Code Quality
```bash
# Backend linting
cd backend && python -m ruff check .

# Frontend linting
cd web && npm run lint

# Type checking
cd web && npm run type-check
```

### Testing
```bash
# Backend tests
cd backend && python -m pytest

# Frontend tests
cd web && npm test

# E2E tests
cd web && npm run test:e2e
```

## 🚀 Deployment Options

### Local Development
```bash
./scripts/setup_and_deploy.sh deploy dev
```
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- Admin Panel: http://localhost:3000/admin

### Production (with SSL)
```bash
./scripts/setup_and_deploy.sh deploy prod
```

### Production (without SSL)
```bash
./scripts/setup_and_deploy.sh deploy prod-no-ssl
```

### Kubernetes
```bash
# Using Helm
helm install onyx deployment/helm/

# Using raw manifests
kubectl apply -f deployment/kubernetes/
```

## 🔧 Configuration

### Environment Variables
Key environment variables for configuration:

```bash
# Authentication
AUTH_TYPE=oidc
OAUTH_CLIENT_ID=your_client_id
OAUTH_CLIENT_SECRET=your_client_secret

# Database
POSTGRES_HOST=localhost
POSTGRES_DB=onyx
POSTGRES_USER=onyx
POSTGRES_PASSWORD=your_password

# Search Engine
VESPA_HOST=localhost
VESPA_PORT=8081

# Cache
REDIS_HOST=localhost
REDIS_PORT=6379

# Security
SECRET_KEY=your_secret_key
ENCRYPTION_KEY=your_encryption_key
```

### Security Configuration
Review and customize `security/security-config.yaml` for your security requirements.

## 📈 Monitoring

### Health Endpoints
- `/health` - Basic health check
- `/metrics` - Prometheus metrics
- `/admin/health` - Detailed system status

### Logging
- Application logs: `/var/log/onyx/`
- Security logs: `/var/log/onyx/security/`
- Audit logs: `/var/log/onyx/audit/`

## 🔌 Connectors

Onyx supports 40+ connectors including:

**Cloud Storage**
- Google Drive
- Microsoft SharePoint
- Dropbox
- Box

**Communication**
- Slack
- Microsoft Teams
- Discord
- Gmail

**Documentation**
- Confluence
- Notion
- GitBook
- Zendesk

**Development**
- GitHub
- GitLab
- Jira
- Linear

**CRM & Sales**
- Salesforce
- HubSpot
- Gong
- Outreach

[View all connectors](https://docs.onyx.app/connectors)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Run security and quality checks
4. Submit a pull request

### Development Guidelines
- Follow the security configuration in `security/security-config.yaml`
- Run `python scripts/cleanup_and_improve.py` before committing
- Ensure all tests pass
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📖 [Documentation](https://docs.onyx.app/)
- 💬 [Slack Community](https://join.slack.com/t/onyx-dot-app/shared_invite/zt-34lu4m7xg-TsKGO6h8PDvR5W27zTdyhA)
- 🎮 [Discord](https://discord.gg/TDJ59cGV2X)
- 📧 [Email Support](mailto:founders@onyx.app)

## 🔄 Changelog

### v1.0.0-enhanced
- ✅ Security hardening and vulnerability fixes
- ✅ Automated setup and deployment scripts
- ✅ Comprehensive security configuration
- ✅ Enhanced development environment
- ✅ Improved code quality tools
- ✅ Cleanup and optimization scripts

---

**Note**: This is an enhanced version of the original Onyx project with additional security, deployment, and development improvements. Always review security configurations before production deployment.