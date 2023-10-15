SELECT active.name as table_name, active.rows, archive.Rows_old FROM (
	SELECT distinct t.name, p.[Rows] FROM sys.tables t
	INNER JOIN sys.partitions p ON t.object_id = p.OBJECT_ID
)active INNER JOIN (
	SELECT DISTINCT t.name as name, p.[Rows] as Rows_old FROM [OTHER_DB_NAME].sys.tables t
	INNER JOIN [OTHER_DB_NAME].sys.partitions p ON t.object_id = p.OBJECT_ID
)archive ON RTRIM(active.name)=RTRIM(archive.name)
WHERE active.rows=0 and archive.rows_old>0
order by active.name