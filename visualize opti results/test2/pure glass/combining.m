%% Creating arrays of each variables
a = load("glass_0.5.mat");
b = load("glass_0.6.mat");
c = load("glass_0.7.mat");
d = load("glass_0.8.mat");
e = load("glass_0.9.mat");
f = load("glass_1.mat");

ES_rated_glass = [a.solution.ES_rated, b.solution.ES_rated, c.solution.ES_rated, d.solution.ES_rated, e.solution.ES_rated, f.solution.ES_rated];

Pel_rated_glass = [a.solution.Pel_rated, b.solution.Pel_rated, c.solution.Pel_rated, d.solution.Pel_rated, e.solution.Pel_rated, f.solution.Pel_rated];

Ppv_rated_glass = [a.solution.Ppv_rated, b.solution.Ppv_rated, c.solution.Ppv_rated, d.solution.Ppv_rated, e.solution.Ppv_rated, f.solution.Ppv_rated];

P_ch_glass = [a.solution.P_ch, b.solution.P_ch, c.solution.P_ch, d.solution.P_ch, e.solution.P_ch, f.solution.P_ch];

P_dch_glass = [a.solution.P_dch, b.solution.P_dch, c.solution.P_dch, d.solution.P_dch, e.solution.P_dch, f.solution.P_dch];

del_glass = [a.solution.del, b.solution.del, c.solution.del, d.solution.del, e.solution.del, f.solution.del];

P_el_glass = [a.solution.P_el, b.solution.P_el, c.solution.P_el, d.solution.P_el, e.solution.P_el, f.solution.P_el];

P_pv_glass = [a.solution.P_pv, b.solution.P_pv, c.solution.P_pv, d.solution.P_pv, e.solution.P_pv, f.solution.P_pv];

ES_glass = [a.solution.ES, b.solution.ES, c.solution.ES, d.solution.ES, e.solution.ES, f.solution.ES];

mh2_glass = [a.solution.mh2, b.solution.mh2, c.solution.mh2, d.solution.mh2, e.solution.mh2, f.solution.mh2];

Pel_rated_aux_glass = [a.solution.Pel_rated_aux, b.solution.Pel_rated_aux, c.solution.Pel_rated_aux, d.solution.Pel_rated_aux, e.solution.Pel_rated_aux, f.solution.Pel_rated_aux];

%% plotting

% Rated_powers
% rated_powers = [Ppv_rated_glass; ES_rated_glass; Pel_rated_glass];
% bar(rated_powers)
% xticklabels = {'PV', 'ES', 'EL'};
% xticks(1:3);
% set(gca, 'XTickLabel', xticklabels);
% title("Rated Powers (glass)")
% legend('50%', '60%', '70%', '80%', '90%','100%');

% Hydrogen Production
% half_h2 = mh2_glass(:,1)';
% full_h2 = mh2_glass(:,6)';
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
% half_h2 = mh2_glass(:,1);
% half_h2_daily = reshape(half_h2, 24, [])';
% full_h2 = mh2_glass(:,6);
% full_h2_daily = reshape(full_h2, 24, [])';
% daily_production_50 = sum(half_h2_daily, 2);
% daily_production_100 = sum(full_h2_daily,2);
% x_data = 1:365;
% plot(x_data, daily_production_50,x_data,daily_production_100);
% 
% bar([daily_production_50,daily_production_100]);
% legend("50%", "100%");

% hydrogen production maximum at 169th day
% half_h2 = mh2_glass(:,1);
% half_h2_daily = reshape(half_h2, 24, [])';
% full_h2 = mh2_glass(:,6);
% full_h2_daily = reshape(full_h2, 24, [])';
% day169_full = full_h2_daily(60,:);
% day169_half = half_h2_daily(60,:);
% x_data_max = 1:24;
% plot(x_data_max,day169_full,x_data_max,day169_half);
% legend

% PV, ES, EL power for 60 the day
% half_h2 = mh2_glass(:,1);
% half_ppv = P_pv_glass(:,1);
% half_es = ES_glass(:,1);
% half_es(end) = [];
% half_el = P_el_glass(:,1);
% half_h2_daily = reshape(half_h2, 24, [])';
% half_ppv_daily = reshape(half_ppv, 24, [])';
% half_es_daily = reshape(half_es, 24, [])';
% half_el_daily = reshape(half_el, 24, [])';
% 
% full_h2 = mh2_glass(:,6);
% full_ppv = P_pv_glass(:,6);
% full_es = ES_glass(:,6);
% full_es(end) = [];
% full_el = P_el_glass(:,6);
% full_h2_daily = reshape(full_h2, 24, [])';
% full_ppv_daily = reshape(full_ppv, 24, [])';
% full_es_daily = reshape(full_es, 24, [])';
% full_el_daily = reshape(full_el, 24, [])';
% 
% day169_full = full_h2_daily(60,:);
% day169_half = half_h2_daily(60,:);
% 
% day60_pv_half = half_ppv_daily(60,:);
% day60_es_half = half_es_daily(60,:);
% day60_el_half = half_el_daily(60,:);
% day60_pv_full = full_ppv_daily(60,:);
% day60_es_full = full_es_daily(60,:);
% day60_el_full = full_el_daily(60,:);
% 
% x_data_daily = 1:24;
% plot(x_data_daily,day60_pv_half,x_data_daily,day60_es_half,x_data_daily,day60_el_half,x_data_daily,day60_pv_full,x_data_daily,day60_es_full,x_data_daily,day60_el_full)
% legend
% 
% subplot(3,1,1);
% plot(x_data_daily,day60_pv_half,x_data_daily,day60_pv_full);
% ylabel("PV Power (MW)");
% xlabel("Time (Hour)");
% legend("50% H2 share", "100% H2 share");
% 
% subplot(3,1,2);
% plot(x_data_daily,day60_es_half,x_data_daily,day60_es_full);
% ylabel("BESS Energy (MWh)");
% xlabel("Time (Hour)");
% legend("50% H2 share", "100% H2 share")
% 
% subplot(3,1,3);
% plot(x_data_daily,day60_el_half,x_data_daily,day60_el_full);
% ylabel("EL Power (MW)");
% xlabel("Time (Hour)");
% legend("50% H2 share", "100% H2 share")

% capacity factor
% el_operated_times = sum(del_glass);
% plot(el_operated_times);

% buffer1 = P_el_glass(:,1);
% histo_x = nonzeros(P_el_glass(:,1));
% % histogram(histo_x);
% nd = fitdist(histo_x,"Normal");
% plot(nd);

ontime_50 = sum(del_glass(:,1));
ontime_100 = sum(del_glass(:,6));
buf1 = reshape(del_glass(:,1), 24, [])';
buf2 = reshape(del_glass(:,6), 24, [])';
half_ontime_daily = sum(buf1,2);
full_ontime_daily = sum(buf2,2);
day_year = 1:365;
% plot(day_year,half_ontime_daily,day_year,full_ontime_daily);
% bar([half_ontime_daily,full_ontime_daily])
buf3 = [sum(buf1)',sum(buf2)'];
buf3 = round(buf3,0);
bar([sum(buf1)',sum(buf2)'])

