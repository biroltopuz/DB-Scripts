USE AdventureWorks

-- SQL Server using forced index
SELECT ContactID FROM Person.Contact WITH (INDEX(AK_Contact_rowguid))

-- SQL Server using different index for different/same tables
SELECT c.ContactID FROM Person.Contact c WITH (INDEX(AK_Contact_rowguid))
INNER JOIN Person.Contact pc WITH (INDEX(PK_Contact_ContactID)) ON c.ContactID = pc.ContactID

-- https://blog.sqlauthority.com/2009/02/07/sql-server-introduction-to-force-index-query-hints-index-hint/
