%% First Section
% Fixed Datas (almost)
% Solar Data
f_pv = 0.86;
alpha_pv = -0.003;
NOCT = 44; % degree celsius
G_std = 1; % kW/m2
T_cell_std = 25; % degree celsius

% Battery Data
ESmax = 0.95;
ESmin = 0.15;
sigmaES = 0.000083;
nESch = 0.91;
nESds = 0.91;
SOC_in = 0.5;

% Electrolyser Data
nel = 0.769;
lhv = 33.33; % kWh/kg
Pel_min = 0.1;
Pel_max = 1;
mh2Year_required = 0.7.*562190;

% Economic Data
pv_per_kw = 981; % cost of panel per kW
battery_per_kwh = 276; % cost of battery per kWh
el_per_kw =  739;
burner_conversion_cost = 0.393330202 * 1e+06;
N = 20; % Project life period 20 years
r = 0.1; % Discount rate 10%
discount_factors = (1 + r).^(-1:N); % from n=1 to N, -ve mean row vecotor
 
% PV power Calculation
data_pv = readtable('dayton_2022_edited.csv');
GHI = data_pv.GHI;
Tamb = data_pv.Temperature;

% GHI = load("GHI.mat");
% GHI = GHI.GHI;
% Tamb = load("Tamb.mat");
% Tamb = Tamb.Tamb;
T_cell =  Tamb + (GHI./800).*(NOCT-20);

clear data_pv;


% number of time steps
nPeriods = length(GHI);
nPeriodsplus1 = nPeriods + 1;

Ppv_rated_min = 0;
Ppv_rated_max = 30; % MW

% Electrolyser
Pel_rated_min = 0;
Pel_rated_max = 30; % MW

% Battery
ES_rated_min = 0;
ES_rated_max = 30; % MWh

tic
%% Optimization Section

% Create optimization variables
del2 = optimvar("del",nPeriods,"Type","integer","LowerBound",0,"UpperBound",...
    1);
P_pv2 = optimvar("P_pv",nPeriods,"LowerBound",0);
P_el2 = optimvar("P_el",nPeriods,"LowerBound",0);
P_ch2 = optimvar("P_ch",nPeriods,"LowerBound",0);
P_dch2 = optimvar("P_dch",nPeriods,"LowerBound",0);
ES2 = optimvar("ES",nPeriodsplus1,"LowerBound",0);
mh22 = optimvar("mh2",nPeriods,"LowerBound",0);
Ppv_rated2 = optimvar("Ppv_rated","LowerBound",Ppv_rated_min,"UpperBound",...
    Ppv_rated_max);
Pel_rated2 = optimvar("Pel_rated","LowerBound",Pel_rated_min,"UpperBound",...
    Pel_rated_max);
ES_rated2 = optimvar("ES_rated","LowerBound",ES_rated_min,"UpperBound",...
    ES_rated_max);
Pel_rated_aux2 = optimvar("Pel_rated_aux",nPeriods,"LowerBound",0);

% Set initial starting point for the solver
initialPoint2.del = zeros(size(del2));
initialPoint2.P_pv = zeros(size(P_pv2));
initialPoint2.P_el = zeros(size(P_el2));
initialPoint2.P_ch = zeros(size(P_ch2));
initialPoint2.P_dch = zeros(size(P_dch2));
initialPoint2.ES = zeros(size(ES2));
initialPoint2.mh2 = zeros(size(mh22));
initialPoint2.Ppv_rated = Ppv_rated_min;
initialPoint2.Pel_rated = Pel_rated_min;
initialPoint2.ES_rated = ES_rated_min;
initialPoint2.Pel_rated_aux = zeros(size(Pel_rated_aux2));

% Create problem
problem = optimproblem;

% Define problem objective
problem.Objective = (1.35.*(el_per_kw.*Pel_rated2.*1000) + (pv_per_kw.*Ppv_rated2.*1000) + 1.1.*(battery_per_kwh.*ES_rated2.*1000) + burner_conversion_cost) ...
    + sum(((0.075.*(el_per_kw.*Pel_rated2.*1000) + 0.01.*(pv_per_kw.*Ppv_rated2.*1000) + 0.025.*(battery_per_kwh.*ES_rated2.*1000))./discount_factors));

% Define problem constraints
problem.Constraints.constraint1 = P_pv2 >= P_el2 + P_ch2 - P_dch2;
problem.Constraints.constraint2 = P_pv2 == f_pv.*(Ppv_rated2.*1e6).*(GHI./(G_std.*1000)).*(1 + alpha_pv.*(T_cell-T_cell_std))/(1e6);
problem.Constraints.constraint3 = Pel_rated_aux2 <= Pel_rated2 - (1-del2).*Pel_rated_min;
problem.Constraints.constraint4 = Pel_rated_aux2 >= Pel_rated2 - (1-del2).*Pel_rated_max;
problem.Constraints.constraint5 = Pel_rated_aux2 <= Pel_rated_max.*del2;
problem.Constraints.constraint6 = Pel_rated_aux2 >= Pel_rated_min.*del2;
problem.Constraints.constraint7 = P_el2 >= Pel_min.*Pel_rated_aux2;
problem.Constraints.constraint8 = P_el2 <= Pel_max.*Pel_rated_aux2;
problem.Constraints.constraint9 = ES2 >= ESmin.*ES_rated2;
problem.Constraints.constraint10 = ES2 <= ESmax.*ES_rated2;
problem.Constraints.constraint11 = ES2(1) == ES_rated2.*SOC_in;
problem.Constraints.constraint12 = ES2(2:nPeriodsplus1) == ES2(1:nPeriods).*(1-sigmaES) + nESch.*P_ch2 - P_dch2./nESds;
problem.Constraints.constraint13 = mh22 == (nel.*P_el2.*1000)./lhv;
problem.Constraints.constraint14 = sum(mh22) >= mh2Year_required;

% Set nondefault solver options
options2 = optimoptions("intlinprog","Display","final");

% Display problem information
show(problem);

% Solve problem
[solution,objectiveValue,reasonSolverStopped] = solve(problem,...
    "Solver","intlinprog","Options",options2);

% Display results
solution
reasonSolverStopped
objectiveValue

% Clear variables
clearvars del2 P_pv2 P_el2 P_ch2 P_dch2 ES2 mh22 Ppv_rated2 Pel_rated2 ES_rated2...
    Pel_rated_aux2 initialPoint2 options2 reasonSolverStopped objectiveValue


%% Lcoh
n = 1:N;
discount_factor = (1 + r).^n;
Stack_dr = 0.00525;
Capex = 1.35.*(el_per_kw.*solution.Pel_rated.*1000) + (pv_per_kw.*solution.Ppv_rated.*1000) + 1.1.*(battery_per_kwh.*solution.ES_rated.*1000) + burner_conversion_cost;
Opex = 0.075.*(el_per_kw.*solution.Pel_rated.*1000) + 0.01.*(pv_per_kw.*solution.Ppv_rated.*1000) + 0.025.*(battery_per_kwh.*solution.ES_rated.*1000);
one = sum(Opex ./ discount_factor);
two = sum((sum(solution.mh2) .* ((1 - Stack_dr).^n)) ./ discount_factor);
lcoh = (Capex + one)./two
sum(solution.mh2)
toc