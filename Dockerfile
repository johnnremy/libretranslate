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

# Pre-install translation models using argostranslate
RUN python3 -c "
import argostranslate.package

# Update package index
argostranslate.package.update_package_index()

# Get available packages
available_packages = argostranslate.package.get_available_packages()

# Install common language pairs
language_pairs = [
    ('en', 'fr'),  # English to French
    ('fr', 'en'),  # French to English
    # ('en', 'es'),  # English to Spanish
    # ('es', 'en'),  # Spanish to English
    # ('en', 'de'),  # English to German
    # ('de', 'en'),  # German to English
]

for from_code, to_code in language_pairs:
    package = next(
        (p for p in available_packages if p.from_code == from_code and p.to_code == to_code),
        None
    )
    if package:
        print(f'Installing {from_code} -> {to_code}')
        argostranslate.package.install_from_path(package.download())
    else:
        print(f'Package {from_code} -> {to_code} not found')
"

# Expose port
EXPOSE 5000

# Start command that works with Render's PORT environment variable
CMD ["sh", "-c", "libretranslate --host 0.0.0.0 --port ${PORT:-5000}"]
