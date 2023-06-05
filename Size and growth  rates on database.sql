-- Database size
SELECT DB_NAME(database_id) as database_name
, CAST(SUM(CASE WHEN type_desc = 'LOG' THEN size END) * 8. / 1024 AS DECIMAL(8,2)) as log_size_mb
, CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8. / 1024 AS DECIMAL(8,2)) as row_size_mb
, CAST(SUM(size) * 8. / 1024 AS DECIMAL(8,2)) as total_size_mb
FROM sys.master_files WITH(NOWAIT)
--WHERE database_id = DB_ID() -- for current db 
GROUP BY database_id


-- Monthly database growth rates in SQL Server
SELECT DATABASE_NAME,YEAR(backup_start_date) YEAR_, MONTH(backup_start_date) MONTH_,
MIN(BackupSize) FIRSTSIZE_MB, MAX(BackupSize) LASTSIZE_MB, MAX(BackupSize)-MIN(BackupSize) AS GROW_MB,
ROUND((MAX(BackupSize)-MIN(BackupSize))/CONVERT(FLOAT,MIN(BackupSize))*100,2) AS PERCENT_
FROM (
	SELECT s.database_name,	s.backup_start_date, COUNT(*) OVER (PARTITION BY s.database_name) AS SampleSize
	, CAST((s.backup_size / 1024 / 1024) AS INT) AS BackupSize,	
	CAST((LAG(s.backup_size) OVER (PARTITION BY s.database_name ORDER BY s.backup_start_date) / 1024 / 1024) AS INT) AS Previous_Backup_Size
	FROM msdb..backupset s
	WHERE s.type = 'D' --full backup
	and s.database_name='[DATABASE_NAME]'
) T GROUP BY DATABASE_NAME, MONTH(backup_start_date), YEAR(backup_start_date)


-- https://ittutorial.org/sql-server-dba-scripts-all-in-one-useful-database-administration-scripts/
DECLARE @startDate datetime = GetDate();
SELECT PVT.DatabaseName
, PVT.[0], PVT.[-1], PVT.[-2], PVT.[-3], PVT.[-4], PVT.[-5], PVT.[-6]
, PVT.[-7], PVT.[-8], PVT.[-9], PVT.[-10], PVT.[-11], PVT.[-12]
FROM (
	SELECT BS.database_name AS DatabaseName
	, DATEDIFF(mm, @startDate, BS.backup_start_date) AS MonthsAgo
	, CONVERT(numeric(10, 1), AVG(BF.file_size / 1048576.0)) AS AvgSizeMB
	FROM msdb.dbo.backupset as BS
	INNER JOIN msdb.dbo.backupfile AS BF ON BS.backup_set_id = BF.backup_set_id
	WHERE NOT BS.database_name IN ('master', 'msdb', 'model', 'tempdb')
		AND BF.[file_type] = 'D'
		AND BS.backup_start_date BETWEEN DATEADD(yy, -1, @startDate) AND @startDate
		GROUP BY BS.database_name, DATEDIFF(mm, @startDate, BS.backup_start_date)
) AS BCKSTAT
PIVOT (
	SUM(BCKSTAT.AvgSizeMB) FOR BCKSTAT.MonthsAgo IN ([0], [-1], [-2], [-3], [-4], [-5], [-6], [-7], [-8], [-9], [-10], [-11], [-12])
) AS PVT
ORDER BY PVT.DatabaseName;
