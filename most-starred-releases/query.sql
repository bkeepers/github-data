SELECT
  repo.id,
  releases.name,
  COUNT(*) AS star_count,
  releases.made_public_at,
FROM (
  SELECT
    *
  FROM
    [githubarchive:year.2015],
    TABLE_DATE_RANGE([githubarchive:day.], TIMESTAMP('2016-01-01'), CURRENT_TIMESTAMP())) AS events
JOIN (
  SELECT
    repo.id AS id,
    repo.name AS name,
    created_at AS made_public_at
  FROM
    [githubarchive:year.2015],
    TABLE_DATE_RANGE([githubarchive:day.], TIMESTAMP('2016-01-01'), CURRENT_TIMESTAMP())
  WHERE
    type = 'PublicEvent') AS releases
ON
  releases.id = events.repo.id
WHERE
  events.type = 'WatchEvent'
  AND events.created_at < DATE_ADD(releases.made_public_at, 7, "DAY")
GROUP BY
  repo.id,
  releases.name,
  releases.made_public_at
ORDER BY
  star_count DESC
LIMIT
  20;
