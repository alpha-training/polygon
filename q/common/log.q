\d .log

out:{[typ;msg]
 m:$[b:10=abs type msg;msg;" "sv .qi.tostr each msg];
 -1 typ," ",string[`time$.poly.now`]," ",m;
 }

info:out "info"
fatal:out "fatal"

\d .

