/ entry file

{
   if[not count poly_home:getenv`POLY_HOME;
     -1".env must be loaded. Try running:\nsource .env\nExiting"; exit 0];
    
    a:read0 hsym `$poly_home,"/.env";
    a:@[a;where a like"export*";7_];
    a@:where 0<count each a;
    {sv[`;`.env,x]set getenv x}each `$first flip "="vs'a;
 }[];

system"l ",.env.QI_HOME,"/qi.q"
system"l ",.env.POLY_HOME,"/q/common/log.q"
system"l ",.env.POLY_HOME,"/q/common/poly.q"
system"l ",.env.POLY_HOME,"/q/common/fs.q"
.fs.load "q/common/cfg.q"

if[`script in key .cfg.args;
  .fs.load .env.Q_SCRIPTS,"/",.fs.dotq .cfg.args`script];