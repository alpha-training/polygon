/ Generalised script to manage signals
\c 30 145
rfills:reverse fills reverse@
N:1000000
SYMS:`AAPL`BP`IBM
PX:SYMS!25.00 47.20 87.34
S:N?SYMS
bar:([]sym:S;time:09:30:00.0+til N;price:PX[S]+N#sums(N#-3 1 2 -2 3 5 2 1 4)%100;enterSig:N#00001010000001001b;exitSig:N#01001000b;size:N?100*1+til 20)
update autoExit:1b from `bar where i>N-300;
update enterSig:0b from`bar where exitSig|autoExit;
show meta update I:-1+sums i=i by sym from `bar;
update enterI:I,side:{rand -1 1}each i from `bar where enterSig,not exitSig;
update exitI:I from `bar where exitSig;
update nextEnter:rfills enterI,nextExit:rfills exitI by sym from `bar;
update nextEnter:next nextEnter by sym from`bar where nextEnter=enterI;

PNL:.07
pnlf1:{[en;ex] PNL<=ex-en}

/ CK:`I`existing`enterPrice`action
check:{[s;pnlf;exitSig;px;nextEnter;nextExit;x]
 j:x 0;enterPx:x 1;
 if[x 2;  / if exiting
   if[null en:nextEnter j;:x];
   :(en;px en;0b;`enter)];
 if[exitSig j;:(j;enterPx;1b;`sig)];
 if[null ex:nextExit j;:x];
 if[min pnlExits:pnlf[enterPx;px w:j+1+til ex-j];
  :(w pnlExits?1b;enterPx;1b;`pnl)];
 (ex;enterPx;1b;`sig)
 }

run:{[s;pnlf;exitSig;px;nextEnter;nextExit;enterSig]
  j:enterSig?1b;
  r:flip`I`enterPx`exiting`action!flip check[s;pnlf1;exitSig;px;nextEnter;nextExit]\[(j;px j;0b;`enter)];
  update sym:s from r
  }

\ts r:raze get exec run[first sym;pnlf1;exitSig;price;nextEnter;nextExit;enterSig] by sym from bar

nbar:bar lj `sym`I xkey r