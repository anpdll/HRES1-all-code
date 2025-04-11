%% Constants and Parameters
f_pv = 0.86;
NOCT = 44; % degree celsius
PV_TEMPERATURE_COEFFICIENT = -0.003; % Temperature coefficient for PV system
STANDARD_TEMPERATURE = 25; % Standard temperature for PV system (in Celsius)
STANDARD_IRRADIANCE = 1000; % Standard irradiance (in W/m^2)
data_pv = readtable('dayton_2022_edited.csv');
GHI = data_pv.GHI;
Tamb = data_pv.Temperature;
datetime = data_pv.datetime;
T_cell =  Tamb + (GHI./800).*(NOCT-20);


NUM_PERIODS = length(GHI);
PV_RATED_MIN = 0;
PV_RATED_MAX = 800; % MW
ELECTROLYSER_RATED_MIN = 0;
ELECTROLYSER_RATED_MAX = 500; % MW
BATTERY_RATED_MIN = 0;
BATTERY_RATED_MAX = 500; % MWh
ELECTROLYSER_MIN_MODULATION = 0.1; % Minimum load factor for electrolyser
ELECTROLYSER_MAX_MODULATION = 1; % Maximum load factor for electrolyser
BATTERY_MIN_SOC = 0.15; % Minimum state of charge for battery
BATTERY_MAX_SOC = 0.95; % Maximum state of charge for battery
BATTERY_SELF_DISCHARGE_RATE = 0.000083; % Battery self-discharge rate
BATTERY_CHARGE_EFFICIENCY = 0.91; % Battery charge efficiency
BATTERY_DISCHARGE_EFFICIENCY = 0.91; % Battery discharge efficiency
HYDROGEN_TARGET = 400; % Minimum hydrogen production target (in tonnes)
INITIAL_BATTERY_SOC = 0.5; % Initial state of charge of the battery

DISCOUNT_RATE = 0.1; % Discount rate for economic calculations
ANALYSIS_PERIOD = 20; % Analysis period in years
ELECTROLYSER_STACK_DEGRADATION_RATE = 0.00525; % Electrolyser stack degradation rate

%% Economic Parameters
YEAR = 2024;
ELECTROLYSER_COST_CONSTANTS = [301.04, 11603, 0.649, -27.33]; % [k0, k, a, b]
ELECTROLYSER_BASE_YEAR = 2020;
ELECTROLYSER_OPEX_FACTOR = 0.075; % Operational expenditure factor for electrolyser
PV_COST_PER_KW = 1000; % Cost per kW for PV system
PV_OPEX_FACTOR = 0.01; % Operational expenditure factor for PV system
BATTERY_COST_PER_KWH = 200; % Cost per kWh for battery
BATTERY_OPEX_FACTOR = 0.025; % Operational expenditure factor for battery
BURNER_COST_CONSTANTS = [0.1896, 0.6113, -0.001308, 1.09]; % [a, b, c, currency_conversion]
SYSTEM_INSTALLATION_FACTOR = 0.12; % System installation cost factor

%% Introducing Decision Variables
del = optimvar('del', NUM_PERIODS, 1, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
P_pv = optimvar('P_pv', NUM_PERIODS, 1, 'LowerBound', 0);
P_el = optimvar('P_el', NUM_PERIODS, 1, 'LowerBound', 0);
P_ch = optimvar('P_ch', NUM_PERIODS, 1, 'LowerBound', 0);
P_dch = optimvar('P_dch', NUM_PERIODS, 1, 'LowerBound', 0);
Ppv_rated = optimvar('Ppv_rated', 1, 1, 'LowerBound', PV_RATED_MIN, 'UpperBound', PV_RATED_MAX);
Pel_rated = optimvar('Pel_rated', 1, 1, 'LowerBound', ELECTROLYSER_RATED_MIN, 'UpperBound', ELECTROLYSER_RATED_MAX);
ES_rated = optimvar('ES_rated', 1, 1, 'LowerBound', BATTERY_RATED_MIN, 'UpperBound', BATTERY_RATED_MAX);

%% Constraints
% Power Balance
Constraints = P_pv >= P_el + P_ch - P_dch;

% PV Rating
Constraints = [Constraints, Ppv_rated >= PV_RATED_MIN, Ppv_rated <= PV_RATED_MAX];

% Electrolyser Rating
Constraints = [Constraints, Pel_rated >= ELECTROLYSER_RATED_MIN, Pel_rated <= ELECTROLYSER_RATED_MAX];

% Battery Rating
Constraints = [Constraints, ES_rated >= BATTERY_RATED_MIN, ES_rated <= BATTERY_RATED_MAX];

% PV Generation
Ppv_eq = P_pv == f_pv.*Ppv_rated .* (GHI ./ STANDARD_IRRADIANCE) .* (1 + PV_TEMPERATURE_COEFFICIENT .* (T_cell - STANDARD_TEMPERATURE ));
Constraints = [Constraints, Ppv_eq];

% Electrolyser Constraints
Pel_rated_aux = Pel_rated .* del;
Constraints = [Constraints, Pel_rated_aux <= Pel_rated - (1 - del) .* ELECTROLYSER_RATED_MIN, ...
                          Pel_rated_aux >= Pel_rated - (1 - del) .* ELECTROLYSER_RATED_MAX, ...
                          Pel_rated_aux <= ELECTROLYSER_RATED_MAX .* del, ...
                          Pel_rated_aux >= ELECTROLYSER_RATED_MIN .* del, ...
                          P_el >= ELECTROLYSER_MIN_MODULATION .* Pel_rated_aux, ...
                          P_el <= ELECTROLYSER_MAX_MODULATION .* Pel_rated_aux];

% Hydrogen Production
mh2 = (nel .* P_el .* 1000) ./ lhv; % Hydrogen production in tonnes
Constraints = [Constraints, sum(mh2) >= HYDROGEN_TARGET];

% Battery Constraints
Constraints = [Constraints, ES(1) == ES_rated * INITIAL_BATTERY_SOC];
Constraints = [Constraints, ES(2:end) == ES(1:end-1) * (1 - BATTERY_SELF_DISCHARGE_RATE) + BATTERY_CHARGE_EFFICIENCY * P_ch(1:end-1) - P_dch(2:end) / BATTERY_DISCHARGE_EFFICIENCY];
Constraints = [Constraints, ES >= BATTERY_MIN_SOC * ES_rated, ES <= BATTERY_MAX_SOC * ES_rated];

% Economic Constraints
q = Pel_rated .* 1000; % Electrolyser rated capacity in kW
k0 = ELECTROLYSER_COST_CONSTANTS(1);
k = ELECTROLYSER_COST_CONSTANTS(2);
a = ELECTROLYSER_COST_CONSTANTS(3);
b = ELECTROLYSER_COST_CONSTANTS(4);
v = YEAR;
v0 = ELECTROLYSER_BASE_YEAR;
ELectrolyser_capex = k0 + (k ./q) .* (q .^ a) .* ((v / v0) .^ b);
Electrolyser_opex = ELECTROLYSER_OPEX_FACTOR .* ELectrolyser_capex;

PV_capex = PV_COST_PER_KW .* Ppv_rated;
PV_opex = PV_OPEX_FACTOR .* PV_capex;

Battery_capex = BATTERY_COST_PER_KWH .* ES_rated;
Battery_opex = BATTERY_OPEX_FACTOR .* Battery_capex;

Burner_power = nel .* Pel_rated_max; % Peak hydrogen production rate in MW
a_burner = BURNER_COST_CONSTANTS(1);
b_burner = BURNER_COST_CONSTANTS(2);
c_burner = BURNER_COST_CONSTANTS(3);
Burner_capex = (a .* Burner_power .^ b + c) .* currency_conversion;

System_installation_capex = SYSTEM_INSTALLATION_FACTOR .* (ELectrolyser_capex + PV_capex + Battery_capex + Burner_capex);

Capex = ELectrolyser_capex + PV_capex + Battery_capex + Burner_capex + System_installation_capex;
Opex = Electrolyser_opex + PV_opex + Battery_opex;

discount_factors = (1 + DISCOUNT_RATE) .^ (1:ANALYSIS_PERIOD);
present_value_opex = sum(Opex ./ discount_factors);
present_value_hydrogen = sum((sum(mh2) .* (1 - ELECTROLYSER_STACK_DEGRADATION_RATE) .^ (1:ANALYSIS_PERIOD)) ./ discount_factors);

lcoh = (Capex + present_value_opex) / present_value_hydrogen;

%% Objective Function
objective = lcoh;

%% Solve the Optimization Problem
options = optimoptions('ga');
[sol, fval] = ga(@(x) objective, [], [], [], [], [], lb, ub, [], options);