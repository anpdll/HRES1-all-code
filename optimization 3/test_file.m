% % Burner_power = (nel.*Pel_rated); % Peak hydrogen production per hour multiplied by lhv,MW
% % Burner_capex = ((0.1896 * (nel.*Pel_rated).^0.6113 - 0.001308).*1.09); % included euro to dollor conversion
% 
% % 
% % 1.075.*(el_per_kw.*Pel_rated.*1000) + 1.01.*(pv_per_kw.*Ppv_rated.*1000) + 1.025.*(battery_per_kwh.*ES_rated.*1000)
% % 
% % ((0.1896 * (nel.*Pel_rated).^0.6113 - 0.001308).*1.09) + 1.075.*(el_per_kw.*Pel_rated.*1000) + 1.01.*(pv_per_kw.*Ppv_rated.*1000) + 1.025.*(battery_per_kwh.*ES_rated.*1000)
% 
% 
% Opex = ((075.*(el_per_kw.*Pel_rated.*1000) + .01.*(pv_per_kw.*Ppv_rated.*1000) + .025.*(battery_per_kwh.*ES_rated.*1000))./discount_factors);
% 
% NPC = ((el_per_kw.*Pel_rated.*1000) + (pv_per_kw.*Ppv_rated.*1000) + (battery_per_kwh.*ES_rated.*1000)) + sum(((075.*(el_per_kw.*Pel_rated.*1000) + .01.*(pv_per_kw.*Ppv_rated.*1000) + .025.*(battery_per_kwh.*ES_rated.*1000))./discount_factors));
% 
% 
% % N = 20; % Project life period (years)
% % r = 0.1; % Discount rate (10%)
% % Opex = 8000;
% % Capex = 100000;
% 
% % % Calculate LCOH using vectorization
% % discount_factors = (1 + r).^(-1:N);
% % present_values_opex = Opex * discount_factors;
% % one = sum(present_values_opex);  % Vectorized sum
% % 
% % lcoh = Capex + one;
% % 
% % % Round to 3 decimal places
% % lcoh = round(lcoh, 3);  % More efficient rounding with round function
% % 
% % disp(['Levelized Cost of Ownership (LCOH): ', num2str(lcoh)]);
N = 20;
r = 0.1;
% n = 1:N;
% discount_factor = (1 + r).^n;
Stack_dr = 0.00525;
Capex = (el_per_kw.*solution.Pel_rated.*1000) + (pv_per_kw.*solution.Ppv_rated.*1000) + (battery_per_kwh.*solution.ES_rated.*1000);
Opex = 0.075.*(el_per_kw.*solution.Pel_rated.*1000) + 0.01.*(pv_per_kw.*solution.Ppv_rated.*1000) + 0.025.*(battery_per_kwh.*solution.ES_rated.*1000);
% one = sum(Opex ./ discount_factor);
% two = sum((sum(solution.mh2)) .* ((1 - Stack_dr).^n)) ./ discount_factor);
% lcoh = (Capex + one)./two

syms n

% Making LCOH Equation
one = symsum(Opex./((1+r).^n),n,1,N);
two = symsum(((sum(solution.mh2)))./((1+r).^n),n,1,N);
lcoh = (Capex + one)./two;

lcoh = vpa(subs(lcoh),3)











