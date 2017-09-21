function py = nelsonpy(maturities,betas,tau)
%% Nelson-Siegel par yield, CEY
% based on Eq.7, 20 and 22 from GSW

py = 2*(1-discount(nelsony(maturities,betas,tau),maturities));
for i=1:length(maturities)
    mats = (1:2*maturities(i))/2;
    py(i) = py(i) / sum(discount(nelsony(mats,betas,tau),mats));
end
py = py*100;
end
function d = discount(yields, maturities)
%% discount factor
% GSW Eq. 2
d = exp(-yields.*maturities/100);
end

