function [lcoh] = opti_lcoh_calculator_1(numberPV,Pel_rated,ESrated, mh2_year)

%% Data
% PV Data
area = 1.244; % m^2

nPVref = 0.181; % Percent
Tref = 25; % degree celcius
alphaPV = -0.0038; % percent/kelvin
noct = 45; % degree celcius

% Electrolyser Data
nel = 0.769;
Pel_max = Pel_rated;


% Economic Data
pv_per_kw = 981; % cost of panel per kW
battery_per_kwh = 276; % cost of battery per kWh
Stack_dr = 0.00525; % Stack Degradation rate per year 0.525% 
N = 20; % Project life period 20 years
r = 0.1; % Discount rate 10%


%% Solar Power Calculation
data = readtable('2022 edited data.csv');
GHI = data.GHI;
Tamb = data.Temperature;
nPV = nPVref.*(1 - alphaPV.*(Tamb + (GHI.*(noct-20)./800)-Tref));
solar_power = max(0, GHI .* area .* numberPV .* nPV);
solar_power = solar_power./1000; % kW

%% Economic Part
%Electrolyser
year = 2024;
electrolyser_size = Pel_rated;
ko = 301.04; k = 11603; a = 0.649; b = -27.33; 
vo = 2020; v=year;
q = electrolyser_size; % in kW
ELectrolyser_capex = 1.*(ko + (k./q).*(q.^a)).*(v./vo).^b; 
Electrolyser_opex = 0.075.*ELectrolyser_capex;

% PV 
peak_solar = max(solar_power);
PV_capex = pv_per_kw.*peak_solar;
PV_opex = 0.01.* PV_capex;


% Battery
Battery_capex = battery_per_kwh.*ESrated;
Battery_opex = 0.025.*Battery_capex;

% Burner Replacement
glassmat = load('glass.mat');
Burner_power = nel.*Pel_max./1000; % Peak hydrogen production per hour multiplied by lhv,MW
Burner_capex = burner_conversion_calculator(Burner_power, glassmat.glassfit.a, glassmat.glassfit.b, glassmat.glassfit.c);
%Burner_capex = 0;

% System installation
System_installation_capex = 0.12.*(ELectrolyser_capex+PV_capex+Battery_capex+Burner_capex);

%Overall Capex
Capex = ELectrolyser_capex+PV_capex+Battery_capex+Burner_capex+System_installation_capex;

%Overall Opex
Opex = Electrolyser_opex+PV_opex+Battery_opex;

% LCOH Calculation

%defining symbolic variable
syms n

% Making LCOH Equation
one = symsum(Opex./((1+r).^n),n,1,N);
two = symsum(((mh2_year.*((1-Stack_dr).^n)))./((1+r).^n),n,1,N);
lcoh = (Capex + one)./two;
lcoh = vpa(subs(lcoh),3);  % subs converts symbolic result to numeric, vpa roundoff to 3 decimal place
end