CREATE EXTERNAL TABLE Parquet_Table
(
    Dealer_ID VARCHAR(4000),
    Model_ID VARCHAR(4000),
    Branch_ID VARCHAR(4000),
    Date_ID VARCHAR(4000),
    Units_Sold BIGINT,
    Revenue BIGINT
)
WITH
(
    LOCATION = '/cetas_revenue',
    DATA_SOURCE = raw_ext_source_abfss,
    FILE_FORMAT = PARQUET_format
)


----------------------------
--Create Ext Data Source abfss
------------------------------
CREATE EXTERNAL DATA SOURCE raw_ext_source_abfss
WITH
(
    LOCATION = 'abfss://raw@vkdatalake.dfs.core.windows.net',
    CREDENTIAL = vkcreds
)


--CTAS (PolyBase)
CREATE TABLE poly_table
WITH(
    DISTRIBUTION = ROUND_ROBIN
)
AS
Select * FROM Parquet_Table

SELECT * FROM poly_table