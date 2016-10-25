SELECT
  repo_name,
  COUNT(*) AS star_count,
  ROUND((TIMESTAMP_TO_SEC(events.created_at)-TIMESTAMP_TO_SEC(made_public_at))/3600) AS tdiff
FROM (
  SELECT
    *
  FROM (TABLE_DATE_RANGE([githubarchive:day.], TIMESTAMP('2016-10-01'), CURRENT_TIMESTAMP() ))) AS events
INNER JOIN (
  SELECT
    repo.id AS repo_id,
    repo.name AS repo_name,
    created_at AS made_public_at
  FROM (TABLE_DATE_RANGE([githubarchive:day.], TIMESTAMP('2015-10-01'), CURRENT_TIMESTAMP() ))
  WHERE
    type = 'PublicEvent') AS repo_release_dates
ON
  events.repo.id = repo_release_dates.repo_id
WHERE
  events.type = 'WatchEvent'
  AND repo_name IN ('yarnpkg/yarn')
  AND events.created_at < DATE_ADD(repo_release_dates.made_public_at, 7, "DAY")
GROUP BY
  repo_name,
  tdiff
ORDER BY
  repo_name DESC,
  tdiff ASC
;
