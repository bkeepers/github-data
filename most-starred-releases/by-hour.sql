SELECT repo_name, count(*) as star_count, ROUND((TIMESTAMP_TO_SEC(events.created_at)-TIMESTAMP_TO_SEC(made_public_at))/3600) as tdiff
FROM (select * from (TABLE_DATE_RANGE([githubarchive:day.],
 TIMESTAMP('2016-10-01'),
 CURRENT_TIMESTAMP()
))) as events
INNER JOIN (
  SELECT repo.id as repo_id, repo.name as repo_name, created_at as made_public_at
  FROM (TABLE_DATE_RANGE([githubarchive:day.],
    TIMESTAMP('2015-10-01'),
    CURRENT_TIMESTAMP()
  ))
  WHERE type = 'PublicEvent') as repo_release_dates
ON events.repo.id = repo_release_dates.repo_id
WHERE events.type = 'WatchEvent'
AND repo_name in ('yarnpkg/yarn')
AND events.created_at < DATE_ADD(repo_release_dates.made_public_at, 7, "DAY")
GROUP BY 1,3
ORDER BY 1 DESC, 3 ASC
limit 1680;
