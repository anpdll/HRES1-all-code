%% PV calcualtion
f_pv = 0.86;
alpha_pv = -0.003;
NOCT = 44; % degree celsius
P_pv_rated = 10; % kW
G_std = 1; % kW/m2
T_cell_std = 25; % degree celsius

data_pv = readtable('dayton_2022_edited.csv');
GHI = data_pv.GHI;
Tamb = data_pv.Temperature;
datetime = data_pv.datetime;
T_cell =  Tamb + (GHI./800).*(NOCT-20);
P_pv = f_pv.*(P_pv_rated.*1000).*(GHI./(G_std.*1000)).*(1 + alpha_pv.*(T_cell-T_cell_std))/1000;




%% second one
% PV Data
area = 1.244; % m^2
numberPV = 36; % number of panels
nPVref = 0.181; % Percent
Tref = 25; % degree celcius
alphaPV = -0.0038; % percent/kelvin
noct = 45; % degree celcius
nPV = nPVref.*(1 - alphaPV.*(Tamb + (GHI.*(noct-20)./800)-Tref));

solar_power = max(0, GHI .* area .* numberPV .* nPV);
solar_power = solar_power./1000; % kW



subplot(4,1,1);
plot(datetime,P_pv);

subplot(4,1,2);
plot(datetime,solar_power);

subplot(4,1,3);
plot(datetime, solar_power-P_pv);

subplot(4,1,4);
plot(datetime,P_pv-solar_power);

difference = sum(solar_power)-sum(P_pv);