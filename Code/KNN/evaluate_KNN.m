function evaluate_KNN(KNN_results)

number_neighbors = length(KNN_results(1).results_features);
maturities = [1/12 1/4 1/2 1 2 3 5 7 10 20 30];

% extract average distances and take best and worst fits
for i=1:length(KNN_results)
    distance(i) = KNN_results(i).avg_distance;
end

[D, sort_idx] = sort(distance);
worst_fits = KNN_results(sort_idx(end:-1:end-15));
best_fits = KNN_results(sort_idx(1:16));


% plot worst fits
fig = figure;
fig.Name = 'Worst Fits';
for i=1:16
    subplot(4,4,i)
    title(sprintf('%d of %d\ndistance = %d', i, 16, worst_fits(i).avg_distance))
    hold on
    scatter(maturities, worst_fits(i).test_points(1,:) , [], 'r', 'filled')
    for j=1:length(worst_fits(i).results_points)
        results_points(j,:) = worst_fits(i).results_points{j}(1,:);
        scatter(maturities, results_points(j,:), [], 'k', '.')
    end
    avg_results_points = mean(results_points, 1, 'omitnan');
    plot(maturities, avg_results_points, 'b')
    xlabel('Maturities')
    ylabel('Rate')
end


% plot best fits
fig = figure;
fig.Name = 'Best Fits';
for i=1:16
    subplot(4,4,i)
    title(sprintf('%d of %d\ndistance = %d', i, 16, best_fits(i).avg_distance))
    hold on
    scatter(maturities, best_fits(i).test_points(1,:) , [], 'r', 'filled')
    for j=1:length(best_fits(i).results_points)
        results_points(j,:) = best_fits(i).results_points{j}(1,:);
        scatter(maturities, results_points(j,:), [], 'k', '.')
    end
    avg_results_points = mean(results_points, 1, 'omitnan');
    plot(maturities, avg_results_points, 'b')
    xlabel('Maturities')
    ylabel('Rate')
end


% calculate distribution of differennces for both current and forecast
for i=1:length(KNN_results)
    for j=1:number_neighbors
        temp_results_points(:,:,j) = KNN_results(i).results_points{j};
    end
    avg_point_diff{i} = KNN_results(i).test_points - mean(temp_results_points, 3);
end

for i=1:length(avg_point_diff)
    current_point_diff(i,:) = avg_point_diff{i}(1,:);
    forecast_point_diff(i,:) = avg_point_diff{i}(2,:);
end

figure
boxplot(current_point_diff, maturities)
title('Distribution of Average Differences for each Maturity')
xlabel('Maturities')

end