ENDPOINT:" --endpoint-url https://files.polygon.io"
ROOT:"s3://flatfiles/"

.cfg.setArg[`period;""]
.cfg.setArg[`asset;"us_stocks_sip"]
.cfg.setArg[`table;"minute_aggs_v1"]
.cfg.hasArg`delcsv
.cfg.hasArg`force
.z.zd:"J"$" "vs .env.HDB_COMPRESSION

HDB:.fs.path(.env.HDB;.cfg.asset);
FLAT_FILES:.qi.path(.env.FLAT_FILES;.cfg.asset);
CFG:.j.k raze read0 .qi.path (.env.POLY_CONFIG;.cfg.asset;.cfg.table,".json")

currentMonth:{}

getMonthPath:{[mnth]
  mm:-2#"0",sm:.qi.tostr mnth;
  "/" sv(.cfg.asset;.cfg.table;4#sm;mm;"")
  }

runCmd:{[cmd;addr] .fs.system "aws s3 ",cmd," ",ROOT,addr,ENDPOINT}

import:{[period]
  if[","in p:.qi.tostr period;:.z.s each","vs p];
  if[all"[-]"in p;
    root:(i:p?"[")#p;
    :.z.s each root,/:sn where(sn:string til 10)like i _p];
  $[4=c:count p;
    importYear p;
    c=7;
    importMonth p;
    importDate[getMonthPath 7#p;ssr[p;".";"-"],".csv.gz"]];
 }

importYear:{[yr]
 months:{x where x<="m"$.z.d}"M"$(.qi.tostr[yr],"."),/:-2#'"0",'string 1+til 12;
 importMonth each months;
 }
 
importMonth:{[mnth]
  p:getMonthPath mnth;
  r:runCmd["ls";p];
  f:last each" "vs'r;
  importDate[p]each f;
 }

importDate:{[p;f]
  sd:string d:"D"$first"."vs f;
  if[.cfg.force|0=count key tpath:.fs.path(HDB;sd;CFG`table_name;`);
    if[not any w:.fs.exists each {(x;-3_x)}gzpath:.fs.spath(FLAT_FILES;.cfg.table;7#sd;f);
      .fs.ensureDir "/"sv -1_"/"vs gzpath;
      runCmd["cp";p,f," ",gzpath]];
    if[not w 1;.fs.system"gunzip ",gzpath];
    convertDate[tpath;.fs.path csvpath:-3_gzpath;d];
    if[.cfg.delcsv;hdel .fs.path csvpath]];
 }

convertDate:{[tpath;csvpath;d]
  headers:`$.poly.arg[CFG;`headers;()];
  a:$[.poly.arg[CFG;`headersOnFirstLine;1b];
    headers xcol(CFG`types;enlist",")0:csvpath;
    flip headers!(CFG`types;",")0:csvpath];
 r:$[count pp:.poly.arg[CFG;`post_process;()];get[pp]a;a];
 .log.info("Writing to hdb";tpath);
 tpath set .Q.en[HDB;r];
 }

if[count .cfg.period;import .cfg.period];