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

# Create directories for models
RUN mkdir -p /app/models

# Set environment variables (remove problematic storage setting)
ENV ARGOS_TRANSLATE_MODELS_DIR=/app/models

# Pre-install translation models using argostranslate
RUN python3 -c "import argostranslate.package; argostranslate.package.update_package_index(); available_packages = argostranslate.package.get_available_packages(); [argostranslate.package.install_from_path(p.download()) for p in available_packages if (p.from_code, p.to_code) in [('en', 'fr'), ('fr', 'en')]]"

# Expose port
EXPOSE 5000

# Start command that works with Render's PORT environment variable
CMD ["sh", "-c", "libretranslate --host 0.0.0.0 --port ${PORT:-5000}"]