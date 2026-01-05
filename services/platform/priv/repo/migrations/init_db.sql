CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE "platform_theme_enum" AS ENUM (
  'dark',
  'light'
);

CREATE TABLE "users" (
  "id" uuid PRIMARY KEY,
  "username" varchar(31) UNIQUE NOT NULL,
  "email" varchar(255) UNIQUE NOT NULL,
  "profile_picture" varchar(511),
  "password" varchar(511) NOT NULL,
  "slug" varchar(63) UNIQUE NOT NULL,
  "platform_theme" platform_theme_enum NOT NULL DEFAULT 'dark',
  "is_enabled" bool NOT NULL DEFAULT (true),
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_users_username_format" CHECK (username ~ '^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$'),
  CONSTRAINT "chk_users_email_format" CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  CONSTRAINT "chk_users_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE TABLE "kingdoms" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "leader_id" uuid NOT NULL,
  "name" varchar(31) UNIQUE NOT NULL,
  "slug" varchar(63) UNIQUE NOT NULL,
  "fame" numeric(12,3) NOT NULL DEFAULT (30000.0),
  "defense_troup" jsonb NOT NULL DEFAULT ('{"b1": 0, "b2": 0, "b3": 0, "b4": 0, "b5": 0, "b6": 0, "b7": 0, "b8": 0}'),
  "attack_troup" jsonb NOT NULL DEFAULT ('{"b1": 0, "b2": 0, "b3": 0, "b4": 0, "b5": 0, "b6": 0, "b7": 0, "b8": 0}'),
  "is_active" bool NOT NULL DEFAULT (false),
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_kingdoms_name_format" CHECK (name ~ '^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$'),
  CONSTRAINT "chk_kingdoms_fame_positive" CHECK (fame >= 0.0),
  CONSTRAINT "chk_kingdoms_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  CONSTRAINT "chk_kingdoms_defense_troup_structure" CHECK (defense_troup ?& ARRAY['b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8']),
  CONSTRAINT "chk_kingdoms_attack_troup_structure" CHECK (attack_troup ?& ARRAY['b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8']),
  CONSTRAINT "chk_kingdoms_defense_troup_units_count_positive" CHECK ((defense_troup->>'b1')::int >= 0 
    AND (defense_troup->>'b2')::int >= 0 
    AND (defense_troup->>'b3')::int >= 0 
    AND (defense_troup->>'b4')::int >= 0 
    AND (defense_troup->>'b5')::int >= 0 
    AND (defense_troup->>'b6')::int >= 0 
    AND (defense_troup->>'b7')::int >= 0 
    AND (defense_troup->>'b8')::int >= 0),
  CONSTRAINT "chk_kingdoms_attack_troup_units_count_positive" CHECK ((attack_troup->>'b1')::int >= 0 
    AND (attack_troup->>'b2')::int >= 0 
    AND (attack_troup->>'b3')::int >= 0 
    AND (attack_troup->>'b4')::int >= 0 
    AND (attack_troup->>'b5')::int >= 0 
    AND (attack_troup->>'b6')::int >= 0 
    AND (attack_troup->>'b7')::int >= 0 
    AND (attack_troup->>'b8')::int >= 0)
);

CREATE TABLE "protagonists" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "kingdom_id" uuid,
  "name" varchar(31) UNIQUE NOT NULL,
  "fame" numeric(12,3) NOT NULL DEFAULT (0.0),
  "slug" varchar(63) UNIQUE NOT NULL,
  "anonymous" bool NOT NULL DEFAULT (true),
  "profile_picture" varchar(511),
  "biography" text,
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_protagonists_biography_length" CHECK (char_length(biography) <= 500000),
  CONSTRAINT "chk_protagonists_fame_positive" CHECK (fame >= 0.0),
  CONSTRAINT "chk_protagonists_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE TABLE "missives" (
  "id" uuid PRIMARY KEY,
  "sender_id" uuid NOT NULL,
  "receiver_id" uuid NOT NULL,
  "content" text NOT NULL,
  "is_read" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_missives_content_length" CHECK (char_length(content) <= 10000),
  CONSTRAINT "chk_missives_sender_is_not_receiver" CHECK (sender_id <> receiver_id)
);

CREATE TABLE "chronicles" (
  "id" uuid PRIMARY KEY,
  "gm_id" uuid NOT NULL,
  "user_id" uuid NOT NULL,
  "title" varchar(63) UNIQUE NOT NULL,
  "slug" varchar(127) UNIQUE NOT NULL,
  "description" text,
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_chronicles_description_length" CHECK (char_length(description) <= 15000),
  CONSTRAINT "chk_chronicles_title_format" CHECK (title ~ '^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$'),
  CONSTRAINT "chk_chronicles_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE TABLE "protagonists_chronicles" (
  "protagonist_id" uuid,
  "chronicle_id" uuid,
  PRIMARY KEY ("protagonist_id", "chronicle_id")
);

CREATE TABLE "chapters" (
  "id" uuid PRIMARY KEY,
  "chronicle_id" uuid NOT NULL,
  "protagonist_id" uuid NOT NULL,
  "content" text NOT NULL,
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_chapters_content_length" CHECK (char_length(content) <= 25000)
);

CREATE TABLE "chapters_views" (
  "chapter_id" uuid,
  "user_id" uuid,
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  PRIMARY KEY ("chapter_id", "user_id")
);

CREATE TABLE "boards" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "title" varchar(63) UNIQUE NOT NULL,
  "description" varchar(511) NOT NULL,
  "slug" varchar(127) UNIQUE NOT NULL,
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_boards_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE TABLE "threads" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "board_id" uuid NOT NULL,
  "title" varchar(63) NOT NULL,
  "slug" varchar(127) UNIQUE NOT NULL,
  "is_removed" bool NOT NULL DEFAULT (false),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  CONSTRAINT "chk_threads_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

CREATE TABLE "posts" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "thread_id" uuid NOT NULL,
  "content" text NOT NULL,
  CONSTRAINT "chk_posts_content_length" CHECK (char_length(content) <= 10000)
);

CREATE TABLE "sessions" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "token" bytea UNIQUE NOT NULL,
  "context" varchar(31) NOT NULL DEFAULT ('session'),
  "ip_address" inet,
  "user_agent" varchar(511),
  "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE UNIQUE INDEX "idx_only_one_active_kingdom_per_user" ON "kingdoms" ("user_id") WHERE "is_active" = true;

CREATE INDEX "idx_kingdoms_user_id" ON "kingdoms" ("user_id");

CREATE INDEX "idx_kingdoms_leader_id" ON "kingdoms" ("leader_id");

CREATE UNIQUE INDEX "idx_protagonists_id_user_id" ON "protagonists" ("id", "user_id");

CREATE INDEX "idx_protagonists_user_id" ON "protagonists" ("user_id");

CREATE INDEX "idx_protagonists_kingdom_id" ON "protagonists" ("kingdom_id");

CREATE INDEX "idx_missives_sender_id" ON "missives" ("sender_id");

CREATE INDEX "idx_missives_receiver_id" ON "missives" ("receiver_id");

CREATE INDEX "idx_chronicles_gm_id" ON "chronicles" ("gm_id");

CREATE INDEX "idx_chronicles_user_id" ON "chronicles" ("user_id");

CREATE INDEX "idx_chapters_chronicle_id" ON "chapters" ("chronicle_id");

CREATE INDEX "idx_chapters_protagonist_id" ON "chapters" ("protagonist_id");

CREATE INDEX "idx_boards_user_id" ON "boards" ("user_id");

CREATE INDEX "idx_threads_user_id" ON "threads" ("user_id");

CREATE INDEX "idx_threads_board_id" ON "threads" ("board_id");

CREATE INDEX "idx_posts_user_id" ON "posts" ("user_id");

CREATE INDEX "idx_posts_thread_id" ON "posts" ("thread_id");

CREATE INDEX "sessions_user_id" ON "sessions" ("user_id");

ALTER TABLE "kingdoms" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "kingdoms" ADD FOREIGN KEY ("leader_id") REFERENCES "protagonists" ("id");

ALTER TABLE "kingdoms" ADD FOREIGN KEY ("leader_id", "user_id") REFERENCES "protagonists" ("id", "user_id");

ALTER TABLE "protagonists" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "protagonists" ADD FOREIGN KEY ("kingdom_id") REFERENCES "kingdoms" ("id");

ALTER TABLE "missives" ADD FOREIGN KEY ("sender_id") REFERENCES "kingdoms" ("id");

ALTER TABLE "missives" ADD FOREIGN KEY ("receiver_id") REFERENCES "kingdoms" ("id");

ALTER TABLE "chronicles" ADD FOREIGN KEY ("gm_id") REFERENCES "users" ("id");

ALTER TABLE "chronicles" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "protagonists_chronicles" ADD FOREIGN KEY ("protagonist_id") REFERENCES "protagonists" ("id");

ALTER TABLE "protagonists_chronicles" ADD FOREIGN KEY ("chronicle_id") REFERENCES "chronicles" ("id");

ALTER TABLE "chapters" ADD FOREIGN KEY ("chronicle_id") REFERENCES "chronicles" ("id");

ALTER TABLE "chapters" ADD FOREIGN KEY ("protagonist_id") REFERENCES "protagonists" ("id");

ALTER TABLE "chapters_views" ADD FOREIGN KEY ("chapter_id") REFERENCES "chapters" ("id");

ALTER TABLE "chapters_views" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "boards" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "threads" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "threads" ADD FOREIGN KEY ("board_id") REFERENCES "boards" ("id");

ALTER TABLE "posts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "posts" ADD FOREIGN KEY ("thread_id") REFERENCES "threads" ("id");

ALTER TABLE "sessions" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
