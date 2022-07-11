/*********************/
/* report reader     */
/*********************/
-- run on master database
CREATE LOGIN di_report_reader WITH PASSWORD = 'myReallyStrongPassword' 

-- run on DW database
CREATE USER di_report_reader FROM LOGIN di_report_reader WITH DEFAULT_SCHEMA = dwv;
ALTER ROLE db_datareader ADD MEMBER di_report_reader

/*********************/
/* AD groups          */
/*********************/
-- FINANCE
USE [master];
CREATE USER [DAG - diexp finance] FROM EXTERNAL PROVIDER;

USE [DW];
CREATE USER [DAG - diexp finance] FROM EXTERNAL PROVIDER;
ALTER ROLE lbmc_finance ADD MEMBER [DAG - diexp finance]

-- HR
USE [master];
CREATE USER [DAG - diexp hr] FROM EXTERNAL PROVIDER;

USE [DW];
CREATE USER [DAG - diexp hr] FROM EXTERNAL PROVIDER;
ALTER ROLE lbmc_hr ADD MEMBER [DAG - diexp hr]

-- INTERNAL SYS
USE [master];
CREATE USER [DAG - diexp internal sys] FROM EXTERNAL PROVIDER;

USE [DW];
CREATE USER [DAG - diexp internal sys] FROM EXTERNAL PROVIDER;
ALTER ROLE lbmc_internal_sys ADD MEMBER [DAG - diexp internal sys]

-- AUDIT
USE [master];
CREATE USER [DAG - diexp audit] FROM EXTERNAL PROVIDER;

USE [DW];
CREATE USER [DAG - diexp audit] FROM EXTERNAL PROVIDER;
ALTER ROLE lbmc_audit ADD MEMBER [DAG - diexp audit]

-- ADVISORY
USE [master];
CREATE USER [DAG - diexp advisory] FROM EXTERNAL PROVIDER;

USE [DW];
CREATE USER [DAG - diexp advisory] FROM EXTERNAL PROVIDER;
ALTER ROLE lbmc_advisory ADD MEMBER [DAG - diexp advisory]

-- MARKETING
USE [master];
CREATE USER [DAG - diexp marketing] FROM EXTERNAL PROVIDER;

USE [DW];
CREATE USER [DAG - diexp marketing] FROM EXTERNAL PROVIDER;
ALTER ROLE lbmc_marketing ADD MEMBER [DAG - diexp marketing]
