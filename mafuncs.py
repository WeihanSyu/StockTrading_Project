def sma(prices, n, length, *args):
    ma = []
    for i in range(0, length-n+1):
        ma.append(sum(prices[i:(n+i)])/n)
    return ma

def wma(prices, n, length, *args):
    ma = []
    for i in range(0, length-n+1):
        numerator = []
        k = 0
        for j in range(i, n+i):
            numerator.append(prices[j]*(k+1))
            k += 1
        ma.append(sum(numerator)/((n*(n+1))/2))
    return ma

def ema(prices, n, length, s):
    sma = sum(prices[0:n])/n
    ma = [(prices[n]*(s/(1+n))) + (sma*(1-(s/(1+n))))]
    for i in range(1, length-n): 
        ma.append( ( prices[i+n]*(s/(1+n)) ) + ( ma[i-1]*(1-(s/(1+n))) ) )
    return ma

def dema(prices, n, length, s):
    ma = []
    ema1 = ema(prices, n, length, s)
    l = len(ema1)
    ema_sq = []
    for i in range(0, l):
        ema_sq.append( (prices[i+n])*(s/(1+n)) + ( ema1[i]*(1-(s/(1+n))) ) )
    
    for x,y in zip(ema1, ema_sq):
        ma.append(2*x - y)
   
    return ma

def tema(prices, n, length, s):
    ma = []
    ema1 = ema(prices, n, length, s)
    l = len(ema1)
    ema_sq = []
    ema_cu = []
    for i in range(0, l):
        ema_sq.append( (prices[i+n])*(s/(1+n)) + ( ema1[i]*(1-(s/(1+n))) ) )
        ema_cu.append( (prices[i+n])*(s/(1+n)) + ( ema_sq[i]*(1-(s/(1+n))) ) )
    
    for x,y,z in zip(ema1, ema_sq, ema_cu):
        ma.append( (3*x) - (3*y) + z )
    
    return ma

def tma(prices, n, length, *args):
    ma = []
    simple = sma(prices, n, length)
    l = len(simple)
    for i in range(0, l-n+1):
        ma.append(sum(simple[i:(n+i)])/n)
    return ma
        
def cmo(prices, n, length):
    SoU = [0]*length
    SoD = [0]*length
    chande = []
    for i in range(0, length-n+1):
        for j in range(i, i+n-1):
            if prices[j] < prices[j+1]:
                SoU[i] += (prices[j+1] - prices[j])
            elif prices[j] > prices[j+1]:
                SoD[i] += abs(prices[j+1] - prices[j])
        chande.append( ((SoU[i]-SoD[i])/(SoU[i]+SoD[i]))*100 )
    return chande

def vma(prices, n, length, s):
    ma = []
    numerator = [0]*(length-n+1-9)
    denominator = [0]*(length-n+1-9)
    chande = cmo(prices, n, length)
    b = [abs(x/100) for x in chande]
    a = s/(n+1)
    for i in range(9, length-n+1):
        for j in range(i, i+n):
            numerator[i-9] += ( prices[j]*( (a*b[j-9])**(abs(j-i-9)) ) )  # abs(j-i-9) must always go from 9 to 0
            denominator[i-9] += ( (a*b[j-9])**(abs(j-i-9)) )  # Math looks good
        ma.append( sum(numerator[(i-9):(i+1)]) / sum(denominator[(i-9):(i+1)]) )
    return ma

def lsma(prices, n, length, *args):
    ma = []
    b = []
    a = []
    t = [x for x in range(1, length+1)]  # Since all times are divided evenly (intraday, daily, weekly), let's call each time 1
    sumTX = [0]*(length-n+1)
    sumT = [0]*(length-n+1)
    sumX = [0]*(length-n+1)
    
    for i in range(0, length-n+1):
        for j in range(i, i+n):
            sumTX[i] += t[j]*prices[j]
            sumT[i] += t[j]
            sumX[i] += prices[j]
        b.append( (n*sumTX[i]-(sumT[i]*sumX[i])) / (n*sumT[i]-(sumT[i]*sumX[i])) )
        a.append( (sumX[i]/n) - ( b[i] * (sumT[i]/n) ) )
        ma.append(b[i]*t[i]+a[i])
    
    return ma
