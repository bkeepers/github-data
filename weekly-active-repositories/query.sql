SELECT
  STRFTIME_UTC_USEC(PARSE_UTC_USEC(STRING(events.created_at)), "%Y-%U") AS year_week,
  COUNT(DISTINCT(events.repo.name)) AS active_licensed_repos
FROM (
  SELECT
    *
  FROM
    TABLE_DATE_RANGE([githubarchive:day.], TIMESTAMP('2016-01-01'), CURRENT_TIMESTAMP()),
    [githubarchive:year.2015]) AS events
JOIN
  [bigquery-public-data:github_repos.licenses] as licenses
ON
  licenses.repo_name = events.repo.name
WHERE
  events.type NOT IN ('WatchEvent', 'ForkEvent', 'DeleteEvent')
GROUP BY
  year_week
ORDER BY
  year_week ASC
