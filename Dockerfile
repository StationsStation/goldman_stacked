# Dockerfile

FROM python:3.11-slim

ENV POETRY_VERSION=1.8.2

# Install Poetry
RUN apt-get update && apt-get install -y curl build-essential \
  && curl -sSL https://install.python-poetry.org | python3 - \
  && ln -s /root/.local/bin/poetry /usr/local/bin/poetry \
  && poetry config virtualenvs.create false

WORKDIR /app

# Copy only the lock and config to install deps first (cache efficiency)
COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root --no-interaction

# Copy the rest of the app
COPY controller_api controller_api
COPY specs specs
WORKDIR controller_api

EXPOSE 5000

CMD ["python", "main.py"]
