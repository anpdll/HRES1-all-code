%% Fixed Datas (almost)
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

% Electrolyser Data
nel = 0.769;
lhv = 33.33; % kWh/kg
Pel_min = 0.1;
Pel_max = 1;

% Economic Data
pv_per_kw = 981; % cost of panel per kW
battery_per_kwh = 276; % cost of battery per kWh
Stack_dr = 0.00525; % Stack Degradation rate per year 0.525% 
N = 20; % Project life period 20 years
r = 0.1; % Discount rate 10%
n = 1:N;
discount_factor = (1 + r).^n;

% PV power Calculation
data_pv = readtable('dayton_2022_edited.csv');
GHI = data_pv.GHI;
Tamb = data_pv.Temperature;
datetime = data_pv.datetime;
T_cell =  Tamb + (GHI./800).*(NOCT-20);


% number of time steps
nPeriods = length(GHI);

%% PV, Electrolyser and Battery Min Max values
% Pv
Ppv_rated_min = 0;
Ppv_rated_max = 800; % MW

% Electrolyser
Pel_rated_min = 0;
Pel_rated_max = 500; % MW

% Battery
ES_rated_min = 0;
ES_rated_max = 500; % MWh

%% Introducing decision variables
del = optimvar('del',nPeriods,1,'Type','integer','LowerBound',0,'UpperBound',1);
P_pv = optimvar('P_pv',nPeriods,1,'Type','continuous','LowerBound',0,'UpperBound',Ppv_rated_max);
P_el = optimvar('P_el',nPeriods,1,'Type','continuous','LowerBound',0,'UpperBound',Pel_rated_max);
P_ch = optimvar('P_ch',nPeriods,1,'Type','continuous','LowerBound',0,'UpperBound',ES_rated_max);
P_dch = optimvar('P_dch',nPeriods,1,'Type','continuous','LowerBound',0,'UpperBound',ES_rated_max);
Ppv_rated = optimvar('Ppv_rated',nPeriods,1,'Type','integer','LowerBound',Ppv_rated_min,'UpperBound',Ppv_rated_max);
Pel_rated = optimvar('Pel_rated',nPeriods,1,'Type','integer','LowerBound',Pel_rated_min,'UpperBound',Pel_rated_max);
ES_rated = optimvar('ES_rated',nPeriods,1,'Type','integer','LowerBound',ES_rated_min,'UpperBound',ES_rated_max);


%% Power Balance
Pb_ineq = P_pv >= P_el + P_ch - P_dch;

%% PV, Electrolyser and battery sizing inequality
% PV
PV_rating1 = Ppv_rated_min <= Ppv_rated;
PV_rating2 = Ppv_rated <= Ppv_rated_max;

% Electrolyser
Electrolyser_rating1 = Pel_rated_min <= Pel_rated;
Electrolyser_rating2 = Pel_rated <= Pel_rated_max;

% Battery inequality
Battery_rating1 = ES_rated_min <= ES_rated;
Battery_rating2 = ES_rated <= ES_rated_max;


%% Constraints particular to PV
Ppv_eq1 = P_pv == f_pv.*(P_pv_rated.*1e6).*(GHI./(G_std.*1000)).*(1 + alpha_pv.*(T_cell-T_cell_std))/(1e6); % MW


%% Constraints particular to Electrolyser
% initializing size of mass of hydrogen vector
mh2 = zeros(nPeriods,1);

% introducting binary variable to define on/off state
Pel_eq1 = Pel_rated_aux == pel_rated.*del;

% inequalities required after introducing binary variable
el1 = Pel_rated_aux <= Pel_rated - (1-del).*Pel_rated_min;
el2 = Pel_rated_aux >= Pel_rated - (1-del).*Pel_rated_max;
el3 = Pel_rated_aux <= Pel_rated_max.*del;
el4 = Pel_rated_aux >= Pel_rated_min.*del;

% for electrolyser modulation
Electrolyser_modulation1 = (Pel_min.*Pel_rated_aux) <= P_el;
Electrolyser_modulation2 = P_el <= (Pel_max.*Pel_rated_aux);

%% Constriants Particular to Hydrogen Production
mh2_eq1 = mh2 == (nel.*P_el.*1000)./lhv;
mh2_eq2 = sum(mh2) >= 400;


%% Constraints particular to Battery
% Initial Charge
SOC_in = 0.5;

% for Battery Modulation
Battery_modulation1 = (ESmin.*ES_rated)<= ES;
Battery_modulation2 = ES <= (ESmax.*ES_rated);

% State of the charge in battery
ESeq1 = ES(1) == ES_rated.*SOC_in;
ESeq2 = ES(2:nPeriods) == ES(1:nPeriods-1).*(1-sigmaES) + nESch.*P_ch - P_dch./nESds;

%% Economic Part
%Electrolyser
year = 2024;
ko = 301.04; k = 11603; a = 0.649; b = -27.33; 
vo = 2020; v=year;

% electrolyzer capex constraints
eco_el1 = q == Pel_rated.*1000; % in kW
eco_el2 = ELectrolyser_capex == 1.*(ko + (k./q).*(q.^a)).*(v./vo).^b; 
eco_el3 = Electrolyser_opex == 0.075.*ELectrolyser_capex;

% PV 
eco_pv1 = PV_capex == pv_per_kw.*Ppv_rated;
eco_pv2 = PV_opex == 0.01.* PV_capex;

% Battery
eco_es1 = Battery_capex == battery_per_kwh.*ES_rated;
eco_es2 = Battery_opex == 0.025.*Battery_capex;

% Burner Replacement
eco_burner1 = Burner_power == (nel.*Pel_rated_max); % Peak hydrogen production per hour multiplied by lhv,MW
eco_burner2 = Burner_capex == (0.1896 * Burner_power.^0.6113 - 0.001308).*1.09; % included euro to dollor conversion

% System installation
eco_sys1 = System_installation_capex == 0.12.*(ELectrolyser_capex+PV_capex+Battery_capex+Burner_capex);

%Overall Capex
eco_oc = Capex == ELectrolyser_capex+PV_capex+Battery_capex+Burner_capex+System_installation_capex;

%Overall Opex
eco_oo = Opex == Electrolyser_opex+PV_opex+Battery_opex;

% Lcoh
% Computing the two sums without loops
eco_l1 = one == sum(Opex ./ discount_factor);
eco_l2 = two == sum((sum(mh2) .* ((1 - Stack_dr).^n)) ./ discount_factor);

% Computing LCOH
lcoh = (Capex + one) / two;

%% Optimization Process
min_lcoh = optimproblem('ObjectiveSense','minimize');

% Objective
dispatch.Objective = lcoh;

% Constraints

