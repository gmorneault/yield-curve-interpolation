%% Import securities

fred_source = fred('https://research.stlouisfed.org/fred2/');

% Import all maturities
mats_all = [1/12 1/4 1/2 1 2 3 5 7 10 20 30];
secs_all = {'DTB4WK' 'DTB3' 'DTB6' 'DTB1YR' 'DGS2' 'DGS3' 'DGS5' 'DGS7' 'DGS10' 'DGS20' 'DGS30'};
tsy_all = fetch(fred_source, secs_all, '1-jan-1961', '28-feb-2015');

% Import maturities used for fitting
mats_fit = [1/4 5 10];
secs_fit = {'DTB3' 'DGS5' 'DGS10'};
secs_fit_idx = ismember(secs_all, secs_fit);
tsy_fit = tsy_all(secs_fit_idx)

% Save securities
save Treasury_Securities.mat tsy_fit tsy_all

% Load securities
load('Treasury_Securities');


%% Create financial time series

% Time series using all maturities
for i=1:length(secs_all)
    sec = strtrim(tsy_all(i).SeriesID);
    idx = find(~isnan(tsy_all(i).Data(:,2)));
    temp = fints(tsy_all(i).Data(idx,1), tsy_all(i).Data(idx,2), sec);
    if i==1
        fts_all = temp;
    else
        fts_all = merge(fts_all, temp, 'DateSetMethod', 'union', 'Sort', 0);
    end
end

fts_all([1 end])

% Time series using only 3 mo, 5 yr, and 10 yr
for i=1:length(secs_fit)
    sec = strtrim(tsy_fit(i).SeriesID);
    idx = find(~isnan(tsy_fit(i).Data(:,2)));
    temp = fints(tsy_fit(i).Data(idx,1), tsy_fit(i).Data(idx,2), sec);
    if i==1
        fts_fit = temp;
    else
        fts_fit = merge(fts_fit, temp, 'DateSetMethod', 'intersection', 'Sort', 0);
    end
end

fts_fit([1 end])


fts_all = merge(fts_all, fts_fit, 'DateSetMethod', 'intersection', 'Sort', 0);
fts_all([1 end])
