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
  * <details>
    <summary>Code snippet</summary>
   
    ```python
    class api_construct:
        def __init__(self, function, symbol, apikey):
            self.function = function
            self.symbol = symbol
            self.apikey = apikey

        def intraday(self, interval='1min', adjusted='true', outputsize='compact', datatype='json'):
            self.url = 'https://www.alphavantage.co/query?function=' + self.function + '&symbol=' + self.symbol\
            + '&interval=' + interval + '&adjusted=' + adjusted + '&outputsize=' + outputsize + '&apikey='\
            + self.apikey + '&datatype=' + datatype
    ```
    </details>
    
  * We use a Class object to store all the different non-premium stock data APIs. To call each API, a URL string is used with the format provided by Alpha Vantage.
  * These URLs are constructed by a method in the class and most of the parameters can take multiple values, but have a default value which makes them optional, except for *function*, *symbol*, and *apikey* where function and symbol shouldn't have a default value and apikey is just static. Thus, these three parameters will be defined in the \__init__ method.
    * Note that *interval* also doesn't have a default value and is a required parameter. I set it to the minimum time interval as default just for my own convenience.
  * Since the other parameters all have default values, we will define them as key/value pairs in the methods and use **kwargs to call them in the next function.
  * <details>
    <summary>Code snippet</summary>

    ```python
    def api_call(function, symbol, **kwargs):
        construct = api_construct(function, symbol, key)
        if function == 'TIME_SERIES_INTRADAY':
            construct.intraday(**kwargs)
            tbl_name = 'intraday'
        ...
        url = construct.url
        return url, tbl_name
    ```
    </details>

  * The function *api_call()* is our main function and only place that we need to change variables between runs if we want different data.
  * The Class *api_construct()* is created inside *api_call()* so we have to input *function* and *symbol*. To change values for the rest of the parameters in the Class, we use **kwargs and simply put it as an input variable when calling the API methods.
  * We also assign the SQL table names to a variable *tbl_name* in this function so that we can interact with the SQL table using pyodbc, e.g. "SELECT * FROM" + tbl_name + ";" without having to type in the correct table name in relevant places for every single run.
* **4. Make the API Call**
  * Call the main function with the parameter values of your choice
  * Use *requests* HTTP library to make the call the API.
  * data from successfull requests are either stored as json or csv (some can only be csv, check Alpha Vantage API documentation)
* **5. Format the data and put into SQL Server**
  * We split this 

### Stock_Project_Analysis_Manual
### StockProject_Analysis_ANN




