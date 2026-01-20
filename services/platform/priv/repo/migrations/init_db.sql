-- Initial LNM3 Platform PGSQL DB schema
-- Blocks end with `;;\n` to make the file easy to split in
-- migrations scripts, since Ecto executes commands one by
-- one. Ugly pragmatic.


-- ------------
-- EXTENSIONS
-- ------------

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- ------------
-- FUNCTIONS
-- ------------

-- VALIDATE UNIT ARCHETYPE CONTENT
CREATE OR REPLACE FUNCTION is_valid_unit_archetype(unit_archetype text) RETURNS boolean AS $$
BEGIN
    RETURN unit_archetype IN ('B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8',
                         'b1', 'b2', 'b3', 'b4', 'b5', 'b6', 'b7', 'b8');
END;
$$ LANGUAGE plpgsql IMMUTABLE;;

-- VALIDATE TROOP STRUCTURE
-- A troop must be a flat list of 8 postive integers
CREATE OR REPLACE FUNCTION is_valid_troop(troop integer[]) RETURNS boolean AS $$
BEGIN
    RETURN array_ndims(troop) = 1 AND array_length(troop, 1) = 8 AND 0 <= ALL(troop)
END;
$$ LANGUAGE plpgsql IMMUTABLE;;

-- VALIDATE BATTLE LOG STRUCTURE
CREATE OR REPLACE FUNCTION is_valid_battle_log(log jsonb) RETURNS boolean AS $$
BEGIN
    IF jsonb_typeof(log) <> 'array' THEN
       RETURN FALSE;
    END IF;
    RETURN NOT EXISTS (
        SELECT 1
        FROM jsonb_array_elements(log) AS elem
        WHERE
            NOT (elem ? 'attacking_unit' AND elem ? 'defending_unit' AND elem ? 'kill_steps')
            OR jsonb_typeof(elem->'kill_steps') <> 'array'
            OR NOT is_valid_unit_archetype(elem->>'attacking_unit')
            OR NOT is_valid_unit_archetype(elem->>'defending_unit')
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;;

-- PREVENT DEFINITIVE REMOVE FROM BEING CANCELLED
CREATE OR REPLACE FUNCTION prevent_unremove() RETURNS TRIGGER AS $$
BEGIN
    IF OLD.is_removed = true AND NEW.is_removed = false THEN
        RAISE EXCEPTION 'Operation not allowed: is_removed is irreversible.';
       END IF;
       RETURN NEW;
END;
$$ LANGUAGE plpgsql;;


-- ------------
-- TYPES
-- ------------

CREATE TYPE "user_role_enum" AS ENUM(
    'user',
    'curator',
    'admin'
);;

CREATE TYPE "platform_theme_enum" AS ENUM (
    'dark',
    'light'
);;

CREATE TYPE "outbox_message_status" AS ENUM(
    'pending',
    'success',
    'failed'
);;


-- ------------
-- TABLES
-- ------------

-- USERS
CREATE TABLE "users" (
    "id" uuid PRIMARY KEY,
    "nickname" varchar(31) NOT NULL,
    "email" varchar(255) NOT NULL,
    "profile_picture" varchar(2048),
    "password" varchar(511) NOT NULL,
    "slug" varchar(63) UNIQUE NOT NULL,
    "roles" user_role_enum[] NOT NULL DEFAULT '{user}',
    "platform_theme" platform_theme_enum NOT NULL DEFAULT 'dark',
    "is_enabled" bool NOT NULL DEFAULT (true),
    "is_removed" bool NOT NULL DEFAULT (false),
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "chk_users_nickname_format" CHECK (nickname ~ '^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-_\.&]+$'),
    CONSTRAINT "chk_users_email_format" CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT "chk_users_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);;

-- SHOUTS
CREATE TABLE "shouts" (
    "id" uuid PRIMARY KEY,
    "user_id" uuid NOT NULL,
    "content" text,
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "chk_shouts_content_length" CHECK (char_length(content) <= 500)
);;

-- WHISPERS
CREATE TABLE "whispers" (
    "id" uuid PRIMARY KEY,
    "content" text,
    "sender_id" uuid NOT NULL,
    "receiver_id" uuid NOT NULL,
    "is_read" bool NOT NULL DEFAULT (false),
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "chk_whispers_content_length" CHECK(char_length(content) <= 10000),
    CONSTRAINT "chk_whispers_sender_is_not_receiver" CHECK (sender_id <> receiver_id)
);;

-- KINGDOMS
CREATE TABLE "kingdoms" (
    "id" uuid PRIMARY KEY,
    "player_id" uuid NOT NULL,
    "leader_id" uuid NOT NULL,
    "name" varchar(63) NOT NULL,
    "slug" varchar(127) UNIQUE NOT NULL,
    "fame" numeric(12,3) NOT NULL DEFAULT (30000.0),
    "defense_troop" integer[] NOT NULL DEFAULT '{0, 0, 0, 0, 0, 0, 0, 0}',
    "attack_troop" integer[] NOT NULL DEFAULT '{0, 0, 0, 0, 0, 0, 0, 0}',
    "is_active" bool NOT NULL DEFAULT (false),
    "is_removed" bool NOT NULL DEFAULT (false),
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "chk_kingdoms_name_format" CHECK (name ~ '^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$'),
    CONSTRAINT "chk_kingdoms_fame_positive" CHECK (fame >= 0.0),
    CONSTRAINT "chk_kingdoms_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
    CONSTRAINT "chk_kingdoms_defense_troop_integrity" CHECK (is_valid_troop(defense_troop))
    CONSTRAINT "chk_kingdoms_attack_troop_integrity" CHECK (is_valid_troop(attack_troop))
);;

-- BATTLES
CREATE TABLE "battles" (
    "id" uuid PRIMARY KEY,
    "attacker_kingdom_id" uuid,
    "defender_kingdom_id" uuid,
    "attacker_initial_troop" integer[] NOT NULL,
    "defender_initial_troop" integer[] NOT NULL,
    "log" jsonb NOT NULL,
    "attacker_final_troop" integer[] NOT NULL,
    "defender_final_troop" integer[] NOT NULL,
    "attacker_wins" bool NOT NULL,
    "attacker_fame_modifier" numeric(12,3) NOT NULL,
    "defender_fame_modifier" numeric(12,3) NOT NULL,
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "chk_battles_attacker_is_not_defender" CHECK (attacker_kingdom_id <> defender_kingdom_id),
    CONSTRAINT "chk_battles_attacker_initial_troop_integrity" CHECK (is_valid_troop(attacker_initial_troop)),
    CONSTRAINT "chk_battles_defender_initial_troop_integrity" CHECK (is_valid_troop(defender_initial_troop)),
    CONSTRAINT "chk_battles_attacker_final_troop_integrity" CHECK (is_valid_troop(attacker_final_troop)),
    CONSTRAINT "chk_battles_defender_final_troop_integrity" CHECK (is_valid_troop(defender_final_troop)),
    CONSTRAINT "chk_log_integrity" CHECK (is_valid_battle_log(log))
);;

-- PROTAGONISTS
CREATE TABLE "protagonists" (
    "id" uuid PRIMARY KEY,
    "player_id" uuid NOT NULL,
    "kingdom_id" uuid,
    "name" varchar(31) NOT NULL,
    "fame" numeric(12,3) NOT NULL DEFAULT (0.0),
    "slug" varchar(63) UNIQUE NOT NULL,
    "is_anonymous" bool NOT NULL DEFAULT (true),
    "profile_picture" varchar(2048),
    "biography" text,
    "is_removed" bool NOT NULL DEFAULT (false),
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "chk_protagonists_name_format" CHECK (name ~ '^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$'),
    CONSTRAINT "chk_protagonists_biography_length" CHECK (char_length(biography) <= 500000),
    CONSTRAINT "chk_protagonists_fame_positive" CHECK (fame >= 0.0),
    CONSTRAINT "chk_protagonists_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);;

-- MISSIVES
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
);;

-- CHRONICLES
CREATE TABLE "chronicles" (
    "id" uuid PRIMARY KEY,
    "gm_id" uuid NOT NULL,
    "player_id" uuid NOT NULL,
    "title" varchar(63) NOT NULL,
    "slug" varchar(127) UNIQUE NOT NULL,
    "description" text,
    "is_removed" bool NOT NULL DEFAULT (false),
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "chk_chronicles_description_length" CHECK (char_length(description) <= 15000),
    CONSTRAINT "chk_chronicles_title_format" CHECK (title ~ '^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$'),
    CONSTRAINT "chk_chronicles_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);;

-- PROTAGONISTS & CHRONICLES
CREATE TABLE "protagonists_chronicles" (
    "protagonist_id" uuid,
    "chronicle_id" uuid,
    PRIMARY KEY ("protagonist_id", "chronicle_id")
);;

-- CHAPTERS
CREATE TABLE "chapters" (
    "id" uuid PRIMARY KEY,
    "chronicle_id" uuid NOT NULL,
    "protagonist_id" uuid NOT NULL,
    "content" text NOT NULL,
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "chk_chapters_content_length" CHECK (char_length(content) <= 25000)
);;

-- CHAPTERS VIEWS
CREATE TABLE "chapters_views" (
    "chapter_id" uuid,
    "user_id" uuid,
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    PRIMARY KEY ("chapter_id", "user_id")
);;

-- BOARDS
CREATE TABLE "boards" (
    "id" uuid PRIMARY KEY,
    "user_id" uuid NOT NULL,
    "title" varchar(63) NOT NULL,
    "description" varchar(511) NOT NULL,
    "slug" varchar(127) UNIQUE NOT NULL,
    "is_removed" bool NOT NULL DEFAULT (false),
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "chk_boards_slug_format" CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);;

-- THREADS
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
);;

-- POSTS
CREATE TABLE "posts" (
    "id" uuid PRIMARY KEY,
    "user_id" uuid NOT NULL,
    "thread_id" uuid NOT NULL,
    "content" text NOT NULL,
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "updated_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT "chk_posts_content_length" CHECK (char_length(content) <= 10000)
);;

-- SESSIONS
CREATE TABLE "sessions" (
    "id" uuid PRIMARY KEY,
    "user_id" uuid NOT NULL,
    "token" bytea UNIQUE NOT NULL,
    "context" varchar(31) NOT NULL DEFAULT ('session'),
    "ip_address" inet,
    "user_agent" varchar(511),
    "expires_at" timestamp NOT NULL,
    "inserted_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);;

-- OUTBOX (technical table)
CREATE TABLE "outbox" (
    "id" integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "message_type" varchar(255) NOT NULL,
    "payload" jsonb NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "consumed_by" varchar(255)[] DEFAULT '{}',
    "failed_attempts" integer NOT NULL DEFAULT (0),
    "last_error" varchar(1027),
    "status" outbox_message_status NOT NULL DEFAULT 'pending',
    "scheduled_at" timestamp NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    "closed_at" timestamp
);;

-- ------------
-- INDEXES
-- ------------

-- USERS
CREATE UNIQUE INDEX "idx_users_nickname_not_removed" ON "users" ("nickname") WHERE "is_removed" = false;;
CREATE UNIQUE INDEX "idx_users_email_not_removed" ON "users" ("email") WHERE "is_removed" = false;;

-- SHOUTS
CREATE INDEX "idx_shouts_user_id" ON "shouts" ("user_id");;

-- WHISPERS
CREATE INDEX "idx_whispers_sender_id" ON "whispers" ("sender_id");;
CREATE INDEX "idx_whispers_receiver_id" ON "whispers" ("receiver_id");;

-- KINGDOMS
CREATE UNIQUE INDEX "idx_kingdoms_name_not_removed" ON "kingdoms" ("name") WHERE "is_removed" = false;;
CREATE UNIQUE INDEX "idx_only_one_active_kingdom_per_player" ON "kingdoms" ("player_id") WHERE "is_active" = true;;
CREATE INDEX "idx_kingdoms_player_id" ON "kingdoms" ("player_id");;
CREATE INDEX "idx_kingdoms_leader_id" ON "kingdoms" ("leader_id");;

-- BATTLES
CREATE INDEX "idx_battles_attacker_kingdom_id" ON "battles" ("attacker_kingdom_id");;
CREATE INDEX "idx_battles_defender_kingdom_id" ON "battles" ("defender_kingdom_id");;

-- PROTAGONISTS
CREATE UNIQUE INDEX "idx_protagonists_name_not_removed" ON "protagonists" ("name") WHERE "is_removed" = false;;
CREATE UNIQUE INDEX "idx_protagonists_id_player_id" ON "protagonists" ("id", "player_id");;
CREATE INDEX "idx_protagonists_player_id" ON "protagonists" ("player_id");;
CREATE INDEX "idx_protagonists_kingdom_id" ON "protagonists" ("kingdom_id");;

-- MISSIVES
CREATE INDEX "idx_missives_sender_id" ON "missives" ("sender_id");
CREATE INDEX "idx_missives_receiver_id" ON "missives" ("receiver_id");

-- CHRONICLES
CREATE UNIQUE INDEX "idx_chronicles_title_not_removed" ON "chronicles" ("title") WHERE "is_removed" = false;;
CREATE INDEX "idx_chronicles_gm_id" ON "chronicles" ("gm_id");;
CREATE INDEX "idx_chronicles_player_id" ON "chronicles" ("player_id");;

-- CHAPTERS
CREATE INDEX "idx_chapters_chronicle_id" ON "chapters" ("chronicle_id");;
CREATE INDEX "idx_chapters_protagonist_id" ON "chapters" ("protagonist_id");;

-- BOARDS
CREATE UNIQUE INDEX "idx_boards_title_not_removed" ON "boards" ("title") WHERE "is_removed" = false;;
CREATE INDEX "idx_boards_user_id" ON "boards" ("user_id");;

-- THREADS
CREATE INDEX "idx_threads_user_id" ON "threads" ("user_id");;
CREATE INDEX "idx_threads_board_id" ON "threads" ("board_id");;

-- POSTS
CREATE INDEX "idx_posts_user_id" ON "posts" ("user_id");;
CREATE INDEX "idx_posts_thread_id" ON "posts" ("thread_id");;

-- SESSIONS
CREATE INDEX "sessions_user_id" ON "sessions" ("user_id");;

-- OUTBOX
CREATE INDEX idx_outbox_active_messages ON outbox (id) WHERE closed_at IS NULL;;


-- ------------
-- FOREIGN KEYS
-- ------------

-- SHOUTS
ALTER TABLE "shouts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");;

-- WHISPERS
ALTER TABLE "whispers" ADD FOREIGN KEY ("sender_id") REFERENCES "protagonists" ("id");;
ALTER TABLE "whispers" ADD FOREIGN KEY ("receiver_id") REFERENCES "protagonists" ("id");;

-- KINGDOMS
ALTER TABLE "kingdoms" ADD FOREIGN KEY ("player_id") REFERENCES "users" ("id");;
ALTER TABLE "kingdoms"
    ADD CONSTRAINT "fk_kingdoms_leader_id"
    FOREIGN KEY ("leader_id")
    REFERENCES "protagonists" ("id")
    DEFERRABLE INITIALLY IMMEDIATE;;
ALTER TABLE "kingdoms"
    ADD CONSTRAINT "fk_kingdom_has_leader"
    FOREIGN KEY ("leader_id", "id")
    REFERENCES "protagonists" ("id", "kingdom_id");;
    DEFERRABLE INITIALLY IMMEDIATE;;
ALTER TABLE "kingdoms"
    ADD CONSTRAINT "fk_leader_player_ownership"
    FOREIGN KEY ("leader_id", "player_id")
    REFERENCES "protagonists" ("id", "player_id");;

-- BATTLES
ALTER TABLE "battles" ADD FOREIGN KEY ("attacker_kingdom_id") REFERENCES "kingdoms" ("id");;
ALTER TABLE "battles" ADD FOREIGN KEY ("defender_kingdom_id") REFERENCES "kingdoms" ("id");;

-- PROTAGONISTS
ALTER TABLE "protagonists" ADD FOREIGN KEY ("player_id") REFERENCES "users" ("id");;
ALTER TABLE "protagonists"
    ADD CONSTRAINT "fk_protagonists_kingdom_id"
    FOREIGN KEY ("kingdom_id")
    REFERENCES "kingdoms" ("id")
    DEFERRABLE INITIALLY IMMEDIATE;;

-- MISSIVES
ALTER TABLE "missives" ADD FOREIGN KEY ("sender_id") REFERENCES "kingdoms" ("id");;
ALTER TABLE "missives" ADD FOREIGN KEY ("receiver_id") REFERENCES "kingdoms" ("id");;

-- CHRONICLES
ALTER TABLE "chronicles" ADD FOREIGN KEY ("gm_id") REFERENCES "users" ("id");;
ALTER TABLE "chronicles" ADD FOREIGN KEY ("player_id") REFERENCES "users" ("id");;

-- PROTAGONISTS & CHRONICLES
ALTER TABLE "protagonists_chronicles" ADD FOREIGN KEY ("protagonist_id") REFERENCES "protagonists" ("id");;
ALTER TABLE "protagonists_chronicles" ADD FOREIGN KEY ("chronicle_id") REFERENCES "chronicles" ("id");;

-- CHAPTERS
ALTER TABLE "chapters" ADD FOREIGN KEY ("chronicle_id") REFERENCES "chronicles" ("id");;
ALTER TABLE "chapters" ADD FOREIGN KEY ("protagonist_id") REFERENCES "protagonists" ("id");;

-- CHAPTERS VIEWS
ALTER TABLE "chapters_views" ADD FOREIGN KEY ("chapter_id") REFERENCES "chapters" ("id");;
ALTER TABLE "chapters_views" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");;

-- BOARDS
ALTER TABLE "boards" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");;

-- THREADS
ALTER TABLE "threads" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");;
ALTER TABLE "threads" ADD FOREIGN KEY ("board_id") REFERENCES "boards" ("id");;

-- POSTS
ALTER TABLE "posts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");;
ALTER TABLE "posts" ADD FOREIGN KEY ("thread_id") REFERENCES "threads" ("id");;

-- SESSIONS
ALTER TABLE "sessions" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");;


-- ------------
-- PROCEDURES
-- ------------

-- REGISTER A KINGDOM AND ITS LEADER PROTAGONIST
-- This precise action requires deferring constraints during transactions
-- because of cyclic dependency between kingdom and leader
CREATE OR REPLACE PROCEDURE register_kingdom_and_leader(
    p_kingdom_id uuid,
    p_leader_id uuid,
    p_user_id uuid,
    p_kingdom_name varchar,
    p_kingdom_slug varchar,
    p_leader_name varchar,
    p_leader_slug varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    SET CONSTRAINTS fk_kingdoms_leader_id, fk_protagonists_kingdom_id DEFERRED;
    INSERT INTO protagonists (id, user_id, kingdom_id, name, slug, is_anonymous)
    VALUES (p_leader_id, p_user_id, p_kingdom_id, p_leader_name, p_leader_slug);
    INSERT INTO kingdoms (id, user_id, leader_id, name, slug)
    VALUES (p_kingdom_id, p_user_id, p_leader_id, p_kingdom_name, p_kingdom_slug);
END;
$$;


-- ------------
-- TRIGGERS
-- ------------

-- SOFT DELETES ARE DEFINITIVE

-- USERS
CREATE TRIGGER check_users_is_removed_definitive
    BEFORE UPDATE ON users FOR EACH ROW
    WHEN (OLD.is_removed IS TRUE AND NEW.is_removed IS FALSE)
    EXECUTE FUNCTION prevent_unremove();;;

-- KINGDOMS
CREATE TRIGGER check_kingdoms_is_removed_definitive
    BEFORE UPDATE ON kingdoms FOR EACH ROW
    WHEN (OLD.is_removed IS TRUE AND NEW.is_removed IS FALSE)
    EXECUTE FUNCTION prevent_unremove();;

-- PROTAGONISTS
CREATE TRIGGER check_protagonists_is_removed_definitive
    BEFORE UPDATE ON protagonists FOR EACH ROW
    WHEN (OLD.is_removed IS TRUE AND NEW.is_removed IS FALSE)
    EXECUTE FUNCTION prevent_unremove();;

-- CHRONICLES
CREATE TRIGGER check_chronicles_is_removed_definitive
    BEFORE UPDATE ON chronicles FOR EACH ROW
    WHEN (OLD.is_removed IS TRUE AND NEW.is_removed IS FALSE)
    EXECUTE FUNCTION prevent_unremove();;

-- BOARDS
CREATE TRIGGER check_boards_is_removed_definitive
    BEFORE UPDATE ON boards FOR EACH ROW
    WHEN (OLD.is_removed IS TRUE AND NEW.is_removed IS FALSE)
    EXECUTE FUNCTION prevent_unremove();;

-- THREADS
CREATE TRIGGER check_threads_is_removed_definitive
    BEFORE UPDATE ON threads FOR EACH ROW
    WHEN (OLD.is_removed IS TRUE AND NEW.is_removed IS FALSE)
    EXECUTE FUNCTION prevent_unremove();;


-- ------------
-- VIEWS
-- ------------

-- Todo: to be tested
CREATE OR REPLACE VIEW battle_log_notation_view AS
WITH raw_data AS (
    SELECT
        id AS battle_id,
        attacker_kingdom_id,
        defender_kingdom_id,
        split_part(log::text, '\n', 1) as line_initial,
        split_part(log::text, '\n', 2) as line_log,
        split_part(log::text, '\n', 3) as line_final,
        (split_part(log::text, '\n', 4) = '1') as attacker_won
    FROM battles
),
log_steps AS (
    SELECT
        battle_id,
        trim(s.step) as step_raw,
        s.idx as step_order
    FROM raw_data,
        unnest(string_to_array(trim(line_log), ' ')) WITH ORDINALITY AS s(step, idx)
)
SELECT
    ls.battle_id,
    ls.step_order,
    split_part(ls.step_raw, '/', 1) as unit_1,
    split_part(ls.step_raw, '/', 2) as unit_2,
    format(
        split_part(ls.step_raw, '/', 1),
        split_part(ls.step_raw, '/', 2),
        array_length(string_to_array(ls.step_raw, '/'), 1) - 2
    ) as summary_text
FROM log_steps ls
WHERE ls.step_raw <> '';;


-- ------------
-- COMMENTS
-- ------------

-- FUNCTIONS
COMMENT ON FUNCTION validate_troop(integer[])
IS 'A troop must be a flat list of 8 postive integers';;

-- PROCEDURES
COMMENT ON PROCEDURE register_kingdom_and_leader(uuid, uuid, uuid, varchar, varchar, varchar)
IS 'This precise action – registering a kingdom with its leader protagonist – requires ' ||
   'deferring constraints during transactions because of cyclic dependency: kingdom' ||
   'needs a leader, leader needs a kingdom';;

-- SHOUTS
COMMENT ON TABLE "shouts" IS 'Chat messages between users (only one general channel)';;

-- WHISPERS
COMMENT ON TABLE "whispers" IS 'Private messages between two protagonists';;
COMMENT ON COLUMN "whispers"."sender_id" IS 'Protagonist sending the whisper';;
COMMENT ON COLUMN "whispers"."receiver_id" IS 'Protagonist receiving the whisper';;

-- KINGDOMS
COMMENT ON COLUMN "kingdoms"."leader_id" IS 'Protagonist leading the kingdom';;
COMMENT ON COLUMN "kingdoms"."is_active" IS 'One active kingdom per user a time';;
COMMENT ON CONSTRAINT "fk_kingdoms_leader_id"
IS 'Deferrable to allow registering a kingdom with its leader protagonist; ' ||
   'see register_kingdom_and_leader procedure';;
COMMENT ON CONSTRAINT "fk_kingdom_has_leader" IS 'Deferrable to allow changing leader';;

-- PROTAGONISTS
COMMENT ON CONSTRAINT "fk_protagonists_kingdom_id"
IS 'Deferrable to allow registering a kingdom with its leader protagonist; ' ||
   'see register_kingdom_and_leader procedure';;

-- MISSIVES
COMMENT ON COLUMN "missives"."sender_id" IS 'Kingdom sending the missive';;
COMMENT ON COLUMN "missives"."receiver_id" IS 'Kingdom receiving the missive';;

-- CHRONICLES
COMMENT ON COLUMN "chronicles"."gm_id" IS 'User mastering the chronicle';;

-- OUTBOX
COMMENT ON TABLE "outbox" IS "Technical table – asynchronous message bus";;
COMMENT ON COLUMN "outbox"."message_type" IS "Message’s identifier – example: “UserRegistered”";;
COMMENT ON COLUMN "outbox"."payload" IS "Message’s payload";;
COMMENT ON COLUMN "outbox"."consumed_by" IS "List of the services which have already consumed the message";;
COMMENT ON COLUMN "outbox"."scheduled_at" IS "Time of the dispatch start";;
COMMENT ON COLUMN "outbox"."closed_at" IS "Time of the the last consumption, sealing the message";;
