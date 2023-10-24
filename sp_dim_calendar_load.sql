CREATE PROCEDURE [etl].[sp_dim_calendar_load]
    @AuditKey INT
AS

BEGIN TRY

    EXEC dbo.InsertLogRecord 'BEGIN sp_dim_calendar_load', @@PROCID, NULL, @AuditKey

    DECLARE @StartDate DATE = '2015-01-01'
    DECLARE @EndDate DATE = '2025-12-31'
    DECLARE @today DATE = CAST(GETDATE() AS DATE)

    DROP TABLE IF EXISTS #dates;

    TRUNCATE TABLE dim.calendar;

       CREATE TABLE #dates
(
	[date_key] [INT] NOT NULL,
	[date] [DATE] NULL,
	[year] [INT] NULL,
	[month_number] [INT] NULL,
    [month_number_long] [VARCHAR](5) NULL,
	[month_day] [INT] NULL,
	[year_month_number] [INT] NULL,
	[month_year_name] [VARCHAR](50) NULL,
	[day_seq_number] [INT] NULL,
	[month_name_full] [NVARCHAR](255) NULL,
	[month_name_short] [NVARCHAR](255) NULL,
	[quarter] [INT] NULL,
	[year_quarter_name] [NVARCHAR](255) NULL,
	[quarter_seq_number] [INT] NULL,
	[relative_date] [INT] NULL,
	[relative_week] [INT] NULL,
	[relative_month] [INT] NULL,
	[relative_quarter] [INT] NULL,
	[relative_year] [INT] NULL,
	[day_of_week] [NVARCHAR](255) NULL,
	[day_of_week_number] [INT] NULL,
	[week_of_year] [INT] NULL,
	[year_week_number] [INT] NULL,
	[year_week_name] [NVARCHAR](255) NULL,
	[sunday_of_week] [DATE] NULL,
	[monday_of_week] [DATE] NULL,
	[last_day_of_month] [DATE] NULL,
	[fiscal_year] [INT] NULL,
    [fiscal_year_name] [NVARCHAR](255) NULL,
	[fiscal_year_month] [NVARCHAR](255) NULL,
	[fiscal_year_month_number] [INT] NULL,
	[is_week_day] [TINYINT] NULL,
	[is_work_day] [TINYINT] NULL
)

    ; with cte_dates as 
    (

        select YEAR(@StartDate) * 10000 + MONTH(@StartDate) * 100 + DAY(@StartDate) as [date_key]
            ,cast(@StartDate as date) as [date]
            ,datepart(year, @StartDate) as [year]
            ,datepart(month, @StartDate) as [month_number]
            ,RIGHT('0' + CONVERT(NVARCHAR(2), datepart(month, @StartDate)), 2) as [month_number_long]
            ,datepart(day, @StartDate) as [month_day]
            ,concat(datepart(year, @StartDate), 
                case when len(datepart(month, @StartDate)) = 1 then '0' + cast(datepart(month, @StartDate) as varchar) 
                else cast(datepart(month, @StartDate) as varchar) end) as [year_month_number]
            ,format(@StartDate, 'MMM') + ' ' + cast(datepart(year, @StartDate) as varchar) as [month_year_name]
            ,1 as [day_seq_number]
            ,datename(month, @StartDate) as [month_name_full]
            ,format(@StartDate, 'MMM') as [month_name_short]
            ,datepart(quarter, @StartDate) as [quarter]
            ,concat(year(@StartDate), ' Q', datepart(quarter, @StartDate)) as [year_quarter_name]
            ,1 as [quarter_seq_number]
            ,NULL as [relative_date]
            ,NULL as [relative_week]
            ,NULL as [relative_month]
            ,NULL as [relative_quarter]
            ,NULL as [relative_year]
            ,datename(weekday, @StartDate) as [day_of_week]
            ,datepart(weekday, @StartDate) as [day_of_week_number]
            ,datepart(week, @StartDate) as [week_of_year]
            ,concat(cast(datepart(year, @StartDate) as varchar), 
                case when len(cast(datepart(week, @StartDate) as varchar)) = 1 then '0' + cast(datepart(week, @StartDate) as varchar)
                else cast(datepart(week, @StartDate) as varchar) 
                end) as [year_week_number]
            ,cast(datepart(year, @StartDate) as varchar) + '-' + cast(datepart(week, @StartDate) as varchar) as [year_week_name]
			,DATEADD(wk, DATEDIFF(wk, 0, @StartDate), -1) as [sunday_of_week]
            ,DATEADD(wk, DATEDIFF(wk, 0, @StartDate), 0) as [monday_of_week]
            ,eomonth(@StartDate) as [last_day_of_month]
            ,NULL as [fiscal_year]
            ,NULL as [fiscal_year_name]
            ,NULL as [fiscal_year_month]
            ,NULL as [fiscal_year_month_number]
            ,case when (datepart(weekday, @StartDate) in (1, 7)) then 0 else 1 end as [is_week_day]
            ,case when (datepart(weekday, @StartDate) in (1, 7)) then 0 else 1 end as [is_work_day]

        UNION ALL

        select YEAR(DATEADD(day, 1, [date])) * 10000 + MONTH(DATEADD(day, 1, [date])) * 100 + DAY(DATEADD(day, 1, [date])) as [date_key]
            ,DATEADD(day, 1, [date]) as [date]
            ,datepart(year, DATEADD(day, 1, [date])) as [year]
            ,datepart(month, DATEADD(day, 1, [date])) as [month_number]
            ,RIGHT('0' + CONVERT(NVARCHAR(2), datepart(month, DATEADD(day, 1, [date]))), 2) as [month_number_long]
            ,datepart(day, DATEADD(day, 1, [date])) as [month_day]
            ,concat(datepart(year, DATEADD(day, 1, [date])), 
                case when len(datepart(month, DATEADD(day, 1, [date]))) = 1 then '0' + cast(datepart(month, DATEADD(day, 1, [date])) as varchar) 
                else cast(datepart(month, DATEADD(day, 1, [date])) as varchar) end) as [year_month_number]
            ,format(DATEADD(day, 1, [date]), 'MMM') + ' ' + cast(datepart(year, DATEADD(day, 1, [date])) as varchar) as [month_year_name]
            ,1 as [day_seq_number]
            ,datename(month, DATEADD(day, 1, [date])) as [month_name_full]
            ,format(DATEADD(day, 1, [date]), 'MMM') as [month_name_short]
            ,datepart(quarter, DATEADD(day, 1, [date])) as [quarter]
            ,concat(year(DATEADD(day, 1, [date])), ' Q', datepart(quarter, DATEADD(day, 1, [date]))) as [year_quarter_name]
            ,1 as [quarter_seq_number]
            ,NULL as [relative_date]
            ,NULL as [relative_week]
            ,NULL as [relative_month]
            ,NULL as [relative_quarter]
            ,NULL as [relative_year]
            ,datename(weekday, DATEADD(day, 1, [date])) as [day_of_week]
            ,datepart(weekday, DATEADD(day, 1, [date])) as [day_of_week_number]
            ,datepart(week, DATEADD(day, 1, [date])) as [week_of_year]
            ,concat(cast(datepart(year, DATEADD(day, 1, [date])) as varchar), 
                case when len(cast(datepart(week, DATEADD(day, 1, [date])) as varchar)) = 1 then '0' + cast(datepart(week, DATEADD(day, 1, [date])) as varchar)
                else cast(datepart(week, DATEADD(day, 1, [date])) as varchar) 
                end) as [year_week_number]
            ,cast(datepart(year, DATEADD(day, 1, [date])) as varchar) + '-' + cast(datepart(week, DATEADD(day, 1, [date])) as varchar) as [year_week_name]
			,DATEADD(wk, DATEDIFF(wk, 0, DATEADD(DAY, 1, [date])), -1) as [sunday_of_week]
            ,DATEADD(wk, DATEDIFF(wk, 0, DATEADD(DAY, 1, [date])), 0) as [monday_of_week]
            ,eomonth(DATEADD(day, 1, [date])) as [last_day_of_month]
            ,NULL as [fiscal_year]
            ,NULL as [fiscal_year_name]
            ,NULL as [fiscal_year_month]
            ,NULL as [fiscal_year_month_number]
            ,case when (datepart(weekday, DATEADD(day, 1, [date])) in (1, 7)) then 0 else 1 end as [is_week_day]
            ,case when (datepart(weekday, DATEADD(day, 1, [date])) in (1, 7)) then 0 else 1 end as [is_work_day]
        from cte_dates
        where [date] < @EndDate
    )

    insert into #dates
    SELECT * FROM cte_dates option (MAXRECURSION 20000)


    update #dates
        set relative_date = 0
    from #dates
    where [date] = @today

    ; with relative_dates as (

        -- get the past dates
        select
            d.[date]
            ,row_number() over (order by [date] desc) * -1 as relative_date
            from #dates d
            where [date] < @today

        union all

        -- get the future dates
        select 
            d.[date]
            ,row_number() over (order by [date])
            from #dates d
            where [date] > @today

        union all

        -- get today
        select 
            d.[date]
            ,0
            from #dates d
            where [date] = @today
    )

    , relative_weeks as (

        select distinct
            d.[year_week_number]
            ,dense_rank() over (order by [year_week_number] desc) * -1 as relative_week
            from #dates d
            where [year_week_number] < (select year_week_number from #dates where relative_date = 0)

        union all

        select distinct 
            d.[year_week_number]
            ,dense_rank() over (order by [year_week_number]) as relative_week
            from #dates d
            where [year_week_number] > (select year_week_number from #dates where relative_date = 0)

        union all

        select distinct
            d.[year_week_number], 0 as relative_week
            from #dates d
            where [date] = (select [date] from #dates where relative_date = 0)

    )

    , relative_months as (

        select distinct
            d.[year_month_number]
            ,dense_rank() over (order by [year_month_number] desc) * -1 as relative_month
            from #dates d
            where [year_month_number] < (select year_month_number from #dates where relative_date = 0)

        union all

        select distinct
            d.[year_month_number]
            ,dense_rank() over (order by [year_month_number]) as relative_month
            from #dates d
            where [year_month_number] > (select year_month_number from #dates where relative_date = 0)

        union all

        select distinct
            d.[year_month_number], 0 as relative_month
            from #dates d
            where [year_month_number] = (select [year_month_number] from #dates where relative_date = 0)

    )

    , relative_quarters as (
    
        select distinct
            [year_quarter_name]
            ,dense_rank() over (order by [year_quarter_name] desc) * -1 as relative_quarter
            from #dates d
            where [year_quarter_name] < (select [year_quarter_name] from #dates where relative_date = 0)

        union all

        select distinct
            [year_quarter_name]
            ,dense_rank() over (order by [year_quarter_name]) as relative_quarter
            from #dates d
            where [year_quarter_name] > (select [year_quarter_name] from #dates where relative_date = 0)

        union all

        select distinct
            [year_quarter_name], 0 as relative_quarter
            from #dates d
            where [year_quarter_name] = (select [year_quarter_name] from #dates where relative_date = 0)

    )

    , relative_years as (

        select distinct
            [year]
            ,dense_rank() over (order by [year] desc) * -1 as relative_year
            from #dates d
            where [year] < (select [year] from #dates where relative_date = 0)

        union all

        select distinct
            [year]
            ,dense_rank() over (order by [year]) as relative_year
            from #dates d
            where [year] > (select [year] from #dates where relative_date = 0)

        union all

        select distinct
            [year], 0 as relative_year
            from #dates d
            where [year] = (select [year] from #dates where relative_date = 0)

    )

    ,fiscal_years as (
    
    select [date],
        IIF(month_number > 5, year+1, year) as [fiscal_year],
        concat('FY ', IIF(month_number > 5, year+1, year)) as [fiscal_year_name],
        concat('FY ',
            IIF(month_number > 5, 
                concat(cast((year+1) as varchar) + '-',
                    case when len(datepart(month,DATEADD(month, -5, [date]))) = 1 then '0' + cast(datepart(month,DATEADD(month, -5, [date])) as varchar)
                    else cast(datepart(month,DATEADD(month, -5, [date])) as varchar) end),
                concat(cast(year as varchar) + '-',
                    case when len(datepart(month,DATEADD(month, -5, [date]))) = 1 then '0' + cast(datepart(month,DATEADD(month, -5, [date])) as varchar)
                    else cast(datepart(month,DATEADD(month, -5, [date])) as varchar) end) 
            )
        ) as [fiscal_year_month],
        cast(IIF(month_number > 5, year+1, year) * 100 + datepart(month,DATEADD(month, -5, [date])) as numeric) as [fiscal_year_month_number]
    from #dates
    
    )


    update #dates
        set relative_date = rd.relative_date
        ,relative_week = rw.relative_week
        ,relative_month = rm.relative_month
        ,relative_quarter = rq.relative_quarter
        ,relative_year = ry.relative_year
        ,fiscal_year = fy.fiscal_year
        ,fiscal_year_name = fy.fiscal_year_name
        ,fiscal_year_month = fy.fiscal_year_month
        ,fiscal_year_month_number = fy.fiscal_year_month_number
    from #dates d
    left join relative_dates rd
        on d.[date] = rd.[date]
    left join relative_weeks rw
        on d.[year_week_number] = rw.year_week_number
    left join relative_months rm
        on d.year_month_number = rm.year_month_number
    left join relative_quarters rq
        on d.year_quarter_name = rq.year_quarter_name
    left join relative_years ry
        on d.[year] = ry.[year]
    left join fiscal_years fy 
        on d.[date] = fy.[date]

    insert into dim.calendar (
        date_key
        ,[date]
        ,[year]
        ,month_number
        ,month_day
        ,year_month_number
        ,month_year_name
        ,day_seq_number
        ,month_name_full
        ,month_name_short
        ,quarter
        ,year_quarter_name
        ,quarter_seq_number
        ,relative_date
        ,relative_week
        ,relative_month
        ,relative_quarter
        ,relative_year
        ,day_of_week
        ,day_of_week_number
        ,week_of_year
        ,year_week_number
        ,year_week_name
		,sunday_of_week
        ,monday_of_week
        ,last_day_of_month
        ,fiscal_year
        ,fiscal_year_name
        ,fiscal_year_month
        ,fiscal_year_month_number
        ,is_week_day
        ,is_work_day
        ,insert_audit_key
    )
        select
            date_key
            ,[date]
            ,[year]
            ,month_number
            ,month_day
            ,year_month_number
            ,month_year_name
            ,day_seq_number
            ,month_name_full
            ,month_name_short
            ,quarter
            ,year_quarter_name
            ,quarter_seq_number
            ,relative_date
            ,relative_week
            ,relative_month
            ,relative_quarter
            ,relative_year
            ,day_of_week
            ,day_of_week_number
            ,week_of_year
            ,year_week_number
            ,year_week_name
			,sunday_of_week
            ,monday_of_week
            ,last_day_of_month
            ,fiscal_year
            ,fiscal_year_name
            ,fiscal_year_month
            ,fiscal_year_month_number
            ,is_week_day
            ,is_work_day
            ,@AuditKey
        from #dates

    EXEC dbo.InsertLogRecord 'Calendar rows inserted', @@PROCID, @@ROWCOUNT, @AuditKey

    alter index ALL on dim.Calendar REBUILD;

    EXEC dbo.InsertLogRecord 'END sp_dim_calendar_load', @@PROCID, NULL, @AuditKey

END TRY    
BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK;

	DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE()
		,@ErrorServerity int = ERROR_SEVERITY()
		,@ErrorNumber int = ERROR_NUMBER()
		,@ErrorLine int = ERROR_LINE()
		,@ErrorState int = ERROR_STATE()
		,@ErrorProcedure nvarchar(128) = ERROR_PROCEDURE();

	EXEC dbo.InsertLogRecord 'ERROR sp_dim_calendar_load', @@PROCID, NULL, @AuditKey, @ErrorNumber, @ErrorServerity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage;

    THROW;

END CATCH