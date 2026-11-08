# Azure Synapse Analytics

## 1. Azure Synapse Analytics

Azure Synapse Analytics is a service for data integration, data processing, and data warehousing. It brings these capabilities into a workspace where data can be collected, transformed, and queried for analysis.

The main components covered in the tutorial are:

- **Synapse pipelines:** move data between systems and run processing activities in a defined sequence.
- **Apache Spark pools:** process and transform data using Spark applications and notebooks.
- **SQL pools:** run SQL queries for data exploration and warehouse workloads.

A data warehouse stores data organized for reporting and analysis. This project focuses on the SQL features used to query data in storage and load it into warehouse tables.

## 2. Azure Synapse SQL pools

Synapse SQL is a distributed query engine. It divides query processing into tasks that can run across multiple compute resources. This allows different parts of a query to be processed at the same time.

A SQL pool provides the compute used to run these queries. Synapse supports two types: **dedicated SQL pools** and **serverless SQL pools**. Their main differences are how compute is managed and how data is stored and accessed.

## 3. Synapse SQL architecture

Synapse separates compute from storage. Compute performs query processing, while storage holds the data. This separation allows processing capacity to change independently of stored data.

![Synapse SQL architecture showing dedicated and serverless SQL pools](docs/images/sql-architecture.png)

*Source: [Microsoft Learn - Synapse SQL architecture](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/overview-architecture).*

### Control node

The control node receives SQL queries from users or applications. It prepares a distributed execution plan and coordinates the work assigned to compute nodes.

### Compute nodes

Compute nodes execute the assigned tasks and process the required data. Running tasks at the same time is called parallel processing. Dedicated SQL pools use a **Massively Parallel Processing (MPP)** architecture.

### Data Movement Service

**Data Movement Service (DMS)** moves data between compute nodes in a dedicated pool when a query requires it, such as during certain joins and aggregations.

A dedicated pool has **60 distributions**, which are units of data storage and processing. Each compute node can handle one or more distributions. The number of compute nodes depends on the pool's service level. [Architecture reference](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/overview-architecture).

## 4. Dedicated SQL pool and serverless SQL pool

### Dedicated SQL pool

A dedicated SQL pool supports tables that store data inside the warehouse. Data is loaded into these tables before it is queried. It also supports external tables that reference files in storage.

The pool has provisioned compute capacity. Its performance level is expressed in **Data Warehouse Units (DWUs)**. Compute can be scaled, paused, and resumed. Pausing stops compute charges, while storage charges continue. [Pause and resume guidance](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/pause-and-resume-compute-portal).

### Serverless SQL pool

A serverless SQL pool queries files directly in Azure Storage. Azure manages the compute needed for query execution. The workspace provides a serverless SQL endpoint named **Built-in**.

In this project, serverless SQL reads CSV files, creates external tables and views, and exports query results as Parquet. The data remains in the lake, while the database stores the SQL object definitions.

| Feature used in this project | Dedicated SQL pool | Serverless SQL pool |
| --- | --- | --- |
| Store rows in internal warehouse tables | Yes | No |
| Query external files through external tables | Yes | Yes |
| Query files using `OPENROWSET` | No | Yes |
| Choose and manage provisioned compute capacity | Yes | Azure manages compute |

## 5. Apache Spark pools

Apache Spark is a distributed data-processing engine. A Synapse Spark pool provides resources for running Spark applications, including data preparation and transformation code.

The **driver** coordinates the application. **Executors** run tasks on worker nodes. Synapse uses YARN to manage resource allocation. When autoscaling is enabled, the pool can adjust its number of nodes within the configured limits.

Spark code can be written in notebooks using languages such as PySpark and Spark SQL. A notebook contains executable code cells and displays their results. Spark is included here as background to the Synapse platform; the exercises focus on dedicated and serverless SQL pools. [Apache Spark overview](https://learn.microsoft.com/en-us/azure/synapse-analytics/spark/apache-spark-overview).

## 6. Azure Data Lake Storage Gen2

Azure Data Lake Storage Gen2, or **ADLS Gen2**, provides storage for files used in analytics. A storage account with **hierarchical namespace** enabled supports directories and file operations needed for this structure.

Files are organized under containers and directories. The SQL scripts use the storage account `vkdatalake`, the container `raw`, and the input directory `revenue`.

The input is a **CSV**, a text file in which values are separated by commas. Its first row contains the column names. A separate directory, `cetas_revenue`, is used later for the Parquet export.

## 7. Creating the Synapse workspace

A Synapse workspace brings together the SQL pools, scripts, pipelines, and connections. The workspace creation form asks for a resource group, a managed resource group, and a default ADLS Gen2 account. These settings serve different purposes.

### Resource group and managed resource group

The **resource group** is where the Synapse workspace is created. It groups Azure resources that we manage as part of the project. In this setup, the workspace `vksynapse` is created in `VK-Synapse`.

The **managed resource group** holds supporting resources that Synapse manages for the workspace. Azure creates this group automatically, and its name can be specified during workspace creation. It must be separate from the resource group containing the workspace. In the screenshot, this name is left blank so Azure can assign it. [Managed resource group documentation](https://learn.microsoft.com/en-us/powershell/module/az.synapse/new-azsynapseworkspace#-managedresourcegroupname).

The two groups separate project resources from service-managed supporting resources. They are not separate groups for dedicated and serverless SQL pools.

![Workspace creation showing the resource group, workspace name, and region](docs/images/workspace-basics.png)

*The resource group is selected, and the optional managed resource group name is left blank.*

### Default storage account and external storage account

A workspace requires a **default ADLS Gen2 storage account and file system**. The file system is a container within that account. The default account stores workspace data such as Spark table data and Spark application logs. This setup uses `managevksynapse` with the file system `managesynapsefile`. [Default workspace storage](https://learn.microsoft.com/en-us/azure/synapse-analytics/quickstart-create-workspace).

![Default ADLS Gen2 account and file system selected for the workspace](docs/images/workspace-storage.png)

*The default account and file system selected during workspace creation.*

The **external storage account**, `vkdatalake`, holds the data used by the SQL exercises. Its `raw` container contains the input CSV under `revenue` and the exported Parquet under `cetas_revenue`.

| Storage account | Purpose in this setup |
| --- | --- |
| `managevksynapse` | Default storage selected for the workspace |
| `vkdatalake` | Separate lake containing the revenue input and exported files |

Using two storage accounts is a project choice. The separate account lets us practice granting the workspace identity access and configuring SQL to read external data. Synapse can also use files in its default storage account; a second account is not required for every workspace. [Workspace storage setup and sample data](https://learn.microsoft.com/en-us/azure/synapse-analytics/get-started-create-workspace).

The resource groups organize Azure resources, while the storage accounts hold files. The managed resource group and default storage account are separate settings. The `manage` prefix in the storage account's name is simply part of the chosen name.

## 8. Synapse Studio and data integration

**Synapse Studio** is the interface used to develop and run work inside the workspace.

- **Data** shows databases and linked storage.
- **Develop** contains SQL scripts and notebooks.
- **Integrate** contains pipelines used to move and process data.
- **Monitor** shows execution activity.
- **Manage** contains pool, connection, and workspace settings.

Synapse pipelines use data integration capabilities based on Azure Data Factory. A pipeline can combine activities such as copying data and running processing steps. The files in this repository cover SQL exercises; pipeline definitions are not included.

## 9. Distributed tables

A distributed table appears as one table when queried, but its rows are stored according to a distribution strategy. The strategy affects load performance and the movement of data during queries.

### Hash distribution

Hash distribution uses a function on a selected column to assign rows to distributions. Equal values in that column go to the same distribution. It is useful for large tables when the selected column supports frequent joins and distributes rows evenly.

The example `gold.facttable` uses `HASH(dim_key_prod)`. A poorly chosen key can cause **data skew**, where some distributions hold much more data than others.

### Round-robin distribution

Round-robin spreads rows across distributions without grouping matching values. It is useful for staging tables, where data is first loaded before further processing. The example is `round_table`.

### Replicated tables

A replicated table keeps a copy on each compute node. This can reduce data movement when a small table is joined to a larger table. The example is `gold.dim_product`.

A **dimension table** describes entities such as products. A **fact table** stores events and measurements such as sales and revenue. [Distribution guidance](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-tables-distribute).

## 10. Creating the dedicated pool and example tables

Create a dedicated SQL pool from the workspace's SQL pool settings, select a performance level, and wait for provisioning to finish. Connect the script to that pool's database before running the table statements.

Script: [distributed tables.sql](sql/distributed%20tables.sql)

The script creates `round_table`, inserts one sample row, and creates `gold.dim_product` and `gold.facttable`. The last two tables demonstrate their definitions without loading a complete dataset.

A **schema** groups objects within a database. In `gold.facttable`, `gold` is the schema name and `facttable` is the table name.

The dedicated pool can be paused while completing the serverless exercises and resumed for the loading steps.

## 11. Serverless SQL and the logical data warehouse

A **logical data warehouse** exposes data through SQL while the underlying data stays in external storage. Serverless SQL supports this approach through file queries, external tables, and views.

The database stores **metadata**, meaning information that describes the data. This includes table names, column names, data types, and storage locations.

### Managed and external tables

In Spark, a managed table's storage is managed with the table, and dropping it removes its data. An external table references separately managed files; dropping its definition leaves those files in place. The serverless exercises here use external tables. [Spark table deletion behavior](https://spark.apache.org/docs/latest/sql-ref-syntax-ddl-drop-table.html).

## 12. Managed identity and storage permissions

A **managed identity** lets an Azure resource authenticate to another service without storing a password or access key in application code. This project uses the Synapse workspace's system-assigned managed identity to access the external lake.

On the external storage account, use **Access control (IAM)** to assign **Storage Blob Data Contributor** to the workspace identity. This role provides the read and write access needed for these exercises. Storage network rules must also permit the connection.

The role assignment gives the identity permission to access storage. The SQL credential configured later tells SQL to use that identity. [Storage access control](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-storage-files-storage-access-control).

## 13. Uploading the data and selecting the serverless database

Upload the revenue CSV into the `revenue` directory under the `raw` container:

```text
vkdatalake/
  raw/
    revenue/
      <revenue-file>.csv
```

The scripts work with these fields:

| Column | Data represented |
| --- | --- |
| `Dealer_ID` | Dealer identifier |
| `Model_ID` | Model identifier |
| `Branch_ID` | Branch identifier |
| `Date_ID` | Date identifier |
| `Units_Sold` | Units sold |
| `Revenue` | Revenue amount |

The source file is not included in the repository. Check its header, column order, delimiter, and values against the script definitions.

Create a user database on the **Built-in** serverless SQL pool. Select this database when running the serverless scripts. Database objects such as credentials and external tables must be created in the intended database rather than accidentally running the statements in `master`.

## 14. Database master key and database scoped credential

Script: setup statements in [openrowset.sql](sql/openrowset.sql).

### Database master key

A database master key is an encryption key used to protect database secrets, including secrets stored in database scoped credentials. The scripts create it once in each database used for the exercises.

Replace `<YOUR_STRONG_MASTER_KEY_PASSWORD>` privately before running the statement. Keep the real password out of the repository. [CREATE MASTER KEY](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-master-key-transact-sql?view=sql-server-ver17).

### Database scoped credential

A database scoped credential specifies how the database authenticates when accessing an external resource. The credential in this project is `vkcreds`:

```sql
CREATE DATABASE SCOPED CREDENTIAL vkcreds
WITH IDENTITY = 'Managed Identity';
```

This selects managed identity authentication. No storage password or access key is supplied in this credential. It belongs to the database where it is created, so the dedicated database needs its own setup later. [CREATE DATABASE SCOPED CREDENTIAL](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-scoped-credential-transact-sql?view=sql-server-ver17).

## 15. External data source and linked service

An **external data source** is a SQL object that defines a storage location and the credential used to access it. The serverless scripts create `raw_ext_source` pointing to:

```text
https://vkdatalake.dfs.core.windows.net/raw
```

The location ends at the container. Individual queries supply a path such as `revenue`, allowing the same data source to be used for different directories under `raw`. [CREATE EXTERNAL DATA SOURCE](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-external-data-source-transact-sql?view=sql-server-ver17&tabs=dedicated).

A **linked service** stores connection settings for Synapse Studio and data integration activities. An ADLS Gen2 linked service makes the external account available for browsing in Studio. It is configured separately from the SQL external data source.

## 16. OPENROWSET

Script: [openrowset.sql](sql/openrowset.sql).

`OPENROWSET` reads external files and returns their contents as rows for a SQL query. A persistent table does not need to be created first.

```sql
SELECT *
FROM OPENROWSET(
    BULK 'revenue',
    DATA_SOURCE = 'raw_ext_source',
    FORMAT = 'CSV',
    PARSER_VERSION = '2.0',
    HEADER_ROW = TRUE
) AS query1;
```

The query uses these settings:

- `BULK` supplies the file or directory path relative to the data source.
- `DATA_SOURCE` selects the external data source.
- `FORMAT` identifies the input as CSV.
- `PARSER_VERSION` selects the CSV reader version.
- `HEADER_ROW` uses the header for column names.
- `query1` is the required alias for the returned rows.

`SELECT *` returns all columns. Adjust the path to the actual file layout, such as `revenue/*.csv` when appropriate. This file-querying function is supported in serverless SQL, not dedicated SQL pools. [Serverless OPENROWSET documentation](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-openrowset).

## 17. External file formats

An **external file format** defines how external data is read or written. The format definitions are created in [openrowset.sql](sql/openrowset.sql).

`csv_format` uses `DELIMITEDTEXT`, a comma as the field separator, and `FIRST_ROW = 2` to skip the header. These settings must match the input file. An incorrect separator can cause a whole line to be read into one column.

`parquet_format` uses Parquet with Snappy compression. **Parquet** stores data by column and is commonly used for analytical workloads. This format is used for the CETAS output and the later loading exercises. [CREATE EXTERNAL FILE FORMAT](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-external-file-format-transact-sql?view=sql-server-ver17&tabs=parquet).

## 18. External tables in serverless SQL

Script: [Create_Ext_Tables.sql](sql/Create_Ext_Tables.sql).

An external table defines columns over files at a specified location. Its definition includes the column names and data types, location, external data source, and external file format.

The script creates `revenue_ext_Table` over the CSV files in `revenue`. Create `raw_ext_source` and `csv_format` before running this statement.

```sql
SELECT TOP (10) * FROM revenue_ext_Table;
```

The query returns up to ten rows from the files. Creating the external table registers the definition; it does not copy the data into an internal warehouse table. Dropping it leaves the source files in storage. [External table documentation](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-external-tables).

This script defines all columns as `VARCHAR(4000)`, a variable-length text type. Numeric calculations require appropriate numeric types or conversion from text. Check the column order against the CSV, especially `Model_ID` and `Branch_ID`.

## 19. CETAS: Create External Table As Select

Script: [CETAS.sql](sql/CETAS.sql).

**CETAS** exports the result of a `SELECT` query to files and creates an external table over the output. In this project, it reads the revenue CSV with `OPENROWSET`, writes the result as Parquet, and creates `revenue_cetas`.

```text
Input:          raw/revenue/          CSV files
Query:          OPENROWSET
Output:         raw/cetas_revenue/    Parquet files
External table: revenue_cetas
```

The query determines the output columns and types. Because the script selects all input columns without transformations, it preserves the selected values while changing their file format.

Check the generated files and query the table after execution:

```sql
SELECT TOP (10) * FROM revenue_cetas;
```

CETAS requires permission to write to the output location. Use a fresh location for another export. Dropping the external table does not delete the generated files. [CETAS documentation](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-cetas).

## 20. Views in serverless SQL

Script: [Views.sql](sql/Views.sql).

A **view** stores a SQL query definition under a name. The `revenue_view` definition contains the `OPENROWSET` query over the original CSV.

```sql
SELECT TOP (10) * FROM revenue_view;
```

Querying the view runs its stored query against the source data. A regular view does not store a separate copy of the result. In contrast, `revenue_cetas` reads the Parquet output produced by the earlier export. Changes to the original CSV do not automatically refresh that exported data.

Run the view creation statement as a separate batch, followed by the verification queries. The final query in `Views.sql` reads `revenue_cetas`, so it depends on the CETAS exercise.

### External tables and missing files

The tutorial also shows that an external-table definition can exist while its referenced path has no readable data. Creating the definition alone does not confirm that the files exist or that access is configured correctly. Run a query to validate the path, permissions, and file schema. [External table documentation](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-external-tables).

## 21. Loading data into a dedicated SQL pool

The Parquet output is used as input for two loading methods: `COPY INTO` and an external-table query followed by `CTAS`.

Resume the dedicated pool and select its database. The required database objects must be created there because the serverless database's objects are separate.

Script: [External_Res.sql](sql/External_Res.sql).

This file contains the master key, `vkcreds`, an HTTPS external data source, and `parquet_format`. The later external-table exercise uses a separate ABFSS data source defined in `Polybase_CTAS.sql`.

### COPY INTO

Script: [copyinto.sql](sql/copyinto.sql).

`COPY INTO` loads rows from external files into an existing dedicated table. The script creates `copy_into_table` with round-robin distribution and loads Parquet files from `raw/cetas_revenue` using managed identity.

The column mapping identifies which input field supplies each target column. For example, `Model_ID 3` maps the third field in the file to `Model_ID`. The current script maps `Branch_ID` to field 2. Confirm that these positions match the actual Parquet file. [COPY INTO documentation](https://learn.microsoft.com/en-us/sql/t-sql/statements/copy-into-transact-sql?view=azure-sqldw-latest).

The opening `DROP TABLE` is a reset statement. Skip it on the first run if the table does not exist. Use it later only when removing the old practice table is intended.

The file's `SELECT` appears before the load. Run it again after `COPY INTO` to inspect the loaded rows. Repeating the load against a populated table can add duplicate records.

### PolyBase approach with CTAS

Script: [Polybase_CTAS.sql](sql/Polybase_CTAS.sql).

This method creates an external table over the Parquet files, then loads its query result into a new dedicated table using **Create Table As Select (CTAS)**.

```sql
CREATE TABLE poly_table
WITH (DISTRIBUTION = ROUND_ROBIN)
AS
SELECT * FROM Parquet_Table;
```

The statement creates `poly_table` and stores the selected rows in it. The tutorial describes this external-data loading approach as PolyBase. CTAS is the table-creation statement and can also be used with internal source tables. [CTAS documentation](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-develop-ctas).

## References

The following official documentation supports the concepts and SQL syntax used in this project.

### Documentation used alongside the tutorial

- [Synapse SQL architecture](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/overview-architecture)
- [Apache Spark in Azure Synapse Analytics](https://learn.microsoft.com/en-us/azure/synapse-analytics/spark/apache-spark-overview)
- [Guidance for designing distributed tables](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-tables-distribute)
- [CREATE DATABASE SCOPED CREDENTIAL](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-scoped-credential-transact-sql?view=sql-server-ver17)
- [CREATE MASTER KEY](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-master-key-transact-sql?view=sql-server-ver17)
- [CREATE EXTERNAL DATA SOURCE](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-external-data-source-transact-sql?view=sql-server-ver17&tabs=dedicated)
- [OPENROWSET — general SQL Server reference](https://learn.microsoft.com/en-us/sql/t-sql/functions/openrowset-transact-sql?view=sql-server-ver17)
- [CREATE EXTERNAL FILE FORMAT](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-external-file-format-transact-sql?view=sql-server-ver17&tabs=parquet)

### Additional references for running the examples

- [Synapse managed resource group](https://learn.microsoft.com/en-us/powershell/module/az.synapse/new-azsynapseworkspace#-managedresourcegroupname)
- [Workspace settings and default storage](https://learn.microsoft.com/en-us/azure/synapse-analytics/get-started-create-workspace)
- [Managed and external table deletion in Spark](https://spark.apache.org/docs/latest/sql-ref-syntax-ddl-drop-table.html)
- [Create a Synapse workspace](https://learn.microsoft.com/en-us/azure/synapse-analytics/quickstart-create-workspace)
- [Storage access control for serverless SQL](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-storage-files-storage-access-control)
- [OPENROWSET in Synapse serverless SQL](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-openrowset)
- [External tables in Synapse SQL](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-external-tables)
- [CETAS in Synapse SQL](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql/develop-tables-cetas)
- [CTAS in dedicated SQL pool](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-develop-ctas)
- [COPY INTO in Azure Synapse Analytics](https://learn.microsoft.com/en-us/sql/t-sql/statements/copy-into-transact-sql?view=azure-sqldw-latest)
- [Pause and resume dedicated compute](https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/pause-and-resume-compute-portal)