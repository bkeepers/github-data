-- Users making their first public contribution by week
SELECT
  STRFTIME_UTC_USEC(PARSE_UTC_USEC(STRING(first_contribution_at)), "%Y-%U") as year_week,
  COUNT(DISTINCT(login)) AS new_contributor_count
FROM (
  -- Get the date of the first public event for each user and treat that as their
  -- first public contribution.
  SELECT
    events.actor.login AS login,
    MIN(events.created_at) AS first_contribution_at
  FROM (
    SELECT
      *
    FROM
      [githubarchive:year.2011],
      [githubarchive:year.2015],
      [githubarchive:year.2014],
      [githubarchive:year.2013],
      [githubarchive:year.2012],
      TABLE_DATE_RANGE([githubarchive:day.], TIMESTAMP('2016-01-01'), CURRENT_TIMESTAMP()) ) AS events
  WHERE
    events.type NOT IN ('WatchEvent', 'ForkEvent', 'DeleteEvent')
  GROUP BY
    login
  )
GROUP BY
  year_week
ORDER BY
  new_contributor_count;
