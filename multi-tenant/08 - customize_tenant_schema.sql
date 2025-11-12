-- Here's a query to find who clicks more: mobile, or traditional visitors.

SELECT
user_data->>'is_mobile' AS is_mobile,
COUNT(*) AS count
FROM clicks
WHERE company_id = 5
GROUP BY user_data ->> 'is_mobile'
ORDER BY count DESC;

-- We can optimize this query for a single company by creating a partial index

CREATE INDEX click_user_data_is_mobile
ON clicks (user_data ->> 'is_mobile')
WHERE company_id = 5;

-- More generally, we can create a GIN indices on every key and value within the column.

CREATE INDEX click_user_data
ON clicks USING gin (user_data);

-- this speeds up queries like, "which clicks have
-- the is_mobile key present in user_data?"

SELECT id
FROM clicks
WHERE user_data ? 'is_mobile'
AND company_id = 5;