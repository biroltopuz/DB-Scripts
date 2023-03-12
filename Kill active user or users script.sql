-- select spid, status, loginame, hostname, blocked, db_name(dbid), cmd from master..sysprocesses where db_name(dbid) = 'DatabaseName'
-- kill 554;

declare @spid smallint
declare @tString nvarchar(100)

DECLARE Cursor1 CURSOR
FAST_FORWARD FOR
	select spid from master..sysprocesses where db_name(dbid) = 'DatabaseName'
OPEN Cursor1
FETCH NEXT FROM Cursor1 into @spid
	WHILE @@FETCH_STATUS = 0 BEGIN

		SET @tString = RTRIM('KILL ' + CAST(@spid AS VARCHAR(5)))
		EXEC(@tString);
		print @tString;

		FETCH NEXT FROM Cursor1 into @spid

	END
CLOSE Cursor1
DEALLOCATE Cursor1