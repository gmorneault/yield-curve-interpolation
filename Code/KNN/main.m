%% Import
run('import_time_series')

%% Generate features
run('create_features')

fts_obj

%% Load FTS Object
load FTS_Object.mat


%% Unpack dates and features

% unpack dates
for i=1:length(fts_obj)
    dates{i} = fts_obj(i).date;
end
dates = datetime(dates);

% unpack features
for i=1:length(fts_obj)
    X(i,:) = struct2array(fts_obj(i).features);
end


%% Calculate distance metrics and plot

% for Treasury 3 mo, 5 yr, and 10 year spot and change
X1 = X(:,1:6);

% for level, slope, and curve for spot and change
X2 = X(:,7:12);

% scatter3(X1(:,1), X1(:,2), X1(:,3), 10, Y1(:,1))
% xlabel(feat_names(1))
% ylabel(feat_names(2))
% zlabel(feat_names(3))



%% Create test and train sets

objects = fts_obj;
number_neighbors = 10;

% Define date range for test sample
start_date = '1/1/2013';
end_date = '12/31/2013';
test_idx = dates >= datetime(start_date) & dates <= datetime(end_date);


%% Apply KNN for Treasury 6 mo, 5 yr, and 10 year spot and change

features = X(:,1:6);
KNN_results = run_KNN(features, objects, number_neighbors, test_idx);
evaluate_KNN(KNN_results);


%% Apply KNN for level, slope, and curve for spot and change

features = X(:,7:12);
KNN_results = run_KNN(features, objects, number_neighbors, test_idx);
evaluate_KNN(KNN_results);


