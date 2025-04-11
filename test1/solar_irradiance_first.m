%% Solar Calculations
% Manufacturer Data
area = 1.244; % m^2
numberPV = 36;
nPVref = 18.1; % Percent
Tref = 25; % degree celcius
alphaPV = -0.38; % percent/kelvin
noct = 45; % degree celcius


% Step 1: Read the CSV file into a table
data = readtable('2022 edited data.csv');

% Step 2: Extract GHI and datetime values
GHI = data.GHI;
Tamb = data.Temperature;
datetime = data.datetime;

% Step 3: Calculate solar power
nPV = nPVref.*(1 - alphaPV.*(Tamb + (GHI.*(noct-20)./800)-Tref));

solar_power = max(0, GHI .* area .* numberPV .* nPV);
solar_power = solar_power./1000; % kW

% Step 4: Optionally, plot solar power over time
plot(datetime, solar_power);
xlabel('Datetime');
ylabel('Solar Power (kW)');
title('Solar Power Variation Over Time');


% %% Electrolyser Calculations
% nel = 0.614;
% lhv = 33.33; % kWh/kg
% Pel = 6;
% Pel_rated = 6; % kW
% Pel_min = 0.2.*Pel_rated;
% Pel_max = Pel_rated;
% Lel = 1; % electrolyser load
% 
% mh2 = (nel.*Pel.*Lel)./lhv;
% 
% 
% %% Energy storage
% sigmaES = 0.000083;
% nESch = 0.91;
% nESds = 0.91;
% ESmin = 0.15;
% ESmax = 0.95;
% 
% ESnow = ESpre.*(1-sigmaES) + nESch.*PESin - PESout./nESds; % here ESnow and ESpre are present and previous time step energy state

