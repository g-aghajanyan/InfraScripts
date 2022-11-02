-- ENABLE EKM provider in SQL --
-- Enable advanced options.  
USE master;  
GO

sp_configure 'show advanced options', 1;  
GO
RECONFIGURE;  
GO

-- Enable EKM provider  
sp_configure 'EKM provider enabled', 1;  
GO
RECONFIGURE;

-- Create connector to EKM --
CREATE CRYPTOGRAPHIC PROVIDER Key_Vault   
FROM FILE = 'C:\Program Files\SQL Server Connector for Microsoft Azure Key Vault\Microsoft.AzureKeyVaultService.EKM.dll';  
GO

-- Create permission to vault --
USE master;
CREATE CREDENTIAL sysadmin_ekm_cred   
    WITH IDENTITY = 'NAME OF KEY VAULT', -- for public Azure
    SECRET = 'Enterprise App + App secret key (Remove spaces and hyphens)'   
FOR CRYPTOGRAPHIC PROVIDER Vault;

-- create another one for tde_login
USE master;
CREATE CREDENTIAL tdelogin_ekm_cred   
    WITH IDENTITY = 'NAME OF KEY VAULT', -- for public Azure
    SECRET = 'Enterprise App + App secret key (Remove spaces and hyphens)'   
FOR CRYPTOGRAPHIC PROVIDER Praemium_Key_Vault;

-- Add the credential to the SQL Server administrator's domain login   
ALTER LOGIN [admin account]  
ADD CREDENTIAL sysadmin_ekm_cred;

-- create key -- 
CREATE ASYMMETRIC KEY SQL_Key       
FROM PROVIDER [Key_Vault]  
WITH PROVIDER_KEY_NAME = 'SQL-Encryption',  
CREATION_DISPOSITION = OPEN_EXISTING;
-- use this if you get error message 2058 https://www.visualstudiogeeks.com/devops/SqlServerKeyVaultConnectorProviderError2058RegistryConsultEKMProvider --

USE master;
-- Create a SQL Server login associated with the asymmetric key   
-- for the Database engine to use when it loads a database   
-- encrypted by TDE.  
CREATE LOGIN TDE_Login   
FROM ASYMMETRIC KEY SQL_Key;  
GO

-- Alter the TDE Login to add the credential for use by the   
-- Database Engine to access the key vault  
ALTER LOGIN TDE_Login   
ADD CREDENTIAL tdelogin_ekm_cred ;  
GO