% Read the CSV file
data = readtable("Combinedy.csv");

% Filter out rows where the 'FY' column values are below 2000
data_filtered = data(data.FY >= 2000, :);


% Extract categories and kWh values from the filtered data
categories = data_filtered.Category;
kWh_values = data_filtered.kWh;

% Get unique categories and calculate mean kWh values for each category
unique_categories = unique(categories);
mean_kWh_values = accumarray(findgroups(categories), kWh_values, [], @mean);


% Create bar plot
bar(mean_kWh_values);

% Customize x-axis labels
xticks(1:length(unique_categories));
xticklabels(unique_categories);
% xtickangle(45); % Rotate x-axis labels for better readability

% Add labels and title
xlabel('Category');
ylabel('Mean kWh Value');
title('Mean kWh Values for Different Categories (FY >= 2000)');

% Adjust y-axis limits to leave some empty space above the maximum bar
max_kWh = max(mean_kWh_values);
ylim([0, max_kWh * 1.1]); % Increase by 10% above the maximum value

% Adjust x-axis limits to reduce space between first and last bars
xlim([0.4, length(unique_categories) + 0.6]); % Adjust the limits to start from 0.5 and end at the number of categories + 0.5