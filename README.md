# StockTrading_Project
### Summary
* Using Python, call stock market APIs from Alpha Vantage to return market data for a range of time intervals and store them in a database on SQL Server.
* Analysis includes some basic buy and exit strategies using various types of moving averages as well as a simple LSTM model for the closing prices.

### stock_tbls.sql
* This is the sql script to generate the appropriate tables to contain the results from Alpha Vantage's stock APIs.
* Simply change the first line to use whatever database you want to place the tables in.
* The procedure that we create, "dbo.addcol_tempstock", is used to check for duplicate values.
  * On our Python side, we create a global temporary table during runtime and then call dbo.addcol_tempstock which will add column headers to the temporary table depending on what API is used.
  * Now that we have a temporary table with the correct columns for a specific API, we can store newly called data into it, compare it with the corresponding existing table, and add unique rows to our existing table. 

### StockProject_Setup
* Run this script with your ticker symbol of choice and any of the non-premium Core Stock APIs from Alpha Vantage to automatically insert the return data into the SQL tables created by stock_tbls.sql.
* **1. Set up Environment:**
 * Import the necessary modules to run this script
* **2. Store API Key:**
 * To gain access to the API's provided by Alpha Vantage, you need to request a *key*.
 * Your key will need to be invoked everytime you make the API call.
 * We stored our key string as a txt file just so it can't be seen through our code. This section just calls the txt file and assigns the key string to a variable.
* **3. Construct General Form for API Call:**
  * We use a class object to store all the different non-premium stock data APIs. To call each API, a URL string is used with the format provided by Alpha Vantage.
  * These URLs are constructed by a method in the class and most of the parameters can take multiple values, but have a default value (not empty), except for *function*, *symbol*, and *apikey* where function and symbol shouldn't have a default value and apikey is just static. Thus, these three parameters will be defined in the \__init__ method.
  * The other parameters will

### Stock_Project_Analysis_Manual
### StockProject_Analysis_ANN


