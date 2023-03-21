-- Database file location list
SELECT b.name as DatabaseName, a.name as FileName, physical_name as FileLocation 
FROM sys.master_files a
inner join sys.databases b on a.database_id=b.database_id
--WHERE b.name like 'YourDatabaseName%'
--WHERE SUBSTRING(physical_name,1,2)='D:'
ORDER BY b.Name

-- Number of files in the directory
SELECT SUBSTRING(a.physical_name,1,2) as Disk, SUM(1) as TotalDB 
FROM sys.master_files a
inner join sys.databases b on a.database_id=b.database_id
WHERE a.database_id>4 --and b.name like 'YourDatabaseName%'
GROUP BY SUBSTRING(a.physical_name,1,2) 
