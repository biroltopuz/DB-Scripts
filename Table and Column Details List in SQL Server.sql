SELECT t.name as 'Table Name', c.name as 'Column Name', ty.Name 'Data Type', c.max_length 'Max Length',
c.precision, c.scale, c.is_nullable, ISNULL(i.is_primary_key, 0) 'Primary Key', p.rows 'Row Count'
FROM sys.tables t
inner join sys.partitions p ON t.object_id = p.OBJECT_ID
inner join sys.columns c on c.object_id=t.object_id
inner join sys.types ty ON c.user_type_id = ty.user_type_id
left join sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
left join sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
-- WHERE p.rows>0 and t.name like 't%' -- Example of filtering by name and rows count
order by t.name, c.column_id