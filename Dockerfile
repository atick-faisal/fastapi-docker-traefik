# Reference: https://github.com/astral-sh/uv-docker-example

# ----------------------------------------
# 🛠 Builder Stage — Install Dependencies
# ----------------------------------------
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder

# Use compiled bytecode for performance; copy installed packages
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=0
    # Prevent re-downloading Python versions

# Set working directory
WORKDIR /source

# Cache uv and mount project dependencies for efficient builds
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    uv sync --locked --no-install-project --no-dev

# Copy entire source after syncing dependencies to avoid triggering unnecessary rebuilds
COPY . /source

# Re-run sync to install project code into virtual environment
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev

# ----------------------------------------
# 🚀 Final Stage — Lightweight Runtime Image
# ----------------------------------------
FROM python:3.13-slim-bookworm

# IMPORTANT: Match base image to builder to ensure Python path consistency

# Copy app and virtual environment from builder
COPY --from=builder --chown=source:source /source /source

# Prepend venv binaries to PATH
ENV PATH="/source/.venv/bin:$PATH"

# Optional: Set working directory for consistency (optional but helpful)
WORKDIR /source

# Default command to launch FastAPI app (adapt path if needed)
CMD ["fastapi", "run", "--host", "0.0.0.0", "--port", "80", "/source/app/main.py"]
