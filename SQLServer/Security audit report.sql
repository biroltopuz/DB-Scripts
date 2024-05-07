--List all access provisioned to a sql user or windows user/group directly 
SELECT (CASE princ.[type] WHEN 'S' THEN princ.[name] WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI END) AS [UserName],
(CASE princ.[type] WHEN 'S' THEN 'SQL User' WHEN 'U' THEN 'Windows User' END) AS [UserType], 
princ.[name] AS [DatabaseUserName], null AS [Role], perm.[permission_name] AS [PermissionType],
perm.[state_desc] AS [PermissionState], obj.type_desc AS [ObjectType],
OBJECT_NAME(perm.major_id) AS [ObjectName], col.[name] AS [ColumnName]
FROM sys.database_principals princ  
LEFT JOIN sys.login_token ulogin on princ.[sid] = ulogin.[sid]
LEFT JOIN sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
LEFT JOIN sys.columns col ON col.[object_id] = perm.major_id AND col.[column_id] = perm.[minor_id]
LEFT JOIN sys.objects obj ON perm.[major_id] = obj.[object_id]
WHERE princ.[type] in ('S', 'U')
UNION
--List all access provisioned to a sql user or windows user/group through a database or application role
SELECT (CASE memberprinc.[type] WHEN 'S' THEN memberprinc.[name] WHEN 'U' THEN ulogin.[name] COLLATE Latin1_General_CI_AI END) AS [UserName],
(CASE memberprinc.[type] WHEN 'S' THEN 'SQL User' WHEN 'U' THEN 'Windows User' END) AS [UserType], 
memberprinc.[name] AS [DatabaseUserName], roleprinc.[name] AS [Role], perm.[permission_name] AS [PermissionType],
perm.[state_desc] AS [PermissionState], obj.type_desc AS [ObjectType], OBJECT_NAME(perm.major_id) AS [ObjectName],
col.[name] AS [ColumnName]
FROM sys.database_role_members members
JOIN sys.database_principals roleprinc ON roleprinc.[principal_id] = members.[role_principal_id]
JOIN sys.database_principals memberprinc ON memberprinc.[principal_id] = members.[member_principal_id]
LEFT JOIN sys.login_token ulogin on memberprinc.[sid] = ulogin.[sid]
LEFT JOIN sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN sys.columns col on col.[object_id] = perm.major_id AND col.[column_id] = perm.[minor_id]
LEFT JOIN sys.objects obj ON perm.[major_id] = obj.[object_id]
UNION
--List all access provisioned to the public role, which everyone gets by default
SELECT '{All Users}' AS [UserName], '{All Users}' AS [UserType], '{All Users}' AS [DatabaseUserName],
roleprinc.[name] AS [Role], perm.[permission_name] AS [PermissionType], perm.[state_desc] AS [PermissionState],
obj.type_desc AS [ObjectType], OBJECT_NAME(perm.major_id) AS [ObjectName], col.[name] AS [ColumnName]
FROM sys.database_principals roleprinc
LEFT JOIN sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN sys.columns col on col.[object_id] = perm.major_id AND col.[column_id] = perm.[minor_id]                   
JOIN sys.objects obj ON obj.[object_id] = perm.[major_id]
WHERE roleprinc.[type] = 'R' AND roleprinc.[name] = 'public' AND obj.is_ms_shipped = 0
ORDER BY princ.[Name], OBJECT_NAME(perm.major_id), col.[name], perm.[permission_name], perm.[state_desc], obj.type_desc


-- user-based permission list as executable script
SELECT (
    dp.state_desc + ' ' +
    dp.permission_name collate latin1_general_cs_as + 
    ' ON ' + '[' + s.name + ']' + '.' + '[' + o.name + ']' +
    ' TO ' + '[' + dpr.name + ']'
) AS GRANT_STMT
FROM sys.database_permissions AS dp
INNER JOIN sys.objects AS o ON dp.major_id=o.object_id
INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id
INNER JOIN sys.database_principals AS dpr ON dp.grantee_principal_id=dpr.principal_id
WHERE dpr.name NOT IN ('public', 'guest')
    -- AND o.name IN ('My_Procedure')
    -- AND dp.permission_name='EXECUTE'
