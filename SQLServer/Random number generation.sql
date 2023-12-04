-- Random number
SELECT FLOOR(RAND() * 1000);

-- Random number for each row 
-- Source => https://stackoverflow.com/questions/1045138/how-do-i-generate-a-random-number-for-each-row-in-a-t-sql-select
select ABS(CHECKSUM(NewId())) % 14;
