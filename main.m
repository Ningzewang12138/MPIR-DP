clc
clear

N = 3;
D = 2;
K = 5;
delta = 0;
dc = [];



for eps =log(3):log(3) 
[p,tmp]= PIR_DP(N,K,D,eps,delta);
dc = [dc,tmp];
end