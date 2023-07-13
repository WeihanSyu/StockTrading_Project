# StockTrading_Project
### Summary
* Using Python, call stock market API's from Alpha Vantage to return market data for a range of time intervals and store them in a database on SQL Server.
* Analysis includes some basic buy and exit strategies using various types of moving averages as well as a simple LSTM model for the closing prices.

### stock_tbls.sql
* This is the sql script to generate the appropriate tables to contain the results from Alpha Vantage's stock API's.
* Simply change the first line to use whatever database you want to place the tables in.
* The procedure that we create, "dbo.addcol_tempstock", is used to check for duplicate values.
  * On our Python side, we create a global temporary table during runtime and then call dbo.addcol_tempstock which will add column headers to the temporary table depending on what API is used.
  * Now that we have a temporary table with the correct columns for a specific API, we can store newly called data into it, compare it with the corresponding existing table, and add unique rows to our existing table. 

### StockProject_Setup

### Stock_Project_Analysis_Manual
### StockProject_Analysis_ANN


