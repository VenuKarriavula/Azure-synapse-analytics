----------------------------
--CETAS
-----------------------------
CREATE EXTERNAL TABLE revenue_cetas
WITH(
    LOCATION = 'cetas_revenue',
    DATA_SOURCE = raw_ext_source,
    FILE_FORMAT = parquet_format

)
AS
SELECT * FROM OPENROWSET(
    BULK 'revenue',
    DATA_SOURCE = 'raw_ext_source',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    HEADER_ROW = True
) as query1