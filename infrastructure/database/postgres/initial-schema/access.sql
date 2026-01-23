-- ------------
-- USERS
-- ------------

CREATE USER :db_user WITH ENCRYPTED PASSWORD :'db_user_password';


-- ------------
-- CLEAN
-- ------------

REVOKE ALL ON DATABASE :db_name FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA iam FROM PUBLIC;
REVOKE ALL ON SCHEMA roleplay FROM PUBLIC;
REVOKE ALL ON SCHEMA social FROM PUBLIC;
REVOKE ALL ON SCHEMA sovereignty FROM PUBLIC;
REVOKE ALL ON SCHEMA technical FROM PUBLIC;


-- ------------
-- PRIVILEGES
-- ------------

GRANT CONNECT ON DATABASE :db_name TO :db_user;
GRANT USAGE ON SCHEMA public, iam, roleplay, social, sovereignty, technical
    TO :db_user;

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES, TRIGGER, MAINTAIN -- NO TRUNCATE
    ON ALL TABLES
    IN SCHEMA public, iam, roleplay, social, sovereignty, technical
    TO :db_user;
-- GRANT USAGE ON ALL TYPES
--     IN SCHEMA public, iam, roleplay, social, sovereignty, technical
--     TO :db_user;
GRANT USAGE, SELECT ON ALL SEQUENCES
    IN SCHEMA public, iam, roleplay, social, sovereignty, technical
    TO :db_user;
GRANT EXECUTE ON ALL ROUTINES -- Covers FUNCTIONS and PROCEDURES
    IN SCHEMA public, iam, roleplay, social, sovereignty, technical
    TO :db_user;


-- ------------
-- HANDLE FUTURE MIGRATIONS
-- ------------

ALTER DEFAULT PRIVILEGES FOR ROLE :maintenance_admin
    IN SCHEMA public, iam, roleplay, social, sovereignty, technical
    GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES, TRIGGER, MAINTAIN -- NO TRUNCATE
    ON TABLES
    TO :db_user;
ALTER DEFAULT PRIVILEGES FOR ROLE :maintenance_admin
    IN SCHEMA public, iam, roleplay, social, sovereignty, technical
    GRANT USAGE, SELECT
    ON SEQUENCES
    TO :db_user;
ALTER DEFAULT PRIVILEGES FOR ROLE :maintenance_admin
    IN SCHEMA public, iam, roleplay, social, sovereignty, technical
    GRANT USAGE
    ON TYPES
    TO :db_user;
ALTER DEFAULT PRIVILEGES FOR ROLE :maintenance_admin
    IN SCHEMA public, iam, roleplay, social, sovereignty, technical
    GRANT EXECUTE
    ON ROUTINES
    TO :db_user;
