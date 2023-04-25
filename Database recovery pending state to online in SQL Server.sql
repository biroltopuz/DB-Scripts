select 'RESTORE DATABASE '+ name + ' WITH RECOVERY' from sys.databases where state = 1


-- https://www.mustafaerdogmus.com/sql-server-recovery-pending-hatasi-ve-cozumu/
ALTER DATABASE [DATABASE_NAME] SET SINGLE_USER WITH NO_WAIT
ALTER DATABASE [DATABASE_NAME] SET EMERGENCY;
DBCC checkdb ([DATABASE_NAME], REPAIR_ALLOW_DATA_LOSS)
ALTER DATABASE [DATABASE_NAME] SET ONLINE;
ALTER DATABASE [DATABASE_NAME] SET MULTI_USER WITH NO_WAIT


-- https://www.stellarinfo.com/blog/fix-sql-database-recovery-pending-state-issue/
-- 1. Mark Database in Emergency Mode and Initiate Forceful Repair;
ALTER DATABASE [DATABASE_NAME] SET EMERGENCY;
GO
ALTER DATABASE [DATABASE_NAME] SET SINGLE_USER
GO
DBCC CHECKDB ([DATABASE_NAME], REPAIR_ALLOW_DATA_LOSS) WITH ALL_ERRORMSGS;
GO
ALTER DATABASE [DATABASE_NAME] SET MULTI_USER
GO

-- 2. Mark Database in Emergency Mode, Detach the Main Database and Re-attach It
ALTER DATABASE [DATABASE_NAME] SET EMERGENCY;
ALTER DATABASE [DATABASE_NAME] SET MULTI_USER
EXEC sp_detach_db '[DATABASE_NAME]'
EXEC sp_attach_single_file_db @DBName = '[DATABASE_NAME]', @physname = N'[mdf path]'
