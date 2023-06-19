select text, 
SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(st.text)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2) + 1) AS statement_text,
* from sys.dm_exec_requests qs
cross apply sys.dm_exec_sql_text(sql_handle) st
cross apply sys.dm_exec_query_plan(plan_handle);

-- https://ittutorial.org/sql-server-dba-scripts-all-in-one-useful-database-administration-scripts/
