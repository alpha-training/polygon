\l /data/iwickham/polygon/hdb/us_stocks_sip
T:bar1m

/join multiple assets into one strat

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

simplestrat:{[tr;Tsym]
    strat1::bolbands[tr;Tsym;20;1]; /add bolbands column
    update rsi:rsiMain[close;5] from `strat1; /add RSI column
    update return:(close - prev close)%close from `strat1; /add %return column
    strat1::20_strat1; /burn off first 20 rows of data
    update pos:prev prev ((close<LB) & (rsi<40) & (volume>500)) from `strat1; /position open given by 1 no longer open given by 0, lagged by two as first return recieved in two ticks
    update portfolio_return:pos*return from `strat1; /add in portfolio return
    update equity:prds 1+pos*return from `strat1; / accumalted portfolio  return
    update dd:(equity-((|\)equity))% ((|\)equity) from `strat1; / adding in rolling max drawdown; given by (current acc return-max acc return)%max acc return
    (`$"strat1_",string[Tsym]) set strat1;
    stratacc_return:select equity from -1#strat1; /final entry in acc return column
    sharpe_ratio:((avg pr)%sdev pr:select portfolio_return from strat1)*sqrt 98280; /annualised sharpe ratio, minute bars 98280 amount of minutes in trading year
    (`Sharpe_Ratio`Asset_Return`standard_dev`max_drawdown)!(first raze sharpe_ratio;-1+first raze stratacc_return;first sdev pr;min strat1`dd) /show acc return and sharpe ratio and max dd
  }

/covariance function
covar:{{x[y] cov/: x}[x;] each til (x#:)}

/equal weighted Multi asset strat 
multiassetstrat:{[tr;tickers]
  massettable::(tickers)!simplestrat[tr]each tickers;
  weights:(count tickers)#1%count tickers;
  /mean return 
  multiassetport_ret:sum weights*(value massettable)`Asset_Return;
  /calculating portfolio standard deviation
    }



<<<<<<< HEAD
=======
/
EMA:{[tr;Tsym;short;long]
  update emashort:ema[short;prev close],emalong:ema[long;prev close] from T
}
\

STOCHF:{[tr;Tsym;n;m]
    timerange: select from T where date within tr, sym in Tsym;
    Hn:mmax[n]timerange`high;
    Ln:mmin[n]timerange`low;
    K:100*((timerange`close)-Ln)%(Hn-Ln);
    D: mavg[m;K];
    update K:K, D:D from timerange
  }


STOCH:{[tr;Tsym;n;m]
    timerange: select from T where date within tr, sym in Tsym;
    Hn: mmax[n] timerange`high;
    Ln: mmin[n] timerange`low;
    Kfast:100*((timerange`close)-Ln)%(Hn-Ln);
    Kslow:mavg[m;Kfast];
    Dslow:mavg[m;Kslow];
    update Kslow:Kslow,Dslow:Dslow from timerange
    } 

DEMA:{[x;n]
  a:2f % (n+1);       / convert period to alpha
  ema1: ema[a; x];    / first EMA
  ema2: ema[a; ema1]; / EMA of the EMA
  (2f * ema1) - ema2  / combine
}

DEMA:{[]}

dema:{[x;n]
  a:2f % (n+1);       / convert period to alpha
  ema1: ema[a; x];    / first EMA
  ema2: ema[a; ema1]; / EMA of the EMA
  (2f * ema1) - ema2  / combine

}

/

Kieran Feedback

in simple strat, the way you build strat1 is not the recommended way

Instead of setting a global variable, better to create a local variable and amend it on each line

e.g. 

a:select from ...
a:upadate col1:...
a:update col2:func col1 etc

I also suspect that you are not doing by sym
>>>>>>> 3938bacac5650e7cce89b20f12ec6827b10d8e61
