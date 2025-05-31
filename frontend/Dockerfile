# 1. Build Stage
FROM node:20-slim AS builder

WORKDIR /app

# Install system dependencies (minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Copy only package files first
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install

# Copy the rest of the app
COPY . .

# Build the app
RUN yarn build

# 2. Production Stage
FROM node:20-slim AS runner

WORKDIR /app

# Install a tiny static server
RUN yarn global add serve

# Copy build output
COPY --from=builder /app/build ./build

# Expose port
EXPOSE 3000

# Serve the app
CMD ["serve", "-s", "build", "-l", "3000"]



