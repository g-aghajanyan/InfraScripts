SELECT session_id as SPID, "status", is_resumable AS Resumable, command, a.text AS Query,  percent_complete, start_time, 
	dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time, blocking_session_id AS "block",
	wait_type, wait_time, wait_time/1000 as WaitTime, last_wait_type
FROM sys.dm_exec_requests r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a 
WHERE r.command in ('BACKUP DATABASE','RESTORE DATABASE')


-- select * from sys.dm_exec_requests where session_id > 50 and session_id <> @@SPID