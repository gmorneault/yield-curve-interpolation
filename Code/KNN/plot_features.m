function plot_features(feature_names, feature_values, distance)

figure
subplot(2,2,1)
scatter(feature_values(:,1), feature_values(:,2), 10, distance)
xlabel(feature_names(1))
ylabel(feature_names(2))

subplot(2,2,2)
scatter(feature_values(:,1), feature_values(:,3), 10, distance)
xlabel(feature_names(1))
ylabel(feature_names(3))

subplot(2,2,3)
scatter(feature_values(:,2), feature_values(:,3), 10, distance)
xlabel(feature_names(2))
ylabel(feature_names(3))

subplot(2,2,4)
hist(distance,100)
xlabel('Mahalanobis Distance')

