
% Opex = 2;
% Capex = 5;
% mh2_year = 5000;
% Stack_dr = 0.00525; % Stack Degradation rate per year 0.525%
% N = 20; % Project life period 20 years
% r = 0.1; % Discount rate 10%
% 
% % Making LCOH Equation
% 
% % Generating vectors for 'n' and the discount factor
% n = 1:N;
% discount_factor = (1 + r).^n;
% 
% % Computing the two sums without loops
% one = sum(Opex ./ discount_factor);
% two = sum((mh2_year .* ((1 - Stack_dr).^n)) ./ discount_factor);
% 
% % Computing LCOH
% lcoh = (Capex + one) / two;

% 
% GHI = load("GHI.mat");
% GHI = GHI.GHI;
% Tamb = load("Tamb.mat");
% Tamb = Tamb.Tamb;
% nPeriods = length(GHI);

% ESeq1 = ES(1) == ES_rated.*SOC_in;
% ESeq2 = ES(2:nPeriodsplus1) == ES(1:nPeriods).*(1-sigmaES) + nESch.*P_ch - P_dch./nESds;

load("720_2 solar 20000 h2 optimization results.mat");

% plot(nPeriods, solution.P_ch);

% bar(solution.P_dch, nPeriods);
% bar(solution.del, nPeriods);


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



