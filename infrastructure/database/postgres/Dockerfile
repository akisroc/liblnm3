# --- BASE STAGE ---
FROM postgres:18.1-alpine AS base

WORKDIR /app

COPY --chmod=755 init-scripts/init-db.sh /docker-entrypoint-initdb.d/10-init-db.sh
COPY --chmod=755 initial-schema /

HEALTHCHECK --interval=5s --timeout=5s --start-period=10s --retries=5 \
  CMD pg_isready \
  -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" || exit 1

EXPOSE 5432

# --- DEV STAGE ---
FROM base AS dev
RUN apk add --no-cache vim
ENV POSTGRES_LOG_STATEMENT=all

# --- PROD STAGE ---
FROM base AS prod

RUN apk add --no-cache bash gzip rclone

RUN set -eux; \
    mkdir -p /maintenance /opt/lnm3/backups; \
    chown -R postgres:postgres /maintenance /opt/lnm3/backups

COPY --chmod=755 maintenance/backup.sh /maintenance/backup.sh
COPY --chmod=755 maintenance/restore.sh /maintenance/restore.sh

USER postgres
