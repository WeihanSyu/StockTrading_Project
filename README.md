# StockTrading_Project
## Summary
* Using Python, call stock market APIs from Alpha Vantage to return market data for a range of time intervals and store them in a database on SQL Server.
* Analysis includes some basic buy and exit strategies using various types of moving averages as well as a simple LSTM model for the closing prices.
* **Important Details Regarding Alpha Vantage API Updates**
1. **~2023-07-20**
    * Intraday_Extended API has been merged with Intraday API. We have updated our code to reflect these changes, but have kept the old API intact as comments.
    * Daily_Adjusted API has been downgraded to premium and a new Daily API has been released which does not factor dividends and splits into the closing prices.
      * To call the new Daily API, simply remove all instances of *adjusted-like* characters from daily_adj in both the Setup script and the SQL script.
      * Or if you have premium, create a new table and methods for Daily.

## stock_tbls.sql
* This is the sql script to generate the appropriate tables to contain the results from Alpha Vantage's stock APIs.
* Simply change the first line to use whatever database you want to place the tables in.
* The procedure that we create, "dbo.addcol_tempstock", is used to check for duplicate values.
  * On our Python side, we create a global temporary table during runtime and then call dbo.addcol_tempstock which will add column headers to the temporary table depending on what API is used.
  * Now that we have a temporary table with the correct columns for a specific API, we can store newly called data into it, compare it with the corresponding existing table, and add unique rows to our existing table. 

## StockProject_Setup
Run this script with your ticker symbol of choice and any of the non-premium Core Stock APIs from Alpha Vantage to automatically insert the return data into the SQL tables created by stock_tbls.sql.
<details>
<summary><b>1. Set up Environment</b></summary>

* Import the necessary modules to run this script
</details>

<details>
<summary><b>2. Store API Key</b></summary>

* To gain access to the API's provided by Alpha Vantage, you need to request a *key*.
* Your key will need to be invoked everytime you make the API call.
* We stored our key string as a txt file just so it can't be seen through our code. This section just calls the txt file and assigns the key string to a variable.
</details>

<details>
<summary><b>3. Construct General Form for API Call</b></summary>

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
* Since the other parameters all have default values, we will define them as key/value pairs in the methods and use **kwargs to call them in the next function:
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
</details>

<details>
<summary><b>4. Make the API Call</b></summary>

* Call the main function with the parameter values of your choice
* Use *requests* HTTP library to make the call the API.
* Data from successful requests are either stored as json or csv (some can only be csv, check Alpha Vantage API documentation)
</details>

<details>
<summary><b>5.1 Clean and Transform Raw Data</b></summary>

* Section 5 is split into three sub-sections.
* This first section deals with cleaning and transforming the raw data into a nice list where we can easily insert it into SQL Server.
* The raw data for the json file type is a multi-dimensional dictionary. The outermost nest has two keys > 'Meta Data', 'Time Series ()';
* We split the json data into two smaller dictionaries, one for 'Meta Data' and one for 'Time Series'()
* **IMPORTANT:** APIs with an *interval* parameter will require the DATETIME data type in SQL not just DATE. To keep things simple, we could have just made every single table in SQL use the DATETIME format, but for analysis purposes, we wanted to keep it separate. So we must distinguish the two of them before we get to inserting the data into our tables.
* <details>
  <summary>Code snippet</summary>

  ```python
  try:
      del interval  
  except Exception:
      pass

  try:
      symbol = meta['2. Symbol']
      interval = meta['4. Interval']
  except KeyError:
      symbol = meta['2. Symbol']
  ```
  </details>

* Call the interval key in 'Meta Data' within a *try/except* block and assign an interval variable if we have one or leave it blank
* <details>
  <summary>Code snippet</summary>

  ```python
  tbl_keys = list( dicts[ list(dicts.keys())[0] ].keys() )
  try:
      i = 0
      for date in dicts:
          values.append((f"{symbol}_{date}",symbol,date, interval))
          for key in tbl_keys:
              values[i] = values[i] + tuple( [float(dicts[date][key])] )  
          i += 1
  except NameError:
      i = 0
      for date in dicts:
          values.append((f"{symbol}_{date}",symbol,date))
          for key in tbl_keys:
              values[i] = values[i] + tuple( [float(dicts[date][key])] )  
          i += 1
  ```
  </details>
    
* The outermost nested key 'Time Series ()' for the raw dictionary output holds all the stock data in another nested dictionary where **date** is the outermost key so we iterate through each *date in dicts* and place all the data for one date in a **tuple inside a list**.
* Each index of this list is now one unique row for a table in SQL
</details>

<details>
<summary><b>5.2 Make the ODBC Connection</b></summary>

* We use pyodbc to connect
</details>

<details>
<summary><b>5.3 Insert the Data into SQL Table</b></summary>

* <details>
  <summary>Code snippet</summary>

  ```python
  cursor.execute("DROP TABLE IF EXISTS StockData.dbo.##tempstock_tbl;")
  try:
      interval
      cursor.execute("CREATE TABLE StockData.dbo.##tempstock_tbl\
          (stock_id VARCHAR(255), symbol VARCHAR(15), [date] DATETIME, interval VARCHAR(10));")
  except NameError:
      cursor.execute("CREATE TABLE StockData.dbo.##tempstock_tbl\
          (stock_id VARCHAR(255), symbol VARCHAR(15), [date] DATE);")
  ```
  </details>

* Create a temporary table using the try/except block to check for the existence of *interval*. Use DATETIME if exists, else use DATE
* Using the procedure created in *stock_tbls.sql*, dynamically add the column headers into the temporary table.
* We now have an empty table with the correct number and names of headers.
* Since we are not typing out every single value in our list to an INSERT statement, we will use a **question mark <?>** as a place holder in SQL, supported by ODBC. This requires knowing how many columns there are and placing that many **?** marks into the INSERT statement. We want to do this dynamically, not change it very time we run:
* <details>
  <summary>Code snippet</summary>

  ```python
  cursor.execute("SELECT COUNT(COLUMN_NAME) FROM StockData.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '" + tbl_name + "';")
  colSize = str(cursor.fetchone())
  colSize = colSize.replace("(","")
  colSize = colSize.replace(")","")
  colSize = colSize.replace(",","")
  colSize = int(colSize)
  xValues = ""
  for i in range(0, colSize):
      xValues = xValues + "?,"
  xValues = xValues[:-1]

  try:
      interval
      cursor.fast_executemany = True
      cursor.executemany("INSERT INTO StockData.dbo.##tempstock_tbl (stock_id, symbol, [date], interval, " + headerStr + ")\
                    VALUES (" + xValues + ")",\
                    values)
  except NameError:
      cursor.fast_executemany = True
      cursor.executemany("INSERT INTO StockData.dbo.##tempstock_tbl (stock_id, symbol, [date], " + headerStr + ")\
                    VALUES (" + xValues + ")",\
                    values)
      
  cursor.execute("INSERT INTO StockData.dbo." + tbl_name + " SELECT * FROM StockData.dbo.##tempstock_tbl\
                  WHERE stock_id NOT IN (SELECT stock_id FROM StockData.dbo." + tbl_name + ")")
  conn.commit()
  ```
  </details>
    
* Use INFORMATION_SCHEMA.COLUMS with COUNT to get the number of columns. Then use cursor.fetchone to retrieve the output, then clean it up to make it an integer. Loop through the integer value and create the same amount of ? marks in a string value
* Finally, we insert all the values from the stock API into the temporary table with cursor.executemany and then insert the non-duplicate rows into the existing SQL Table by using the **WHERE ... NOT IN ...** clause
* End the script by commiting the SQL changes > conn.commit()
</details>
    
## Stock_Project_Analysis_Manual
Pairs up with **mafuncs.py** (file of common moving average functions) to perform some basic buy and exit strategies using the closing prices stored by StockProject_Setup.
<details>
<summary><b>1. Set up Environment</b></summary>

* Import the necessary modules to run this script
</details>

<details>
<summary><b>2. Pull Data From Our SQL Table into a Pandas Dataframe</b></summary>

* Create an engine object with SQLAlchemy and give the engine a connection string to SQL Server.
* Use *engine.connect* to invoke SQL statements from the connected database
</details>

<details>
<summary><b>3. Set Up Function to Call Initial Data</b></summary>

* <details>
  <summary><b>Code snippet</b></summary>
  
  ```python
  def initial_data():
      while True:
          try:
              start_date = input("Please enter the Starting Date (yyyy-m-dd)")
              start_date = datetime.datetime.strptime(start_date, '%Y-%m-%d')
              if len(df.loc[df['date'] > datetime.date(start_date.year, start_date.month, start_date.day)]) > 0:
              ...
  ```
  </details>

* Incorporate *input()* functions so the user can pick their own start and end dates during runtime.
* To deal with inputs that are not valid in format, we wrap everything in a *try/except* block
* To deal with start dates that are beyond the last date or end dates that are before the first date, check with an *if* statement.
* If all the date ranges are appropriate, then return a pandas dataframe for the stock data within the chosen dates.
</details>

<details>
<summary><b>4. Set Up Function to Remove X-Axis Gaps Between Dates During Plotting</b></summary>

* <details>
  <summary><b>Code snippet</b></summary>

  ```python
  def equidate_ax(fig, ax, dates, fmt="%Y-%m-%d", label="Date"):
      N = len(dates)
      def format_date(index, pos):
          index = np.clip(int(index + 0.5), 0, N - 1)
          return dates[index].strftime(fmt)
      ax.xaxis.set_major_formatter(FuncFormatter(format_date))
      ax.set_xlabel(label)
      fig.autofmt_xdate()
  ```
  </details>

* The function above will make our x-axis dates equidistant during plotting.
* This is important because there is no market activity during weekends or certain holidays, but with dates, Maplotlib sometimes sets up the graph so that dates are continuous even if we didn't input a continuous date range. This makes line graphs have breaks in between.
* With equidistant points, there will be no breaks.
</details>

<details>
<summary><b>5. Moving Average Crossover Strategy</b></summary>

* There are different ways to utilize a crossover strategy, but for our method, we will consider two moving average functions of different time intervals.
* A shorter time interval, called the fast moving average
* A longer time interval, called the slow moving average.
  * Consider a "buy-in" when the fast MA crosses **above** the slow MA which indicates short-term buying pressure and upwards momentum in the market.
  * Consider an "exit" and go "short" when the fast MA crosses **below** the slow MA.
* To start the analysis, get the raw data from a SQL table using the function from section 3. Then we set up the two MA functions and prepare it for plotting,
* <details>
  <summary><b>Code snippet</b></summary>

  ```python
  def ma_setup(nF, nS, ma_func, s=2):
      func_name = ma_func.__name__
    
      x, ini_points = ma_func(data[price_type], nF, len(data), s)
      maFast = [np.nan]*ini_points + x
    
      y, ini_points = ma_func(data[price_type], nS, len(data), s)
      maSlow = [np.nan]*ini_points + y
    
      return nF, nS, func_name, maFast, maSlow
  ```
  </details>

* The function above sets up the two MA functions. Since each one has a different, length, they will also start at different dates depending on how many initial dates they require to calculate the first moving average value. *ini_points* takes care of that for every MA function that we have in **mafuncs.py**
*  To prepare the data the data for plotting, a *signal* and an *entry* column is added which will give a change in value whenever a MA crossover occurs. 
* Additionally, we set up a *return* and *system_return* column to show instantenous buy/sell returns versus following the system strategy over longer periods.
![Axonn](../../../../Software Learning And Cloud/HTML Lessons/Axonn2.jpg)
</details>

## StockProject_Analysis_ANN
Simple artificial neural network using LSTM (long short-term memory networks) to try and predict stock prices.




