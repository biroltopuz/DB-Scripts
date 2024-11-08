exec [dbo].[IndexOptimize]
@Databases = 'USER_DATABASES',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@UpdateStatistics='ALL', 
@OnlyModifiedStatistics='Y',
@WaitAtLowPriorityMaxDuration = 1,
@WaitAtLowPriorityAbortAfterWait = 'SELF',
@Resumable = 'Y',
@DatabaseOrder = 'DATABASE_SIZE_ASC',
@MSShippedObjects='Y', 
@LOBCompaction='Y',
@LogToTable ='Y',
@MaxDOP = 0,
@TimeLimit=25200 -- 7hour