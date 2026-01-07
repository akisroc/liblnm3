# Build stage
FROM php:8.4-cli-alpine AS build

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy dependency files
COPY composer.json composer.lock symfony.lock ./

# Install dependencies
RUN composer install --no-dev --no-scripts --no-autoloader --optimize-autoloader --prefer-dist && \
    composer clear-cache

# Copy application code
COPY . .

# Generate optimized autoloader
RUN composer dump-autoload --optimize --no-dev --classmap-authoritative

# Warm up cache for production
RUN APP_ENV=prod composer run-script auto-scripts || true

# Runtime stage
FROM php:8.4-cli-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    libstdc++ \
    sqlite-libs

# Create non-root user
RUN addgroup -g 1000 archive && \
    adduser -D -u 1000 -G archive archive

WORKDIR /app

# Copy application from build stage
COPY --from=build --chown=archive:archive /app ./

# Ensure data directory is writable (for SQLite)
RUN chown -R archive:archive /app/data /app/var

# Switch to non-root user
USER archive

# Expose port
EXPOSE 8000

# Set environment variables
ENV APP_ENV=prod \
    APP_DEBUG=0

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD php -r "echo 'OK';" || exit 1

# Start the Symfony built-in server
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
