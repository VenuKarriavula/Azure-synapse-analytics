CREATE MASTER KEY ENCRYPTION BY PASSWORD ='<YOUR_STRONG_MASTER_KEY_PASSWORD>'
----------------------------
--Create Credential
------------------------------

CREATE DATABASE SCOPED CREDENTIAL vkcreds
WITH IDENTITY = 'Managed Identity'


----------------------------
--Create Ext Data Source
------------------------------
CREATE EXTERNAL DATA SOURCE raw_ext_source
WITH
(
    LOCATION = 'https://vkdatalake.dfs.core.windows.net/raw',
    CREDENTIAL = vkcreds
)

--Create Ext File Format
------------------------------
CREATE EXTERNAL FILE FORMAT parquet_format
WITH (
    FORMAT_TYPE = parquet,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
)