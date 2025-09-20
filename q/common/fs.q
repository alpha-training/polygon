/ File system

\d .fs

path:{$[-11=type s:$[type x;::;each][.qi.tosym]x;hsym s;` sv @[s;0;hsym]]}
spath:1_string path@
exists:not()~key path@
dotq:{$[x like"*.q";x;x,".q"]}
ensureDir:{[p] if[not exists dir:path p;.fs.system "mkdir -p ",1_string dir]; dir}
.fs.system:{.log.info"system ",x;system x}
.fs.load:{.fs.system"l ",1_string path x}

loadCSV:{(y;enlist",")0:x}
 