% Create problem
lcoh_problem = optimproblem;

% Create optimization variables
numberPV = optimvar("numberPV","LowerBound",1);
Pel_rated = optimvar("Pel_rated","LowerBound",1);
ESrated = optimvar("ESrated","LowerBound",0);

% Set initial starting point for the solver
initialPoint.numberPV = ones(size(numberPV));
initialPoint.Pel_rated = ones(size(Pel_rated));
initialPoint.ESrated = zeros(size(ESrated));

% calculation
mh2_year = hydrogen_year(numberPV,Pel_rated,ESrated);
lcoh = opti_lcoh_calculator_1(numberPV,Pel_rated,ESrated,mh2_year);

lcoh_problem.Objective = lcoh;

lcoh_problem.Constraints.mh2peryear = mh2_year >= 400;

[sol,fval] = solve(steelprob);




