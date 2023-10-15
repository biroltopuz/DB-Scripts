-- DATE ONLY FORMATS
  select convert(varchar, getdate(), 1)
  -- mm/dd/yy	12/30/22
  select convert(varchar, getdate(), 2)
  -- yy.mm.dd	22.12.30
  select convert(varchar, getdate(), 3)
  -- dd/mm/yy	30/12/22
  select convert(varchar, getdate(), 4)
  -- dd.mm.yy	30.12.22
  select convert(varchar, getdate(), 5)
  -- dd-mm-yy	30-12-22
  select convert(varchar, getdate(), 6)
  -- dd-Mon-yy	30 Dec 22
  select convert(varchar, getdate(), 7)
  -- Mon dd, yy	Dec 30, 22
  select convert(varchar, getdate(), 10)
  -- mm-dd-yy	12-30-22
  select convert(varchar, getdate(), 11)
  -- yy/mm/dd	22/12/30
  select convert(varchar, getdate(), 12)
  -- yymmdd	221230
  select convert(varchar, getdate(), 23)
  -- yyyy-mm-dd	2022-12-30
  select convert(varchar, getdate(), 31)
  -- yyyy-dd-mm	2022-30-12
  select convert(varchar, getdate(), 32)
  -- mm-dd-yyyy	12-30-2022
  select convert(varchar, getdate(), 33)
  -- mm-yyyy-dd	12-2022-30
  select convert(varchar, getdate(), 34)
  -- dd-mm-yyyy	30-12-2022
  select convert(varchar, getdate(), 35)
  -- dd-yyyy-mm	30-2022-12
  select convert(varchar, getdate(), 101)	
  -- mm/dd/yyyy	12/30/2022
  select convert(varchar, getdate(), 102)
  -- yyyy.mm.dd	2022.12.30
  select convert(varchar, getdate(), 103)	
  -- dd/mm/yyyy	30/12/2022
  select convert(varchar, getdate(), 104)
  -- dd.mm.yyyy	30.12.2022
  select convert(varchar, getdate(), 105)
  -- dd-mm-yyyy	30-12-2022
  select convert(varchar, getdate(), 106)
  -- dd Mon yyyy	30 Dec 2022
  select convert(varchar, getdate(), 107)
  -- Mon dd, yyyy	Dec 30, 2022
  select convert(varchar, getdate(), 110)
  -- mm-dd-yyyy	12-30-2022
  select convert(varchar, getdate(), 111)
  -- yyyy/mm/dd	2022/12/30
  select convert(varchar, getdate(), 112)
  -- yyyymmdd	20221230


-- TIME ONLY FORMATS
  select convert(varchar, getdate(), 8)
  -- hh:mm:ss	00:38:54
  select convert(varchar, getdate(), 14)
  -- hh:mm:ss:nnn	00:38:54:840
  select convert(varchar, getdate(), 24)
  -- hh:mm:ss	00:38:54
  select convert(varchar, getdate(), 108)
  -- hh:mm:ss	00:38:54
  select convert(varchar, getdate(), 114)
  -- hh:mm:ss:nnn	00:38:54:840


-- DATE & TIME FORMATS
  select convert(varchar, getdate(), 0)
  -- Mon dd yyyy hh:mm AM/PM	Dec 30 2022 12:38AM
  select convert(varchar, getdate(), 9)
  -- Mon dd yyyy hh:mm:ss:nnn AM/PM	Dec 30 2022 12:38:54:840AM
  select convert(varchar, getdate(), 13)
  -- dd Mon yyyy hh:mm:ss:nnn AM/PM	30 Dec 2022 00:38:54:840AM
  select convert(varchar, getdate(), 20)
  -- yyyy-mm-dd hh:mm:ss	2022-12-30 00:38:54
  select convert(varchar, getdate(), 21)
  -- yyyy-mm-dd hh:mm:ss:nnn	2022-12-30 00:38:54.840
  select convert(varchar, getdate(), 22)
  -- mm/dd/yy hh:mm:ss AM/PM	12/30/22 12:38:54 AM
  select convert(varchar, getdate(), 25)
  -- yyyy-mm-dd hh:mm:ss:nnn	2022-12-30 00:38:54.840
  select convert(varchar, getdate(), 26)
  -- yyyy-dd-mm hh:mm:ss:nnn	2022-30-12 00:38:54.840
  select convert(varchar, getdate(), 27)
  -- mm-dd-yyyy hh:mm:ss:nnn	12-30-2022 00:38:54.840
  select convert(varchar, getdate(), 28)
  -- mm-yyyy-dd hh:mm:ss:nnn	12-2022-30 00:38:54.840
  select convert(varchar, getdate(), 29)
  -- dd-mm-yyyy hh:mm:ss:nnn	30-12-2022 00:38:54.840
  select convert(varchar, getdate(), 30)
  -- dd-yyyy-mm hh:mm:ss:nnn	30-2022-12 00:38:54.840
  select convert(varchar, getdate(), 100)
  -- Mon dd yyyy hh:mm AM/PM	Dec 30 2022 12:38AM
  select convert(varchar, getdate(), 109)
  -- Mon dd yyyy hh:mm:ss:nnn AM/PM	Dec 30 2022 12:38:54:840AM
  select convert(varchar, getdate(), 113)
  -- dd Mon yyyy hh:mm:ss:nnn	30 Dec 2022 00:38:54:840
  select convert(varchar, getdate(), 120)
  -- yyyy-mm-dd hh:mm:ss	2022-12-30 00:38:54
  select convert(varchar, getdate(), 121)
  -- yyyy-mm-dd hh:mm:ss:nnn	2022-12-30 00:38:54.840
  select convert(varchar, getdate(), 126)
  -- yyyy-mm-dd T hh:mm:ss:nnn	2022-12-30T00:38:54.840
  select convert(varchar, getdate(), 127)
  -- yyyy-mm-dd T hh:mm:ss:nnn	2022-12-30T00:38:54.840


-- ISLAMIC CALENDAR DATES
  select convert(nvarchar, getdate(), 130)
  -- dd mmm yyyy hh:mi:ss:nnn AM/PM	date output
  select convert(nvarchar, getdate(), 131)
  -- dd mmm yyyy hh:mi:ss:nnn AM/PM	10/12/1444 12:38:54:840AM


-- You can also format the date or time without dividing characters, as well as concatenate the date and time string:
  select replace(convert(varchar, getdate(),101),'/','')
  -- mmddyyyy	12302022
  select replace(convert(varchar, getdate(),101),'/','') + replace(convert(varchar, getdate(),108),':','')
  -- mmddyyyyhhmmss	12302022004426


-- All samples in one table
DECLARE @counter INT = 0
DECLARE @date DATETIME = '2006-12-30 00:38:54.840'

CREATE TABLE #dateFormats (dateFormatOption int, dateOutput nvarchar(40))

WHILE (@counter <= 150 )
BEGIN
   BEGIN TRY
      INSERT INTO #dateFormats
      SELECT CONVERT(nvarchar, @counter), CONVERT(nvarchar,@date, @counter) 
      SET @counter = @counter + 1
   END TRY
   BEGIN CATCH;
      SET @counter = @counter + 1
      IF @counter >= 150
      BEGIN
         BREAK
      END
   END CATCH
END

SELECT * FROM #dateFormats
