SELECT
  COUNT(DISTINCT(events.actor.login)) AS contributor_count,
  STRFTIME_UTC_USEC(PARSE_UTC_USEC(STRING(events.created_at)), "%Y-%U") AS year_week
FROM (
  SELECT
    *
  FROM
    TABLE_DATE_RANGE([githubarchive:day.], TIMESTAMP('2016-01-01'), CURRENT_TIMESTAMP()),
    [githubarchive:year.2015],
    [githubarchive:year.2014],
    [githubarchive:year.2013],
    [githubarchive:year.2012],
    [githubarchive:year.2011] ) AS events
WHERE
  events.type NOT IN ('WatchEvent', 'ForkEvent', 'DeleteEvent')
GROUP BY
  year_week
ORDER BY
  year_week ASC
