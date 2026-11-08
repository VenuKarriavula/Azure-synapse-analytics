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

-----------------------------
--Create Ext File Format
------------------------------
CREATE EXTERNAL FILE FORMAT csv_format
WITH (
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS (
        FIELD_TERMINATOR = ',',
        FIRST_ROW = 2
    )
);


----------------------------
--OPENROWSET Function
------------------------------
SELECT * FROM OPENROWSET(
    BULK 'revenue',
    DATA_SOURCE = 'raw_ext_source',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    HEADER_ROW = True
) as query1


--Create Ext File Format
------------------------------
CREATE EXTERNAL FILE FORMAT parquet_format
WITH (
    FORMAT_TYPE = parquet,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
)