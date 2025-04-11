clear all; clc;
%% Fixed Datas (almost)
% Solar Data
f_pv = 0.86;
alpha_pv = -0.003;
NOCT = 44; % degree celsius
G_std = 1; % kW/m2
T_cell_std = 25; % degree celsius


% Electrolyser Data
nel = 0.769;
lhv = 33.33; % kWh/kg
Pel_min = 0.1;
Pel_max = 1;

% Economic Data
pv_per_kw = 981; % cost of panel per kW



% PV power Calculation
data_pv = readtable('dayton_2022_edited_24.csv');
GHI = data_pv.GHI;
Tamb = data_pv.Temperature;

% GHI = load("GHI.mat");
% GHI = GHI.GHI;
% Tamb = load("Tamb.mat");
% Tamb = Tamb.Tamb;
T_cell =  Tamb + (GHI./800).*(NOCT-20);


% number of time steps
nPeriods = length(GHI);

%% PV, Electrolyser and Battery Min Max values
% Pv
Ppv_rated_min = 1;
Ppv_rated_max = 800; % MW

% Electrolyser
Pel_rated_min = 1;
Pel_rated_max = 500; % MW



%% Introducing decision variables
del = optimvar('del',nPeriods,1,'Type','integer','LowerBound',0,'UpperBound',1);
%P_pv = optimvar('P_pv',nPeriods,1,'Type','continuous','LowerBound',0,'UpperBound',Ppv_rated_max);
P_el = optimvar('P_el',nPeriods,1,'Type','continuous','LowerBound',0,'UpperBound',Pel_rated_max);

Ppv_rated = optimvar('Ppv_rated','LowerBound',0);
Pel_rated = optimvar('Pel_rated','LowerBound',0);
ES_rated = optimvar('ES_rated','LowerBound',0);






%% Equations
P_pv = f_pv.*(Ppv_rated.*1e6).*(GHI./(G_std.*1000)).*(1 + alpha_pv.*(T_cell-T_cell_std))/(1e6); % MW

% introducting binary variable to define on/off state
Pel_rated_aux = Pel_rated.*del;
mh2 = (nel.*P_el.*1000)./lhv;

% Initial Charge

% electrolyzer capex constraints
% q = Pel_rated.*1000; % in kW
% ELectrolyser_capex = 1.*(301.04 + (11603./q).*(q.^0.649)).*(2024./2020).^(-27.33); 
ELectrolyser_capex = 700 .* Pel_rated;
Electrolyser_opex = 0.075.*ELectrolyser_capex;
% PV 
PV_capex = pv_per_kw.*Ppv_rated;
PV_opex = 0.01.* PV_capex;

% System installation
System_installation_capex = 0.12.*(ELectrolyser_capex+PV_capex);
%Overall Capex
Capex = ELectrolyser_capex+PV_capex+System_installation_capex;
%Overall Opex
Opex = Electrolyser_opex+PV_opex;
% Computing LCOH
lcoh = (Capex + Opex);

%% Optimization Process
min_lcoh = optimproblem('ObjectiveSense','minimize');

% Objective
min_lcoh.Objective = lcoh;

%% COnstraints
% PV
PV_rating1 = Ppv_rated_min <= Ppv_rated;
PV_rating2 = Ppv_rated <= Ppv_rated_max;

% Electrolyser
Electrolyser_rating1 = Pel_rated_min <= Pel_rated;
Electrolyser_rating2 = Pel_rated <= Pel_rated_max;


% inequalities required after introducing binary variable
el1 = Pel_rated_aux <= Pel_rated - (1-del).*Pel_rated_min;
el2 = Pel_rated_aux >= Pel_rated - (1-del).*Pel_rated_max;
el3 = Pel_rated_aux <= Pel_rated_max.*del;
el4 = Pel_rated_aux >= Pel_rated_min.*del;

% for electrolyser modulation
Electrolyser_modulation1 = (Pel_min.*Pel_rated_aux) <= P_el;
Electrolyser_modulation2 = P_el <= (Pel_max.*Pel_rated_aux);

% Power Balance
Pb_ineq = P_pv >= P_el;

mh2_eq2 = sum(mh2) >= 400;


% Constraints
min_lcoh.Constraints.Pb_ineq = Pb_ineq;
min_lcoh.Constraints.PV_rating1 = PV_rating1;
min_lcoh.Constraints.PV_rating2 = PV_rating2;
min_lcoh.Constraints.Electrolyser_rating1 = Electrolyser_rating1;
min_lcoh.Constraints.Electrolyser_rating2 = Electrolyser_rating2;

%min_lcoh.Constraints.Pel_eq1 = Pel_eq1;
min_lcoh.Constraints.el1 = el1;
min_lcoh.Constraints.el2 = el2;
min_lcoh.Constraints.el3 = el3;
min_lcoh.Constraints.el4 = el4;
min_lcoh.Constraints.Electrolyser_modulation1 = Electrolyser_modulation1;
min_lcoh.Constraints.Electrolyser_modulation2 = Electrolyser_modulation2;
min_lcoh.Constraints.mh2_eq2 = mh2_eq2;




options = optimoptions('intlinprog','Display','final');
[min_lcohsol,fval] = solve(min_lcoh,'options',options);
% [sol, fval] = solve(min_lcoh);

