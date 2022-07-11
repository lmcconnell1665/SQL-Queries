declare @tables nvarchar(max) = ''
declare @views nvarchar(max) = ''
declare @functions nvarchar(max) = ''
declare @stored_procs nvarchar(max) = ''

drop table if exists #all_objects

SELECT name AS object_name   
,SCHEMA_NAME(schema_id) AS schema_name  
,type_desc  
,create_date  
,modify_date  
INTO #all_objects
FROM sys.objects  
WHERE SCHEMA_NAME(schema_id) not in ('sys', 'dbo')
AND type_desc in ('SQL_SCALAR_FUNCTION', 'SQL_STORED_PROCEDURE', 'SQL_TABLE_VALUED_FUNCTION', 'USER_TABLE', 'VIEW')

select @tables = @tables + 'drop table ' + o.object_name + ';'
from #all_objects o
where type_desc = 'USER_TABLE'

select @views = @views + 'drop view ' + o.object_name + ';'
from #all_objects o
where type_desc = 'VIEW'

select @functions = @functions + 'drop function ' + o.object_name + ';'
from #all_objects o
where type_desc in ('SQL_SCALAR_FUNCTION', 'SQL_TABLE_VALUED_FUNCTION')

select @stored_procs = @stored_procs + 'drop stored procedure ' + o.object_name + ';'
from #all_objects o
where type_desc = 'SQL_STORED_PROCEDURE'

select @tables
select @views
select @functions
select @stored_procs

-- only when ready
-- EXEC sp_executesql @tables;
-- EXEC sp_executesql @views;
-- EXEC sp_executesql @functions;
-- EXEC sp_executesql @stored_procs;
