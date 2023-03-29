SELECT t.name 'Table Name', c.name 'Column Name', ty.Name 'Data Type', c.max_length 'Max Length',
c.precision, c.scale, c.is_nullable, ISNULL(i.is_primary_key, 0) 'Primary Key', p.rows 'Row Count'
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.OBJECT_ID
INNER JOIN sys.columns c ON c.object_id = t.object_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
LEFT JOIN sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
-- WHERE p.rows > 0 AND t.name like 't%' -- Example of filtering by name and rows count
ORDER BY t.name, c.column_id