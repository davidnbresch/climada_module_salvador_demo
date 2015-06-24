
%% read and save historical tc tracks
climada_tc_get_unisys_databases
% west pacific
unisys_file   = [climada_global.data_dir filesep 'tc_tracks' filesep 'tracks.epa.txt'];
tc_track      = climada_tc_read_unisys_database(unisys_file);
tc_track_save = strrep(unisys_file,'.epa.txt','_epa.mat');
save(tc_track_save,'tc_track')
% north atlantic
unisys_file   = [climada_global.data_dir filesep 'tc_tracks' filesep 'tracks.atl.txt'];
tc_track      = climada_tc_read_unisys_database(unisys_file);
tc_track_save = strrep(unisys_file,'.atl.txt','_atl.mat');
save(tc_track_save,'tc_track')

% google_earth_save = strrep(strrep(tc_track_save,'.mat','.kmz'),'tc_tracks','');
% climada_tc_track_google_earth(tc_track, google_earth_save)



%% plot historical tc tracks, load first
% basin = 'epa';
basin = 'atl';
switch basin
    case 'atl'
        tc_track_file = [climada_global.data_dir filesep 'tc_tracks' filesep 'tracks_atl.mat'];
        filename = [filesep 'results' filesep 'TC_tracks_ATL_hist.pdf'];
        basin_name = 'North Atlantic';
    case 'epa'
        tc_track_file = [climada_global.data_dir filesep 'tc_tracks' filesep 'tracks_epa.mat'];
        filename = [filesep 'results' filesep 'TC_tracks_EPA_hist.pdf'];
        basin_name = 'western North Pacific';
end
load(tc_track_file)

fig = climada_figuresize(0.5,0.7);
check_country = 'El Salvador';
keep_boundary = 0;
climada_plot_world_borders(1,check_country,'',keep_boundary,'');
track_count = numel(tc_track);
for track_i = 1:1:track_count
    h = climada_plot_tc_track_stormcategory(tc_track(track_i),5,[]);
end
%add legend, makes it quite slow
climada_plot_tc_track_stormcategory(0,8,1);
axis equal
axis([-95 -80 8 20])
polygon_ = [-91.5 12; -85.5 12; -85.5 16; -91.5 16; -91.5 12];
plot(polygon_(:,1), polygon_(:,2),'-r','linewidth',1.5)

print(fig,'-dpdf',[climada_global.data_dir filename])
fprintf('figure saved in %s \n', filename) 


% find all tracks that come close to El Salvador
inpoly_indx = zeros(length(tc_track),1);
for track_i = 1:1:track_count
    inpoly_indx(track_i) = any(inpoly([tc_track(track_i).lon' tc_track(track_i).lat'], polygon_));
end
track_indx = find(inpoly_indx);
fprintf('\t -Total tc tracks in the %s: %d, between %s and %s\n', ...
             basin_name, length(tc_track),datestr(tc_track(1).datenum(1)), datestr(tc_track(end).datenum(end)))
fprintf('\t -Total tc tracks close to El Salvador: %d, between %s and %s\n', ...
             length(track_indx),datestr(tc_track(track_indx(1)).datenum(1)), datestr(tc_track(track_indx(end)).datenum(end)))


         

%% create tc track probabilistic for San Salvador
% tc_track_file = [climada_global.data_dir filesep 'tc_tracks' filesep 'tracks_n_indian_proc'];
% load(tc_track_file)

tc_track_save = strrep(tc_track_file,'.mat','_prob.mat');
ens_size      = 9;
ens_amp       = 0.2; %degree
maxangle      = pi/4;
tc_track      = climada_tc_random_walk_position_windspeed(tc_track,tc_track_save,ens_size,ens_amp,maxangle,1, 0);
% ens_amp  = [];
% Maxangle = [];
% tc_track_out  = climada_tc_random_walk(tc_track,ens_size,ens_amp,Maxangle,0);
save(tc_track_save, 'tc_track')
load(tc_track_save)



%% create tc track figure
% % load BCC boundaries file
% shp_mat_file = [climada_global.data_dir filesep 'results' filesep 'BCC_boundary_shp.mat'];
% load(shp_mat_file)
% fig = climada_figuresize(0.5,0.7);
% event_i = 529;
% check_country = 'El Salvador';
% keep_boundary = 0;
% climada_plot_world_borders(1,check_country,'',keep_boundary,'');
% for t_i = (event_i-1)*(ens_size+1)+1:1:(event_i+0)*(ens_size+1)  %1:numel(tc_track)
%     if tc_track(t_i).orig_event_flag == 1
%         plot(tc_track(t_i).lon, tc_track(t_i).lat,'.-r','markersize',3)
%         hold on
%     else
%         plot(tc_track(t_i).lon, tc_track(t_i).lat,'.-b','markersize',3)
%         hold on
%     end
% end
% % for s_i = 1:numel(BCC_boundary)
% %     plot(BCC_boundary(s_i).X, BCC_boundary(s_i).Y,'-k');
% % end
% axis equal
% axis([-95 -80 8 20])
% xlabel('Longitude'); ylabel('Latitude')
% foldername  = [filesep 'results' filesep 'Miriam_probabilistic_daughters.pdf'];
% print(fig,'-dpdf',[climada_global.data_dir foldername])
% 
% % datestr(hazard.datenum(172*4+1:173*4))
% % datestr(hazard.datenum((event_i-1)*(ens_size+1)+1:1:event_i*(ens_size+1)))
% 
% climada_plot_probabilistic_wind_speed_map(tc_track, (event_i-1)*(ens_size+1)+1)



%% find cyclone Miriam in epa and atl track set
% - create a combined tc_track (just this single track)
% - create probabilistic daughters
% - create figure
% event_i = 529; %in epa
% datestr(tc_track_epa(event_i).datenum(1))
% datestr(tc_track_epa(event_i).datenum(end))
% % delta_ = 535-347;
% delta_ = 599;
% event_i = 535+delta_; %in atl
% datestr(tc_track_atl(event_i).datenum(1))
% datestr(tc_track_atl(event_i).datenum(end))
% 
% fig = climada_figuresize(0.5,0.7);
% check_country = 'El Salvador';
% keep_boundary = 1;
% climada_plot_world_borders(1,check_country,'',keep_boundary,'');
% % climada_plot_tc_track_stormcategory(tc_track_epa(event_i),8,[]);
% climada_plot_tc_track_stormcategory(tc_track_comb(1),8,[]);
% axis equal
% axis([-95 -80 8 20])
% 
% event_i = 535+delta_; %in atl
% tc_track_comb = tc_track_atl(event_i);  
% event_i = 529; %in epa
% tc_track_comb.TimeStep         = [tc_track_comb.TimeStep tc_track_epa(event_i).TimeStep(2:end)];
% tc_track_comb.lon              = [tc_track_comb.lon tc_track_epa(event_i).lon(2:end)];
% tc_track_comb.lat              = [tc_track_comb.lat tc_track_epa(event_i).lat(2:end)];
% tc_track_comb.MaxSustainedWind = [tc_track_comb.MaxSustainedWind tc_track_epa(event_i).MaxSustainedWind(2:end)];
% tc_track_comb.CentralPressure  = [tc_track_comb.CentralPressure  tc_track_epa(event_i).CentralPressure(2:end) ];
% tc_track_comb.yyyy             = [tc_track_comb.yyyy             tc_track_epa(event_i).yyyy(2:end)];
% tc_track_comb.mm               = [tc_track_comb.mm               tc_track_epa(event_i).mm(2:end)];
% tc_track_comb.dd               = [tc_track_comb.dd               tc_track_epa(event_i).dd(2:end)];
% tc_track_comb.hh               = [tc_track_comb.hh               tc_track_epa(event_i).hh(2:end)];
% tc_track_comb.datenum          = [tc_track_comb.datenum          tc_track_epa(event_i).datenum(2:end)];
% 
% % check datestrings
% datestr([tc_track_comb.datenum])
% % save combined track
% tc_track_save = [climada_global.data_dir filesep 'tc_tracks' filesep 'tc_track_comb_Miriam.mat'];
% save(tc_track_save, 'tc_track_comb')
% 
% % create 9 daughters for Miriam
% tc_track_save = strrep(tc_track_save,'.mat','_daughters.mat');
% ens_size      = 9;
% ens_amp       = 0.2; %degree
% maxangle      = pi/4;
% tc_track_comb = climada_tc_random_walk_position_windspeed(tc_track_comb,tc_track_save,ens_size,ens_amp,maxangle,1,0);
% save(tc_track_save, 'tc_track_comb')
% load(tc_track_save)
%   
% % create figure with Miriam and daughters
% event_i = 1;
% climada_plot_probabilistic_wind_speed_map(tc_track_comb, (event_i-1)*(ens_size+1)+1)
% axis equal
% axis([-95 -80 8 20])
% foldername  = [filesep 'results' filesep 'Miriam_probabilistic_daughters.pdf'];
% print(fig,'-dpdf',[climada_global.data_dir foldername])




%% footprint figure
% climada_plot_tc_footprint(hazard,tc_track((event_i-1)*(ens_size+1)+1))
% caxis_range = '';
% res=climada_hazard_plot(hazard,(event_i-1)*(ens_size+1)+1);
% 
% load([climada_global.modules_dir filesep 'barisal_demo' filesep 'data' filesep 'entities' filesep 'Barisal_BCC_1km_100.mat'])
% focus_region = [70 110 06 32];
% check_mode = '';
% tc_track_1 = tc_track((event_i-1)*(ens_size+1)+1);
% hazard = climada_event_damage_data_tc(tc_track_1,entity,'',0,check_mode,focus_region);
% climada_event_damage_animation




%% combine the two probabilistic tc sets (epa, atl)
% load atl prob
tc_track_file = [climada_global.data_dir filesep 'tc_tracks' filesep 'tracks_atl_prob.mat'];
load(tc_track_file)  
tc_track_temp = tc_track;

% load epa prob
tc_track_file = [climada_global.data_dir filesep 'tc_tracks' filesep 'tracks_epa_prob.mat'];
load(tc_track_file) 

% combine atl and epa tracks
tc_track_both = tc_track;
tc_track_both(end+1:end+length(tc_track_temp)) = tc_track_temp;
tc_track      = tc_track_both;
tc_track_file = [climada_global.data_dir filesep 'tc_tracks' filesep 'tracks_epa_atl_prob.mat'];
save(tc_track_file,'tc_track');  




%% create probabilistic tc hazard set
% save([climada_global.system_dir filesep 'centroids_Salvador_10km.mat'], 'centroids');
% save([climada_global.data_dir filesep 'entities' filesep 'entity_Salvador_2014_10km.mat'], 'entity');
centroids_file  = [climada_global.data_dir filesep 'system' filesep 'centroids_Salvador_10km.mat'];
load(centroids_file)

tc_track_file = [climada_global.data_dir filesep 'tc_tracks' filesep 'tracks_epa_atl_prob.mat'];
load(tc_track_file);  

hazard_set_file = [climada_global.data_dir filesep 'hazards' filesep 'Salvador_hazard_TC_prob'];
hazard = climada_tc_hazard_set(tc_track, hazard_set_file, centroids);



%% find centroid in San Salvador (centroid_i = 83)
fig = climada_figuresize(0.5,0.7);
check_country = 'El Salvador';
keep_boundary = 1;
climada_plot_world_borders(1,check_country,'',keep_boundary,'');
plot(centroids.lon, centroids.lat, '+')
axis equal
axis([-95 -80 8 20])

salvador_lon = -89.218600;
salvador_lat =  13.694261;
hold on
plot(salvador_lon, salvador_lat, 'or')
centroid_i = 83;
plot(centroids.lon(centroid_i), centroids.lat(centroid_i), 'dg')


%% tweek the frequencies
hazard.frequency_ori = hazard.frequency;
hazard.frequency     = hazard.frequency_ori*3;
% ori_flag          = logical(hazard.orig_event_flag);
% hazard.frequency(ori_flag) = hazard.frequency_ori(ori_flag);
save(hazard_set_file,'hazard')

% add tc track category manually
% hazard.category = [tc_track.category];
% hazard.category(hazard.category<0) = 0;

% just loading not calculating
hazard_set_file = [climada_global.data_dir filesep 'hazards' filesep 'Salvador_hazard_TC_prob'];
load(hazard_set_file)

%% tc wind stats
climada_hazard_stats(hazard)
foldername  = [filesep 'results' filesep 'TC_wind_stats_Salvador.pdf'];
print(gcf,'-dpdf',[climada_global.data_dir foldername])

%% view wind results in San Salvador (centroid ID 83)
centroid_i = 83;
IFC = climada_hazard2IFC(hazard, centroid_i);
close all
figure
climada_IFC_plot(IFC,0)
axis([0 250 0 60])
foldername  = [filesep 'results' filesep 'TC_wind_intensity_Salvador.pdf'];
print(gcf,'-dpdf',[climada_global.data_dir foldername])


%% was the max event Miriam? (Nov 1988)
ens_size = 9;
orig_event_flag = logical(hazard.orig_event_flag);
[int_max indx]  = max(full(hazard.intensity(orig_event_flag,centroid_i)));
indx = (indx-1)*(ens_size+1)+1;
hazard.name{indx}
datestr(hazard.datenum(indx))
% yes, this is Sidr: 46.8 m/s at centroid_ID 30, 10 Nov 2007

% datestr(hazard.datenum(172*4+1:173*4))
% int_Sidr = full(hazard.intensity(172*10+1,centroid_ID))

% event_i = 172*4+1;
% figure
% res=climada_hazard_plot(hazard,event_i,'','','');
% res=climada_hazard_plot(hazard,event_i+1,'','','');
% figure
% res=climada_hazard_plot(hazard,event_i+2,'','','');
% figure
% res=climada_hazard_plot(hazard,event_i+3,'','','');


%------------------------------
%-------------RAIN-------------
%------------------------------
%% create probabilistic tc RAIN hazard set
centroids_file  = [climada_global.data_dir filesep 'system' filesep 'centroids_Salvador_10km.mat'];
load(centroids_file)

tc_track_file = [climada_global.data_dir filesep 'tc_tracks' filesep 'tracks_epa_atl_prob.mat'];
load(tc_track_file);  

hazard_set_file = [climada_global.data_dir filesep 'hazards' filesep 'Salvador_hazard_TC_RAIN_prob'];
hazard  = climada_tr_hazard_set(tc_track, hazard_set_file, centroids);


%% tweek the frequencies
hazard.frequency_ori = hazard.frequency;
hazard.frequency     = hazard.frequency_ori*3;
% ori_flag          = logical(hazard.orig_event_flag);
% hazard.frequency(ori_flag) = hazard.frequency_ori(ori_flag);
save(hazard_set_file,'hazard')



%% view rain results in San Salvador (centroid ID 83)
centroid_i = 83;
IFC = climada_hazard2IFC(hazard, centroid_i);
% close all
figure
climada_IFC_plot(IFC,0)
axis([0 250 0 200])
foldername  = [filesep 'results' filesep 'TC_Rain_intensity_Salvador.pdf'];
print(gcf,'-dpdf',[climada_global.data_dir foldername])



%% create rain footprint plot
event_i  = 529; %in epa
ens_size = 9;
event_i  = (event_i-1)*(ens_size+1)+1;
climada_hazard_plot(hazard, event_i)
axis equal
axis([-95 -80 8 20])
climada_plot_tc_track_stormcategory(tc_track(event_i),5,[]);


tc_track_Miriam = [climada_global.data_dir filesep 'tc_tracks' filesep 'tc_track_comb_Miriam.mat'];
load(tc_track_Miriam)
hazard_set_file = [climada_global.data_dir filesep 'hazards' filesep 'Salvador_hazard_TC_RAIN_Miriam'];
hazard_Miriam  = climada_tr_hazard_set(tc_track_comb, hazard_set_file, centroids);
event_i  = 1; %in special track for Miriam
climada_hazard_plot(hazard_Miriam, event_i)
axis equal
axis([-91 -87 12 15])
climada_plot_tc_track_stormcategory(tc_track_comb(event_i),5,[]);
salvador_lon = -89.218600;
salvador_lat =  13.694261;
plot(salvador_lon, salvador_lat, 'xr')
foldername  = [filesep 'results' filesep 'TC_Rain_footprint_Miriam.pdf'];
print(gcf,'-dpdf',[climada_global.data_dir foldername])













