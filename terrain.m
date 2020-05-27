function [r]=terrain(x,y)


global wi;
global di;
global zcubic;
%得到某一点高度
r=interp2(wi,di,zcubic,x,y);