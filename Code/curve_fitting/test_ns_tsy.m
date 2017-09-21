%% Define securities
secs = {'DTB4WK' 'DTB3' 'DTB6' 'DGS2' 'DGS3' 'DGS5' 'DGS7' 'DGS10' 'DGS20' 'DGS30'}

%% import and save securities
c = fred('https://research.stlouisfed.org/fred2/');
d = fetch(c,secs,'1-jan-1961','28-feb-2015');
save Treasury_Securities.mat d

%% load securities
load Treasury_Securities.mat

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

%% fit NS whith constraint on t3m, t5y, t10y
ys = fts2mat(fts); % two 1st cols are bills

mats = [1/4 1/2 2 3 5 7 10 20];
billidx = [1 2];
bondidx = 3:length(mats);
tsyidx = [1 5 7];
otheridx = setdiff(1:length(mats),tsyidx);

params = NaN(length(ys),4);
yhats = NaN(size(ys));
j = 0;
idx = 1:length(ys);
for i=idx
    %fprintf('%d\n',i)
    tsys = ys(i,tsyidx);
    yields = ys(:,otheridx);
    
    [betas,tau] = fitNSwc(tsys(1), tsys(2), tsys(3), mats(otheridx), ys(i,otheridx));
    params(i,:) = [betas,tau];
    
    yhats(i,:) = [nelsony(mats(billidx),betas,tau) nelsonpy(mats(bondidx),betas,tau)];
    fprintf('.')
    j = j+1;
    if ~rem(j,100)
        fprintf('%d\n',i)
    end
        
end

store.params = params;
store.yhats = yhats;
save Fitted_Values.mat store

%% load parameters
load Fitted_Values.mat
params = store.params;
yhats = store.yhats;

%% plot the fits vs. the curve
%scatter(repmat(mats,1,length(idx)),reshape(ys(idx,:),1,length(idx)*size(ys,2)),'+r')
%scatter(repmat(1:length(mats),1,length(idx)),reshape(ys(idx,:),1,length(idx)*size(ys,2)),'+r')
%pidx = 3092;
pidx = 1:100:length(idx);
plot(repmat(1:length(mats),length(idx(pidx)),1)',ys(idx(pidx),:)','-+r')
hold on
plot(repmat(1:length(mats),length(idx(pidx)),1)',yhats(idx(pidx),:)','k')
ax = gca;
ax.XTick=1:length(mats);
ax.XTickLabel=num2str(mats');
ax.XTickLabel=num2str(mats');


%% plot params

find(params(:,2)>100)

figure
subplot(,1,1)
plot(repmat(fts.dates(idx),1,4),params(idx,:))
legend({'\beta_0' '\beta_1' '\beta_2' '\tau_1'},'Location','Best')
grid on
datetick('x')
ylim([-30,30])
recessionplot

subplot(3,1,2)
plot(repmat(fts.dates(idx),1,3),ys(idx,tsyidx))
legend({'3m' '5y' '10y'},'Location','Best')
grid on
datetick('x')
recessionplot

subplot(3,1,3)
level = ys(idx,tsyidx(3));
slope = ys(idx,tsyidx(3))-ys(idx,tsyidx(1));
curve = ys(idx,tsyidx(3))+ys(idx,tsyidx(1))-2*ys(idx,tsyidx(2));

plot(repmat(fts.dates(idx),1,3),[level slope curve  ])
legend({'level' 'slope' 'curve'},'Location','Best')
grid on
datetick('x')
recessionplot

%% correlations


scatter(level,params(:,1),'+')
title '\beta_0 level'

scatter(slope,params(:,1),'+')
title '\beta_1 slope'

scatter(slope,params(:,1),'+')
title '\beta_1 slope'

pidx = setdiff(1:length(idx),3092);

corrplot([params(pidx,:) level(pidx,:) slope(pidx,:) curve(pidx,:)],'testR','on','varNames',{'b0' 'b1' 'b2' 't1' 'level' 'slope' 'curve'})

corrplot([params(pidx,:) ys(pidx,tsyidx)],'testR','on','varNames',{'b0' 'b1' 'b2' 't1' '3m' '5y' '10y'})

%% autocorrelation structure
%pidx = 1:length(idx);
figure
for i=1:4
    subplot(4,2,2*i-1)
    autocorr(params(pidx,i),40)
    subplot(4,2,2*i)
    parcorr(params(pidx,i),40)
end

%% ARIMA on tau1
%mdl = arima('ARLags',[21,42],'MALags',[21]);
mdl = arima('ARLags',[21 42  ],'MALags',[]);
tau = params(:,4);

P = mdl.P;
y = log(tau(P+1:end));
y0 = log(tau(1:P));
%X = ys(:,tsyidx);
zlb = ys(:,tsyidx(1))<0.25;
X = [slope.*(slope<.25) slope.*(slope>=.25) curve.*(slope>=.25) curve.*(slope<.25) zlb  ];
%corrplot(X,'testR','on','varNames',{'slop-' 'slope+' 'courve*slope-' 'courve*slope+' 'zlb'})

[EstMdl,EstParamCov,logL,info] = estimate(mdl,y,'Y0',y0,'X',X);
%[EstMdl,EstParamCov,logL,info] = estimate(mdl,y);
EstMdl

aic = aicbic(logL,length(EstParamCov))

[E,V] = infer(EstMdl,y,'Y0',y0,'X',X);
%[E,V] = infer(EstMdl,y);

subplot(2,1,1)
plot(fts.dates(P+1:end),E)
datetick('x')
recessionplot
subplot(2,1,2)
plot(fts.dates(P+1:end),exp(y),'r')
hold on
plot(fts.dates(P+1:end),exp(y-E),'b')
datetick('x')
recessionplot
grid on

%% test code
params = [];
%for i = 1:100:length(fts)
i=1401
    Settle = fts.dates(i);
    % basis act/360
    % Maturity = datemnth(Settle,[1 3 6 12*[2 3 4 5 7 10 30]]', 0, 2);
    Maturity = datemnth(Settle,[1 3 6 12*[2 3 4 5 7 10 30]]');

    CleanPrice = repmat(100,size(Maturity));
    CouponRate = fts2mat(fts(i))'/100;
    Instruments = [repmat(Settle,size(Maturity)) Maturity CleanPrice CouponRate];
    InstrumentPeriod = [12./[1 3 6]'; repmat(4,7,1)];

    PlottingPoints = datemnth(Settle,12:12:360);
    zPlottingPoints = datemnth(Settle,1:12);
    Yield = CouponRate;
    
    opop = optimset('TolFun',1e-8,'MaxIter',1000,'Algorithm','levenberg-marquardt');
    opts = IRFitOptions([CouponRate(1) CouponRate(end)-CouponRate(1) 3 10 1 10],...
        'FitType','Yield','OptOptions',opop);

%    SvenssonModel = IRFunctionCurve.fitNelsonSiegel('Zero',Settle,Instruments,...
    SvenssonModel = IRFunctionCurve.fitSvensson('Zero',Settle,Instruments,...
        'InstrumentPeriod',InstrumentPeriod,'IRFitOptions',opts);
    %    'InstrumentPeriod',InstrumentPeriod,'Basis',2);

    params = [params; SvenssonModel.Parameters];

    % create the plot
    plot(4:10, getParYields(SvenssonModel, Maturity(4:10)),'g')
    hold on
    plot(1:3, getZeroRates(SvenssonModel, Maturity(1:3)),'r')
    plot(1:10,Yield,'+k')
    %datetick('x')
    i
%end

legend({'Svensson Fitted Curve','Yields'},'location','best')

%% Use tau from this paper, and produce yield curves
% Forecasting the term structure of government
% bond yields
% Francis X. Diebolda,b, Canlin Lic,
lambda = 0.0609;
tau = 1/lambda/12;

ys = fts2mat(fts); % two 1st cols are bills

mats = [1/4 1/2 2 3 5 7 10 20];
billidx = [1 2];
bondidx = 3:length(mats);
tsyidx = [1 5 7];
otheridx = setdiff(1:length(mats),tsyidx);

params = NaN(length(ys),4);
yhats = NaN(size(ys));
j = 0;
idx = 1:length(ys);
for i=idx
    %fprintf('%d\n',i)
    tsys = ys(i,tsyidx);
    yields = ys(:,otheridx);
    
    betas = findbetas(tsys(1), tsys(2), tsys(3), tau);
    params(i,:) = [betas,tau];
    
    yhats(i,:) = [nelsony(mats(billidx),betas,tau) nelsonpy(mats(bondidx),betas,tau)];
    fprintf('.')
    j = j+1;
    if ~rem(j,100)
        fprintf('%d\n',i)
    end
        
end

store_t.params = params;
store_t.yhats = yhats;
