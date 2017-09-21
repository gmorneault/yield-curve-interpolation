%% Generate forecasts

% generate individual 2 quarter histories for each date in the
% financial time series 

num_qtrs = 1;

for i=1:length(fts_fit)-100
    start_date = getfield(fts_fit(i), 'dates');
    start_date = datestr(start_date);
    temp_fcst_fit = fts_fit(start_date);
    temp_fcst_all = fts_all(start_date);
    for j=1:num_qtrs
        date_found = 0;
        date_search = datestr(datemnth(start_date,j*3,0,0,0));
        while date_found == 0 & date_search < fts_fit.dates(end)
            if isempty(fts_fit(date_search))
                date_search = datestr(datetime(date_search) + caldays(1));
            else
                date_found = 1;
                temp_fcst_fit = [temp_fcst_fit; fts_fit(date_search)];
                temp_fcst_all = [temp_fcst_all; fts_all(date_search)];
            end
        end
    end
    fts_obj(i) = struct('date', start_date, 'T_fit', fts2mat(temp_fcst_fit), 'T_all', temp_fcst_all);
end

%% Calculate features

array_qtrs = [1:num_qtrs+1]';
feat_names = {'spot_T6mo' 'spot_T5yr' 'spot_T10yr' 'chg_T6mo' 'chg_T5yr' 'chg_T10yr' ...
              'spot_level' 'spot_slope' 'spot_curve' 'chg_level' 'chg_slope' 'chg_curve'}';


fts_obj(length(fts_obj)).features = []

for i=1:length(fts_obj)
    
    % Calculate features for 6mo, 5yrs, and 10yrs treasury
    array_T6mo = fts_obj(i).T_fit(:,1);
    array_T5yr = fts_obj(i).T_fit(:,2);
    array_T10yr = fts_obj(i).T_fit(:,3);

    spot_T6mo = array_T6mo(1);
    spot_T5yr = array_T5yr(1);
    spot_T10yr = array_T10yr(1);

    %lm_T6mo = fitlm(array_qtrs, array_T6mo);
    %lm_T5yr = fitlm(array_qtrs, array_T5yr);
    %lm_T10yr = fitlm(array_qtrs, array_T10yr);

    %chg_T6mo = (array_T6mo(2) - array_T6mo(1)) / array_T6mo(1);
    %chg_T5yr = (array_T5yr(2) - array_T5yr(1)) / array_T5yr(1);
    %chg_T10yr = (array_T10yr(2) - array_T10yr(1)) / array_T10yr(1);

    chg_T6mo = log(array_T6mo(2) / array_T6mo(1));
    chg_T5yr = log(array_T5yr(2) / array_T5yr(1));
    chg_T10yr = log(array_T10yr(2) / array_T10yr(1));
    
    % Calculate features for level, slope, and curve
    array_level = array_T10yr;
    array_slope = array_T10yr - array_T6mo;
    array_curve = 2*array_T5yr - array_T10yr - array_T6mo;

    spot_level = array_level(1);
    spot_slope = array_slope(1);
    spot_curve = array_curve(1);

    %lm_Tlevel = fitlm(array_qtrs, array_Tleftsvel);
    %lm_Tslope = fitlm(array_qtrs, array_Tslope);
    %lm_Tcurve = fitlm(array_qtrs, array_Tcurve);

    %chg_level = (array_level(2) - array_level(1)) / array_level(1);
    %chg_slope = (array_slope(2) - array_slope(1)) / array_slope(1);
    %chg_curve = (array_curve(2) - array_curve(1)) / array_curve(1);

    chg_level = log(array_level(2) / array_level(1));

    if array_slope(2) / array_slope(1) < 0
        chg_slope = -log(-1 * array_slope(2) / array_slope(1));
    else
        chg_slope = log(array_slope(2) / array_slope(1));
    end
    
    if array_curve(2) / array_curve(1) < 0
        chg_curve = -log(-1 * array_curve(2) / array_curve(1));
    else
        chg_curve = log(array_curve(2) / array_curve(1));
    end
       
    feat_values = {spot_T6mo spot_T5yr spot_T10yr chg_T6mo chg_T5yr chg_T10yr ...
                   spot_level spot_slope spot_curve chg_level chg_slope chg_curve}';
    fts_obj(i).features = cell2struct(feat_values, feat_names, 1);
   
end


% Create temporary X data to remove null and inf features
X = struct2array(fts_obj(1).features);
parfor i=2:length(fts_obj)
    X = [X; struct2array(fts_obj(i).features)];
end

% Filter NaN and Inf
filter = not(any(isinf(X) | isnan(X),2));
X = X(filter, :);
fts_obj = fts_obj(filter);

% Save FTS Object
save FTS_Object.mat fts_obj




