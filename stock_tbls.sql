USE StockData;
GO

DROP TABLE IF EXISTS daily_adj;
GO
CREATE TABLE daily_adj (
	stock_id VARCHAR(255) NOT NULL,
	symbol VARCHAR(15) NOT NULL,
	[date] DATE NOT NULL,
	open_price DECIMAL(38, 4),
	high_price DECIMAL(38, 4),
	low_price DECIMAL(38, 4),
	close_price DECIMAL(38, 4),
	adj_close DECIMAL(38, 4),
	volume INT,
	dividend DECIMAL(38, 4),
	split DECIMAL,
	CONSTRAINT pk_daily_adj PRIMARY KEY(stock_id)
);
GO

DROP TABLE IF EXISTS intraday;
GO
CREATE TABLE intraday (
	stock_id VARCHAR(255) NOT NULL,
	symbol VARCHAR(15) NOT NULL,
	[date] DATETIME NOT NULL,
	interval VARCHAR(10) NOT NULL,
	open_price DECIMAL(38,4),
	high_price DECIMAL(38, 4),
	low_price DECIMAL(38, 4),
	close_price DECIMAL(38, 4),
	volume INT,
	CONSTRAINT pk_intraday PRIMARY KEY(stock_id)
);
GO

DROP TABLE IF EXISTS intraday_ext;
GO
CREATE TABLE intraday_ext (
	stock_id VARCHAR(255) NOT NULL,
	symbol VARCHAR(15) NOT NULL,
	[date] DATETIME NOT NULL,
	interval VARCHAR(10) NOT NULL,
	open_price DECIMAL(38, 4),
	high_price DECIMAL(38, 4),
	low_price DECIMAL(38, 4),
	close_price DECIMAL(38, 4),
	volume INT,
	CONSTRAINT pk_intraday_ext PRIMARY KEY(stock_id)
);
GO

DROP TABLE IF EXISTS weekly;
GO
CREATE TABLE weekly (
	stock_id VARCHAR(255) NOT NULL,
	symbol VARCHAR(15) NOT NULL,
	[date] DATE NOT NULL,
	open_price DECIMAL(38, 4),
	high_price DECIMAL(38, 4),
	low_price DECIMAL(38, 4),
	close_price DECIMAL(38, 4),
	volume INT,
	CONSTRAINT pk_weekly PRIMARY KEY(stock_id)
);
GO

DROP TABLE IF EXISTS weekly_adj;
GO
CREATE TABLE weekly_adj (
	stock_id VARCHAR(255) NOT NULL,
	symbol VARCHAR(15) NOT NULL,
	[date] DATE NOT NULL,
	open_price DECIMAL(38, 4),
	high_price DECIMAL(38, 4),
	low_price DECIMAL(38, 4),
	close_price DECIMAL(38, 4),
	adj_close DECIMAL(38, 4),
	volume INT,
	dividend DECIMAL(38,4),
	CONSTRAINT pk_weekly_adj PRIMARY KEY(stock_id)
);
GO

DROP TABLE IF EXISTS monthly;
GO
CREATE TABLE monthly (
	stock_id VARCHAR(255) NOT NULL,
	symbol VARCHAR(15) NOT NULL,
	[date] DATE NOT NULL,
	open_price DECIMAL(38, 4),
	high_price DECIMAL(38, 4),
	low_price DECIMAL(38, 4),
	close_price DECIMAL(38, 4),
	volume BIGINT,
	CONSTRAINT pk_monthly PRIMARY KEY(stock_id)
);
GO

DROP TABLE IF EXISTS monthly_adj;
GO
CREATE TABLE monthly_adj (
	stock_id VARCHAR(255) NOT NULL,
	symbol VARCHAR(15) NOT NULL,
	[date] DATE NOT NULL,
	open_price DECIMAL(38, 4),
	high_price DECIMAL(38, 4),
	low_price DECIMAL(38, 4),
	close_price DECIMAL(38, 4),
	adj_close DECIMAL(38, 4),
	volume BIGINT,
	dividend DECIMAL(38,4),
	CONSTRAINT pk_monthly_adj PRIMARY KEY(stock_id)
);
GO

DROP PROC IF EXISTS dbo.addcol_tempstock;
GO
CREATE PROC dbo.addcol_tempstock
	@colName VARCHAR(255) 
AS
	DECLARE @sql NVARCHAR(MAX);
	SET @sql = 'ALTER TABLE ##tempstock_tbl ADD ' + @colName + ' DECIMAL(38,4)';
	EXEC(@sql);
GO


SELECT stock_id, COUNT(*) FROM daily_adj 
WHERE symbol = 'TRKA'
GROUP BY stock_id
HAVING COUNT(*) > 1;


