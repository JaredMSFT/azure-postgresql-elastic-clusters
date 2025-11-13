DO $$
DECLARE
    i integer;
BEGIN
  FOR i IN SELECT m FROM generate_series(100, 200) AS m LOOP

		WITH mins AS (SELECT 1 AS mins_id),
		maxs AS (SELECT 20 AS maxs_id),
		bounds AS (
		  SELECT min(id) AS min_id, max(id) AS max_id FROM mins, maxs, ads 
          WHERE company_id = CASE 
            WHEN random() < 0.8 THEN 5  -- 80% of rows go to company_id = 5 (creates skew!)
        	ELSE (FLOOR(RANDOM() * (maxs_id - mins_id + 1) + mins_id))::bigint
		  END	
		),
		candidates AS (
		  SELECT (b.min_id + floor(random() * (b.max_id - b.min_id + 1)))::bigint AS id
		  FROM bounds b, generate_series(i * 1000000, (i+1) * 1000000)
		)
		INSERT INTO impressions (company_id, ad_id, seen_at, site_url, cost_per_impression_usd, user_ip, user_data)
		SELECT a.company_id, a.id AS ad_id,
		NOW() - (RANDOM()*365 * INTERVAL '1 day') AS seen_at,
		FORMAT('%s://%s.%s.%s/%s-%s/%s?%s=%s',
			(ARRAY['https','http'])[1+FLOOR(RANDOM()*2)::int],
			(ARRAY['www','api','app','cdn'])[1+FLOOR(RANDOM()*4)::int],
			(ARRAY['contoso','fabrikam','example'])[1+FLOOR(RANDOM()*3)::int],
			(ARRAY['com','net','io'])[1+FLOOR(RANDOM()*3)::int],
			SUBSTR(md5(RANDOM()::text),1,5),
			SUBSTR(md5(RANDOM()::text),1,4),
			SUBSTR(md5(RANDOM()::text),1,6),
			SUBSTR(md5(RANDOM()::text),1,4),
			SUBSTR(md5(RANDOM()::text),1,6)
		) AS site_url,
		RANDOM() AS cost_per_impression_usd,
		INET(FORMAT('%s.%s.%s.%s',
			FLOOR(RANDOM()*256)::int,
			FLOOR(RANDOM()*256)::int,
			FLOOR(RANDOM()*256)::int,
			FLOOR(RANDOM()*256)::int
		)) AS user_ip,	
		JSONB(FORMAT('{"location": "%s%s", "is_mobile": %s}',
			CHR(65 + FLOOR(RANDOM()*26)::int),
			CHR(65 + FLOOR(RANDOM()*26)::int),
			(random() < 0.5)::text
		)) AS user_data
		FROM ads a
		JOIN candidates c ON c.id = a.id
		ON CONFLICT (company_id, id) DO NOTHING;

  END LOOP;
END;
$$;