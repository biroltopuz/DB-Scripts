/* A checkpoint writes the current in-memory modified pages  and transaction log information from memory to disk, and also records the information in the transaction log. */
CHECKPOINT

-- Clean selected execution plan cache
DBCC FREEPROCCACHE (plan_handle_id_/*Here you should write the plan_handle value of your query*/);

-- Causes stored procedures, triggers, and user-defined functions to be recompiled the next time that they're run.
EXEC sp_recompile N'Sales.Customer';

-- Execution plan cache lists
SELECT [qs].[last_execution_time], [qs].[execution_count]
    , [qs].[total_logical_reads]/[qs].[execution_count] [AvgLogicalReads], [qs].[max_logical_reads]
    , [qs].[plan_handle], [p].[query_plan]
FROM sys.dm_exec_query_stats [qs]
CROSS APPLY sys.dm_exec_sql_text([qs].sql_handle) [t]
CROSS APPLY sys.dm_exec_query_plan([qs].[plan_handle]) [p]
WHERE [t].text LIKE '%[Your_Query]%';

-- Execution plan cache lists for running query
SELECT 'KILL ' + cast(session_id AS VARCHAR) + '', 'DBCC FREEPROCCACHE (' + convert(NVARCHAR(max), plan_handle, 1) + ')' command, *
FROM sys.dm_exec_requests
CROSS APPLY sys.dm_exec_sql_text(sql_handle)
CROSS APPLY sys.dm_exec_query_plan(plan_handle) eqp
WHERE TEXT LIKE '%[Your_Query]%' AND session_id NOT IN (@@SPID)

-- will clear the all execution plan cache
DBCC FREEPROCCACHE

-- DBCC FREEPROCCACHE to clear a specific resource pool
SELECT name AS 'Pool Name',
cache_memory_kb/1024.0 AS [cache_memory_MB],
used_memory_kb/1024.0 AS [used_memory_MB]
FROM sys.dm_resource_governor_resource_pools;

DBCC FREEPROCCACHE ('internal');

-- will clear the data cache
DBCC DROPCLEANBUFFERS
