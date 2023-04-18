SELECT t.[text] FROM sys.dm_exec_cached_plans AS p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS t
WHERE t.[text] LIKE N'%[TABLE_NAME]%';

set dateformat dmy;
SELECT t.[text], s.last_execution_time
FROM sys.dm_exec_cached_plans AS p
INNER JOIN sys.dm_exec_query_stats AS s ON p.plan_handle = s.plan_handle
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS t
WHERE s.last_execution_time>='15.04.2023 12:00:00' and t.[text] like N'%[TABLE_NAME]%'
ORDER BY s.last_execution_time DESC;
