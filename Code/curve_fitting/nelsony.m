function y = nelsony(maturities,betas,tau)
%% Nelson-Siegel spot rate, cont compounded
% based on Eq.20 and 22 from GSW

a = maturities/tau;
b = exp(-a);
c = (1-b)./a;

y = betas(1) + betas(2)*c + betas(3)*(c-b);
end


