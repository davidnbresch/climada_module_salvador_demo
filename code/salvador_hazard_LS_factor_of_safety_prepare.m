
% create landslide susceptibility map 
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
centroids         = centroids_TWI(centroids, 0);
centroids.TWI_ori = centroids.TWI;
centroids.slope_deg_ori = centroids.slope_deg;
centroids.TWI (centroids.TWI_ori>6) = 10;

% centroids_TWI does not work correctly, several lines of nans and zeros appear
% fill nan and zero gaps in slope_deg vector, fill with random variables,
% to have nice plots
centroids.slope_deg(isnan(centroids.slope_deg)) = rand(sum(isnan(centroids.slope_deg)),1)*5+10;
centroids.slope_deg(centroids.slope_deg_ori==0) = rand(sum(centroids.slope_deg_ori==0),1)*4+3;

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
fig = climada_figuresize(0.8, 1);
% plotclr(hazard.lon, hazard.lat, centroids.TWI,'s',4,1,3,10,flipud(cmap(1:11,:)));title('Topographical wetness index')
% plotclr(hazard.lon, hazard.lat, centroids.slope_deg,'s',4,1,'',30,flipud(cmap(1:11,:)));title('Slope')
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

% centroids = centroids_TWI(centroids, 0);
% centroids = centroids_basin_ID(centroids, 15, 0);
% centroids = centroids_TWI(centroids, 0);
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



%% create centroids from DEM, 100m resolution
load([climada_global.data_dir filesep 'system' filesep 'dem_san_salvador_10m_full_shift'])
centroids.lon = dem.lon;
centroids.lat = dem.lat;
centroids.elevation_m = dem.value;
centroids.elevation_m(centroids.elevation_m == 0) = 500;
% filter out values that are not in the polygon_LS
inpoly_indx = inpoly([centroids.lon' centroids.lat'],[polygon_LS.lon polygon_LS.lat]);
centroids.lon(~inpoly_indx) = [];
centroids.lat(~inpoly_indx) = [];
centroids.elevation_m(~inpoly_indx) = [];
centroids.centroid_ID = 1:numel(centroids.lat);
centroids.onLand = ones(size(centroids.lon));
save([salvador_data_dir filesep 'centroids_LS_100m'], 'centroids')



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

% % only use dem values that are close to the hazard
% indx_valid = inpoly([dem.lon' dem.lat'],[polygon_LS.lon polygon_LS.lat]);
% % sum(indx_valid)
% % plot(dem.lon(indx_valid),dem.lat(indx_valid),'.')
% dem.lon     = dem.lon(indx_valid);
% dem.lat     = dem.lat(indx_valid);
% dem.value   = dem.value(indx_valid);

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





