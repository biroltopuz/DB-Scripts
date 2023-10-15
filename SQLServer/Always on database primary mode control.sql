if (select sys.fn_hadr_is_primary_replica (DB_NAME())) in (1, null)
begin

    -- Your Command

end