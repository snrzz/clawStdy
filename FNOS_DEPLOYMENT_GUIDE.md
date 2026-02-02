# OpenClaw on FNOS Deployment Guide

This guide covers deploying OpenClaw on FNOS (Freenas/NAS operating system with Docker management).

## FNOS Docker Management Features

FNOS provides a comprehensive Docker management interface with the following capabilities:

### 1. Docker Container Management
- **Container Lifecycle**: Start, stop, restart, pause, unpause containers
- **Resource Limits**: CPU, memory, disk I/O limits per container
- **Network Management**: Built-in bridge networks, port mappings
- **Volume Management**: Persistent storage with host path mappings

### 2. Docker Compose Support
FNOS supports Docker Compose for multi-container applications:

```yaml
version: '3.8'  # Note: FNOS may warn about obsolete version attribute
services:
  openclaw-gateway:
    image: openclaw:local
    container_name: openclaw-gateway
    restart: unless-stopped
    ports:
      - "18789:18789"
      - "18790:18790"
    volumes:
      - ${OPENCLAW_CONFIG_DIR}:/home/node/.openclaw
      - ${OPENCLAW_WORKSPACE_DIR}:/home/node/.openclaw/workspace
    environment:
      - HOME=/home/node
      - OPENCLAW_GATEWAY_TOKEN=${OPENCLAW_GATEWAY_TOKEN}
    init: true
```

### 3. Important FNOS Considerations

#### A. Version Attribute Warning
FNOS Docker may show warning:
```
WARN: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
```
**Solution**: Remove the `version` attribute from docker-compose.yml

#### B. Dockerfile COPY with --exclude
Standard Docker COPY instruction doesn't support `--exclude` flag. Instead use:

```dockerfile
# Wrong (causes error):
COPY --exclude='*test*' --exclude='*.test.*' --exclude='__pycache__/' .

# Correct approaches:
# Option 1: Use .dockerignore
# Option 2: Multi-stage COPY
COPY . .
RUN find /app -name "*test*" -type f -delete && \
    find /app -path "*/__pycache__/*" -delete

# Option 3: Copy specific directories
COPY package.json pnpm-lock.yaml ./
COPY ui/package.json ./ui/
COPY patches ./patches
COPY scripts ./scripts
```

#### C. Environment Variables
FNOS manages environment variables through its UI. Set these before deployment:
- `OPENCLAW_GATEWAY_TOKEN`: Gateway authentication token
- `CLAUDE_AI_SESSION_KEY`: Claude AI session (optional)
- `CLAUDE_WEB_SESSION_KEY`: Claude web session (optional)
- `CLAUDE_WEB_COOKIE`: Claude web cookie (optional)

### 4. FNOS-Specific Deployment Steps

#### Step 1: Prepare Local Build
```bash
# Build the image locally
docker build -t openclaw:local .

# Or use the build script
chmod +x docker-setup.sh
./docker-setup.sh build
```

#### Step 2: Export/Import (if needed)
If building directly on FNOS isn't feasible:
```bash
# Save image
docker save openclaw:local > openclaw-local.tar

# Transfer to FNOS and load
docker load < openclaw-local.tar
```

#### Step 3: FNOS Docker Configuration

1. **Create Container**:
   - Navigate to FNOS Docker > Containers
   - Add Container
   - Configure Image: `openclaw:local`
   - Set Network: Bridge
   - Port Mapping: 18789, 18790
   - Volume Mapping: Config and workspace directories

2. **Environment Variables**:
   - Add all required environment variables through FNOS UI

3. **Restart Policy**: Set to "Unless stopped"

### 5. Troubleshooting Common Issues

#### Issue: COPY requires at least two arguments
**Error**:
```
Dockerfile parse error on line 19: COPY requires at least two arguments, but only one was provided
```
**Cause**: Using `--exclude` flag with COPY (not supported by Docker)
**Fix**: See Section 2B above

#### Issue: Version attribute warning
**Error**: `WARN: the attribute 'version' is obsolete`
**Fix**: Remove `version` from docker-compose.yml

#### Issue: Permission denied on mounted volumes
**Solution**: Ensure FNOS dataset permissions allow access

### 6. Security Considerations

1. **Non-root User**: OpenClaw Dockerfile runs as non-root `node` user
2. **Init Process**: Uses `init: true` for proper signal handling
3. **Token Security**: Store tokens securely in FNOS environment variables

## Quick Reference

| FNOS Version | Docker Support | Notes |
|--------------|----------------|-------|
| FN 11.3+ | Docker CE | Full support |
| TrueNAS 12.0+ | Docker | Via plugins jail |

## Additional Resources

- [OpenClaw Documentation](docs/)
- [FNOS Docker Guide](https://www.truenas.com/docs/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
