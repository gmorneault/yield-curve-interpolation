%% Summary statistics and plots of features

% List variables and their names
names = {{'spot 6 mo', 'spot 5 yr', 'spot 10 yr'}, ...
        {'change 6 mo', 'change 5 yr', 'change 10 yr'}, ...
        {'spot level', 'spot slope', 'spot curve'}, ...
        {'change level', 'change slope', 'change curve'}}
 

% Plotmatrix for each set of features
for i=1:4
    figure
    vars = [1 2 3] + 3*(i-1);
    data = X(:,vars);
    [S,AX,BigAx,H,HAx] = plotmatrix(data);
    for j=1:3
        AX(1,j).Title.String = names{i}{j};
    end
end

% Boxplots for each set of features
figure
subplot(2,2,1)
boxplot(X(:,[1 2 3]), 'labels', names{1})
subplot(2,2,2)
boxplot(X(:,[4 5 6]), 'labels', names{2})
ylim([-5, 5])
subplot(2,2,3)
boxplot(X(:,[7 8 9]), 'labels', names{3})
subplot(2,2,4)
boxplot(X(:,[10 11 12]), 'labels', names{4})
ylim([-5, 5])