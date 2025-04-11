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
data = readtable('dayton_2022_edited.csv');


GHI = data.GHI;
Tamb = data.Temperature;
datetime = data.datetime;


nPV = nPVref.*(1 - alphaPV.*(Tamb + (GHI.*(noct-20)./800)-Tref));

solar_power = max(0, GHI .* area .* numberPV .* nPV);
solar_power = solar_power./1000; % kW


%% loop
% Initializing Variables
ESnow = zeros(size(solar_power));
Pel = zeros(size(solar_power));
mh2 = zeros(size(solar_power));

% loop through each hour
for t = 1:length(solar_power)
    if solar_power(t) >= Pel_min %#ok<BDSCI>
        if solar_power(t) > Pel_max
            PESin = solar_power(t)-Pel_max;
            PESout = 0;
            
            if t == 1
                ESpre = 0.5.*ESrated;
                ESnow(t) = min(ESmax,ESpre.*(1-sigmaES) + nESch.*PESin - PESout./nESds);
                Pel = Pel_max;
                mh2(t) = (nel.*Pel)./lhv;

            else
                if  ESnow(t-1) < ESmax %#ok<BDSCI>
                    ESnow(t) = min(ESmax,ESnow(t-1).*(1-sigmaES) + nESch.*PESin - PESout./nESds);
                    Pel = Pel_max;
                    mh2(t) = (nel.*Pel)./lhv;

                else
                    ESnow(t) = ESmax;
                    Pel = Pel_max;
                    mh2(t) = (nel.*Pel)./lhv;
                end
            end
        else % When if solar_power(t) > Pel_max is false
            if ESnow(t-1) > ESmin %#ok<BDSCI>
                PESin = 0;
                PESout = Pel_max-solar_power(t);
                if ESnow(t-1)-PESout > 0
                    ESnow(t) = max(0,ESnow(t-1).*(1-sigmaES) + nESch.*PESin - PESout./nESds);
                    Pel = Pel_max;
                    mh2(t) = (nel.*Pel)./lhv;
                else
                    ESnow(t) = ESnow(t-1).*(1-sigmaES);
                    Pel = solar_power(t);
                    mh2(t) = (nel.*Pel)./lhv;
                end
                
            else
                Pel = solar_power(t);
                mh2(t) = (nel.*Pel)./lhv;
            end
        end
    else
        PESin = 0;
        PESout = Pel_max - solar_power(t);
        if t == 1
                ESpre = 0.5.*ESrated;
                if ESpre - PESout > 0 %#ok<BDSCI>
                    ESnow(t) = max(0,ESpre.*(1-sigmaES) + nESch.*PESin - PESout./nESds);
                    Pel = Pel_max;
                    mh2(t) = (nel.*Pel)./lhv;
                else
                    ESnow(t) = max(0,ESpre.*(1-sigmaES));
                    mh2(t) = 0;
                end
        else
            if ESnow(t-1) - PESout > 0
                ESnow(t) = max(0,ESnow(t-1).*(1-sigmaES) + nESch.*PESin - PESout./nESds);
                Pel = Pel_max;
                mh2(t) = (nel.*Pel)./lhv;
            else
                ESnow(t) = max(0,ESnow(t-1).*(1-sigmaES));
                mh2(t) = 0;
            end
        end
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
% lcoh = lcoh_calculator(r,Stack_dr,N, Capex, Opex, mh2_year);
% Generating vectors for 'n' and the discount factor
n = 1:N;
discount_factor = (1 + r).^n;

% Computing the two sums without loops
one = sum(Opex ./ discount_factor);
two = sum((mh2_year .* ((1 - Stack_dr).^n)) ./ discount_factor);

% Computing LCOH
lcoh = (Capex + one) / two;


%% plots
% subplot(4,1,1)  % First subplot for solar power
% plot(datetime, solar_power);
% xlabel('Datetime');
% ylabel('Solar Power (kW)');
% title('Solar Power Variation Over Time');
% 
% subplot(4,1,2)  % Second subplot for battery energy
% plot(datetime, ESnow);
% xlabel('Datetime');
% ylabel('Battery (kWh)');
% title('Battery Energy Status Over Time');
% 
% subplot(4,1,3)  % Third subplot for hydrogen production
% plot(datetime, mh2);
% xlabel('Datetime');
% ylabel('mh2 (kg/hr)');
% title('Hydrogen Production Over Time');
% 
% subplot(4,1,4)  % fourth subplot for hydrogen production
% plot(datetime, lcoh);
% xlabel('Datetime');
% ylabel('LCOH ($/kg)');
% title('Hydrogen Production Over Time');









