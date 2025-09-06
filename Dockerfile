FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install LibreTranslate and dependencies
RUN pip install --no-cache-dir \
    libretranslate \
    argos-translate-files

# Create directories for models and data
RUN mkdir -p /app/models /app/data

# Set environment variables
ENV LT_SHARED_STORAGE=/app/data
ENV ARGOS_TRANSLATE_MODELS_DIR=/app/models

# Pre-install translation models
RUN python3 -m libretranslate --install-models en,fr

# Expose port
EXPOSE 5000

# Start command that works with Render's PORT environment variable
CMD ["sh", "-c", "python3 -m libretranslate --host 0.0.0.0 --port ${PORT:-5000}"]
