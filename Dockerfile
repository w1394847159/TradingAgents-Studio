# ==========================================
# Stage 1: Build the Vue Frontend
# ==========================================
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend
COPY web/frontend/package*.json ./
RUN npm ci || npm install
COPY web/frontend ./
RUN npm run build

# ==========================================
# Stage 2: Install Python dependencies
# ==========================================
FROM python:3.12-slim AS python-builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /build
COPY . .
RUN pip install --no-cache-dir ".[all]"

# ==========================================
# Stage 3: Final Runtime Image
# ==========================================
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY --from=python-builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN useradd --create-home appuser \
 && install -d -m 0755 -o appuser -g appuser /home/appuser/.tradingagents
USER appuser
WORKDIR /home/appuser/app

# Copy the python codebase
COPY --from=python-builder --chown=appuser:appuser /build .

# Copy the compiled frontend build files from Stage 1
COPY --from=frontend-builder --chown=appuser:appuser /app/frontend/dist ./web/frontend/dist

ENTRYPOINT ["tradingagents"]
