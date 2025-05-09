%% Data
% PV Data
area = 1.244; % m^2
numberPV = 36; % number of panels
nPVref = 0.181; % Percent
Tref = 25; % degree celcius
alphaPV = -0.0038; % percent/kelvin
noct = 45; % degree celcius

% Electrolyser Data
nel = 0.769;
lhv = 33.33; % kWh/kg
Pel_rated = 10; % kW
Pel_min = 0.1.*Pel_rated;
Pel_max = Pel_rated;


% Battery Data
ESrated = 0; % kWh
ESmax = 0.95.*ESrated;
ESmin = 0.15.*ESrated;
sigmaES = 0.000083;
nESch = 0.91;
nESds = 0.91;

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
datetime = data.datetime;


nPV = nPVref.*(1 - alphaPV.*(Tamb + (GHI.*(noct-20)./800)-Tref));

solar_power = max(0, GHI .* area .* numberPV .* nPV);
solar_power = solar_power./1000; % kW


%% loop
% Initializing Variables
Pel = zeros(size(solar_power));
mh2 = zeros(size(solar_power));

% loop through each hour
for t = 1:length(solar_power)
    if solar_power(t) >= Pel_min %#ok<BDSCI>
        if solar_power(t) > Pel_max
                Pel = Pel_max;
                mh2(t) = (nel.*Pel)./lhv;
        else
            Pel = solar_power(t);
            mh2(t) = (nel.*Pel)./lhv;
        end
    else
        mh2(t) = 0;
    end
end
mh2_year = sum(mh2);

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
load('glass.mat')
Burner_power = nel.*Pel_max./1000; % Peak hydrogen production per hour multiplied by lhv
Burner_capex = burner_conversion_calculator(Burner_power, glassfit.a, glassfit.b, glassfit.c);
%Burner_capex = 0;

% System installation
System_installation_capex = 0.12.*(ELectrolyser_capex+PV_capex+Battery_capex+Burner_capex);

%Overall Capex
Capex = ELectrolyser_capex+PV_capex+Battery_capex+Burner_capex+System_installation_capex;

%Overall Opex
Opex = Electrolyser_opex+PV_opex+Battery_opex;

% LCOH Calculation
lcoh = lcoh_calculator(r,Stack_dr,N, Capex, Opex, mh2_year);

%% plots
subplot(4,1,1)  % First subplot for solar power
plot(datetime, solar_power);
xlabel('Datetime');
ylabel('Solar Power (kW)');
title('Solar Power Variation Over Time');

subplot(4,1,2)  % Second subplot for battery energy
plot(datetime, ESnow);
xlabel('Datetime');
ylabel('Battery (kWh)');
title('Battery Energy Status Over Time');

subplot(4,1,3)  % Third subplot for hydrogen production
plot(datetime, mh2);
xlabel('Datetime');
ylabel('mh2 (kg/hr)');
title('Hydrogen Production Over Time');

subplot(4,1,4)  % fourth subplot for hydrogen production
plot(datetime, lcoh);
xlabel('Datetime');
ylabel('LCOH ($/kg)');
title('Hydrogen Production Over Time');









