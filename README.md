# Claude Code with Gemini via LiteLLM

This project sets up a Docker environment to run **Claude Code** (Anthropic's CLI tool) but routes the actual LLM requests to **Google Gemini** using **LiteLLM** as a proxy.

## Prerequisites

- Docker & Docker Compose
- A Google Gemini API Key

## Setup

1. **Set your Gemini API Key:**
   You can set it in your shell or create a `.env` file (recommended).
   ```bash
   export GEMINI_API_KEY="your_gemini_key_here"
   ```
   Or create a `.env` file:
   ```env
   GEMINI_API_KEY=your_gemini_key_here
   ```

2. **Start the Services:**
   ```bash
   docker compose up -d --build
   ```

3. **Initialize Claude Code:**
   Because we have set `ANTHROPIC_AUTH_TOKEN` in the docker-compose file, you might **not** need to interactively authenticate!
   
   Enter the container:
   ```bash
   docker compose exec claude-code bash
   ```
   
   Run the tool:
   ```bash
   claude
   ```
   
   If it still asks for login, just follow the prompts, but the environment variable usually bypasses the need for a valid Anthropic account check against their servers when a custom base URL is used.

## Configuration

- **Models:** The `litellm_config.yaml` maps standard Claude models (like `claude-3-5-sonnet-20240620`) to `gemini/gemini-1.5-pro`.
- **Proxy:** LiteLLM runs on port `4000`. Claude Code is configured to talk to `http://litellm:4000` via the `ANTHROPIC_BASE_URL` environment variable.

## Troubleshooting

If you encounter errors regarding API compatibility (e.g., LiteLLM complaining about request format):
- Claude Code uses the Anthropic API format.
- LiteLLM primarily expects OpenAI API format but has support for Anthropic inputs in some configurations.
- Check the `litellm` logs: `docker compose logs -f litellm`
