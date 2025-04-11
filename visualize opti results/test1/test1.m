ceramics = load("ceramics_all10.mat");
chemical = load("chemical_all10.mat");
fd = load("fd_all10.mat");
glass = load("glass_all10.mat");
metal = load("metal_all10.mat");

% Assuming you have loaded the mat files as ceramics, chemical, fd, glass, and metal
datasets = {ceramics, chemical, fd, glass, metal};

extracted_values = cell(size(datasets));

for i = 1:length(datasets)
    dataset = datasets{i};
    ES_rated_values = [];
    Pel_rated_values = [];
    Ppv_rated_values = [];
    
    for j = 1:numel(dataset.solution_combo)
        combo = dataset.solution_combo{j};
        ES_rated_values = [ES_rated_values, combo.ES_rated];
        Pel_rated_values = [Pel_rated_values, combo.Pel_rated];
        Ppv_rated_values = [Ppv_rated_values, combo.Ppv_rated];
    end
    
    extracted_values{i}.ES_rated = ES_rated_values;
    extracted_values{i}.Pel_rated = Pel_rated_values;
    extracted_values{i}.Ppv_rated = Ppv_rated_values;
end