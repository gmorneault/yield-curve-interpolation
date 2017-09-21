%% import securities
secs = {'DTB4WK' 'DTB3' 'DTB6' 'DGS2' 'DGS3' 'DGS5' 'DGS7' 'DGS10' 'DGS20' 'DGS30'};
%c = fred('https://research.stlouisfed.org/fred2/');
%d = fetch(c,secs,'1-jan-1961','28-feb-2015');
load('Treasury_Securities');

%% test for Rodrigues equality with Laguerre polynomial

syms x;

j = {};
for k=1:20
    j{k,1} = sprintf('k = %d',k);
    rodrigues = exp(x) / factorial(k) * diff(x^k*exp(-x),x,k);
    rodrigues = simplify(rodrigues);
    if isequaln(rodrigues, laguerreL(k,x));
        j{k,2} = 'EQUAL';
    else
        j{k,2} = 'NOT EQUAL';
    end
end

j;


%% create Laguerre yield curve function

syms tau lambda beta c0 c1 c2 c3 c4

% define yield function
N=1;
F1 = sym(0);
for j = 0:N-1
    C = sym(0);
    for k = j+1:N
        C = C + sym(sprintf('c%d',k))/k;
    end
    F1 = F1 + C * laguerreL(j,lambda*tau);   
end

y = beta + c0*(1 - exp(-lambda*tau))/(lambda*tau) + exp(-lambda*tau)*F1;
yield = matlabFunction(y, 'Vars',{[beta lambda c0 c1 c2], tau})

% define difference function to minimize
F2 = sym(0);
for j = 0:N
    F2 = F2 + sym(sprintf('c%d',k)) * laguerreL(j,lambda*tau);   
end

dist = y - beta - exp(-lambda*tau)*F2;
distance = matlabFunction(dist, 'Vars',{[lambda c0 c1 c2], tau})


%% merge to one fts

% exclude 1m and 30y
for i=2:(length(secs)-1)
    sn = strtrim(d(i).SeriesID);
    idx = find(~isnan(d(i).Data(:,2)));
    temp = fints(d(i).Data(idx,1),d(i).Data(idx,2),sn);
    if i==2
        fts = temp;
    else
        fts = merge(fts, temp, 'DateSetMethod','intersection','Sort',0);
    end
end
fts([1 end])

%% define bond indices

ys = fts2mat(fts); % two 1st cols are bills
mats = [1/4 1/2 2 3 5 7 10 20];
billidx = [1 2];
bondidx = 3:length(mats);
tsyidx = [1 5 7];
otheridx = setdiff(1:length(mats),tsyidx);
idx = 1:length(ys);

%% plot history

subplot(1,2,1)

    plot(repmat(fts.dates(idx),1,3),ys(idx,tsyidx))
    legend({'3m' '5y' '10y'},'Location','Best')
    grid on
    datetick('x')
    recessionplot

subplot(1,2,2)

    level = ys(idx,tsyidx(3));
    slope = ys(idx,tsyidx(3))-ys(idx,tsyidx(1));
    curve = ys(idx,tsyidx(3))+ys(idx,tsyidx(1))-2*ys(idx,tsyidx(2));

    plot(repmat(fts.dates(idx),1,3),[level slope curve])
    legend({'level' 'slope' 'curve'},'Location','Best')
    grid on
    datetick('x')
    recessionplot

%% fit curve

guess = [1 1 1 1 1];
lb=[0.02 0.02 0.02 0.02 0.02];
ub=[30 30 30 30 30];
%options = optimoptions('lsqcurvefit','TolFun',1e-8,'Algorithm','levenberg-marquardt');
options = optimoptions('lsqcurvefit','TolFun',1e-8,'Display','off');

for i=idx(1:20)
    params(i,:) = lsqcurvefit(yield,guess,mats,ys(i,:),lb,ub,options);
end

%% plot fit

y_data = ys(10,:);
param = params(10,:);

plot(mats, yield(param, mats)); hold on
scatter(mats,y_data); hold off


%[beta lambda c0 c1 c2]
yield(param, mats)
