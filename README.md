# Claude Code Proxy (LiteLLM + Claude Code Router)

This project sets up a Docker environment to run **Claude Code** (Anthropic's CLI tool) while routing the LLM requests to other providers like **Google Gemini** or **OpenRouter** (Grok, DeepSeek, etc.).

It supports two architectures:
1.  **LiteLLM Proxy** (Python-based, standard OpenAI compatible proxy).
2.  **Claude Code Router** (Node.js-based, specialized for Claude Code's specific API quirks).

## Quick Start (Fused Mode - Recommended)

The recommended way is to use the "Fused" mode, where the client (Claude Code) and the proxy run in the same container. This avoids networking issues and provides a clean, self-contained shell.

### 1. Set API Keys
Set your keys in your shell:
```bash
export GEMINI_API_KEY="your_gemini_key"
export OPENROUTER_API_KEY="your_openrouter_key"
```

### 2. Run the Shell
To use the **Router** (Recommended for Gemini/Thinking models):
```bash
make shell-router
```

To use **LiteLLM**:
```bash
make shell-litellm
```

Once inside the shell, just run:
```bash
claude
```

## Architecture & Routing Logic

### Router Logic (Claude Code Router)
The Node.js router (`make shell-router`) uses specific logic to map Claude's intents to your configured models (`claude-code-router/config.json`).

**Current Mapping:**
*   **Haiku Requests:** Automatically routed to **`background`** model (Configured as: `gemini-2.5-flash-lite-preview`).
*   **Sonnet / Opus Requests:** Routed to **`default`** model (Configured as: `x-ai/grok-4.1-fast` via OpenRouter).
*   **Thinking Enabled:** Routed to **`think`** model (Configured as: `x-ai/grok-4.1-fast`).
*   **Long Context (>60k tokens):** Routed to **`longContext`** model.
*   **Web Search Tool:** Routed to **`webSearch`** model (Configured as: `gemini-2.5-flash-preview`).

### Advanced Routing Details

There is no explicit config setting for "Sonnet" or "Opus" in the router's JSON config. The routing logic is hardcoded as follows:

1.  **Explicit Override:** If you type `/model provider,model` in Claude, it uses that.
2.  **Long Context:** If tokens > threshold (60000), it uses `Router.longContext`.
3.  **Subagent:** If the prompt contains `<CCR-SUBAGENT-MODEL>`, it uses that model.
4.  **Haiku Special Case:** If the request model string contains "haiku", it forces the use of `Router.background`.
    ```typescript
    // src/utils/router.ts
    if (
      req.body.model?.includes("claude") &&
      req.body.model?.includes("haiku") &&
      config.Router.background
    ) {
      return config.Router.background;
    }
    ```
5.  **Web Search:** If tools include "web_search", it uses `Router.webSearch`.
6.  **Thinking:** If thinking is enabled, it uses `Router.think`.
7.  **Default:** Everything else (including Sonnet and Opus requests) falls back to `Router.default`.

**Summary:**
*   **Haiku requests** → `Router.background`
*   **Sonnet / Opus requests** → `Router.default` (unless they trigger "Thinking" or "Long Context").

**Workaround if you want Opus to be different from Sonnet:**
You would need to write a **Custom Router Script** (`custom-router.js`) as described in the router documentation, and configure `CUSTOM_ROUTER_PATH` in your config.

### LiteLLM Logic
The Python proxy (`make shell-litellm`) uses `litellm_config.yaml`.
*   It maps specific model names (e.g., `claude-3-5-sonnet`) directly to target models (e.g., `gemini/gemini-2.5-flash`).
*   **Known Issue:** LiteLLM currently struggles with Gemini's caching validation for short prompts (Error: `Cached content is too small`), which is why the Router is recommended for Gemini 2.5.

## Legacy Setup (Distributed Architecture)

If you prefer running services separately (e.g., for debugging the router logs independently), you can use the legacy `docker-compose up` method.

### 1. Start the Services
```bash
make up
```
This starts `router` (port 3000), `litellm` (port 4000), and `claude-code` (idle).

### 2. Switch Proxy
Use the Makefile to restart the `claude-code` container with the correct environment variable:

*   **To use Router:** `make switch-to-router`
*   **To use LiteLLM:** `make switch-to-litellm`

### 3. Enter the Container
```bash
make shell
# Inside:
claude
```

## Commands

| Command | Description |
| :--- | :--- |
| `make shell-router` | Build & enter the fused Router container (Node.js). |
| `make shell-litellm` | Build & enter the fused LiteLLM container (Python). |
| `make up` | Start the legacy distributed setup (separate containers). |
| `make down` | Stop all containers. |
| `make logs` | View logs of detached containers. |
| `make clean` | Stop services and remove volumes. |