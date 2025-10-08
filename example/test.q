system"l ",getenv[`HOME],"/code/qi/qi.q"
include`qs
.qs.loadCustomSettings`test.json

\l /data/pmorris/polygon/hdb/us_stocks_sip/

getBB:{[dt;s] .qs.bollBands select from bar1m where date=dt,sym in s}

r:getBB[max date;`AAPL`MSFT]