SELECT object_name(si.[object_id]) AS [TableName], 
(CASE WHEN si.[stats_id] = 0 then 'Heap'
WHEN si.[stats_id] = 1 then 'CL'
WHEN INDEXPROPERTY ( si.[object_id], si.[name], 'IsAutoStatistics') = 1 THEN 'Stats-Auto'
WHEN INDEXPROPERTY ( si.[object_id], si.[name], 'IsHypothetical') = 1 THEN 'Stats-HIND'
WHEN INDEXPROPERTY ( si.[object_id], si.[name], 'IsStatistics') = 1 THEN 'Stats-User'
WHEN si.[stats_id] BETWEEN 2 AND 1004 THEN 'NC ' + RIGHT('00' + convert(varchar, si.[stats_id]), 3)
ELSE 'Text/Image' END) AS [IndexType], 
si.[name] AS [IndexName], si.[stats_id] AS [IndexID], 
(CASE WHEN si.[stats_id] BETWEEN 1 AND 250 AND STATS_DATE (si.[object_id], si.[stats_id]) < DATEADD(m, -1, getdate()) 
THEN '!! More than a month OLD !!'
WHEN si.[stats_id] BETWEEN 1 AND 250 AND STATS_DATE (si.[object_id], si.[stats_id]) < DATEADD(wk, -1, getdate()) 
THEN '! Within the past month !'
WHEN si.[stats_id] BETWEEN 1 AND 250 THEN 'Stats recent'
ELSE '' END) AS [Warning], 
STATS_DATE (si.[object_id], si.[stats_id]) AS [Last Stats Update], no_recompute
FROM sys.stats AS si
WHERE OBJECTPROPERTY(si.[object_id], 'IsUserTable') = 1 and STATS_DATE (si.[object_id], si.[stats_id]) is not null
	AND ( INDEXPROPERTY ( si.[object_id], si.[name], 'IsAutoStatistics') = 1 
	OR INDEXPROPERTY ( si.[object_id], si.[name], 'IsHypothetical') = 1 
	OR INDEXPROPERTY ( si.[object_id], si.[name], 'IsStatistics') = 1 )
ORDER BY [Last Stats Update] 

-- https://ittutorial.org/sql-server-dba-scripts-all-in-one-useful-database-administration-scripts/
