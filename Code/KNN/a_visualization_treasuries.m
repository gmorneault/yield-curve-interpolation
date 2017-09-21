%% Plot historic data


fit_data = fts2mat(fts_fit);
fit_names = {'3 month', '5 year', '10 year'}

% Plot time series and boxplot of 3 mo, 5 yr, and 10 yr
figure

subplot(2,1,1)
plot(repmat(fts_fit.dates,1,3), fit_data)
legend(fit_names)
datetick('x', 2)
recessionplot

subplot(2,1,2)
boxplot(fit_data, 'labels', fit_names)