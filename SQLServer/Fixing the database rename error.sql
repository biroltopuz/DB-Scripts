use master
ALTER DATABASE [DATABASE_NAME] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE [DATABASE_NAME] MODIFY NAME = [NEW_DATABASE_NAME]
ALTER DATABASE [NEW_DATABASE_NAME] SET MULTI_USER