SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT er.session_id AS SPID, er.blocking_session_id AS BlkBy, er.total_elapsed_time AS ElapsedMS, 
er.cpu_time AS CPU, er.logical_reads + er.reads AS IOReads, er.writes AS IOWrites, ec.execution_count AS Executions,
er.command AS CommandType, OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid) AS ObjectName,
SUBSTRING (qt.text, er.statement_start_offset/2, 
	(CASE WHEN er.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2 
	ELSE er.statement_end_offset END - er.statement_start_offset)/2 ) AS SQLStatement, ses.status AS Status,
ses.login_name AS [Login], ses.host_name AS Host, DB_Name(er.database_id) AS DBName, er.last_wait_type AS LastWaitType,
er.start_time AS StartTime, con.net_transport AS Protocol, 
(CASE ses.transaction_isolation_level WHEN 0 THEN 'Unspecified' WHEN 1 THEN 'Read Uncommitted' WHEN 2 THEN 'Read Committed' 
	WHEN 3 THEN 'Repeatable' WHEN 4 THEN 'Serializable' WHEN 5 THEN 'Snapshot'  END) AS transaction_isolation,
con.num_writes AS ConnectionWrites, con.num_reads AS ConnectionReads, con.client_net_address AS ClientAddress,
con.auth_scheme AS Authentication
FROM sys.dm_exec_requests er 
LEFT JOIN sys.dm_exec_sessions ses ON ses.session_id = er.session_id 
LEFT JOIN sys.dm_exec_connections con ON con.session_id = ses.session_id 
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) as qt 
OUTER APPLY ( 
	SELECT execution_count = MAX(cp.usecounts) FROM sys.dm_exec_cached_plans cp 
	WHERE cp.plan_handle = er.plan_handle 
) ec 
ORDER BY er.blocking_session_id DESC, er.logical_reads + er.reads DESC, er.session_id;

-- https://ittutorial.org/sql-server-dba-scripts-all-in-one-useful-database-administration-scripts/
