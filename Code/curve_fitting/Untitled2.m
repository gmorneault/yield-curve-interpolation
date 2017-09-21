nelsony([1 2 3 4 5 6 7 8 9 20],[3.91760612	-1.27795525	-1.9493971],0.33921759)

nelsonpy([1 2 3 4 5 6 7 8 9 20],[3.91760612	-1.27795525	-1.9493971],0.33921759)


%% '1-Feb-2001'
disp '=== Test beta fit ======='
tsys = [4.87, 4.78, 5.1]
tau = 0.43;
betas = findbetas(tsys(1), tsys(2), tsys(3), tau)
[nelsony(1/4, betas, tau) nelsonpy([5,10],betas,tau)]

%
disp '=== Test NS fit ======='
maturities = [1/2 2 3 7 20 30];
yields = [4.63 4.55 4.59 5.01 5.55 5.46];

[betas,tau] = fitNSwc(tsys(1), tsys(2), tsys(3), maturities, yields)
[nelsony(1/2,betas,tau) nelsonpy(maturities(2:end),betas,tau)]

[nelsony(1/4, betas, tau) nelsonpy([5,10],betas,tau)]

mats = [1/4 1/2 2 3 5 7 10 20 30]
ys = [tsys(1) yields(1:3) tsys(2) yields(4) tsys(3) yields(end-1:end)]

scatter(mats,ys,'+r')
hold on
plot(mats(1:2),nelsony(mats(1:2),betas,tau),'k')
plot(mats(3:end),nelsonpy(mats(3:end),betas,tau),'b')

