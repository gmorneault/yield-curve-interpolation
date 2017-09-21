function [betas,tau] = fitNSwc(t3m,t5y,t10y,maturities,yields)
%% fit Nelson-Siegel, with 3m, 5y and 10y TSY constraints

fun = @(tau,maturities) [nelsony(maturities(maturities<1), findbetas(t3m,t5y,t10y,tau), tau) ...
    nelsonpy(maturities(maturities>=1), findbetas(t3m,t5y,t10y,tau), tau)];
guess = 1;
lb=0.02;
ub=30;
%options = optimoptions('lsqcurvefit','TolFun',1e-8,'Algorithm','levenberg-marquardt');
options = optimoptions('lsqcurvefit','TolFun',1e-8,'Display','off');
tau = lsqcurvefit(fun,guess,maturities,yields,lb,ub,options);
betas = findbetas(t3m,t5y,t10y,tau);

end

% function ys = getyields(t3m,t5y,t10y,maturities,yields)
% bills = find(maturities<1);
% ys = [nelsony(maturities(maturities<1), findbetas(t3m,t5y,t10y,tau), tau)
% 
% [nelsony(maturities(maturities<1), findbetas(t3m,t5y,t10y,tau), tau) ...
%     nelsonpy(maturities(maturities>=1), findbetas(t3m,t5y,t10y,tau), tau);
% 
% end