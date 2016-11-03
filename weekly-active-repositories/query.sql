#standardSQL
WITH
  -- Get all events from 2015 until now
  events AS (
    SELECT * FROM `githubarchive.year.2015` UNION ALL
    SELECT * FROM `githubarchive.day.2016*`
  ),

  -- Get repos >= 10 stars
  relevant_repos AS (
    SELECT
      watch_events.id,
      COUNT(*) AS stars
    FROM
      (SELECT events.repo.id FROM events WHERE events.type = 'WatchEvent') as watch_events
    GROUP BY
      watch_events.id
    HAVING
      stars >= 10
  )
SELECT
  FORMAT_TIMESTAMP("%Y-%U", events.created_at) AS year_week,
  COUNT(DISTINCT(events.repo.name)) AS active_repos,
  COUNT(DISTINCT(events.actor.id)) AS acitve_contributors,
  COUNT(*) AS contributions
FROM
  events
JOIN
  relevant_repos
ON
  events.repo.id = relevant_repos.id
-- JOIN
--   `bigquery-public-data.github_repos.licenses` as licenses
-- ON
--   licenses.repo_name = events.repo.name
WHERE
  events.type IN (
    'CommitCommentEvent',
    'CreateEvent',
    'DeleteEvent',
    'IssueCommentEvent',
    'IssuesEvent',
    'PullRequestEvent',
    'PullRequestReviewEvent',
    'PullRequestReviewCommentEvent',
    'PushEvent',
    'ReleaseEvent'
  )
GROUP BY
  year_week
ORDER BY
  year_week ASC
;
