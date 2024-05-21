-- Ola Hallengren
EXECUTE dbo.IndexOptimize 
@Databases = 'USER_DATABASES',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y',
@LogToTable = 'Y',
@lockTimeout = 30,
@TimeLimit = 21600 --6 hour


-- MygGeneral job
EXECUTE dbo.IndexOptimize
@Databases = 'USER_DATABASES',
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y',
@LogToTable = 'Y',
@TimeLimit = 21600 --6 hour


-- index maintenance
EXECUTE dbo.IndexOptimize
@Databases = 'ALL_DATABASES',
@DatabaseOrder = 'DATABASE_SIZE_ASC',
@DatabasesInParallel = 'Y',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 4,
@FragmentationLevel2 = 5,
@Indexes='ALL_INDEXES',
@LogToTable='Y',
@MaxDOP = 4,
@MinNumberOfPages = 20,
@WaitAtLowPriorityMaxDuration=5,
@WaitAtLowPriorityAbortAfterWait='SELF',
@lockTimeout = 30,
@LOBCompaction = 'Y'
@TimeLimit = 21600, --6 hour


-- Statistics maintenance
EXECUTE dbo.IndexOptimize
@Databases = 'ALL_DATABASES',
@DatabaseOrder = 'DATABASE_SIZE_ASC',
@DatabasesInParallel = 'Y',
@FragmentationLow = NULL,
@FragmentationMedium = NULL,
@FragmentationHigh = NULL,
@UpdateStatistics = 'ALL',
--@OnlyModifiedStatistics = 'Y',
@StatisticsModificationLevel = 2,
@StatisticsSample = 100,
@LogToTable='Y',
@MaxDOP = 4
@TimeLimit = 21600, --6 hour
