%% Creating arrays of each variables
a = load("ceramics_0.5.mat");
b = load("ceramics_0.6.mat");
c = load("ceramics_0.7.mat");
d = load("ceramics_0.8.mat");
e = load("ceramics_0.9.mat");
f = load("ceramics_1.mat");

ES_rated_ceramics = [a.solution.ES_rated, b.solution.ES_rated, c.solution.ES_rated, d.solution.ES_rated, e.solution.ES_rated, f.solution.ES_rated];

Pel_rated_ceramics = [a.solution.Pel_rated, b.solution.Pel_rated, c.solution.Pel_rated, d.solution.Pel_rated, e.solution.Pel_rated, f.solution.Pel_rated];

Ppv_rated_ceramics = [a.solution.Ppv_rated, b.solution.Ppv_rated, c.solution.Ppv_rated, d.solution.Ppv_rated, e.solution.Ppv_rated, f.solution.Ppv_rated];

P_ch_ceramics = [a.solution.P_ch, b.solution.P_ch, c.solution.P_ch, d.solution.P_ch, e.solution.P_ch, f.solution.P_ch];

P_dch_ceramics = [a.solution.P_dch, b.solution.P_dch, c.solution.P_dch, d.solution.P_dch, e.solution.P_dch, f.solution.P_dch];

del_ceramics = [a.solution.del, b.solution.del, c.solution.del, d.solution.del, e.solution.del, f.solution.del];

P_el_ceramics = [a.solution.P_el, b.solution.P_el, c.solution.P_el, d.solution.P_el, e.solution.P_el, f.solution.P_el];

P_pv_ceramics = [a.solution.P_pv, b.solution.P_pv, c.solution.P_pv, d.solution.P_pv, e.solution.P_pv, f.solution.P_pv];

ES_ceramics = [a.solution.ES, b.solution.ES, c.solution.ES, d.solution.ES, e.solution.ES, f.solution.ES];

mh2_ceramics = [a.solution.mh2, b.solution.mh2, c.solution.mh2, d.solution.mh2, e.solution.mh2, f.solution.mh2];

Pel_rated_aux_ceramics = [a.solution.Pel_rated_aux, b.solution.Pel_rated_aux, c.solution.Pel_rated_aux, d.solution.Pel_rated_aux, e.solution.Pel_rated_aux, f.solution.Pel_rated_aux];

%% plotting

% Rated_powers
% rated_powers = [Ppv_rated_ceramics; ES_rated_ceramics; Pel_rated_ceramics];
% bar(rated_powers)
% xticklabels = {'PV', 'ES', 'EL'};
% xticks(1:3);
% set(gca, 'XTickLabel', xticklabels);
% title("Rated Powers (ceramics)")
% legend('50%', '60%', '70%', '80%', '90%','100%');

% Hydrogen Production
% half_h2 = mh2_ceramics(:,1)';
% full_h2 = mh2_ceramics(:,6)';
% x_h2 = 1:8760;
% 
% h2_buffer_half = zeros(1,8760);
% h2_buffer_half(1) = half_h2(1);
% 
% h2_buffer_full = zeros(1,8760);
% h2_buffer_full(1) = full_h2(1);
% 
% for i = 2:8760
%     h2_buffer_half(i) = h2_buffer_half(i-1) + half_h2(i);
%     h2_buffer_full(i) = h2_buffer_full(i-1) + full_h2(i);
% end
% 
% 
% plot(x_h2,h2_buffer_half, DisplayName='half');
% hold on
% plot(x_h2, h2_buffer_full, DisplayName='full');
% legend(Location="northwest");
% hold off

% hydrogen production daily
% half_h2 = mh2_ceramics(:,1);
% half_h2_daily = reshape(half_h2, 24, [])';
% full_h2 = mh2_ceramics(:,6);
% full_h2_daily = reshape(full_h2, 24, [])';
% daily_production_50 = sum(half_h2_daily, 2);
% daily_production_100 = sum(full_h2_daily,2);
% x_data = 1:365;
% % plot(x_data, daily_production_50,x_data,daily_production_100);
% 
% bar([daily_production_50,daily_production_100]);
% legend("50%", "100%");

% capacity factor
% half_pch = P_ch_ceramics(:,1);
% half_pch_daily = reshape(half_pch, 24, [])';
% half_pdch = P_dch_ceramics(:,1);
% half_pdch_daily = reshape(half_pdch, 24, [])';
% 
% full_pch = P_ch_ceramics(:,6);
% full_pch_daily = reshape(full_pch, 24, [])';
% full_pdch = P_dch_ceramics(:,6);
% full_pdch_daily = reshape(full_pdch, 24, [])';
% 
% day60pch = half_pch_daily(60,:);
% day60pdch = half_pdch_daily(60,:);
% x_daily = 1:24;
% % plot(x_daily,day60pch,x_daily,day60pdch);
% bar(day60pch)
% hold on
% bar(day60pdch);
% legend("charging half", "discharging half");

% el_operated = sum(del_ceramics);
% plot(el_operated)

