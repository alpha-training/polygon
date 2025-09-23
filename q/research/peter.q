T:`bar1m

getBB:{[tm;s;n] / Calculate Bollinger Bands for symbols 's' over time range 'tm', over 'n' periods
    tab:select from T where sym in s, time within tm;
    typicalPrice:avg(tab[`high];tab[`low];tab[`close]);
    simMovAvg:mavg[n;typicalPrice];
    stdDev:mdev[n;typicalPrice];
    upperBand:simMovAvg+2*stdDev;
    lowerBand:simMovAvg-2*stdDev;
    update upperBand:upperBand, lowerBand:lowerBand from tab}