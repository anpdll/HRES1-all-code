function [lcoh]= lcoh_calculator(Battery_rating, Electrolyser_rating,mh2_year,Solar_rating)

%% Data
% PV Data
peak_solar = Solar_rating;

% Electrolyser Data
nel = 0.769;
Pel_rated = Electrolyser_rating; % kW
Pel_max = Pel_rated;


% Battery Data
ESrated = Battery_rating; % kWh

% Economic Data
pv_per_kw = 981; % cost of panel per kW
battery_per_kwh = 276; % cost of battery per kWh
Stack_dr = 0.00525; % Stack Degradation rate per year 0.525% 
N = 20; % Project life period 20 years
r = 0.1; % Discount rate 10%


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
PV_capex = pv_per_kw.*peak_solar;
PV_opex = 0.01.* PV_capex;


% Battery
Battery_capex = battery_per_kwh.*ESrated;
Battery_opex = 0.025.*Battery_capex;

% Burner Replacement
load('glass.mat')
Burner_power = nel.*Pel_max./1000; % Peak hydrogen production per hour multiplied by lhv,MW
Burner_capex = burner_conversion_calculator(Burner_power, glassfit.a, glassfit.b, glassfit.c);
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