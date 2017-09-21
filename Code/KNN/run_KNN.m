function [KNN] = run_KNN(features, objects, number_neighbors, test_idx)

test_features = features(test_idx,:);
test_objects = objects(test_idx);

train_features = features(~test_idx,:);
train_objects = objects(~test_idx);

NS = ExhaustiveSearcher(train_features, 'Distance', 'mahalanobis');



KNN = struct;
for i=1:length(test_objects)
    KNN(i).test_features = test_features(i,:);
    KNN(i).test_points = fts2mat(test_objects(i).T_all);
    results_idx = knnsearch(NS, test_features(i,:), 'K', number_neighbors);
    results_objects = train_objects(results_idx);
    KNN(i).results_features = train_features(results_idx,:);
    for j=1:length(results_objects)
        KNN(i).results_points{j} = fts2mat(results_objects(j).T_all);
    end    
end


cov_mat = NS.DistParameter;
inv_cov_mat = inv(cov_mat);

for i=1:length(KNN)
    a = KNN(i).test_features;
    b = KNN(i).results_features;
    for j=1:length(number_neighbors)
        dist(j) = sqrt((a - b(j,:)) * inv_cov_mat * (a - b(j,:))');
    end
    KNN(i).distance = dist;
    KNN(i).avg_distance = mean(dist);
end

