FROM python:3.11-slim

WORKDIR /app

# Install system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY face_api.py .

# Copy face data
COPY face_data ./face_data

# Expose port (Hugging Face Spaces uses 7860 by default, but we keep 5000 for API)
EXPOSE 7860

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:7860/health || exit 1

# Run with gunicorn, respect PORT env var (Hugging Face uses 7860)
CMD ["gunicorn", "--bind", "0.0.0.0:${PORT:-7860}", "--workers", "2", "--timeout", "120", "face_api:app"]
