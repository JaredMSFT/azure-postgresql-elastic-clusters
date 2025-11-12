SELECT a.campaign_id
       ,RANK() OVER (
         PARTITION BY a.campaign_id
         ORDER BY a.campaign_id, COUNT(*) DESC
       )
       ,COUNT(*) AS n_impressions
       ,a.id
FROM ads AS a
JOIN impressions AS i
ON i.company_id = a.company_id
AND i.ad_id  = a.id
WHERE a.company_id = 5
GROUP BY a.campaign_id, a.id
ORDER BY a.campaign_id, n_impressions DESC;