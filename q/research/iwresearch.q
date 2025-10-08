\l /data/iwickham/polygon/hdb/us_stocks_sip
T:bar1m

bolbands:{[tr;Tsym;n;z]
    timerange:select from T where date within (tr),sym in Tsym;
    MB:update mb:mavg[n;prev close],rsd:mdev[n;prev close] from timerange;
    bolbands:update UB:mb+z*rsd,LB:mb-z*rsd from MB
    }

relativeStrength:{[num;y]
  begin:num#0Nf;
  start:avg((num+1)#y);
  begin,start,{(y+x*(z-1))%z}\[start;(num+1)_y;num] 
  }

rsiMain:{[close;n]
  diff:-[close;prev close];
  rs:relativeStrength[n;diff*diff>0]%relativeStrength[n;abs diff*diff<0];
  rsi:100*rs%(1+rs);
  rsi 
  }

bbsimplestrat:{[tr;Tsym]
    strat1::bolbands[tr;Tsym;20;1]; /add bolbands column
    update rsi:rsiMain[close;5] from `strat1; /add RSI column
    update return:(close - prev close)%close from `strat1; /add %return column
    strat1::20_strat1; /burn off first 20 rows of data
    update pos:prev prev ((close<LB) & (rsi<40) & (volume>500)) from `strat1; /position open given by 1 no longer open given by 0, lagged by two as first return recieved in two ticks
    update portfolio_return:pos*return from `strat1; /add in portfolio return
    update equity:prds 1+pos*return from `strat1; / accumalted portfolio return
    update dd:(equity-((|\)equity))% ((|\)equity) from `strat1; / adding in rolling max drawdown; given by (current acc return-max acc return)%max acc return
    stratacc_return::select equity from -1#strat1; /final entry in acc return column
    sharpe_ratio:((avg pr)%sdev pr:select portfolio_return from strat1)*sqrt 98280; /annualised sharpe ratio, minute bars 98280 amount of minutes in trading year
    (`Sharpe_Ratio`Portfolio_Return`max_drawdown)!(first raze sharpe_ratio;first raze stratacc_return;min strat1`dd) /show acc return and sharpe ratio and max dd
    }