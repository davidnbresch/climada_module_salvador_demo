

%--------------------------------------------------------------------------
% this is not used anymore
% with this script, the landslide hazard for las canas was created
%--------------------------------------------------------------------------
% Lea Mueller, muellele@gmail.com, 20151125, rename to climada_centroids_TWI_calc from centroids_TWI


% load assets
load([climada_global.project_dir filesep 'Salvador_entity_2015_LS'])


% load hazard LS binary
load([climada_global.project_dir filesep 'Salvador_hazard_LS_2015'])

% load shp files
load([climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS'])


%----------------------------------------
%% create landslide hazard for LAS CANAS
%----------------------------------------

% module data dir
module_data_dir =[climada_global.modules_dir filesep 'salvador_demo' filesep 'data'];

% landslide directory on shared drive
ls_dir = [climada_global.project_dir filesep 'LS' filesep];

% load assets
load([climada_global.project_dir filesep 'Salvador_entity_2015_LS']) % las canas



%% create ls hazard LAS CANAS

n_events = 1000;
wiggle_factor = 0.35; 
TWI_condition = 0.9;
wiggle_factors_slope = 0.1; 
slope_condition = 0.45;
n_downstream_cells = 2;
hazard_set_file = [ls_dir 'Salvador_hazard_LS_2015_las_canas.mat'];
hazard  = climada_ls_hazard_set_binary(centroids,n_events,hazard_set_file,wiggle_factor,TWI_condition,wiggle_factors_slope,slope_condition,n_downstream_cells,polygon_canas);


% encode to distance
centroids.lon = hazard.lon;
centroids.lat = hazard.lat;
cutoff = 1000;
hazard_distance = climada_hazard_encode_distance(hazard,centroids,cutoff);
save([ls_dir 'hazard_distance'],'hazard_distance')


%% load hazard distance
load([ls_dir 'hazard_distance'])


% calculate statistics for return periods
% hazard_distance.intensity_ori = hazard_distance.intensity;
% hazard_distance.intensity = hazard_distance.distance_m;
% return_periods = [2 5 10 20 33 50 80 100 500 1000];
return_periods = [2 5 10 25 50 100];
hazard_distance_stats = climada_hazard_stats(hazard_distance,return_periods,0);

% figure
% e_i = 500;
% plotclr(hazard.lon, hazard.lat, hazard_distance.intensity_fit(e_i,:),'','',1,0,400);
% plotclr(hazard.lon, hazard.lat, hazard_distance.intensity(e_i,:),'','',1);
% hazard_distance.distance_m = (1-hazard_distance.intensity)*cutoff;

figure
plotclr(hazard_distance_stats.lon,hazard.lat,hazard_distance_stats.centroid_ID,'','',1)
figure; plot(hazard_distance_stats.R,hazard_distance_stats.intensity_sort(:,4500),'-x')
hold on; plot([0 hazard_distance_stats.R_fit],[0; hazard_distance_stats.intensity_fit(:,4500)],'-xr')
xlim([0 50])



%% create return period figures
% climada_hazard_stats_figure(hazard_distance_stats,[2 5 10 25 50])

% set min and max values to be shown on map
miv = 0;
mav = 220; %mav = 415;
% cmap = flipud(climada_colormap('LS'));
cmap = climada_colormap('LS');
cmap(end-2:end-1,:) = [];
hazard_distance_stats.distance_m_fit = (1.-hazard_distance_stats.intensity_fit)*hazard_distance.cutoff_m;
hazard_distance_stats.distance_m_fit(hazard_distance_stats.intensity_fit>=1) = 1;
markersize = 3.0;% markersize = 2.2;
marker = 's';
for e_i = 1:length(return_periods)
    %e_i = 3;
    fig = climada_figuresize(0.65,0.8);%(0.5,0.6);
    cbar = plotclr(hazard.lon, hazard.lat, hazard_distance_stats.distance_m_fit(e_i,:),marker,markersize,1,miv,mav,cmap);
    %plotclr(hazard.lon, hazard.lat, hazard_distance_stats.intensity_fit(e_i,:),'','',1,0,1,cmap);
    hold on; 
    plot3(polygon_canas.X, polygon_canas.Y,ones(size(polygon_canas.X))*1000,'color',[100 100 100]/255);
    g = plot3(entity.assets.lon, entity.assets.lat,ones(size(entity.assets.lat))*1000,'.','linewidth',0.2,'markersize',1.8,'color',[200 200 200]/255);%[255 64 64 ]/255);
    %g = plot(entity.assets.lon-5, entity.assets.lat-5,'.','linewidth',1,'markersize',7,'color',[200 200 200]/255);%[255 64 64 ]/255);
    %set(cbar,'YTick',[])
    set(get(cbar,'ylabel'),'String', 'Distance to landslide (m)','fontsize',13);
    title(sprintf('Return period %d years',hazard_distance_stats.R_fit(e_i)),'fontsize',13)
    axis(axlim); box on; climada_figure_scale_add('',7,1)
    
    pdf_filename = sprintf('Landslides_las_Canas_%d_years_.pdf',hazard_distance_stats.R_fit(e_i));
    print(fig,'-dpdf',[ls_dir pdf_filename])
end
%%



% figure
n_colors = jet(n_events);
fig = climada_figuresize(0.5,0.6);
plot(entity.assets.lon, entity.assets.lat,'.','linewidth',0.2,'markersize',0.8,'color',[255 64 64 ]/255);
hold on
legendstr = []; h = [];
for e_i = 1:n_events
    is_event = logical(hazard.intensity(e_i,:));
    %hold on; plot3(hazard.lon(is_event), hazard.lat(is_event), ones(sum(is_event))*3000, 'dr','linewidth',2,'markersize',5,'color',[255 64 64 ]/255)
    h(e_i) = plot(hazard.lon(is_event), hazard.lat(is_event),'dr','linewidth',2,'markersize',5,'color',n_colors(e_i,:));
    hold on; plot(polygon_canas.X, polygon_canas.Y, 'b-');
    legendstr{e_i} = sprintf('Event %d',e_i);
end
title(sprintf('LS event %d',e_i)); axis(axlim); box on; climada_figure_scale_add('',7,1)
legend(h,legendstr)
% pdf_filename = sprintf('LS_aspect.pdf');
% print(fig,'-dpdf',[ls_dir pdf_filename])


%% visualize landslide hazard
% sort events according to number of sliding cells
no_sliding_cell = sum(full(hazard.intensity),2);
[sorted_sliding_cells, is_sorted] = sort(no_sliding_cell);

% is_ranked = [is_sorted(end) is_sorted(round(length(is_sorted)/3*2)) is_sorted(round(length(is_sorted)/3)) is_sorted(1)];

is_ranked = [is_sorted(end) is_sorted(round(length(is_sorted)/2)) is_sorted(1)];

no_sliding_cell(is_sorted(end))
no_sliding_cell(is_sorted(round(length(is_sorted)/2)))
no_sliding_cell(is_sorted(1))

n_events = numel(is_ranked);
% figure
% n_colors = flipud(lines(n_events));
n_colors(1,:) = [238 43 43]/255;
n_colors(2,:) = [255 165 0]/255;
n_colors(3,:) = [0 154 205]/255;
% n_colors(3,:) = [238 232 205]/255;
% beginColor =  [238 43 43]/255;
% endColor = [255 165 0]/255;
% n_colors = makeColorMap(beginColor,endColor,n_events);


fig = climada_figuresize(0.8,1.0);%(0.5,0.6);
g = plot(entity.assets.lon, entity.assets.lat,'.','linewidth',0.2,'markersize',1.8,'color',[200 200 200]/255);%[255 64 64 ]/255);
hold on
g = plot(entity.assets.lon-5, entity.assets.lat-5,'.','linewidth',1,'markersize',7,'color',[200 200 200]/255);%[255 64 64 ]/255);
legendstr = []; h = [];
markersize = 6;
for e_i = 1:n_events
    is_event = logical(hazard.intensity(is_ranked(e_i),:));
    %hold on; plot3(hazard.lon(is_event), hazard.lat(is_event), ones(sum(is_event))*3000, 'dr','linewidth',2,'markersize',5,'color',[255 64 64 ]/255)
    h(e_i) = plot(hazard.lon(is_event), hazard.lat(is_event),'o','linewidth',2,'markersize',markersize-1*(e_i-1),'color',n_colors(e_i,:),'markerfacecolor',n_colors(e_i,:));
    hold on; plot(polygon_canas.X, polygon_canas.Y, 'b-','color',[100 100 100]/255);
    legendstr{e_i} = sprintf('Event %d',is_ranked(e_i));
end
% title(sprintf('LS event %d',e_i)); 
title('Landslides, Rio las Cañas');
axis(axlim); box on; climada_figure_scale_add('',7,1)
legend([h g],{'50 year return period' '20 year return period' '2 year return period' 'Assets (draft)'},'location','northwest')
legend('boxoff')
% legend(h,legendstr)
climada_figure_axis_limits_equal_for_lat_lon(axlim)
pdf_filename = sprintf('LS_return_periods.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])


%% visualize landslide hazard as return period
no_sliding_cell_per_centroid = sum(full(hazard.intensity),1);
% max(no_sliding_cell_per_centroid)
% [sorted_sliding_cells, is_sorted] = sort(no_sliding_cell_per_centroid);

no_cells_return_period = [50 150 330];

n_events = numel(no_cells_return_period);
% figure
% n_colors = flipud(lines(n_events));
n_colors(1,:) = [238 43 43]/255;
n_colors(2,:) = [255 165 0]/255;
n_colors(3,:) = [0 154 205]/255;
% n_colors(3,:) = [238 232 205]/255;
% beginColor =  [238 43 43]/255;
% endColor = [255 165 0]/255;
% n_colors = makeColorMap(beginColor,endColor,n_events);


fig = climada_figuresize(0.8,1.0);%(0.5,0.6);
g = plot(entity.assets.lon, entity.assets.lat,'.','linewidth',0.2,'markersize',1.8,'color',[200 200 200]/255);%[255 64 64 ]/255);
hold on
g = plot(entity.assets.lon-5, entity.assets.lat-5,'.','linewidth',1,'markersize',7,'color',[200 200 200]/255);%[255 64 64 ]/255);
legendstr = []; h = [];
markersize = 6;
markersize_list = [6 4 3];
for e_i = 1:n_events
    is_event = no_sliding_cell_per_centroid>no_cells_return_period(e_i);
    h(e_i) = plot(hazard.lon(is_event), hazard.lat(is_event),'o','linewidth',2,'markersize',markersize_list(e_i),'color',n_colors(e_i,:),'markerfacecolor',n_colors(e_i,:));
    hold on; plot(polygon_canas.X, polygon_canas.Y, 'b-','color',[100 100 100]/255);
    legendstr{e_i} = sprintf('Return period %d',round(hazard.orig_years./no_cells_return_period(e_i)));
end
% title(sprintf('LS event %d',e_i)); 
title('Landslides, Rio las Cañas');
axis(axlim); box on; climada_figure_scale_add('',7,1)
% legend([h g],{'50 year return period' '20 year return period' '2 year return period' 'Assets (draft)'},'location','northwest')
legend(h,legendstr)
% legend('boxoff')
climada_figure_axis_limits_equal_for_lat_lon(axlim)
% pdf_filename = sprintf('LS_return_periods.pdf');
% print(fig,'-dpdf',[ls_dir pdf_filename])



%% Historical land slide data
% historical_LS = climada_shaperead([module_data_dir filesep 'system' filesep 'REPORTE DE DAÑOS 07 CIERRE06pm noviembre 2011.shp']);
% historical_LS_2 = climada_shaperead([module_data_dir filesep 'system' filesep 'deslizamientos_nov2014.shp']);



%%  create figures to understand the situation

delta_lon = 0.005;
lon_min = min(entity.assets.lon(is_selected))-delta_lon;
lon_max = max(entity.assets.lon(is_selected))+delta_lon;
lat_min = min(entity.assets.lat(is_selected))-delta_lon;
lat_max = max(entity.assets.lat(is_selected))+delta_lon;

markersize = 2.2;
marker = 's';
cbar_on = 1;
axlim = [lon_min lon_max lat_min lat_max];
miv = '';
mav = '';

% assets
titlestr = 'Entity assets (USD)';
miv = 1000;
mav = 2*10^5;
fig = climada_figuresize(0.5,0.6);
plotclr(entity.assets.lon(is_selected), entity.assets.lat(is_selected), entity.assets.Value(is_selected),marker,markersize,cbar_on,miv,mav);
title(titlestr); axis(axlim); box on; hold on
climada_figure_axis_limits_equal_for_lat_lon(axlim); climada_figure_scale_add('',7,1);
% polygon_canas = climada_shape_selector(fig,1,1);
% polygon_canas.lon = polygon_canas.X;
% polygon_canas.lat = polygon_canas.Y;
polygon_acelhuate = climada_shape_selector(fig,1,1);
polygon_acelhuate.lon = polygon_acelhuate.X;
polygon_acelhuate.lat = polygon_acelhuate.Y;
% shape_plotter(polygon_rio_acelhuate, '')
% shape_plotter(shapes,label_att,lon_fieldname,lat_fieldname,varargin)
pdf_filename = sprintf('LS_entity_assets_acelhuate.pdf'); %pdf_filename = sprintf('LS_entity_assets.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])

% dem
titlestr = 'DEM (masl)';
miv = 520;
mav = 650;
fig = climada_figuresize(0.5,0.6);
plotclr(centroids.lon, centroids.lat, centroids.elevation_m, marker,markersize,cbar_on,miv,mav);
hold on; plot3(entity.assets.lon, entity.assets.lat, ones(size(entity.assets.lon))*3000, '.r','linewidth',0.2,'markersize',1.2,'color','k')%[255 64 64 ]/255
title(titlestr); axis(axlim); box on; climada_figure_scale_add('',7,1)
% pdf_filename = sprintf('LS_DEM_masl.pdf');
pdf_filename = sprintf('LS_DEM_masl_with_assets_black.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])

% slope
titlestr = 'Slope (degree)';
miv = 0;
mav = 40;
fig = climada_figuresize(0.5,0.6);
plotclr(centroids.lon, centroids.lat, centroids.slope_deg, marker,markersize,cbar_on,miv,mav);
hold on; plot3(entity.assets.lon, entity.assets.lat, ones(size(entity.assets.lon))*3000, '.r','linewidth',0.2,'markersize',1.2,'color',[255 64 64 ]/255)
title(titlestr); axis(axlim); box on; climada_figure_scale_add('',7,1)
% pdf_filename = sprintf('LS_slope_degree.pdf');
pdf_filename = sprintf('LS_slope_degree_with assets.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])

% TWI
titlestr = 'TWI (-)';
miv = 2;
mav = 9.5;
fig = climada_figuresize(0.5,0.6);
plotclr(centroids.lon, centroids.lat, centroids.TWI, marker,markersize,cbar_on,miv,mav);
hold on; plot3(entity.assets.lon, entity.assets.lat, ones(size(entity.assets.lon))*3000, '.r','linewidth',0.2,'markersize',1.2,'color','k')
title(titlestr); axis(axlim); box on; climada_figure_scale_add('',7,1)
% pdf_filename = sprintf('LS_TWI.pdf');
pdf_filename = sprintf('LS_TWI_with_assets.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])

% Flood score
titlestr = 'Flood score (-)';
miv = -5;
mav = 250;
fig = climada_figuresize(0.5,0.6);
plotclr(centroids.lon, centroids.lat, centroids.FL_score, marker,markersize,cbar_on,miv,mav);
title(titlestr); axis(axlim); box on; climada_figure_scale_add('',7,1)
pdf_filename = sprintf('LS_flood_score.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])
% plotclr(centroids.lon, centroids.lat, centroids.FL_score, marker,markersize,cbar_on);

% sink_ID
titlestr = 'Sink ID (-)';
fig = climada_figuresize(0.5,0.6);
plotclr(centroids.lon, centroids.lat, centroids.sink_ID, marker,markersize,cbar_on);
title(titlestr); axis(axlim); box on; climada_figure_scale_add('',7,1)
pdf_filename = sprintf('LS_sink_ID.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])

% aspect
titlestr = 'Aspect (-)';
miv = 0;
mav = 360;
fig = climada_figuresize(0.5,0.6);
plotclr(centroids.lon, centroids.lat, centroids.aspect_deg, marker,markersize,cbar_on,miv,mav);
title(titlestr); axis(axlim); box on; climada_figure_scale_add('',7,1)
pdf_filename = sprintf('LS_aspect.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])




%-----------------------------------
%-----------------------------------
%-----------------------------------







%% landslide hazard for rio las canas
% % DEM 50m resolution
% resolution_m = 50;
% dem = salvador_dem_read('', resolution_m, 1);
% load([climada_global.project_dir filesep 'centroids_LS_10m_rectangle_canas'])
% centroids = climada_centroids_TWI_calc(centroids,1);
% centroids.slope_deg(isnan(centroids.slope_deg)) = rand(sum(isnan(centroids.slope_deg)),1)*5+5;
% [hazard_LS, hazard_RF]  = climada_ls_hazard_set(centroids,'');
hazard_all_events = full(nansum(hazard.intensity));
is_event = hazard_all_events<0 | hazard_all_events>0;
sum(is_event)
hazard.lon = hazard.lon(is_event);
hazard.lat = hazard.lat(is_event);
hazard.centroid_ID = 1:numel(hazard.lat);
hazard.elevation_m = hazard.elevation_m(is_event);
hazard.intensity = hazard.intensity(:,is_event);
hazard.event_ID = 1:sum(is_event);
hazard.orig_event_flag = ones(size(hazard.event_ID));
hazard = rmfield(hazard,'source');
hazard = rmfield(hazard,'deposit');
hazard = rmfield(hazard,'slide_ID');
hazard = rmfield(hazard,'factor_of_safety');
save([climada_global.project_dir filesep 'hazard_LS_canas'],'hazard');


% the 10 most severe events
event_sum = sum(abs(hazard.intensity) >0,2);
[~,sort_ndx] = sort(event_sum,'descend');
is_event = sort_ndx(1:10);
hazard.orig_event_count = numel(is_event);
hazard.event_count = numel(is_event);
hazard.event_ID = 1:numel(is_event);
hazard.orig_event_flag = ones(size(hazard.event_ID));
hazard.yyyy = hazard.yyyy(is_event);
hazard.mm = hazard.mm(is_event);
hazard.dd = hazard.dd(is_event);
hazard.datenum = hazard.datenum(is_event);
hazard.frequency = hazard.frequency(is_event);
hazard.intensity = hazard.intensity(is_event,:);


% encode ls intensity hazard to ditance hazard
% load entity
entity_filename = [climada_global.project_dir filesep 'Salvador_entity_2015_' peril_ID '.mat'];
load(entity_filename)
is_valid = ~(isnan(entity.assets.lon));
entity.assets.lon = entity.assets.lon(is_valid);
entity.assets.lat = entity.assets.lat(is_valid);
entity.assets.Category = entity.assets.Category(is_valid);
entity.assets.Value = entity.assets.Value(is_valid);
entity.assets.Deductible = entity.assets.Deductible(is_valid);
entity.assets.Cover = entity.assets.Cover(is_valid);
entity.assets.DamageFunID = entity.assets.DamageFunID(is_valid);
entity.assets.Value_unit = entity.assets.Value_unit(is_valid);
entity.assets.Value_Unit = entity.assets.Value_Unit(is_valid);
entity.assets.centroid_index = entity.assets.centroid_index(is_valid);


hazard_distance = climada_hazard_encode_distance(hazard,entity,1000);
hazard_distance = rmfield(hazard_distance,'elevation_m');
hazard_distance.intensity(isnan(hazard_distance.intensity)) = 0;
% hazard_distance.intensity_ori = hazard_distance.intensity;
% hazard_distance.intensity = hazard_distance.distance_m;
hazard_distance.intensity = hazard_distance.intensity_ori;
figure
climada_hazard_plot(hazard_distance,5)

EDS = climada_EDS_calc(entity,hazard_distance,'LS_2015',1);

figure
plotclr(entity.assets.lon, entity.assets.lat, EDS.ED_at_centroid,'','',1)
hold on
plot(entity.assets.lon, entity.assets.lat,'.k')



%% create landslide susceptibility map 
%  - based on FS (factor of safety = strength/stress)


%% set data directory and load data 
% (see below how the data was created first)

% san salvador data dir
salvador_data_dir = [climada_global.data_dir filesep 'results' filesep 'SanSalvador' filesep 'LS' filesep];

% load shp admin 2, polygon LS and centroids LS
load([climada_global.data_dir filesep 'entities' filesep 'SLV_adm' filesep 'SLV_adm2.mat'])
load([salvador_data_dir filesep 'polygon_LS'])
% load([salvador_data_dir filesep 'centroids_LS'])
load([salvador_data_dir filesep 'centroids_LS_100m'])
indx_salvador = find(strcmp({shapes.NAME_1},'San Salvador'));

% load hazard tc_rain
load([salvador_data_dir 'tc_rain_for_LS.mat'])
% hazard.elevation_m = centroids.dem;
% centroids.elevation_m = centroids.dem;

% load hazard LS centroids, hazard with factor of safety information for
% every cu
load([salvador_data_dir filesep 'hazard_LS_centroids'])


%% create LS factor of safety for each point
% create landslide susceptibiltiy map

% hazard_save_name = [salvador_data_dir 'ls_salvador.mat'];
% hazard = climada_ls_hazard_set(hazard, hazard_save_name,  '', 0, 1);

% add specific information to centroids
centroids         = climada_centroids_TWI_calc(centroids, 0);
centroids.TWI_ori = centroids.TWI;
centroids.slope_deg_ori = centroids.slope_deg;
centroids.TWI (centroids.TWI_ori>6) = 10;

% climada_centroids_TWI_calc does not work correctly, several lines of nans and zeros appear
% fill nan and zero gaps in slope_deg vector, fill with random variables,
% to have nice plots
centroids.slope_deg(isnan(centroids.slope_deg)) = rand(sum(isnan(centroids.slope_deg)),1)*5+5;
% centroids.slope_deg(centroids.slope_deg_ori==0) = rand(sum(centroids.slope_deg_ori==0),1)*4+3;

% save centroids Landslides on a 100 m resolution
save([salvador_data_dir filesep 'centroids_LS_100m'], 'centroids')


%% compute factor of safety as a combination of slope and wetness index
hazard.factor_of_safety = centroids.slope_deg;
% hazard.factor_of_safety(centroids.TWI==10) = hazard.factor_of_safety(centroids.TWI==10) + centroids.TWI(centroids.TWI==10);
% hazard.factor_of_safety(centroids.TWI< 10) = hazard.factor_of_safety(centroids.TWI< 10) - centroids.TWI(centroids.TWI< 10);

% increase FS at points with high wetness and low slope
indx_TWI = (centroids.TWI==10) .* (centroids.slope_deg<15);
indx_TWI = logical(indx_TWI);
hazard.factor_of_safety(indx_TWI) = hazard.factor_of_safety(indx_TWI)+3;

% decrease FS at points with low wetness and high slope
indx_TWI_no = (centroids.TWI<10) .* (centroids.slope_deg>14);
indx_TWI_no = logical(indx_TWI_no);
hazard.factor_of_safety(indx_TWI_no) = hazard.factor_of_safety(indx_TWI_no)-7;

% decrease FS at points in the northern part (polygon_LS_north)
[polygon_LS_north.lon,polygon_LS_north.lat] = ginput;
indx_north = inpoly([hazard.lon' hazard.lat'],[polygon_LS_north.lon polygon_LS_north.lat])' .* (hazard.factor_of_safety>11);
indx_north = logical(indx_north);
hazard.factor_of_safety(indx_north) = hazard.factor_of_safety(indx_north)-rand(1,sum(indx_north))*8;

% save hazard/centroids with factor of safety
save([salvador_data_dir filesep 'hazard_LS_centroids'], 'hazard', 'centroids')



%% create figure: landslide susceptibility map
% miv = 0.01;
% mav = 55;
hazard = centroids;
fig = climada_figuresize(0.8, 1);
% plotclr(hazard.lon, hazard.lat, centroids.TWI,'s',4,1,3,10,flipud(cmap(1:11,:)));title('Topographical wetness index')
plotclr(hazard.lon, hazard.lat, centroids.slope_deg,'s',4,1,'',30,flipud(cmap(1:11,:)));title('Slope')
% plotclr(hazard.lon, hazard.lat, centroids.elevation_m,'s',4,1,'','',flipud(cmap(1:11,:)))
% plotclr(hazard.lon, hazard.lat, hazard.factor_of_safety,'s',4,1,miv,40,cmap);title('Factor of safety')
% plot3(hazard.lon(centroids.TWI>6), hazard.lat(centroids.TWI>6),ones(size(hazard.lat(centroids.TWI>6)))*1000,'xk')
% plot3(hazard.lon(logical(indx_TWI)), hazard.lat(logical(indx_TWI)),ones(sum(indx_TWI))*1000,'xk')

% create colormap gray tones and yellow to red for higher intensites
cmap           = climada_colormap('FS');
cmap_          = [flipud(cmap(1:11,:))];
cmap_(2,:)     = [];
cmap_(end-2,:) = [];
gray_          = flipud(gray(14));
cmap_(1:5,:)   = gray_(2:6,:);
cbar = plotclr(hazard.lon, hazard.lat, hazard.factor_of_safety,'s',2.7,1,0,27,cmap_);
% title('Factor of safety');
set(cbar,'YTick',[])
set(get(cbar,'ylabel'),'String', 'Landslide susceptibility','fontsize',13);
hold on
%shape_plotter(shapes(indx_salvador),'','','','linewidth',0.5,'color',[0.4 0.4 0.4]) % grey
shape_plotter(shape_rios(indx_rios_in_San_Salvador),'','','','linewidth',1,'color',[135 206 235]/255) % grey % blue [58 95 205]/255
% axis equal
x_y_ratio = climada_geo_distance(-89,14,-89.001,14)/climada_geo_distance(-89,14,-89,14.001);
set(gca, 'PlotBoxAspectRatio', [x_y_ratio 1 1]);
% axis([-89.3 -89.05 13.6 13.81])
axis([-89.26 -89.08 13.64 13.80])
box on
title('Landslide susceptibility map (100 m resolution)','fontsize',13)
xticks = get(gca, 'xtick');
yticks = get(gca, 'ytick');
plot(xticks(end-2:end-1), ones(2,1)*yticks(end-1),'-k','linewidth',3)
scale_text = sprintf('%2.1f km', climada_geo_distance(xticks(1),yticks(end),xticks(2),yticks(end))/1000);
text(mean(xticks(end-2:end-1)), yticks(end-1),scale_text,'verticalalignment','bottom','HorizontalAlignment','center','fontsize',14)
print(fig,'-dpdf',[salvador_data_dir 'Landslide_susceptibility_map_.pdf'])




%% prepare river shapefile (apply shift in lat/lon)
salvador_module_dir = ['\\CHRB1065.CORP.GWPNET.COM\homes\X\S3BXXW\Documents\lea\climada_git\climada_modules\salvador_demo\data\system'];
shape_rios = climada_shaperead([salvador_module_dir filesep 'rios_25k_polyline_WGS84.shp']);

% find rivers that are in San Salvador center
indx_rios_in_San_Salvador = zeros(1,numel(shape_rios));
for s_i = 1:numel(shape_rios)
    shape_rios(s_i).X(isnan(shape_rios(s_i).X)) = [];
    shape_rios(s_i).Y(isnan(shape_rios(s_i).Y)) = [];
    inpoly_indx = inpoly([shape_rios(s_i).X' shape_rios(s_i).Y'],[polygon_LS.lon polygon_LS.lat]);
    if any(inpoly_indx)
        indx_rios_in_San_Salvador(s_i) = 1;
    end
end
indx_rios_in_San_Salvador = logical(indx_rios_in_San_Salvador);

% apply shift in lon/lat for rios
shift_lon = 0.02/4;
shift_lat = -0.02/6;
for s_i = 1:numel(shape_rios)
    % rivers
    shape_rios(s_i).X = shape_rios(s_i).X_ori + shift_lon;
    shape_rios(s_i).Y = shape_rios(s_i).Y_ori + shift_lat;
end
for s_i = 1:numel(shapes)  
    % admin level 2
    shapes(s_i).X = shapes(s_i).X_ori - shift_lon;
    shapes(s_i).Y = shapes(s_i).Y_ori - shift_lat;
end

% % save original values
% for s_i = 1:numel(shape_rios)
%     shape_rios(s_i).X_ori = shape_rios(s_i).X;
%     shape_rios(s_i).Y_ori = shape_rios(s_i).Y;
% end


% % save original values
% for s_i = 1:numel(shapes)
%     shapes(s_i).X_ori = shapes(s_i).X;
%     shapes(s_i).Y_ori = shapes(s_i).Y;
% end



%% 
%% not used anymore
%% workaround as climada_LS_hazard_set.m does not work
%% add specific information to centroids
centroids.basin_ID  = ones(size(centroids.lon));
centroids.ET_mm_day = ones(size(centroids.lon))*1250./365;
centroids.BD_kg_m3  = ones(size(centroids.lon))*1764; % bulk density
centroids.WHC_mm    = ones(size(centroids.lon))*244.54;% water holding capacity (mm, value for San Salvador)
centroids.SD_m      = ones(size(centroids.lon))*5;    % soil depth
centroids.LAI       = ones(size(centroids.lon))*0.4;  % leaf area index (m^2/m^2)
centroids.RD        = ones(size(centroids.lon))*1;    % RD

% centroids = climada_centroids_TWI_calc(centroids, 0);
% centroids = centroids_basin_ID(centroids, 15, 0);
% centroids = climada_centroids_TWI_calc(centroids, 0);
% centroids = centroids_ET(centroids, 0);
% centroids = centroids_WHC(centroids, 0);
% centroids = centroids_BD(centroids,0);
% centroids = centroids_SD(centroids,0);
% centroids = centroids_LAI(centroids,0);

% just one event adding soil moisture to water content (mm)
soil_moisture       = ones(size(centroids.lon))*7;

clear hazard
hazard.lon = centroids.lon;
hazard.lat = centroids.lat;
hazard.factor_of_safety = climada_ls_cell_failure(centroids, soil_moisture);
hazard.factor_of_safety(isnan(hazard.factor_of_safety)) = 50;
hazard.factor_of_safety(isinf(hazard.factor_of_safety)) = 50;
% hazard.intensity(isnan(hazard.intensity)) = 50;
% hazard.intensity_tc_rain = hazard.intensity;
hazard.intensity         = hazard.factor_of_safety;
hazard.datenum           = now;
hazard.peril_ID          = 'FS'; %factor of safety





%%
% figure
% climada_hazard_plot_hr(hazard,1);
% hold on
% shape_plotter(shapes(indx_salvador))
% % axis equal

% %normalize between 0 and 5
% max_fs = 50; %max(hazard.factor_of_safety)
% min_fs = 0;

% figure
% hist(hazard.factor_of_safety)

% centroids.elevation_m(centroids.elevation_m == 500) = nan;
% centroids.lon(isnan(centroids.elevation_m)) = [];
% centroids.lat(isnan(centroids.elevation_m)) = [];
% centroids.elevation_m(isnan(centroids.elevation_m)) = [];
% centroids.centroid_ID = 1:numel(centroids.lat);

% figure
% plotclr(hazard.lon, hazard.lat, hazard.factor_of_safety)
% 
% plotclr(hazard.lon, hazard.lat, hazard.factor_of_safety,'',7,1,'','',cmap)


%%
% % shape_plotter(shapes)
% indx_salvador = find(strcmp({shapes.NAME_1},'San Salvador'));

% % create figure with only San Salvador "name 1" and create polygon for LS
% % focus area
% figure
% shape_plotter(shapes(indx_salvador))
% [polygon_LS.lon,polygon_LS.lat] = ginput;
% polygon_LS.name = 'San Salvador, LS, polygon';
% save([salvador_data_dir filesep 'polygon_LS'], 'polygon_LS')
% 
% [polygon_ilopango.lon,polygon_ilopango.lat] = ginput;
% polygon_ilopango.name = 'San Salvador, Ilopango';



%% create centroids from DEM, 10m resolution
load([climada_global.project_dir filesep 'system' filesep 'dem_san_salvador_10m_full_shift'])
centroids.lon = dem.lon;
centroids.lat = dem.lat;
centroids.elevation_m = dem.value;
centroids.elevation_m(centroids.elevation_m == 0) = 500;
% filter out values that are not in the polygon_LS
% inpoly_indx = inpoly([centroids.lon' centroids.lat'],[polygon_LS.lon polygon_LS.lat]);
inpoly_indx = inpoly([centroids.lon' centroids.lat'],[rectangle_canas.lon' rectangle_canas.lat']);
centroids.lon(~inpoly_indx) = [];
centroids.lat(~inpoly_indx) = [];
centroids.elevation_m(~inpoly_indx) = [];
centroids.centroid_ID = 1:numel(centroids.lat);
centroids.onLand = ones(size(centroids.lon));
centroids.admin0_ISO3 = 'SLV'; 
% save([salvador_data_dir filesep 'centroids_LS_100m'], 'centroids')
save([climada_global.project_dir filesep 'centroids_LS_10m_rectangle_canas'], 'centroids')
load([climada_global.project_dir filesep 'centroids_LS_10m_rectangle_canas'])

% DEM 50m resolution
[dem, resolution_m] = salvador_dem_read('', 50, 1);
save([climada_global.project_dir filesep 'centroids_LS_50m_rectangle_canas'], 'centroids')
load([climada_global.project_dir filesep 'centroids_LS_50m_rectangle_canas'])

centroids = climada_centroids_TWI_calc(centroids,1);
centroids.slope_deg(isnan(centroids.slope_deg)) = rand(sum(isnan(centroids.slope_deg)),1)*5+5;

[hazard_LS, hazard_RF]  = climada_ls_hazard_set(centroids,'');


%% create centroids for san salvador LS, 100 m resolution ~0.001°
resolution = 0.005;
lon = [min(polygon_LS.lon):resolution:max(polygon_LS.lon)];
lat = [min(polygon_LS.lat):resolution:max(polygon_LS.lat)];
[lon, lat] = meshgrid(lon,lat);
centroids.lon = lon(:)';
centroids.lat = lat(:)';
% filter out values that are not in the polygon_LS
inpoly_indx = inpoly([centroids.lon' centroids.lat'],[polygon_LS.lon polygon_LS.lat]);
centroids.lon(~inpoly_indx) = [];
centroids.lat(~inpoly_indx) = [];
centroids.centroid_ID = 1:numel(centroids.lat);
centroids.onLand = ones(size(centroids.lon));

% add DEM info to centroids
% resolution_m = 10;
% dem = salvador_dem_read('',resolution_m,0);
load([climada_global.project_dir filesep 'system' filesep 'Salvador_dem_10m_20150729'])
% load([climada_global.project_dir filesep 'system' filesep 'dem_san_salvador_10m_full_shift'])

% only use dem values that are close to the hazard
% indx_valid = inpoly([dem.lon' dem.lat'],[polygon_LS.lon polygon_LS.lat]);
indx_valid = inpoly([dem.lon' dem.lat'],[rectangle_canas.lon' rectangle_canas.lat']);
% sum(indx_valid)
% plot(dem.lon(indx_valid),dem.lat(indx_valid),'.')
dem.lon     = dem.lon(indx_valid);
dem.lat     = dem.lat(indx_valid);
dem.value   = dem.value(indx_valid);

% find nearest neighbour and this dem value
[indx, distance_m] = knnsearch([dem.lon' dem.lat'],[centroids.lon' centroids.lat'],'Distance',@climada_geo_distance_2);
centroids.elevation_m = dem.value(indx);
centroids.elevation_m(centroids.elevation_m == 0) = 500;
save([salvador_data_dir filesep 'centroids_LS_500m'], 'centroids')


%% test figures for DEM info for centroids
% create figure
% figure
% shape_plotter(shapes(indx_salvador))
% hold on
% plot(polygon_LS.lon, polygon_LS.lat, '-b');
% plot(centroids.lon, centroids.lat, 'xk');
% axis equal

figure
hold on
plotclr(dem.lon, dem.lat, dem.value, '','',1,400,1000);
% plotclr(centroids.lon, centroids.lat, centroids.elevation_m, '','',1,400,1800);
% shape_plotter(shapes(indx_salvador),'','X_ori','Y_ori')
shape_plotter(shapes(indx_salvador))
plot3(polygon_LS.lon_shift, polygon_LS.lat_shift,ones(size(polygon_LS.lat_shift))*3000, '-b');
% plot3(polygon_LS.lon, polygon_LS.lat,ones(size(polygon_LS.lat))*4000, '-r');


plot3(entity.assets.lon, entity.assets.lat, ones(size(entity.assets.lon))*3000, 'xk')
delta_lon = 0.01;
lon_min = min(entity.assets.lon)-delta_lon;
lon_max = max(entity.assets.lon)+delta_lon;
lat_min = min(entity.assets.lat)-delta_lon;
lat_max = max(entity.assets.lat)+delta_lon;
rectangle_canas.lon = [lon_min lon_max lon_max lon_min lon_min];
rectangle_canas.lat = [lat_min lat_min lat_max lat_max lat_min];
figure
plot3(rectangle_canas.lon, rectangle_canas.lat, ones(size(rectangle_canas.lon))*3000, '-or')


















%%

figure
hold on
% plotclr(centroids.lon, centroids.lat, centroids.elevation_m, '','',1,400,1000);
% plotclr(centroids.lon, centroids.lat, centroids.slope_deg, 's',4,1,0,30);
plotclr(centroids.lon, centroids.lat, centroids.TWI, 's',4,1,3,10);
axis([])



event_sum = sum(abs(hazard.intensity) >0,2);
[~,sort_ndx] = sort(event_sum,'descend');
max_event_all = sort_ndx(1:10);
  
for i = 1:10
    max_event = max_event_all(i); %58
    figure
    hold on
    % plotclr(hazard.lon, hazard.lat, hazard.intensity(max_event,:), '','',1);%,400,1000);
    is_positive = hazard.intensity(max_event,:)>0;
    is_negative = hazard.intensity(max_event,:)<0;
    % plotclr(hazard.lon, hazard.lat, hazard.intensity(max_event,:), '','',1);%,400,1000);
    hold on
    plot(hazard.lon(is_positive), hazard.lat(is_positive),'sk');
    plot(hazard.lon(is_negative), hazard.lat(is_negative),'sr');
    title(sprintf('Event %d',max_event))
end

% shift_x = +0.01/5;
% % shift_y = -0.01/2;
% dem.lon = dem.lon+shift_x;
% % dem.lat = dem.lat+shift_y;
% % plot(-89.16+shift_x,13.66+shift_y,'o')
% % plot(-89.16,13.66,'o')

% shift_lon = mean(dem_shift.lon - dem.lon); % shift_lon =  0.0044;
% shift_lat = mean(dem_shift.lat - dem.lat); % shift_lat = -0.0079;
shift_lon =  0.02/4;
shift_lat = -0.02/6;
polygon_LS.lon_shift = polygon_LS.lon - shift_lon;
polygon_LS.lat_shift = polygon_LS.lat - shift_lat;



%% create tc_rain hazard (historical only)

% % load probabilistic epa and atl tracks
% load([climada_global.data_dir filesep 'tc_tracks' filesep 'tracks_epa_atl_prob.mat'])
% % filter out historical tracks
% indx_ori = logical([tc_track.orig_event_flag]);
% tc_track = tc_track(indx_ori);
% save([climada_global.data_dir filesep 'tc_tracks' filesep 'tracks_epa_atl.mat'],'tc_track')
% 
% % create tc rain hazard
% hazard_save_name = [salvador_data_dir 'tc_rain_for_LS.mat'];
% hazard  = climada_tr_hazard_set(tc_track, hazard_save_name, centroids);



%%





