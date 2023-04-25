-- Agent job list in SQL Server
SELECT j.NAME, j.description, l.NAME AS login_name, j.enabled, j.date_created, j.date_modified, j.version_number, h.run_datetime_last
FROM msdb..sysjobs j
LEFT JOIN master.sys.syslogins l ON j.owner_sid = l.sid
LEFT JOIN (
	SELECT job_id, Max(Cast(Cast(run_date AS CHAR(8)) + ' ' + Stuff(Stuff(RIGHT('000000' + Cast(run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS DATETIME)) run_datetime_last
	FROM msdb.dbo.sysjobhistory
	WHERE step_id = 0
	GROUP BY job_id
) h ON j.job_id=h.job_id
ORDER BY j.NAME;

-- Viewing Job History in SQL Server
SELECT job.job_id AS [JobID], job.NAME AS [JobName],
(CASE WHEN jh.run_date IS NULL OR jh.run_time IS NULL THEN NULL
	ELSE Cast(Cast(jh.run_date AS CHAR(8)) + ' ' + Stuff(Stuff(RIGHT('000000' + Cast(jh.run_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS DATETIME) END) AS [LastRunDateTime],
(CASE jh.run_status WHEN 0 THEN 'Failed' WHEN 1 THEN 'Succeeded' WHEN 2 THEN 'Retry' WHEN 3 THEN 'Canceled' WHEN 4 THEN 'Running' END) AS [LastRunStatus],
Stuff(Stuff(RIGHT('000000' + Cast(jh.run_duration AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS [LastRunDuration (HH:MM:SS)],
jh.message AS [LastRunStatusMessage]
FROM msdb.dbo.sysjobs AS [job]
LEFT JOIN (
    SELECT job_id, run_date, run_time, run_status, run_duration, message,
	Row_number() OVER (partition BY job_id ORDER BY run_date DESC, run_time DESC) AS RowNumber
    FROM msdb.dbo.sysjobhistory
    WHERE step_id = 0
) AS jh ON job.job_id = jh.job_id
ORDER BY lastrundatetime DESC;