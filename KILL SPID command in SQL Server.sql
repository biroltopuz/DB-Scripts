-- Using SP_who2 command:
sp_who2

-- Using Dynamic Management View:
SELECT * FROM sys.dm_exec_sessions WHERE is_user_process = 1;

-- The @@SPID global variable = Get current session id
SELECT @@SPID AS CurrentSPID;

-- No kill, just check the estimated roll back time
KILL 554 with STATUSONLY


-- Kill one session
select spid, status, loginame, hostname, blocked, db_name(dbid), cmd from master..sysprocesses where db_name(dbid) = '[DATABASE_NAME]'
-- Sample =>  Kill 554

-- Kill all database session
declare @spid smallint
declare @tString nvarchar(100)

DECLARE Cursor1 CURSOR
FAST_FORWARD FOR
	select spid from master..sysprocesses where db_name(dbid) = '[DATABASE_NAME]'
OPEN Cursor1
FETCH NEXT FROM Cursor1 into @spid
	WHILE @@FETCH_STATUS = 0 BEGIN
		SET @tString = RTRIM('KILL ' + CAST(@spid AS VARCHAR(10)))
		EXEC(@tString);
		print @tString;
	FETCH NEXT FROM Cursor1 into @spid
	END
CLOSE Cursor1
DEALLOCATE Cursor1
