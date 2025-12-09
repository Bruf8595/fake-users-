-- procedures.sql — ОСТАННІЙ ФАЙЛ НАЗАВЖДИ (ВСЕ РІЗНЕ, ОЧІ РІЗНІ)

DROP FUNCTION IF EXISTS rnd(BIGINT, INT) CASCADE;
DROP FUNCTION IF EXISTS normal(FLOAT, FLOAT, BIGINT, INT) CASCADE;
DROP FUNCTION IF EXISTS geo_uniform(BIGINT, INT) CASCADE;
DROP FUNCTION IF EXISTS pick_from(TEXT, TEXT, BIGINT, INT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS pick_eye_color(INT) CASCADE;
DROP FUNCTION IF EXISTS generate_full_name(TEXT, BIGINT, INT) CASCADE;
DROP FUNCTION IF EXISTS generate_address(TEXT, BIGINT, INT) CASCADE;
DROP FUNCTION IF EXISTS generate_phone(TEXT, BIGINT, INT) CASCADE;
DROP FUNCTION IF EXISTS generate_email(TEXT, BIGINT, INT) CASCADE;
DROP FUNCTION IF EXISTS generate_batch(VARCHAR, BIGINT, INT, INT) CASCADE;


CREATE OR REPLACE FUNCTION rnd(seed BIGINT, idx INT DEFAULT 0)
RETURNS FLOAT AS $$
DECLARE x BIGINT := (seed + idx) % 2147483647;
BEGIN
    x := (x * 16807) % 2147483647;
    IF x < 0 THEN x := x + 2147483647; END IF;
    RETURN x::FLOAT / 2147483647.0;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION normal(m FLOAT, sdev FLOAT, seed BIGINT, idx INT)
RETURNS FLOAT AS $$
DECLARE u1 FLOAT := rnd(seed, idx*2); u2 FLOAT := rnd(seed, idx*2+1);
BEGIN
    IF u1 <= 0 THEN u1 := 0.0000001; END IF;
    RETURN m + sdev * SQRT(-2 * LN(u1)) * COS(2 * PI() * u2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;


CREATE OR REPLACE FUNCTION geo_uniform(seed BIGINT, idx INT)
RETURNS TABLE(lat FLOAT, lon FLOAT) AS $$
BEGIN
    lat := ASIN(2 * rnd(seed, idx*10+1) - 1) * 180 / PI();
    lon := rnd(seed, idx*10+2) * 360 - 180;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


CREATE OR REPLACE FUNCTION pick_from(tname TEXT, loc TEXT, seed BIGINT, idx INT, col TEXT DEFAULT 'name')
RETURNS TEXT AS $$
DECLARE cnt INT := 1; res TEXT;
BEGIN
    EXECUTE 'SELECT COUNT(*) FROM ' || quote_ident(tname) || ' WHERE locale = $1' INTO cnt USING loc;
    IF cnt = 0 THEN cnt := 1; END IF;
    EXECUTE format('SELECT COALESCE(%I, ''Unknown'') FROM %I WHERE locale = $1 ORDER BY id LIMIT 1 OFFSET $2', col, tname)
    INTO res USING loc, FLOOR(rnd(seed, idx*100+1) * cnt)::INT % cnt;
    RETURN COALESCE(res, 'Unknown');
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION pick_eye_color(idx INT)
RETURNS TEXT AS $$
DECLARE 
    colors TEXT[] := ARRAY['Brown','Blue','Green','Hazel','Gray'];
    weights FLOAT[] := ARRAY[0.45, 0.27, 0.15, 0.08, 0.05];
    r FLOAT := rnd(123456789::BIGINT, idx * 10000 + 1);
    cum FLOAT := 0;
    i INT;
BEGIN
    FOR i IN 1..5 LOOP
        cum := cum + weights[i];
        IF r <= cum THEN RETURN colors[i]; END IF;
    END LOOP;
    RETURN 'Brown';
END;
$$ LANGUAGE plpgsql IMMUTABLE;


CREATE OR REPLACE FUNCTION generate_full_name(loc TEXT, seed BIGINT, idx INT)
RETURNS TEXT AS $$
DECLARE 
    first TEXT := pick_from('names', loc, seed, idx*10000+1, 'first_name');
    last TEXT := pick_from('names', loc, seed, idx*10000+2, 'last_name');
    title TEXT := '';
BEGIN
    IF rnd(seed, idx*10000+3) > 0.7 THEN
        title := pick_from('titles', loc, seed, idx*10000+4, 'title') || ' ';
    END IF;
    RETURN title || first || ' ' || last;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION generate_address(loc TEXT, seed BIGINT, idx INT)
RETURNS TEXT AS $$
DECLARE 
    street TEXT := pick_from('streets', loc, seed, idx*10000+5, 'street_name');
    city_name TEXT := pick_from('cities', loc, seed, idx*10000+6, 'city');
    region_name TEXT := COALESCE(pick_from('cities', loc, seed, idx*10000+7, 'region'), '');
    zip TEXT := LPAD(FLOOR(rnd(seed, idx*10000+8)*100000)::TEXT, 5, '0');
BEGIN
    RETURN (100 + FLOOR(rnd(seed, idx*10000+9)*900))::TEXT || ' ' || street ||
           CASE WHEN rnd(seed, idx*10000+10) > 0.5 THEN ' Apt ' || (FLOOR(rnd(seed, idx*10000+11)*200) + 1)::TEXT ELSE '' END ||
           ', ' || city_name || ', ' || region_name || ' ' || zip;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION generate_phone(loc TEXT, seed BIGINT, idx INT)
RETURNS TEXT AS $$
DECLARE fmt TEXT := pick_from('phone_formats', loc, seed, idx*10000+12, 'format_pattern');
BEGIN
    fmt := REPLACE(fmt, '###', LPAD(FLOOR(rnd(seed, idx*10000+13)*1000)::TEXT,3,'0'));
    fmt := REPLACE(fmt, '####', LPAD(FLOOR(rnd(seed, idx*10000+14)*10000)::TEXT,4,'0'));
    fmt := REPLACE(fmt, '#######', LPAD(FLOOR(rnd(seed, idx*10000+15)*10000000)::TEXT,7,'0'));
    RETURN fmt;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION generate_email(loc TEXT, seed BIGINT, idx INT)
RETURNS TEXT AS $$
DECLARE 
    domain TEXT := pick_from('domains', loc, seed, idx*10000+16, 'domain');
    first TEXT := LOWER(pick_from('names', loc, seed, idx*10000+17, 'first_name'));
    last TEXT := LOWER(pick_from('names', loc, seed, idx*10000+18, 'last_name'));
BEGIN
    RETURN first || CASE WHEN rnd(seed, idx*10000+19) > 0.5 THEN '.' ELSE '' END || last || '@' || domain;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION generate_batch(p_locale VARCHAR, p_seed BIGINT, p_batch_index INT, p_batch_size INT DEFAULT 10)
RETURNS TABLE(user_json JSON) AS $$
DECLARE
    base_seed BIGINT := p_seed + p_batch_index * 100000;
    i INT;
    geo_lat FLOAT; geo_lon FLOAT;
BEGIN
    FOR i IN 0..p_batch_size-1 LOOP
        SELECT lat, lon INTO geo_lat, geo_lon FROM geo_uniform(base_seed + i*1000, i);

        user_json := json_build_object(
            'full_name', generate_full_name(p_locale, base_seed + i*1000, i),
            'address', generate_address(p_locale, base_seed + i*1000, i),
            'lat', ROUND(geo_lat::NUMERIC, 6),
            'lon', ROUND(geo_lon::NUMERIC, 6),
            'height_cm', ROUND(normal(175, 18, base_seed + i*1000, i*100)::NUMERIC, 1),
            'weight_kg', ROUND(normal(73, 22, base_seed + i*1000, i*101)::NUMERIC, 1),
            'eye_color', pick_eye_color(i),
            'phone', generate_phone(p_locale, base_seed + i*1000, i),
            'email', generate_email(p_locale, base_seed + i*1000, i)
        );
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;