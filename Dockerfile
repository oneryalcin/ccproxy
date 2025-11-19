FROM node:20-slim

# Prevent interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools
# ripgrep is added as it's used by Claude for searching.
RUN apt-get update && apt-get install -y \
    git \
    curl \
    vim \
    less \
    ca-certificates \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code (Native Recommended Method)
# This typically installs to ~/.claude/bin
RUN curl -fsSL https://claude.ai/install.sh | bash

# Ensure Claude is in the PATH
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory
WORKDIR /app

# Keep container alive
CMD ["tail", "-f", "/dev/null"]

