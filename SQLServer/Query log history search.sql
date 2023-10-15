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


-- Search stored procedure run history
SELECT d.object_id, d.database_id, OBJECT_NAME(object_id, database_id) [procedure_name],
d.cached_time, d.last_execution_time, d.total_elapsed_time,
d.total_elapsed_time/d.execution_count AS [avg_elapsed_time],
d.last_elapsed_time, d.execution_count
FROM sys.dm_exec_procedure_stats AS d
ORDER BY [total_worker_time] DESC;

SELECT st.text as SQL, qs.creation_time, qs.last_execution_time, qp.dbid, qp.objectid
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, DEFAULT, DEFAULT) AS qp
WHERE st.text like '%[PROCEDURE_NAME]%';
