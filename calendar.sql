CREATE TABLE [dim].[calendar]
(
	[date_key] [int] NOT NULL,
	[date] [date] NOT NULL,
	[year] [int] NOT NULL,
	[month_number] [int] NOT NULL,
	[month_number_long] [varchar](5) NULL,
	[month_day] [int] NOT NULL,
	[year_month_number] [int] NOT NULL,
	[month_year_name] [varchar](50) NOT NULL,
	[day_seq_number] [int] NOT NULL,
	[month_name_full] [nvarchar](255) NOT NULL,
	[month_name_short] [nvarchar](255) NOT NULL,
	[quarter] [int] NOT NULL,
	[year_quarter_name] [nvarchar](255) NOT NULL,
	[quarter_seq_number] [int] NOT NULL,
	[relative_date] [int] NOT NULL,
	[relative_week] [int] NOT NULL,
	[relative_month] [int] NOT NULL,
	[relative_quarter] [int] NOT NULL,
	[relative_year] [int] NOT NULL,
	[day_of_week] [nvarchar](255) NOT NULL,
	[day_of_week_number] [int] NOT NULL,
	[week_of_year] [int] NOT NULL,
	[year_week_number] [int] NOT NULL,
	[year_week_name] [nvarchar](255) NOT NULL,
	[sunday_of_week] [DATE] NOT NULL,
	[monday_of_week] [date] NOT NULL,
	[last_day_of_month] [date] NOT NULL,
	[fiscal_year] [int] NULL,
	[fiscal_year_name] [nvarchar](255) NULL,
	[fiscal_year_month] [nvarchar](255) NULL,
	[fiscal_year_month_number] [int] NULL,
	[is_week_day] [tinyint] NOT NULL,
	[is_work_day] [tinyint] NULL,
	[insert_audit_key] INT NOT NULL,
	[update_audit_key] INT NULL,
	CONSTRAINT pk_date_key PRIMARY KEY (date_key)
)

GO

CREATE NONCLUSTERED INDEX idx_relative_date ON dim.calendar (relative_date, relative_week, relative_month, relative_year);

GO

CREATE NONCLUSTERED INDEX idx_date_id ON dim.calendar ([date], [year], [month_number], [month_day]);

GO
