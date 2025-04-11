function [mh2_year] = hydrogen_year(NumberOfPV, Electrolyser_rating, Battery_rating)

%% Data
% PV Data
area = 1.244; % m^2
numberPV = NumberOfPV; % number of panels
nPVref = 0.181; % Percent
Tref = 25; % degree celcius
alphaPV = -0.0038; % percent/kelvin
noct = 45; % degree celcius

% Electrolyser Data
nel = 0.769;
lhv = 33.33; % kWh/kg
Pel_rated = Electrolyser_rating; % kW
Pel_min = 0.1.*Pel_rated;
Pel_max = Pel_rated;


% Battery Data
ESrated = Battery_rating; % kWh
ESmax = 0.95.*ESrated;
ESmin = 0.15.*ESrated;
sigmaES = 0.000083;
nESch = 0.91;
nESds = 0.91;


%% Solar Power Calculation
data = readtable('2022 edited data.csv');
GHI = data.GHI;
Tamb = data.Temperature;
nPV = nPVref.*(1 - alphaPV.*(Tamb + (GHI.*(noct-20)./800)-Tref));
solar_power = GHI .* area .* numberPV .* nPV;
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



end