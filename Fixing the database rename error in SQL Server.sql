use master
ALTER DATABASE [YourDatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE [YourDatabaseName] MODIFY NAME = [YourDatabaseName_New]
ALTER DATABASE [YourDatabaseName_New] SET MULTI_USER