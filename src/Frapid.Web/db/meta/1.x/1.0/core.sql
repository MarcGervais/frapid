﻿-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/00.db core/extensions.sql --<--<--
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/00.db core/postgresql-roles.sql --<--<--
DO
$$
BEGIN
    IF NOT EXISTS (SELECT * FROM pg_catalog.pg_roles WHERE rolname = 'frapid_db_user') THEN
        CREATE ROLE frapid_db_user WITH LOGIN PASSWORD 'change-on-deployment';
    END IF;

    COMMENT ON ROLE mix_erp IS 'The default user for frapid databases.';

    EXECUTE 'ALTER DATABASE ' || current_database() || ' OWNER TO frapid_db_user;';
END
$$
LANGUAGE plpgsql;

DO
$$
BEGIN
    IF NOT EXISTS (SELECT * FROM pg_catalog.pg_roles WHERE rolname = 'frapid_report_user') THEN
        CREATE ROLE frapid_report_user WITH LOGIN PASSWORD 'change-on-deployment';
    END IF;

    COMMENT ON ROLE mix_erp IS 'This user account is used by the Reporting Engine to run ad-hoc queries. It is strictly advised for this user to only have a read-only access to the database.';
END
$$
LANGUAGE plpgsql;



-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
DROP SCHEMA IF EXISTS i18n CASCADE;
CREATE SCHEMA i18n;

CREATE TABLE i18n.resources
(
  resource_id                                   SERIAL PRIMARY KEY,
  resource_class                                text,
  key                                           text,
  value                                         text
);

CREATE UNIQUE INDEX resource_class_key_uix
ON i18n.resources(LOWER(resource_class), LOWER(key));

CREATE TABLE i18n.localized_resources
(
    localized_resource_id                       BIGSERIAL PRIMARY KEY,
    resource_id                                 integer NOT NULL REFERENCES i18n.resources,
    culture_code                                national character varying(5) NOT NULL,
    value                                       text
);

-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/05.views/0.resource_view.sql --<--<--
DROP VIEW IF EXISTS i18n.resource_view;

CREATE VIEW i18n.resource_view
AS
SELECT 
    resource_class, '' as culture, key, value
FROM i18n.resources
UNION ALL
SELECT resource_class, culture_code, key, i18n.localized_resources.value 
FROM i18n.localized_resources
INNER JOIN i18n.resources
ON i18n.localized_resources.resource_id = i18n.resources.resource_id;

-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/05.views/localized_resource_view.sql --<--<--
DROP VIEW IF EXISTS i18n.localized_resource_view;

CREATE VIEW i18n.localized_resource_view
AS
SELECT
    resource_class || 
    CASE WHEN COALESCE(culture, '') = '' THEN '' ELSE '.' || culture END 
    || '.' || key as key, value 
FROM i18n.resource_view;


-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/06.functions-and-logic/add_localized_resource.sql --<--<--
DROP FUNCTION IF EXISTS i18n.add_localized_resource
(
    _resource_class  text,
    _culture_code    text,
    _key             text,
    _value           text
);

CREATE FUNCTION i18n.add_localized_resource
(
    _resource_class  text,
    _culture_code    text,
    _key             text,
    _value           text
)
RETURNS void 
VOLATILE
AS
$$
    DECLARE _resource_id    integer;
BEGIN
    IF(COALESCE(_culture_code, '') = '') THEN
        PERFORM i18n.add_resource(_resource_class, _key, _value);
        RETURN;
    END IF;
       
    SELECT resource_id INTO _resource_id
    FROM i18n.resources
    WHERE UPPER(resource_class) = UPPER(_resource_class)
    AND UPPER(key) = UPPER(_key);

    IF(_resource_id IS NOT NULL) THEN
        IF EXISTS
        (
            SELECT 1 FROM i18n.localized_resources 
            WHERE i18n.localized_resources.resource_id=_resource_id
            AND culture_code = _culture_code
        ) THEN
            UPDATE i18n.localized_resources
            SET value=_value
            WHERE i18n.localized_resources.resource_id=_resource_id
            AND culture_code = _culture_code;

            RETURN;
        END IF;

        INSERT INTO i18n.localized_resources(resource_id, culture_code, value)
        SELECT _resource_id, _culture_code, _value;
    END IF;
END
$$
LANGUAGE plpgsql;

-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/06.functions-and-logic/add_resource.sql --<--<--
DROP FUNCTION IF EXISTS i18n.add_resource
(
    resource_class  text,
    key             text,
    value           text
);

CREATE OR REPLACE FUNCTION i18n.add_resource
(
    resource_class  text,
    key             text,
    value           text
)
RETURNS void 
VOLATILE
AS
$$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM i18n.resources WHERE i18n.resources.resource_class=$1 AND i18n.resources.key=$2) THEN
        INSERT INTO i18n.resources(resource_class, key, value)
        SELECT $1, $2, $3;
    END IF;
END
$$
LANGUAGE plpgsql;


-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/06.functions-and-logic/get_localization_table.sql --<--<--
DROP FUNCTION IF EXISTS i18n.get_localization_table(text);

CREATE FUNCTION i18n.get_localization_table
(
    culture_code        text
)
RETURNS TABLE
(
    id                  bigint,
    resource_class      text,
    key                 text,
    original            text,
    translated          text
)
AS
$$
BEGIN   
    CREATE TEMPORARY TABLE t
    (
        resource_id         integer,
        resource_class      text,
        key                 text,
        original            text,
        translated          text
    ) ON COMMIT DROP;
    
    INSERT INTO t
    SELECT
        i18n.resources.resource_id, 
        i18n.resources.resource_class, 
        i18n.resources.key, 
        i18n.resources.value,
        ''
    FROM i18n.resources;

    UPDATE t
    SET translated = i18n.localized_resources.value
    FROM i18n.localized_resources
    WHERE t.resource_id = i18n.localized_resources.resource_id
    AND i18n.localized_resources.culture_code=$1;

    RETURN QUERY
    SELECT
        row_number() OVER(ORDER BY t.resource_class, t.key),
        t.resource_class, 
        t.key, 
        t.original,
        t.translated
    FROM t;
END
$$
LANGUAGE plpgsql;


-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/06.functions-and-logic/get_output_for.sql --<--<--
DROP FUNCTION IF EXISTS i18n.get_output_for(national character varying(3));

CREATE FUNCTION i18n.get_output_for(national character varying(3))
RETURNS text
AS
$$
BEGIN
    RETURN array_to_string(array_agg(i18n.resource), E'\n')
    FROM
    (
        SELECT
            
            'SELECT * FROM i18n.add_localized_resource(''' ||
            i18n.resources.resource_class || ''', ''' || $1 || ''', ''' ||
            i18n.resources.key || ''', ''' ||
            REPLACE(i18n.localized_resources.value, '''', '''''') || ''');--' ||
            i18n.resources.value AS resource
        FROM i18n.localized_resources
        LEFT JOIN i18n.resources
        ON i18n.localized_resources.resource_id = i18n.resources.resource_id
        WHERE culture_code = $1
        ORDER BY i18n.resources.resource_class, i18n.resources.key
    )
    i18n;
END
$$
LANGUAGE plpgsql;


-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/06.functions-and-logic/get_resource.sql --<--<--
DROP FUNCTION IF EXISTS i18n.get_resource(_culture_code text, _resource_class text, _key text);

CREATE FUNCTION i18n.get_resource(_culture_code text, _resource_class text, _key text)
RETURNS text
STABLE
AS
$$
    DECLARE _resource_id    integer;
    DECLARE _resource       text;
    DECLARE _value          text;
BEGIN
    SELECT 
        resource_id,
        value
    INTO
        _resource_id,
        _resource
    FROM i18n.resources
    WHERE resource_class = _resource_class
    AND key = _key;

    SELECT
        value
    INTO
        _value
    FROM i18n.localized_resources
    WHERE culture_code = _culture_code
    AND resource_id = _resource_id;


    _resource := COALESCE(_value, _resource);
    
    RETURN _resource;
END
$$
LANGUAGE plpgsql;

-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/10.Localization/0.neutral-resource(en)/language.sql --<--<--
SELECT i18n.add_localized_resource('Titles', '', 'SignIn', 'Sign In');
SELECT i18n.add_localized_resource('Titles', '', 'Username', 'Username');
SELECT i18n.add_localized_resource('Titles', '', 'Password', 'Password');
SELECT i18n.add_localized_resource('Titles', '', 'ReturnToWebsite', 'Return to Website');
SELECT i18n.add_localized_resource('Titles', '', 'Or', 'Or');
SELECT i18n.add_localized_resource('Titles', '', 'Add', 'Add');
SELECT i18n.add_localized_resource('Titles', '', 'Save', 'Save');
SELECT i18n.add_localized_resource('Titles', '', 'Edit', 'Edit');
SELECT i18n.add_localized_resource('Titles', '', 'Delete', 'Delete');
SELECT i18n.add_localized_resource('Titles', '', 'Update', 'Update');


-->-->-- C:/Users/nirvan/Desktop/mixerp/frapid/src/Frapid.Web/db/meta/1.x/1.0/src/99.ownership.sql --<--<--
DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_tables 
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND tableowner <> 'frapid_db_user'
    LOOP
        EXECUTE 'ALTER TABLE '|| this.schemaname || '.' || this.tablename ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'ALTER '
        || CASE WHEN p.proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
        || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
        || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') OWNER TO frapid_db_user;' AS sql
    FROM   pg_catalog.pg_proc p
    JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
    LOOP        
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_views
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND viewowner <> 'frapid_db_user'
    LOOP
        EXECUTE 'ALTER VIEW '|| this.schemaname || '.' || this.viewname ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'ALTER SCHEMA ' || nspname || ' OWNER TO frapid_db_user;' AS sql FROM pg_namespace
    WHERE nspname NOT LIKE 'pg_%'
    AND nspname <> 'information_schema'
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;



DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT      'ALTER TYPE ' || n.nspname || '.' || t.typname || ' OWNER TO frapid_db_user;' AS sql
    FROM        pg_type t 
    LEFT JOIN   pg_catalog.pg_namespace n ON n.oid = t.typnamespace 
    WHERE       (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid)) 
    AND         NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
    AND         typtype NOT IN ('b')
    AND         n.nspname NOT IN ('pg_catalog', 'information_schema')
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_tables 
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND tableowner <> 'report_user'
    LOOP
        EXECUTE 'GRANT SELECT ON TABLE '|| this.schemaname || '.' || this.tablename ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'GRANT EXECUTE ON '
        || CASE WHEN p.proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
        || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
        || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') TO report_user;' AS sql
    FROM   pg_catalog.pg_proc p
    JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
    LOOP        
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_views
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND viewowner <> 'report_user'
    LOOP
        EXECUTE 'GRANT SELECT ON '|| this.schemaname || '.' || this.viewname ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'GRANT USAGE ON SCHEMA ' || nspname || ' TO report_user;' AS sql FROM pg_namespace
    WHERE nspname NOT LIKE 'pg_%'
    AND nspname <> 'information_schema'
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;
