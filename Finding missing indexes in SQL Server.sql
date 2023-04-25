-- Create script
SELECT TOP 25 dm_mid.database_id AS DatabaseID, dm_migs.avg_user_impact * (dm_migs.user_seeks + dm_migs.user_scans) Avg_Estimated_Impact,
dm_migs.last_user_seek AS Last_User_Seek, OBJECT_NAME(dm_mid.object_id, dm_mid.database_id) AS [TableName], 
'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.object_id, dm_mid.database_id) + '_' + REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns, ''), ', ', '_'), '[', ''), ']', '') +
	(CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN '_' ELSE '' END)
	+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns, ''), ', ', '_'), '[', ''), ']', '') 
	+ ']' + ' ON ' + dm_mid.statement + ' (' + ISNULL(dm_mid.equality_columns, '') 
	+ (CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN ',' ELSE ''	END)
	+ ISNULL(dm_mid.inequality_columns, '') + ')' + ISNULL(' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement
FROM sys.dm_db_missing_index_groups dm_mig
INNER JOIN sys.dm_db_missing_index_group_stats dm_migs ON dm_migs.group_handle = dm_mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details dm_mid ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_id = db_id()
ORDER BY Avg_Estimated_Impact DESC;

-- Another list
select TOP 25 DB_NAME(id.database_id) as databaseName, id.statement as TableName, id.equality_columns, id.inequality_columns,
 id.included_columns, gs.last_user_seek, gs.user_seeks, gs.last_user_scan, gs.user_scans,
 gs.avg_total_user_cost * gs.avg_user_impact * (gs.user_seeks + gs.user_scans) as ImprovementValue
from sys.dm_db_missing_index_group_stats gs
INNER JOIN sys.dm_db_missing_index_groups ig on gs.group_handle = ig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details id on id.index_handle = ig.index_handle
order by avg_total_user_cost * avg_user_impact * (user_seeks + user_scans) desc;