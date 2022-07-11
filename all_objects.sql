-- returns all objects created on the databases (excluding sys objects)

SELECT name AS object_name   
  ,SCHEMA_NAME(schema_id) AS schema_name  
  ,type_desc  
  ,create_date  
  ,modify_date  
FROM sys.objects  
-- WHERE modify_date > GETDATE() - 70
WHERE SCHEMA_NAME(schema_id) not in ('sys', 'dbo')
AND type_desc in ('SQL_SCALAR_FUNCTION', 'SQL_STORED_PROCEDURE', 'SQL_TABLE_VALUED_FUNCTION', 'USER_TABLE', 'VIEW')
