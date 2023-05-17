SELECT TOP 50 OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid) as ObjectName, qt.text as TextData
, qs.total_physical_reads as DiskReads --The worst reads, disk reads
, qs.total_logical_reads as MemoryReads --Logical Reads are memory reads
, qs.execution_count as Executions, qs.total_worker_time as TotalCPUTime, qs.total_worker_time/qs.execution_count as AverageCPUTime
, qs.total_elapsed_time as DiskWaitAndCPUTime, qs.max_logical_writes as MemoryWrites, qs.creation_time as DateCached
, DB_Name(qt.dbid) as DatabaseName, qs.last_execution_time as LastExecutionTime
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
ORDER BY qs.total_worker_time DESC;


select top 50 query_stats.query_hash, SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count) as avgCPU_USAGE,
min(query_stats.statement_text) as QUERY
from (
	select qs.*, SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
		((case statement_end_offset	when -1 then DATALENGTH(st.text) else qs.statement_end_offset end - qs.statement_start_offset)/2) +1) as statement_text
	from sys.dm_exec_query_stats as qs
	cross apply sys.dm_exec_sql_text(qs.sql_handle) as st 
) as query_stats
group by query_stats.query_hash
order by 2 desc;

-- Source => https://ittutorial.org/sql-server-dba-scripts-all-in-one-useful-database-administration-scripts/
