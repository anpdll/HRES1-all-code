load("8760 2 million hydrogen solver stopped prematurely exceeding time limit.mat");

subplot(5,1,1)
plot(solution.P_pv);
ylabel("P_(pv)");

subplot(5,1,2)
plot(solution.del);
ylabel("ON/OFF");

subplot(5,1,3)
plot(solution.P_el);
ylabel("P_(el)");

subplot(5,1,4)
plot(solution.mh2);
ylabel("m_(H2)");

subplot(5,1,5)
plot(solution.ES);
ylabel("SOC");

%% LCOH
% Economic Data
pv_per_kw = 981; % cost of panel per kW
battery_per_kwh = 276; % cost of battery per kWh
el_per_kw =  900;
N = 20; % Project life period 20 years
r = 0.1; % Discount rate 10%
discount_factors = (1 + r).^(-1:N); % from n=1 to N, -ve mean row vecotor
n = 1:N;
discount_factor = (1 + r).^n;
Stack_dr = 0.00525;

Capex = (el_per_kw.*solution.Pel_rated.*1000) + (pv_per_kw.*solution.Ppv_rated.*1000) + (battery_per_kwh.*solution.ES_rated.*1000);
Opex = 0.075.*(el_per_kw.*solution.Pel_rated.*1000) + 0.01.*(pv_per_kw.*solution.Ppv_rated.*1000) + 0.025.*(battery_per_kwh.*solution.ES_rated.*1000);
one = sum(Opex ./ discount_factor);
two = sum((sum(solution.mh2) .* ((1 - Stack_dr).^n)) ./ discount_factor);
lcoh = (Capex + one)./two
sum(solution.mh2)