% Read the CSV file
data = readtable("Combinedy.csv");

% Filter out rows where the 'FY' column values are below 2000
data_filtered = data(data.FY >= 2000, :);


% Extract categories and kWh values from the filtered data
categories = data_filtered.Category;
kWh_values = data_filtered.kWh;
MW_values = data_filtered.MW;
H2_values = data_filtered.H2_required;
hours_values = data_filtered.PRODHOURS;

% Get unique categories and calculate median kWh values for each category
unique_categories = unique(categories);
median_kWh_values = accumarray(findgroups(categories), kWh_values, [], @median);
median_MW_values = accumarray(findgroups(categories), MW_values, [], @median);
median_H2_values = accumarray(findgroups(categories), H2_values, [], @median);
median_hours_values = accumarray(findgroups(categories), hours_values, [], @median);

avg_KWH_MW_H2 = [median_kWh_values, median_MW_values,median_H2_values, median_hours_values];
% writematrix(avg_KWH_MW_H2, 'median_KWH_MW_H2_hours.csv');

% bar(median_kWh_values);
% bar(median_MW_values);
% bar(median_H2_values);
