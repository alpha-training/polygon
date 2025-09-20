\d .cfg

EPOCH_OFFSET:946684800000000000

args:first each .Q.opt .z.x
setArg:{[k;default] sv[`;`.cfg,k] set .poly.arg[args;k;default];}
hasArg:{[k] sv[`;`.cfg,k]set k in key args;}