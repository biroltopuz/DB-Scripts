select serverproperty('MachineName') as 'machine_name'
, isnull(serverproperty('InstanceName'),'mssqlserver') as 'instance_name'
, @@SERVERNAME 'sql_server_name', DB_NAME(mf.database_id) 'database_name'
, mf.name 'logical_name', mf.physical_name 'physical_name'
, left(mf.physical_name,1) 'disk_drive', mf.type_desc 'file_type'
, mf.state_desc 'state', (case mf.is_read_only when 0 then 'no' when 1 then 'yes' end) 'read_only'
,convert(numeric(18,2),convert(numeric,mf.size)*8/1024) 'size_mb'
,divfs.size_on_disk_bytes/1024/1024 'size_on_disk_mb'
, (case mf.is_percent_growth
	when 0 then cast(convert(int,convert(numeric,mf.growth)*8/1024) as varchar) + ' MB'
	when 1 then cast(mf.growth as varchar) + '%'
end) as 'growth'
, (case mf.is_percent_growth
	when 0 then convert(numeric(18,2),convert(numeric,mf.growth)*8/1024)
	when 1 then convert(numeric(18,2),(convert(numeric,mf.size)*mf.growth/100)*8/1024)
end) as 'next_growth_mb'
, (case mf.max_size
	when 0 then 'NO-growth'
	when -1 then (case mf.growth when 0 then 'NO-growth' else 'unlimited' end)
	else cast(convert(int,convert(numeric,mf.max_size)*8/1024) as varchar)+' MB'
end) as 'max_size'
, divfs.num_of_reads, divfs.num_of_bytes_read/1024/1024 'read_mb', divfs.io_stall_read_ms
, divfs.num_of_writes, divfs.num_of_bytes_written/1024/1024 'write_mb', divfs.io_stall_write_ms
from sys.master_files as mf
left outer join sys.dm_io_virtual_file_stats(null,null) as divfs on mf.database_id=divfs.database_id and mf.file_id=divfs.file_id;

-- Source => https://ittutorial.org/sql-server-dba-scripts-all-in-one-useful-database-administration-scripts/
