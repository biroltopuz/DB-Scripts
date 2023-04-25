SELECT database_name = DB_NAME(database_id)
, log_size_mb = CAST(SUM(CASE WHEN type_desc = 'LOG' THEN size END) * 8. / 1024 AS DECIMAL(8,2))
, row_size_mb = CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8. / 1024 AS DECIMAL(8,2))
, total_size_mb = CAST(SUM(size) * 8. / 1024 AS DECIMAL(8,2))
FROM sys.master_files WITH(NOWAIT)
--WHERE database_id = DB_ID() -- for current db 
GROUP BY database_id



DECLARE @startDate datetime;
SET @startDate = GetDate();

SELECT PVT.DatabaseName
, PVT.[0], PVT.[-1], PVT.[-2], PVT.[-3], PVT.[-4], PVT.[-5], PVT.[-6]
, PVT.[-7], PVT.[-8], PVT.[-9], PVT.[-10], PVT.[-11], PVT.[-12]
FROM
(SELECT BS.database_name AS DatabaseName
,DATEDIFF(mm, @startDate, BS.backup_start_date) AS MonthsAgo
,CONVERT(numeric(10, 1), AVG(BF.file_size / 1048576.0)) AS AvgSizeMB
FROM msdb.dbo.backupset as BS
INNER JOIN
msdb.dbo.backupfile AS BF
ON BS.backup_set_id = BF.backup_set_id
WHERE NOT BS.database_name IN
('master', 'msdb', 'model', 'tempdb')
AND BF.[file_type] = 'D'
AND BS.backup_start_date BETWEEN DATEADD(yy, -1, @startDate) AND @startDate
GROUP BY BS.database_name
,DATEDIFF(mm, @startDate, BS.backup_start_date)
) AS BCKSTAT
PIVOT (SUM(BCKSTAT.AvgSizeMB)
FOR BCKSTAT.MonthsAgo IN ([0], [-1], [-2], [-3], [-4], [-5], [-6], [-7], [-8], [-9], [-10], [-11], [-12])
) AS PVT
ORDER BY PVT.DatabaseName;

-- https://ittutorial.org/sql-server-dba-scripts-all-in-one-useful-database-administration-scripts/
