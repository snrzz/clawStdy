# clawStdy - OpenClaw Study Repository

This repository contains the OpenClaw source code with additional documentation for FNOS deployment.

## Contents

- **openclaw/**: Latest source code from openclaw/openclaw
- **FNOS_DEPLOYMENT_GUIDE.md**: Comprehensive guide for deploying on FNOS with Docker

## Quick Start

### 1. Clone and Build
```bash
git clone https://github.com/snrzz/clawStdy.git
cd clawStdy

# Install dependencies
pnpm install --frozen-lockfile

# Build
pnpm build
```

### 2. Docker Deployment (FNOS)
See [FNOS_DEPLOYMENT_GUIDE.md](FNOS_DEPLOYMENT_GUIDE.md) for detailed instructions.

### 3. Environment Setup
Copy environment template and configure:
```bash
cp .env.example .env
# Edit .env with your tokens
```

## Features

- Multi-platform AI assistant (any OS, any platform)
- Docker-ready deployment
- FNOS compatible
- Multiple channel support (Discord, Slack, Telegram, WhatsApp, etc.)
- Plugin architecture

## Documentation

- [OpenClaw Docs](docs/)
- [FNOS Deployment Guide](FNOS_DEPLOYMENT_GUIDE.md)

## License

MIT License - See original OpenClaw repository for details.
