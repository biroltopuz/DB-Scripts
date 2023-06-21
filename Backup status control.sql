SELECT DB.name AS Database_Name, MAX(DB.recovery_model_desc) AS Recovery_Model, MAX(BS.backup_start_date) AS Last_Backup,
MAX(CASE WHEN BS.type = 'D' THEN BS.backup_start_date END) AS Last_Full_backup, SUM(CASE WHEN BS.type = 'D' THEN 1 END) AS Count_Full_backup,
MAX(CASE WHEN BS.type = 'L' THEN BS.backup_start_date END) AS Last_Log_backup, SUM(CASE WHEN BS.type = 'L' THEN 1 END) AS Count_Log_backup,
MAX(CASE WHEN BS.type = 'I' THEN BS.backup_start_date END) AS Last_Differential_backup, SUM(CASE WHEN BS.type = 'I' THEN 1 END) AS Count_Differential_backup,
MAX(CASE WHEN BS.type = 'F' THEN BS.backup_start_date END) AS LastFile, SUM(CASE WHEN BS.type = 'F' THEN 1 END) AS CountFile,
MAX(CASE WHEN BS.type = 'G' THEN BS.backup_start_date END) AS LastFileDiff, SUM(CASE WHEN BS.type = 'G' THEN 1 END) AS CountFileDiff,
MAX(CASE WHEN BS.type = 'P' THEN BS.backup_start_date END) AS LastPart, SUM(CASE WHEN BS.type = 'P' THEN 1 END) AS CountPart,
MAX(CASE WHEN BS.type = 'Q' THEN BS.backup_start_date END) AS LastPartDiff, SUM(CASE WHEN BS.type = 'Q' THEN 1 END) AS CountPartDiff 
FROM sys.databases AS DB
LEFT JOIN msdb.dbo.backupset AS BS ON BS.database_name = DB.name
WHERE ISNULL(BS.is_damaged, 0) = 0 -- exclude damaged backups 
GROUP BY DB.name
ORDER BY Last_Backup desc;

-- https://ittutorial.org/sql-server-dba-scripts-all-in-one-useful-database-administration-scripts/
