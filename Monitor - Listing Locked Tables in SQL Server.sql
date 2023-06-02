SELECT STR(request_session_id, 4, 0) AS spid, CONVERT(VARCHAR(12), DB_NAME(resource_database_id)) AS db_name,
(CASE WHEN resource_database_id = DB_ID() AND resource_type = 'OBJECT' 
	THEN CONVERT(CHAR(20), OBJECT_NAME(resource_associated_entity_id)) 
	ELSE CONVERT(CHAR(20), resource_associated_entity_id) END) AS object,
CONVERT(VARCHAR(12), resource_type) AS resrc_type,
CONVERT(VARCHAR(12), request_type) AS req_type,
CONVERT(CHAR(1), request_mode) AS mode,
CONVERT(VARCHAR(8), request_status) AS status
FROM sys.dm_tran_locks
ORDER BY request_session_id, 3 DESC;