#standardSQL
WITH
  -- all events
  events AS (
    SELECT * FROM `githubarchive.year.*` UNION ALL
    SELECT * FROM `githubarchive.day.2016*`
  ),

  -- star counts by repo
  stars as (
    SELECT
      repo.id as repo_id,
      COUNT(*) as count
    FROM events
    WHERE type = 'WatchEvent'
    GROUP BY repo_id
  ),

  first_contribution AS (
    SELECT
      events.actor.login AS login,
      MIN(events.created_at) AS created_at
    FROM events
    GROUP BY login
  )

SELECT
  events.repo.id as repo_id,
  events.repo.name as repo_name,
  count(*) as event_count,
  count(DISTINCT first_contribution.login) as new_contributors_count
FROM events
JOIN stars ON stars.repo_id = events.repo.id
LEFT OUTER JOIN first_contribution ON
  events.actor.login = first_contribution.login
  AND events.created_at BETWEEN first_contribution.created_at AND TIMESTAMP_ADD(first_contribution.created_at, INTERVAL 30 DAY)
WHERE
 stars.count > 100
GROUP BY repo_id, repo_name
HAVING
  event_count > 100
  AND (new_contributors_count / event_count) >= 0.05
ORDER BY new_contributors_count / event_count DESC
LIMIT 100;
