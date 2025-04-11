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

% Get unique categories and calculate mean kWh values for each category
unique_categories = unique(categories);
mean_kWh_values = accumarray(findgroups(categories), kWh_values, [], @mean);
mean_MW_values = accumarray(findgroups(categories), MW_values, [], @mean);
mean_H2_values = accumarray(findgroups(categories), H2_values, [], @mean);
mean_hours_values = accumarray(findgroups(categories), hours_values, [], @mean);

avg_KWH_MW_H2_hours = [mean_kWh_values, mean_MW_values,mean_H2_values, mean_hours_values];
% writematrix(avg_KWH_MW_H2, 'avg_KWH_MW_H2.csv');
