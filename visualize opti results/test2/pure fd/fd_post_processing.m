data = load("fd_combined_data.mat");
burner_cost = readmatrix("burner_cost_fd.csv");


% Economic Data
% natural_gas_price = 0.031388; %usd/kwh
natural_gas_price = 0.031388;
pv_per_kw = 981; % cost of panel per kW
battery_per_kwh = 276; % cost of battery per kWh
el_per_kw =  705;
burner_conversion_cost = burner_cost .* 1e+06;
N = 20; % Project life period 20 years
r = 0.1; % Discount rate 10%

%% LCOH
capex = (1.35.*(el_per_kw.*data.Pel_rated_fd'.*1000) + (pv_per_kw.*data.Ppv_rated_fd'.*1000) ...
    + 1.1.*(battery_per_kwh.*data.ES_rated_fd'.*1000) + burner_conversion_cost);

opex_inner = (0.075.*(el_per_kw.*data.Pel_rated_fd'.*1000) + 0.01.*(pv_per_kw.*data.Ppv_rated_fd'.*1000) ...
    + 0.025.*(battery_per_kwh.*data.ES_rated_fd'.*1000));

syms n
opex = double(symsum((opex_inner./((1+r).^n)),n,1,20));

NPC_fd = capex + opex;

mh2_sum = (sum(data.mh2_fd))';

mh2_discounted = double(symsum((mh2_sum./((1+r).^n)),n,1,20));

lcoh_fd = NPC_fd ./ mh2_discounted;

%% LCOE

h2_yearly_demand = data.f.yearly_demand .* ones(size(mh2_sum));
energy_NG_required = max(0, (h2_yearly_demand - mh2_sum) .* 33.33); %kwh

NG_cost = natural_gas_price .* energy_NG_required;

NPC_NG = double(symsum(NG_cost./((1+r).^n),n,1,20));

Energy_yearly_demand = h2_yearly_demand .* 33.33; %kWh

energy_discounted = double(symsum(Energy_yearly_demand./((1+r).^n), n, 1, 20));

lcoe_fd = (NPC_fd + NPC_NG) ./ energy_discounted;

%% CO2 emission
CO2_per_year_fd = (Energy_yearly_demand .* 0.1805)./1000; %tonne

%% Emission price to just meet the hydrogen based lcoe
Energy_onlyNG = h2_yearly_demand .* 33.33;
NPC_onlyNG = double(symsum((natural_gas_price .* Energy_onlyNG)./((1+r).^n), n,1,20));
discounted_co2 = double(symsum(CO2_per_year_fd./((1+r).^n),n,1,20));


EP_fd = ((lcoe_fd .* energy_discounted) - NPC_onlyNG) ./ discounted_co2;

%% Emission price for ease of plot
% LCOE_with_EP_fd2 = ones(6,30000);
% for i = 1:1:30000
%     EP_price = i/10;
%     LCOE_loop = (NPC_onlyNG + discounted_co2.*EP_price) ./ energy_discounted;
%     LCOE_with_EP_fd2(:,i) = LCOE_loop;
% end
% 
% x_range_ep = 0.1:0.1:3000;
% plot(x_range_ep, LCOE_with_EP_fd2(1,:))
% 
% % semilogx(0.1:0.1:3000, LCOE_with_EP_fd2(1,:))
% grid on

%% plots
% NPC optim
npc_el = 1.35.*(el_per_kw.*data.Pel_rated_fd'.*1000) + 0.075.*(el_per_kw.*data.Pel_rated_fd'.*1000);
npc_pv = pv_per_kw.*data.Ppv_rated_fd'.*1000 + 0.01.*(pv_per_kw.*data.Ppv_rated_fd'.*1000);
npc_es = 1.1.*(battery_per_kwh.*data.ES_rated_fd'.*1000) + 0.025.*(battery_per_kwh.*data.ES_rated_fd'.*1000);

% after emission price
npc_co2 = discounted_co2 .* EP_fd;

aSecond_for_combo = [npc_pv, npc_es, npc_el, burner_conversion_cost, NPC_NG, CO2_per_year_fd, lcoh_fd, lcoe_fd, EP_fd, NPC_onlyNG, npc_co2];







