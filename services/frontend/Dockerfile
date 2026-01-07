# Build stage
FROM oven/bun:1-alpine AS build

WORKDIR /app

# Copy package files
COPY package.json bun.lock* ./

# Install dependencies with Bun
RUN bun install --frozen-lockfile

# Copy application code
COPY . .

# Build Nuxt application
RUN bun run build

# Runtime stage
FROM oven/bun:1-alpine

WORKDIR /app

# Copy built application from build stage
COPY --from=build /app/.output /app/.output

# Expose port
EXPOSE 3000

# Set environment variables
ENV HOST=0.0.0.0 \
    PORT=3000 \
    NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD bun --version || exit 1

# Start the application
CMD ["bun", "run", ".output/server/index.mjs"]
