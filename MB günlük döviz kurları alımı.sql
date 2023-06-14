CREATE PROCEDURE sp_GetMBCurrEx
	@DATE DATETIME=NULL
AS BEGIN

	SET NOCOUNT ON

	IF @DATE IS NULL SET @DATE=CONVERT(DATE, GETDATE())
	DECLARE @url as nvarchar(1000)

	if @DATE=CONVERT(DATE, GETDATE())
		set @url='http://www.tcmb.gov.tr/kurlar/today.xml'
    else
		set @url='http://www.tcmb.gov.tr/kurlar/'+FORMAT(@DATE, 'yyyyMM')+'/'+FORMAT(@DATE, 'ddMMyyyy')+'.xml'

	--print @url
	DECLARE @status int
	DECLARE @responseText as table(responseText XML)
	DECLARE @res as Int;

	EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @res OUT
	EXEC sp_OAMethod @res, 'open', NULL, 'GET', @url, 'false'
	EXEC sp_OAMethod @res, 'send'
	EXEC sp_OAGetProperty @res, 'status', @status OUT
	
	INSERT INTO @ResponseText(ResponseText)

	EXEC sp_OAGetProperty @res, 'responseXML.xml'
	EXEC sp_OADestroy @res

	DECLARE @XML XML, @TEXT NVARCHAR(MAX)
	SELECT @XML=responseText FROM @ResponseText
	DECLARE @Obj int
	SELECT @XML=responseText FROM @responseText
	EXEC sp_xml_preparedocument @Obj OUTPUT, @XML;

	IF OBJECT_ID('TEMPDB..#TMPCURR') IS NOT NULL DROP TABLE #TMPCURR
	
	SELECT * INTO #TMPCURR
	FROM OPENXML(@Obj, N'//Tarih_Date/Currency')
		WITH(Tarihi smalldatetime '../@Date', CurrencyCode VARCHAR(10) '@CurrencyCode', 
		CrossOrder VARCHAR(10) '@CrossOrder', Unit VARCHAR(100) 'Unit', Isim VARCHAR(100) 'Isim', 
		Alis VARCHAR(100) 'ForexBuying', Satis VARCHAR(100) 'ForexSelling', EfAlis VARCHAR(100) 'BanknoteBuying', 
		EfSatis VARCHAR(100) 'BanknoteSelling') AS TCMB

	exec sp_xml_removedocument @Obj;

	SELECT * FROM #TMPCURR

	DROP TABLE #TMPCURR

END
