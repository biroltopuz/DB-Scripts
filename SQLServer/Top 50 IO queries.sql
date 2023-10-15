-- TOP 50 IO queries
select q.[text],
SUBSTRING(q.text, (highest_cpu_queries.statement_start_offset/2)+1,
    ((CASE highest_cpu_queries.statement_end_offset
    WHEN -1 THEN DATALENGTH(q.text)
    ELSE highest_cpu_queries.statement_end_offset
    END - highest_cpu_queries.statement_start_offset)/2) + 1) AS statement_text,
highest_cpu_queries.total_worker_time,
highest_cpu_queries.total_logical_reads,
highest_cpu_queries.last_execution_time,
highest_cpu_queries.execution_count,
q.dbid, q.objectid, q.number, q.encrypted,
highest_cpu_queries.plan_handle
from (
    select top 50 qs.last_execution_time, qs.execution_count, qs.plan_handle, 
    qs.total_worker_time, qs.statement_start_offset, qs.statement_end_offset,
    qs.total_logical_reads
    from sys.dm_exec_query_stats qs
    order by qs.total_worker_time desc
) as highest_cpu_queries 
cross apply sys.dm_exec_sql_text(plan_handle) as q
order by highest_cpu_queries.total_logical_reads desc;


-- TOP IO queries
select 
SUBSTRING(st.text,(qs.statement_start_offset/2)+1,
    ((case statement_end_offset when -1 then DATALENGTH(st.text)
    else qs.statement_end_offset end
    - qs.statement_start_offset)/2) +1) as statement_text,
qs.total_logical_reads, qs.total_physical_reads, qs.execution_count
from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as st 
order by qs.total_logical_reads desc, qs.execution_count desc;


-- IO stats and detail information
select serverproperty('MachineName') 'machine_name'
, isnull(serverproperty('InstanceName'),'mssqlserver') 'instance_name'
, @@SERVERNAME 'sql_server_name', DB_NAME(mf.database_id) 'database_name'
, mf.name 'logical_name', mf.physical_name 'physical_name'
, left(mf.physical_name,1) 'disk_drive', mf.type_desc 'file_type', mf.state_desc 'state'
, (case mf.is_read_only when 0 then 'no' when 1 then 'yes' end) as 'read_only'
, convert(numeric(18,2),convert(numeric,mf.size)*8/1024) 'size_mb'
, divfs.size_on_disk_bytes/1024/1024 'size_on_disk_mb'
, (case mf.is_percent_growth when 0 then cast(convert(int,convert(numeric,mf.growth)*8/1024) as varchar) + ' MB'
    when 1 then cast(mf.growth as varchar) + '%' end) as 'growth'
, (case mf.is_percent_growth when 0 then convert(numeric(18,2),convert(numeric,mf.growth)*8/1024)
    when 1 then convert(numeric(18,2),(convert(numeric,mf.size)*mf.growth/100)*8/1024) end) as 'next_growth_mb'
, (case mf.max_size when 0 then 'NO-growth'
    when -1 then (case mf.growth when 0 then 'NO-growth' else 'unlimited' end)
    else cast(convert(int,convert(numeric,mf.max_size)*8/1024) as varchar)+' MB' end) as 'max_size'
, divfs.num_of_reads, divfs.num_of_bytes_read/1024/1024 'read_mb', divfs.io_stall_read_ms, 
divfs.num_of_writes, divfs.num_of_bytes_written/1024/1024 'write_mb', divfs.io_stall_write_ms
from sys.master_files as mf
left outer join sys.dm_io_virtual_file_stats(null,null) as divfs
    on mf.database_id=divfs.database_id and mf.file_id=divfs.file_id;


-- Source => https://ittutorial.org/sql-server-dba-scripts-all-in-one-useful-database-administration-scripts/
