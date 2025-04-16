select * from
(
	SELECT name, is_disabled FROM sys.triggers
)active inner join (
	SELECT name, is_disabled FROM [OTHER_DB_NAME].sys.triggers
)archive on active.name=archive.name
where active.is_disabled<>archive.is_disabled
order by active.name