function betas = findbetas(t3m,t5y,t10y,tau)
%% for a given tau in Nelson-Siegel, find beths to fit 3m, 5y and 10y TSY
F = @(betas) [t3m - nelsony(3/12, betas,tau);
    t5y - nelsonpy(5, betas,tau);
    t10y - nelsonpy(10, betas,tau)];
guess = [t10y, t3m-t10y, 0];
options = optimoptions('fsolve','TolFun',1e-8,'Display','off');
% ,'DiffMaxChange',10);
[betas,fval,exitflag,output] = fsolve(F, guess, options);

end
