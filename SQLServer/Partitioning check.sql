select distinct
pp.[object_id], TbName = OBJECT_NAME(pp.[object_id]), index_name = i.[name],
index_type_desc = i.type_desc, partition_scheme = ps.[name], data_space_id = ps.data_space_id,
function_name = pf.[name], function_id = ps.function_id
from sys.partitions pp
inner join sys.indexes i on pp.[object_id] = i.[object_id] and pp.index_id = i.index_id
inner join sys.data_spaces ds on i.data_space_id = ds.data_space_id
inner join sys.partition_schemes ps on ds.data_space_id = ps.data_space_id
inner JOIN sys.partition_functions pf on ps.function_id = pf.function_id
order by TbName, index_name;

-- https://ittutorial.org/sql-server-dba-scripts-all-in-one-useful-database-administration-scripts/
