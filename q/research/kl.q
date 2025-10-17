/ Generalised script to manage signals
\c 30 180
rfills:reverse fills reverse@
N:1000000
SYMS:`AAPL`BP`IBM
PX:SYMS!25.00 47.20 87.34
S:N?SYMS
sizeOrder:7h$.1*

DROP_COLS:`enterI`entry`next_enter`next_exit_long`next_exit_short`exiting _
PNL:.03
pnlf:{[long;en;ex] PNL<=$[long;ex-en;en-ex]}

bar:([]sym:S;time:09:30:00.0+til N;price:PX[S]+.01*N?10;size:N?100*1+til 20;enter_long:N?00001b;exit_long:N?00001b;enter_short:N?00001b;exit_short:N?00001b)

.u.J:SYMS!count[SYMS]#0

checkRow:{[price;entry;next_enter;exit_long;exit_short;next_exit_long;next_exit_short;x]
 j:x 0;
 exiting:x 1;
 entryPx:x 2;
 order:x 3;
 state:signum position:x 4;
 note:x 5;
 if[exiting;  / if exiting
   if[null en:next_enter j;:x];
   if[en=j;if[null en:next_enter j+1;:x]];
   order:entry en;
   :(en;0b;price en;order;0;`)];
  newPos:position+order;
  exl:exs:0N;
  if[long:1h=newState:signum newPos;
    if[null exl:next_exit_long j;:x]];
  if[not long;
    if[null exs:next_exit_short j;:x]];
 ex:(exs;exl)long;  / index of the next exit
 if[count[pnlExits]>w1:(pnlExits:pnlf[long;entryPx;price w:j+1+til ex-j])?1b;
   :(w w1;1b;entryPx;neg newPos;newPos;`pnl)];
 (ex;1b;entryPx;neg newPos;newPos;`sig)
 }

runPerSym:{[price;j;entry;next_enter;exit_long;exit_short;next_exit_long;next_exit_short]
  flip`I`exiting`entryPx`order`opos`note!flip checkRow[price;entry;next_enter;exit_long;exit_short;next_exit_long;next_exit_short]\[(j;0b;price j;entry j;0;`)]
  }

run:{[a]
  a:update enter_long:0b from a where exit_long;
  a:update enter_short:0b from a where exit_short;
  a:update enter_long:0b,enter_short:0b from a where enter_long,enter_short;
  a:update I:-1+sums i=i by sym from a;
  a:update enter:1b,enterI:I,entry:sizeOrder[size]*-1 1 enter_long from a where enter_long|enter_short;
  a:update next_enter:rfills enterI,next_exit_long:rfills ?[exit_long;I;0N],next_exit_short:rfills ?[exit_short;I;0N] by sym from a;
  rs:exec runPerSym[price;enter?1b;entry;next_enter;exit_long;exit_short;next_exit_long;next_exit_short]by sym from a;
  r:DROP_COLS a lj 2!raze{[rs;s]`sym`I xcols update sym:s from rs s}[rs]each key rs;
  r:update fills entryPx,npos:fills opos+order by sym from r;
  r:update upnl:abs[npos]*-1 1[npos>0]*price-entryPx from r where null note,npos<>0;
  update rpnl:opos*price-entryPx from r where not null note
 }

\ts nbar:run bar
aa:select from nbar where sym=`AAPL