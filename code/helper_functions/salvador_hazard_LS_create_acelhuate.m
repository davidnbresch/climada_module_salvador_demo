%--------------------------------------------------------------------------
% this is not used anymore
% with this script, the landslide hazard for acelhuate was created
%--------------------------------------------------------------------------
% Lea Mueller, muellele@gmail.com, 20151125, rename to climada_centroids_generate from climada_generate_centroids
% Lea Mueller, muellele@gmail.com, 20151125, rename to climada_centroids_TWI_calc from centroids_TWI



% % load assets
% load([climada_global.project_dir filesep 'Salvador_entity_2015_LS'])
% 
% % load hazard LS binary
% load([climada_global.project_dir filesep 'Salvador_hazard_LS_2015'])
% 
% % load shp files
% load([climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS'])



%-----------------------------------------
%% create landslide hazard for Acelhuate
%-----------------------------------------

% module data dir
module_data_dir =[climada_global.modules_dir filesep 'salvador_demo' filesep 'data'];

% landslide directory on shared drive
ls_dir = [climada_global.project_dir filesep 'LS' filesep];

% load assets
% load([climada_global.project_dir filesep 'Salvador_entity_2015_LS']) % las canas
load([climada_global.project_dir filesep 'Salvador_entity_2015_FL']) % acelhuate

% load shp files
load([climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS'])

%% create centroids for ACELHUATE 
% - on a regular 30 m grid
% - with centroids.lon, centroids.lat, centroids.elevation_m
% - centroids.slope_deg, centroids.TWI
%-----------------------------------

% load dem 30m entire AMSS
load([climada_global.project_dir filesep 'LS' filesep 'dem_30m_AMSS'])
% resolution_m = 30;
% check_plot = 1;
% [dem, resolution_m] = salvador_dem_read('', resolution_m, check_plot);

% load assets acelhuate
load([climada_global.project_dir filesep 'Salvador_entity_2015_FL'])

% select FL assets
is_selected = climada_assets_select(entity,'FL');

% delta_lon = 0.01; %
% % delta_lon = 0.005;
% % delta_lon = 0.015; %
% lon_min = min(entity.assets.lon(is_selected))-delta_lon;
% lon_max = max(entity.assets.lon(is_selected))+delta_lon;
% lat_min = min(entity.assets.lat(is_selected))-delta_lon;
% lat_max = max(entity.assets.lat(is_selected))+delta_lon;

% overwrite with manual values
lon_min = -89.255;
lon_max = -89.162;
lat_min =  13.655;
lat_max =  13.73;

% create rectangle around acelhuate
rectangle_acelhuate.lon = [lon_min lon_max lon_max lon_min lon_min];
rectangle_acelhuate.lat = [lat_min lat_min lat_max lat_max lat_min];

% plot DEM and assets
% set figure parameters
markersize = 3;
marker = 's';
cbar_on = 1;
axlim = [lon_min lon_max lat_min lat_max];
fig = climada_figuresize(0.5,1.0);
plotclr(dem.lon, dem.lat, dem.value,marker,markersize,cbar_on);
% plotclr(dem.lon, dem.lat, dem.value,marker,markersize,cbar_on,550,1000);
hold on
plot3(entity.assets.lon(is_selected), entity.assets.lat(is_selected), ones(size(entity.assets.lon(is_selected)))*3000, 'xk','markersize',markersize-1)
plot3(rectangle_acelhuate.lon, rectangle_acelhuate.lat, ones(size(rectangle_acelhuate.lon))*3000, '-or')
title('DEM AMSS'); box on; 
climada_figure_axis_limits_equal_for_lat_lon([-89.45 -89.0 13.55 13.85]);
climada_figure_scale_add('',7,1)
pdf_filename = sprintf('AMSS_DEM_Acelhuate_rectangle.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])

% % only use dem values that are within Acelhuate rectangle
% indx_valid = inpoly([dem.lon' dem.lat'],[rectangle_acelhuate.lon' rectangle_acelhuate.lat']);
% % sum(indx_valid)
% % figure; plot(dem.lon(indx_valid),dem.lat(indx_valid),'.')

% % only use dem values that are within Acelhuate rectangle
indx_valid = inpoly([centroids.lon' centroids.lat'],[rectangle_acelhuate.lon' rectangle_acelhuate.lat']);
sum(indx_valid)
figure; plotclr(centroids.lon(indx_valid),centroids.lat(indx_valid),centroids.elevation_m(indx_valid),'.')
hold on; plot3(rectangle_acelhuate.lon, rectangle_acelhuate.lat, ones(size(rectangle_acelhuate.lon))*3000, '-or')

centroids.lon = centroids.lon(indx_valid);
centroids.lat = centroids.lat(indx_valid);
% centroids.centroid_ID = centroids.centroid_ID(indx_valid);
% centroids.onLand = centroids.onLand(indx_valid);
% centroids.elevation_m = centroids.elevation_m(indx_valid);
% centroids.basin_ID = centroids.basin_ID(indx_valid);
% centroids.FL_score = centroids.FL_score(indx_valid);
% centroids.TWI = centroids.TWI(indx_valid);
% centroids.slope_deg = centroids.slope_deg(indx_valid);
% centroids.area_m2 = centroids.area_m2(indx_valid);
% centroids.aspect_deg = centroids.aspect_deg(indx_valid);
% centroids.sink_ID = centroids.sink_ID(indx_valid);
% centroids.lat_ori = centroids.lat_ori(indx_valid);
% centroids.slope_factor = centroids.slope_factor(indx_valid);
% centroids.TWI_norm = centroids.TWI_norm(indx_valid);
% centroids.sink_ID_10 = centroids.sink_ID_10(indx_valid,:);



% create centroids on a regular grid
clear centroids 
res_km = 0.03;     
centroids = climada_centroids_generate(rectangle_acelhuate,res_km,0,'NO_SAVE',1);
centroids.admin0_ISO3 = 'SLV'; 
% compute centroids elevation
centroids.elevation_m = F_DEM(centroids.lon',centroids.lat')';
centroids.basin_ID = ones(size(centroids.lon));
centroids.centroid_ID = 1:numel(centroids.lon);
centroids.onLand = ones(size(centroids.lon));
% Calculate flood scores and topographic wetness indices
centroids = climada_centroids_TWI_calc(centroids, 0);
% save([ls_dir 'centroids_acelhuate_30m'],'centroids')
% save([ls_dir 'centroids_acelhuate_30m_v2'],'centroids')
save([ls_dir 'centroids_acelhuate_30m_v3'],'centroids')

% centroids_old = centroids;
% within_rectangle = inpoly([centroids_old.lon' centroids_old.lat'],[rectangle_acelhuate.lon' rectangle_acelhuate.lat']);
% centroids.lon = centroids_old.lon(within_rectangle);
% centroids.lat = centroids_old.lat(within_rectangle);
% centroids.elevation_m = centroids_old.elevation_m(within_rectangle);

% move centroids/dem to south (roughly 200 m)
% centroids.lat_ori = centroids.lat;
delta_lat = -0.01/6.5;
centroids.lat = centroids.lat_ori+delta_lat;

% find flow direction
centroids = climada_flow_find(centroids);

    
%%  create figures to understand the situation
%-----------------------------------

load([ls_dir 'centroids_acelhuate_30m_v3'])

delta_lon = 0.002;
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
fig = climada_figuresize(0.5,1.0);
plotclr(entity.assets.lon(is_selected), entity.assets.lat(is_selected), entity.assets.Value(is_selected),marker,markersize,cbar_on,miv,mav);
title(titlestr); axis(axlim); box on; hold on
climada_figure_axis_limits_equal_for_lat_lon(axlim); climada_figure_scale_add('',7,1);
% % polygon_canas = climada_shape_selector(fig,1,1);
% % polygon_canas.lon = polygon_canas.X;
% % polygon_canas.lat = polygon_canas.Y;
% polygon_acelhuate = climada_shape_selector(fig,1,1);
% polygon_acelhuate.lon = polygon_acelhuate.X;
% polygon_acelhuate.lat = polygon_acelhuate.Y;
% % shape_plotter(polygon_rio_acelhuate, '')
% % shape_plotter(shapes,label_att,lon_fieldname,lat_fieldname,varargin)
pdf_filename = sprintf('LS_entity_assets_acelhuate.pdf'); %pdf_filename = sprintf('LS_entity_assets.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])

% dem
titlestr = 'DEM (masl)';
miv = 550;
mav = 1000;
% miv = 520;
% mav = 650;
fig = climada_figuresize(0.5,1.0);
% plot(centroids.lon, centroids.lat,'.')
plotclr(centroids.lon, centroids.lat, centroids.elevation_m, marker,markersize,cbar_on,miv,mav);
hold on; plot3(entity.assets.lon(is_selected), entity.assets.lat(is_selected), ones(size(entity.assets.lon(is_selected)))*3000, '.r','linewidth',0.2,'markersize',1.2,'color','k')%[255 64 64 ]/255
title(titlestr); axis(axlim); box on
climada_figure_axis_limits_equal_for_lat_lon(axlim); climada_figure_scale_add('',7,1);
% pdf_filename = sprintf('LS_DEM_masl.pdf');
pdf_filename = sprintf('LS_DEM_masl_with_assets_black.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])


% slope
titlestr = 'Slope (degree)';
miv = 0;
mav = 25;
fig = climada_figuresize(0.5,1.0);
plotclr(centroids.lon, centroids.lat, centroids.slope_deg, marker,markersize,cbar_on,miv,mav);
hold on; plot3(entity.assets.lon(is_selected), entity.assets.lat(is_selected), ones(size(entity.assets.lon(is_selected)))*3000, '.r','linewidth',0.2,'markersize',1.2,'color',[255 64 64 ]/255)
title(titlestr); axis(axlim); box on
climada_figure_axis_limits_equal_for_lat_lon(axlim); climada_figure_scale_add('',7,1);
% pdf_filename = sprintf('LS_slope_degree.pdf');
pdf_filename = sprintf('LS_slope_degree_with assets.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])

% TWI
titlestr = 'TWI (-)';
miv = 2;
mav = 16;
fig = climada_figuresize(0.5,1.0);
plotclr(centroids.lon, centroids.lat, centroids.TWI, marker,markersize,cbar_on,miv,mav);
hold on; plot3(entity.assets.lon(is_selected), entity.assets.lat(is_selected), ones(size(entity.assets.lon(is_selected)))*3000, '.r','linewidth',0.2,'markersize',1.2,'color','k')
title(titlestr); axis(axlim); box on
climada_figure_axis_limits_equal_for_lat_lon(axlim); climada_figure_scale_add('',7,1);
% pdf_filename = sprintf('LS_TWI.pdf');
pdf_filename = sprintf('LS_TWI_with_assets.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])

% aspect
titlestr = 'Aspect (-)';
miv = 0;
mav = 360;
fig = climada_figuresize(0.5,1.0);
plotclr(centroids.lon, centroids.lat, centroids.aspect_deg, marker,markersize,cbar_on,miv,mav);
title(titlestr); axis(axlim); box on
climada_figure_axis_limits_equal_for_lat_lon(axlim); climada_figure_scale_add('',7,1);
pdf_filename = sprintf('LS_aspect.pdf');
print(fig,'-dpdf',[ls_dir pdf_filename])


% % Flood score
% titlestr = 'Flood score (-)';
% miv = -5;
% mav = 250;
% fig = climada_figuresize(0.5,1.0);
% plotclr(centroids.lon, centroids.lat, centroids.FL_score, marker,markersize,cbar_on,miv,mav);
% title(titlestr); axis(axlim); box on; climada_figure_scale_add('',7,1)
% pdf_filename = sprintf('LS_flood_score.pdf');
% print(fig,'-dpdf',[ls_dir pdf_filename])
% % plotclr(centroids.lon, centroids.lat, centroids.FL_score, marker,markersize,cbar_on);

% % sink_ID
% titlestr = 'Sink ID (-)';
% fig = climada_figuresize(0.5,1.0);
% plotclr(centroids.lon, centroids.lat, centroids.sink_ID, marker,markersize,cbar_on);
% title(titlestr); axis(axlim); box on; climada_figure_scale_add('',7,1)
% pdf_filename = sprintf('LS_sink_ID.pdf');
% print(fig,'-dpdf',[ls_dir pdf_filename])


% slope factor
titlestr = 'Slope factor (-)';
miv = 0;
mav = 0.35;
fig = climada_figuresize(0.5,1.0);
plotclr(centroids.lon, centroids.lat, centroids.slope_factor, marker,markersize,cbar_on,miv,mav);
title(titlestr); axis(axlim); box on
climada_figure_axis_limits_equal_for_lat_lon(axlim); climada_figure_scale_add('',7,1);
pdf_filename = sprintf('LS_slope_factor.pdf');
% print(fig,'-dpdf',[ls_dir pdf_filename])

% % TWI normalized
titlestr = 'TWI normalized (-)';
miv = 0;
mav = 1.6;
fig = climada_figuresize(0.5,1.0);
plotclr(centroids.lon, centroids.lat, centroids.TWI_norm, marker,markersize,cbar_on,miv,mav);
title(titlestr); axis(axlim); box on
climada_figure_axis_limits_equal_for_lat_lon(axlim); climada_figure_scale_add('',7,1);
pdf_filename = sprintf('LS_TWI_norm.pdf');
% print(fig,'-dpdf',[ls_dir pdf_filename])


% % figure
% c_i = 40500;
% is_sink = ismember(centroids.centroid_ID,centroids.sink_ID_10(c_i,:));
% % figure
% % plotclr(centroids.lon, centroids.lat, centroids.elevation_m, marker,markersize,cbar_on,500,1000);
% % hold on
% plot3(centroids.lon(is_sink),centroids.lat(is_sink),ones(size(centroids.lon(is_sink)))*1300,'color',[100 100 100]/255);


%% create ls hazard
%-----------------------------------
% centroids.slope_factor(centroids.slope_factor>0.35) = 0.35;
% TWI_norm = centroids.TWI/10;
% TWI_norm(TWI_norm>1.11) = 1.11;
% centroids.TWI_norm = TWI_norm;

% acelhuate parameters
n_events = 1000;
wiggle_factor = 0.35; 
TWI_condition = 1.25;
wiggle_factors_slope = 0.18; 
slope_condition = 0.28; %slope_condition = 0.5;
n_downstream_cells = 2;

% las canas parameters
% wiggle_factor = 0.35; 
% TWI_condition = 0.9;
% wiggle_factors_slope = 0.1; 
% slope_condition = 0.45;
% n_downstream_cells = 2;
hazard_set_file = [ls_dir 'Salvador_hazard_LS_2015_acelhuate.mat'];
hazard  = climada_ls_hazard_set_binary(centroids,n_events,hazard_set_file,wiggle_factor,TWI_condition,...
    wiggle_factors_slope,slope_condition,n_downstream_cells,polygon_acelhuate,polygon_correction,0.93);


%% visualize hazard ls simple
% ------------------------------
n_events = 10;
n_colors = jet(n_events);
fig = climada_figuresize(0.5,1.2);
plot(entity.assets.lon, entity.assets.lat,'.','linewidth',0.2,'markersize',0.8,'color',[255 64 64 ]/255);
hold on
legendstr = []; h = [];
for e_i = 1:n_events
    is_event = logical(hazard.intensity(e_i,:));
    if any(is_event)
        %hold on; plot3(hazard.lon(is_event), hazard.lat(is_event), ones(sum(is_event))*3000, 'dr','linewidth',2,'markersize',5,'color',[255 64 64 ]/255)
        h(e_i) = plot(hazard.lon(is_event), hazard.lat(is_event),'dr','linewidth',2,'markersize',5,'color',n_colors(e_i,:));
        hold on; plot(polygon_canas.X, polygon_canas.Y, 'b-');
        legendstr{e_i} = sprintf('Event %d',e_i);
    end
end
title(sprintf('LS event %d',e_i)); axis(axlim); box on; 
climada_figure_axis_limits_equal_for_lat_lon(axlim); climada_figure_scale_add('',7,1)
legend(h,legendstr,'location','eastoutside')
% pdf_filename = sprintf('LS_aspect.pdf');
% print(fig,'-dpdf',[ls_dir pdf_filename])

% polygon_correction = climada_shape_selector(fig,1,1);
% polygon_correction.lon = polygon_correction.X;
% polygon_correction.lat = polygon_correction.Y;



%% encode to distance
% ------------------------------
centroids_new.lon = centroids.lon(indx_valid);
centroids_new.lat = centroids.lat(indx_valid);
centroids_new.centroid_ID = 1:numel(centroids_new.lat);
centroids_new.elevation_m = centroids.elevation_m(indx_valid);
% centroids.lon = hazard.lon;
% centroids.lat = hazard.lat;
cutoff = 1000;
hazard_distance = climada_hazard_encode_distance(hazard,centroids_new,cutoff);
save([ls_dir 'Salvador_hazard_LS_acelhuate_2015'],'hazard_distance')

% cut out polygon
indx_valid = inpoly([hazard.lon' hazard.lat'],[polygon_acelhuate.lon' polygon_acelhuate.lat']);
sum(indx_valid)
hazard.lon = hazard.lon(indx_valid);
hazard.lat = hazard.lat(indx_valid);
hazard.centroid_ID = 1:numel(hazard.lat);
hazard.intensity = hazard.intensity(:,indx_valid);
hazard = rmfield(hazard,'distance_m');
save([ls_dir 'Salvador_hazard_LS_acelhuate_2015'],'hazard')


%% load hazard distance
load([climada_global.project_dir filesep 'Salvador_hazard_LS_acelhuate_2015'])


% calculate statistics for return periods
% hazard_distance.intensity_ori = hazard_distance.intensity;
% hazard_distance.intensity = hazard_distance.distance_m;
% return_periods = [2 5 10 20 33 50 80 100 500 1000];
return_periods = [2 5 10 25 50 60 70 80 90 100 150 200];
hazard_distance_stats = climada_hazard_stats(hazard,return_periods,0);
climada_hazard_stats_figure(hazard_distance_stats,return_periods)

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
hazard_distance_stats.distance_m_fit = (1.-hazard_distance_stats.intensity_fit)*hazard.cutoff_m;
hazard_distance_stats.distance_m_fit(hazard_distance_stats.intensity_fit>=1) = 1;
markersize = 3.0;% markersize = 2.2;
marker = 's';
for e_i = 5:length(return_periods)
    %e_i = 3;
    fig = climada_figuresize(0.5,1.1);
    cbar = plotclr(hazard.lon, hazard.lat, hazard_distance_stats.distance_m_fit(e_i,:),marker,markersize,1,miv,mav,cmap);
    %plotclr(hazard.lon, hazard.lat, hazard_distance_stats.intensity_fit(e_i,:),'','',1,0,1,cmap);
    hold on; 
    plot3(polygon_acelhuate.X, polygon_acelhuate.Y,ones(size(polygon_acelhuate.X))*1000,'color',[100 100 100]/255);
    g = plot3(entity.assets.lon, entity.assets.lat,ones(size(entity.assets.lat))*1000,'.','linewidth',0.2,'markersize',1.8,'color',[200 200 200]/255);%[255 64 64 ]/255);
    %g = plot(entity.assets.lon-5, entity.assets.lat-5,'.','linewidth',1,'markersize',7,'color',[200 200 200]/255);%[255 64 64 ]/255);
    %set(cbar,'YTick',[])
    set(get(cbar,'ylabel'),'String', 'Distance to landslide (m)','fontsize',13);
    title(sprintf('Return period %d years',hazard_distance_stats.R_fit(e_i)),'fontsize',13)
    axis(axlim); box on; 
    climada_figure_axis_limits_equal_for_lat_lon(axlim); climada_figure_scale_add('',7,1)
    
    pdf_filename = sprintf('Landslides_acelhuate_%d_years.pdf',hazard_distance_stats.R_fit(e_i));
    print(fig,'-dpdf',[ls_dir pdf_filename])
end








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




