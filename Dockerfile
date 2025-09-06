FROM libretranslate/libretranslate:latest

# Pre-install common translation models during build
RUN python3 -m libretranslate --install-models en,fr

# Expose the port
EXPOSE 5000

# Start command that works with Render's PORT environment variable
CMD ["sh", "-c", "python3 -m libretranslate --host 0.0.0.0 --port ${PORT:-5000}"]
