name = 'MouseColonAsc.txt';
np = 8;
vf = 0.85;
cct = 19;
wt = 8;
Mnp = (np-3):(np+4);
Mvf = [1,0.9,0.875,0.825,0.75,0.7,0.65,0.6];
make_params(np,vf,cct,wt,Mnp,Mvf,name)


name = 'MouseColonTrans.txt';
np = 12;
vf = 0.9;
cct = 21;
wt = 22;
Mnp = (np-3):(np+6);
Mvf = [1, 0.95, 0.925, 0.875, 0.85, 0.8, 0.75, 0.7];
make_params(np,vf,cct,wt,Mnp,Mvf,name)


name = 'MouseColonCaecum.txt';
np = 8;
vf = 0.6125;
cct = 15.5;
wt = 7.5;
Mnp = (np-3):(np+6);
Mvf = [0.5:.05:0.65, 0.625,0.7,0.8,0.9];
make_params(np,vf,cct,wt,Mnp,Mvf,name)


name = 'RatColonAsc.txt';
np = 16;
vf = 0.65;
cct = 39;
wt = 13;
Mnp = (np-3):(np+6);
Mvf = [0.5:.05:0.6, 0.625, 0.675,0.7,0.8,0.9];
make_params(np,vf,cct,wt,Mnp,Mvf,name)


name = 'RatColonDesc.txt';
np = 28;
vf = 0.7;
cct = 57;
wt = 8;
Mnp = (np-3):(np+6);
Mvf = [0.55, 0.6, 0.65, 0.675, 0.725, 0.75,0.8,0.9];
make_params(np,vf,cct,wt,Mnp,Mvf,name)


name = 'RatColonCaecum.txt';
np = 12;
vf = 0.8;
cct = 25;
wt = 8;
Mnp = (np-3):(np+6);
Mvf = [0.65, 0.7, 0.75, 0.775, 0.825, 0.85,0.9,1];
make_params(np,vf,cct,wt,Mnp,Mvf,name)


name = 'RatColonTrans.txt';
np = 20;
vf = 0.6;
cct = 42;
wt = 9;
Mnp = (np-3):(np+6);
Mvf = [0.5, 0.55, 0.575, 0.625, 0.65,0.7,0.8, 0.9];
make_params(np,vf,cct,wt,Mnp,Mvf,name)