FROM python:3.8-slim
LABEL maintainer="Nils Reimers <info@nils-reimers>"

# Install system dependencies
RUN apt-get update && apt-get -y install build-essential procps

# Install PyTorch from the specified wheel file
RUN pip install --no-cache-dir \
    https://download.pytorch.org/whl/cpu/torch-1.8.0%2Bcpu-cp38-cp38-linux_x86_64.whl

# Install FastAPI, Uvicorn, and Gunicorn
RUN pip install --no-cache-dir "uvicorn[standard]" gunicorn fastapi

# Copy and install Python dependencies
COPY ./requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

# Download NLTK data
RUN python -m nltk.downloader 'punkt'

# Copy startup scripts and configuration files
COPY ./start_backend.sh /start_backend.sh
RUN chmod +x /start_backend.sh

COPY ./start_frontend.sh /start_frontend.sh
RUN chmod +x /start_frontend.sh

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

COPY ./gunicorn_conf_backend.py /gunicorn_conf_backend.py
COPY ./gunicorn_conf_frontend.py /gunicorn_conf_frontend.py

# Set up working directory
COPY ./src /app
WORKDIR /app/
ENV PYTHONPATH=/app
EXPOSE 80

# Create cache folders
RUN mkdir -p /cache/easynmt /cache/transformers /cache/torch

ENV EASYNMT_CACHE=/cache/easynmt
ENV TRANSFORMERS_CACHE=/cache/transformers
ENV TORCH_CACHE=/cache/torch

# Run start script
CMD ["/start.sh"]
