select wt.session_id, wt.exec_context_id, wt.wait_duration_ms, wt.wait_type, wt.blocking_session_id, wt.resource_address,
wt.resource_description, s.program_name, st.text, sp.query_plan, s.cpu_time cpu_time_ms, s.memory_usage*8 memory_usage_kb
from sys.dm_os_waiting_tasks wt
join sys.dm_exec_sessions s on s.session_id=wt.session_id
join sys.dm_exec_requests r on r.session_id=s.session_id
outer apply sys.dm_exec_sql_text(r.sql_handle) st
outer apply sys.dm_exec_query_plan(r.plan_handle) sp
where s.is_user_process=1
order by wt.session_id, wt.exec_context_id;


-- Wait events of database
SELECT getdate() as 'Run_Time' --script running time
, wait_type --wait type
, waiting_tasks_count
, CAST(wait_time_ms / 1000. AS DECIMAL(12, 2)) AS wait_time_s --saniye cinsinden bekleme zamani
, CAST(100. * wait_time_ms / SUM(wait_time_ms) OVER() AS DECIMAL(12, 2)) AS pct --toplam beklemeye orani
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ('BROKER_TASK_STOP','Total','SLEEP','BROKER_EVENTHANDLER','BROKER_RECEIVE_WAITFOR',
    'BROKER_TRANSMITTER','CHECKPOINT_QUEUE','CHKPT,CLR_AUTO_EVENT','CLR_MANUAL_EVENT','KSOURCE_WAKEUP','LAZYWRITER_SLEEP',
    'LOGMGR_QUEUE','ONDEMAND_TASK_QUEUE','REQUEST_FOR_DEADLOCK_SEARCH','RESOURCE_QUEUE','SERVER_IDLE_CHECK',
    'SLEEP_BPOOL_FLUSH','SLEEP_DBSTARTUP','SLEEP_DCOMSTARTUP','SLEEP_MSDBSTARTUP','SLEEP_SYSTEMTASK','SLEEP_TASK',
    'SLEEP_TEMPDBSTARTUP','SNI_HTTP_ACCEPT','SQLTRACE_BUFFER_FLUSH','TRACEWRITE','WAIT_FOR_RESULTS','WAITFOR_TASKSHUTDOWN',
    'XE_DISPATCHER_WAIT','XE_TIMER_EVENT','WAITFOR')
ORDER BY 4 DESC


-- Query 3
with waits as(
    select wait_type, wait_time_ms / 1000.0 as waits,
    (wait_time_ms - signal_wait_time_ms) / 1000.0 as resources,
    signal_wait_time_ms / 1000.0 as signals,
    waiting_tasks_count as waitcount,
    100.0 * wait_time_ms / sum (wait_time_ms) over() as percentage,
    row_number() over(order by wait_time_ms desc) as rownum
    from sys.dm_os_wait_stats
    where wait_type not in (N'CLR_SEMAPHORE', N'LAZYWRITER_SLEEP',
        N'RESOURCE_QUEUE', N'SQLTRACE_BUFFER_FLUSH',
        N'SLEEP_TASK', N'SLEEP_SYSTEMTASK',
        N'WAITFOR', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH',
        N'XE_TIMER_EVENT', N'XE_DISPATCHER_JOIN',
        N'LOGMGR_QUEUE', N'FT_IFTS_SCHEDULER_IDLE_WAIT',
        N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT',
        N'CLR_AUTO_EVENT', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'TRACEWRITE', N'XE_DISPATCHER_WAIT',
        N'BROKER_TO_FLUSH', N'BROKER_EVENTHANDLER',
        N'FT_IFTSHC_MUTEX', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'DIRTY_PAGE_POLL', N'SP_SERVER_DIAGNOSTICS_SLEEP')
)
select w1.wait_type as waittype, 
cast (w1.waits as decimal(14, 2)) wait_s,
cast (w1.resources as decimal(14, 2)) resource_s,
cast (w1.signals as decimal(14, 2)) signal_s,
w1.waitcount wait_count,
cast (w1.percentage as decimal(4, 2)) percentage,
cast ((w1.waits / w1.waitcount) as decimal (14, 4)) avgWait_s,
cast ((w1.resources / w1.waitcount) as decimal (14, 4)) avgResource_s,
cast ((w1.signals / w1.waitcount) as decimal (14, 4)) avgSignal_s
from waits as w1
inner join waits as w2 on w2.rownum <= w1.rownum
group by w1.rownum, w1.wait_type, w1.waits, w1.resources, w1.signals, w1.waitcount, w1.percentage
having sum (w2.percentage) - w1.percentage < 95; -- percentage threshold

-- https://ittutorial.org/sql-server-dba-scripts-all-in-one-useful-database-administration-scripts/
