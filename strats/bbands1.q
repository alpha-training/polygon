/ Bollinger Band mean reversion with RSI, volume filter, TP/SL, and EOD exit

T:`bar1m

CFG:.j.k trim raze read0`:config/bbands1.json

getMidBand:{[x] mavg[7h$CFG`BAND_PERIOD;x]}

getRSI:{[close;period]
    diff:close - prev close;
    gain:diff*(diff>0f);loss:diff*(diff<0)*-1;
    smooth:{[vals;period]
        n:period; 
        seed:avg vals[1+til n];
        (n#0Nf),seed,{(y+x*(z-1))%z}\[(sum n#vals)%n;(n+1)_vals;n]};    
    rs:(smooth[gain;period])%(smooth[loss;period]);
    rsi:?[(smooth [loss;period])=0;100;100*rs%(1+rs)]}

/ add more intermediary functions here

getBBands1:{[d;s] /getBBands1[2025.09.01 2025.09.05;`JPM`GE`IBM]
  a:select from T where date within d,sym in s;
  a:update K:first i by date,sym from a;  / useful to have a unique index
  a:update midBand:getMidBand close by K from a;
  a:update upperBand:midBand+2*mdev[7h$CFG`BAND_PERIOD;close] by K from a;
  a:update lowerBand:midBand-2*mdev[7h$CFG`BAND_PERIOD;close] by K from a;
  a:update rsi5:getRSI[close;5] by K from a;
  a:update enterLong:`boolean$((0^close<lowerBand) and (0^rsi5<CFG`RSI_ENTRY_MAX) and (0^volume>CFG`VOL_MIN)) from a;
  a:update entryPrice:close from a where enterLong=1; a:update entryPrice:fills entryPrice from a;
  /a:update tr:max each flip (close-prev close;high-low;abs high-prev close) by K from a;
  /a:update atr14:mavg[14h;tr] by K from a;
  /a:update posSize:min[(CFG`k)%atr14;CFG`MAX_LEV] from a;
  a:update uPNL:((close-entryPrice)%entryPrice) by K from a;
  a:update exitLong:`boolean$((0^close>midBand) or (0^uPNL>CFG`TP) or (0^uPNL<CFG`SL) or (0^time>"V"$CFG`EOD)) from a;
  a}

getBB:{[tm;s] / Calculate Bollinger Bandas for symbols 's' over time range 'tm', over 'n' periods
    tab:select from T where sym in s, time within tm;
    typicalPrice:avg(tab`high;tab`low;tab`close);
    simMovAvg:mavg[7h$CFG`BAND_PERIOD;typicalPrice];
    stdDev:mdev[7h$CFG`BAND_PERIOD;typicalPrice];
    upperBand:simMovAvg+stdDev*7h$CFG`BAND_K;
    lowerBand:simMovAvg-stdDev*7h$CFG`BAND_K;
    tab:update upperBand:upperBand, lowerBand:lowerBand from tab}

/
\l /data/pmorris/polygon/hdb/us_stocks_sip/
testTable:getBBands1[2025.09.01 2025.09.30;`JPM`GE`IBM]
a:select from T where date within 2025.09.01 2025.09.30,sym in `JPM`GE`IBM;

TOY SYSTEM: bar1m:select from bar1m where date=2025.01.03,sym=`A

enterLong
 close < lowerBand20, rsi5 < RSI_ENTRY_MAX, volume > VOL_MIN

exitLong
 close > midBand20
 or uPNL > TP
 or uPNL < SL
 or time > EOD

positionSize
 k / ATR14 capped at MAX_LEV


