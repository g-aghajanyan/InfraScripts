-- DB Summery
SELECT      sys.databases.Name,  
            CONVERT(VARCHAR,SUM(size)*8/1024)+' MB' AS [Total disk space],
			sys.databases.database_id AS [DB ID],
			sys.databases.state_desc AS [State],
			sys.databases.create_date AS [Created],
			sys.databases.compatibility_level AS [Compatibility],
			sys.databases.recovery_model_desc AS [Recovery Type],
			sys.databases.user_access_desc AS [Access Mode]
FROM        sys.databases   
JOIN        sys.master_files  
ON          sys.databases.database_id=sys.master_files.database_id  
GROUP BY    sys.databases.database_id, sys.databases.name, sys.databases.state_desc, sys.databases.create_date, sys.databases.compatibility_level,
			sys.databases.recovery_model_desc, sys.databases.user_access_desc
ORDER BY    sys.databases.name

-- DB Master Files, Specify DB Name
SELECT    	sys.master_files.database_id AS [ID],
			sys.databases.Name AS [DB Name],
			sys.master_files.type_desc AS [Type], 
			CONVERT(VARCHAR,SUM(sys.master_files.size)*8/1024)+' MB' AS [File Name],
			sys.master_files.physical_name AS [File Path],
			sys.master_files.name AS [File Name],
			sys.master_files.state_desc AS [State]
FROM        sys.databases
JOIN        sys.master_files  
ON          sys.databases.database_id=sys.master_files.database_id  
-- WHERE		sys.databases.Name = '***'
GROUP BY    sys.master_files.database_id, sys.databases.name, sys.master_files.name, sys.master_files.type_desc, sys.master_files.physical_name,
			sys.master_files.size, sys.master_files.state_desc
ORDER BY    sys.master_files.database_id


-- Move Files to new location 

-- ALTER DATABASE dbname   
--     MODIFY FILE ( NAME = filename,   
--                   FILENAME = 'E:\New_location\fn.mdf');  
-- GO