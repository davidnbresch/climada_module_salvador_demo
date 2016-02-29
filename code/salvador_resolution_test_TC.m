
% Resolution sensitivity analysis for climada applied to 
% landslides and tropical cyclones in San Salvador
% Lea Mueller, 20160219

% Perform sensitivity analysis for different resolutions for two cases, 
% 1) landslides in Las Cañas neighborhood in San Salvador and 
% 2) tropical cyclones in the metropolitan area of San Salvador (AMSS). 
% Analyzed resolutions range from high resolution (~50 meter), mid 
% resolution (~1 km) to low resolution (~10 km).
% Lea Mueller, muellele@gmail.com, 20160229, rename to climada_shapeplotter from shape_plotter


%% Tropical cyclones wind

climada_global.font_scale = 1.4;
climada_global.max_distance_to_hazard = 10^6;
climada_global.markersize = 5;

% load shps files
load([climada_global.data_dir filesep 'results' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS.mat'])

% TC hazard san salvador AMSS
TC_hazard_file = [climada_global.data_dir filesep 'hazards' filesep 'Salvador_hazard_TC_2015.mat'];
hazard = climada_hazard_load('Salvador_hazard_TC_2015.mat');
% hazard = rmfield(hazard,'name');
climada_map_plot(hazard)

hazard.intensity_all = sum(hazard.intensity,1);
figure; climada_map_plot(hazard,'intensity_all'); hold on; climada_shapeplotter(polygon_LS,'','lon','lat')
% hold on; plot(entity_high_res.assets.lon, entity_high_res.assets.lat,'x','markersize',12)

% return_periods = [50 500 1000]; check_plot = 0;
% hazard_stats = climada_hazard_stats(hazard,return_periods,check_plot);


% high resolution assets
TC_entity_file = [climada_global.data_dir filesep 'entities' filesep 'TC_entity_AMSS.xls'];
entity_high_res = climada_entity_read(TC_entity_file,'NOENCODE');
entity_high_res.assets.Value(entity_high_res.assets.Category==2) = 0;
climada_global.markersize = 6;
climada_figuresize(0.6,0.8); climada_map_plot(entity_high_res,'Value');
hold on; climada_shapeplotter(polygon_AMSS,'','lon','lat')
climada_figure_axis_limits_equal_for_lat_lon([-89.32 -89.03 13.629 13.84]); climada_figure_scale_add('',1,1)

% polygon_AMSS = climada_shape_selector(gcf,1);
% climada_geo_distance(entity_high_res.assets.lon(1), entity_high_res.assets.lat(1), entity_high_res.assets.lon(2), entity_high_res.assets.lat(2))
% 
% climada_geo_distance(entity_high_res.assets.lon(2), entity_high_res.assets.lat(2), entity_high_res.assets.lon(3), entity_high_res.assets.lat(3))
% % figure;climada_shapeplotter(polygon_ilopango,'','lon','lat')
% % climada_shapeplotter(shape_rivers)
% % rios_25k_shapes = climada_shaperead([salvador_data_dir filesep 'system' filesep 'rios_25k_polyline_WGS84.shp'],1);


% EDS high resolution
annotation_name = 'high resolution assets';
EDS = climada_EDS_calc(entity_high_res,hazard,annotation_name);
climada_figuresize(0.6,0.8); climada_map_plot(EDS,'ED_at_centroid');
hold on; climada_shapeplotter(polygon_AMSS,'','lon','lat')
climada_figure_axis_limits_equal_for_lat_lon([-89.32 -89.03 13.629 13.84]); climada_figure_scale_add('',1,1)

% adaptation measures high resolution
measures_impact_reference = 'no';
measures_impact_high_res = climada_measures_impact(entity_high_res,hazard,measures_impact_reference);
climada_figuresize(0.4,0.9); climada_adaptation_cost_curve(measures_impact_high_res)

% save
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'TC_entity_high_res.mat'],'entity_high_res')
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'TC_EDS.mat'],'EDS')
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'TC_measures_impact_high_res.mat'],'measures_impact_high_res')


%% mid resolution (1km)
% mid resolution assets
admin0_name = 'El Salvador'; admin1_name = 'San Salvador'; selections = 0; scale_Value = [0 1 0];
entity_nightlight = climada_nightlight_entity(admin0_name,admin1_name,selections,0,scale_Value);
figure;climada_map_plot(entity_nightlight)
hold on; climada_shapeplotter(polygon_AMSS,'','lon','lat')
figure;climada_entity_plot(entity_nightlight)

entity_nightlight_2 = climada_nightlight_entity(admin0_name,'La Libertad',selections,0,scale_Value);
figure;climada_map_plot(entity_nightlight_2)
hold on; climada_shapeplotter(polygon_AMSS,'','lon','lat')

% combine the two
entity_nightlight.assets.Value = [entity_nightlight.assets.Value entity_nightlight_2.assets.Value];
entity_nightlight.assets.lon = [entity_nightlight.assets.lon entity_nightlight_2.assets.lon];
entity_nightlight.assets.lat = [entity_nightlight.assets.lat entity_nightlight_2.assets.lat];

% climada_geo_distance(entity.assets.lon(1), entity.assets.lat(1), entity.assets.lon(2), entity.assets.lat(2))
% climada_geo_distance(entity_mid_res.assets.lon(2), entity_mid_res.assets.lat(2), entity_mid_res.assets.lon(3), entity_mid_res.assets.lat(3))

% filter out points within AMSS polygon (648 points)
is_inside = inpoly([entity_nightlight.assets.lon; entity_nightlight.assets.lat]', [polygon_AMSS.lon; polygon_AMSS.lat]');
sum(is_inside)

% create mid_res assets (18 points)
entity_nightlight.assets.Value_orig = entity_nightlight.assets.Value;
entity_nightlight.assets.Value(~is_inside)= 0;
entity_mid_res = entity_high_res;
assets = entity_nightlight.assets;
assets.lon = entity_nightlight.assets.lon(is_inside);
assets.lat = entity_nightlight.assets.lat(is_inside);
assets.Value = entity_nightlight.assets.Value(is_inside);
assets.DamageFunID = ones(size(assets.Value))*121;
assets.Deductible = zeros(size(assets.Value));
assets.Cover = zeros(size(assets.Value));
assets = rmfield(assets,'Value_orig');

scale_Value = [0 -1.0159e8 2.1351e7 sum(entity_high_res.assets.Value)];
assets.Value = scale_Value(1) + scale_Value(2)*assets.Value + scale_Value(3)*assets.Value.^2;
assets.comment=sprintf('%s: y = %2.2f + %2.2f*x^1 + %2.2f*x^2',mfilename,scale_Value(1:3));
if length(scale_Value)==4
    assets.Value = assets.Value/sum(assets.Value)*scale_Value(4); % normalize, multiply
    assets.comment=[assets.comment sprintf(', normalized, then *%2.2f',scale_Value(4))];
end
assets.Cover = assets.Value;
entity_mid_res.assets = assets;
entity_mid_res.measures = rmfield(entity_mid_res.measures,'regional_scope');
entity_mid_res.measures.regional_scope = logical(ones(10,9));

climada_global.markersize = 10;
climada_figuresize(0.6,0.8);climada_map_plot(entity_mid_res)
hold on; climada_shapeplotter(polygon_AMSS,'','lon','lat')
climada_figure_axis_limits_equal_for_lat_lon([-89.32 -89.03 13.629 13.84]); climada_figure_scale_add('',1,1)


% EDS mid resolution
annotation_name = 'mid resolution assets';
EDS(2) = climada_EDS_calc(entity_mid_res,hazard,annotation_name);

climada_figuresize(0.6,0.8); climada_map_plot(EDS(2),'ED_at_centroid','','');
hold on; climada_shapeplotter(polygon_AMSS,'','lon','lat')
climada_figure_axis_limits_equal_for_lat_lon([-89.32 -89.03 13.629 13.84]); climada_figure_scale_add('',1,1)


% adaptation measures mid resolution
measures_impact_reference = 'no';
measures_impact_mid_res = climada_measures_impact(entity_mid_res,hazard,measures_impact_reference);
climada_figuresize(0.4,0.9); climada_adaptation_cost_curve(measures_impact_mid_res)

% save
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'TC_entity_mid_res.mat'],'entity_mid_res')
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'TC_EDS.mat'],'EDS')
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'TC_measures_impact_mid_res.mat'],'measures_impact_mid_res')


%% low resolution (10 km)

admin0_name = 'El Salvador'; admin1_name = 'San Salvador'; selections = 10; scale_Value = [0 1 0];
entity_nightlight_10km = climada_nightlight_entity(admin0_name,admin1_name,selections,0,scale_Value);
figure;climada_map_plot(entity_nightlight_10km)
hold on; climada_shapeplotter(polygon_AMSS,'','lon','lat')
% figure;climada_entity_plot(entity_nightlight_10km)

entity_nightlight_10km_2 = climada_nightlight_entity(admin0_name,'La Libertad',selections,0,scale_Value);
figure;climada_map_plot(entity_nightlight_10km_2)
hold on; climada_shapeplotter(polygon_AMSS,'','lon','lat')

% combine the two
entity_nightlight_10km.assets.Value = [entity_nightlight_10km.assets.Value entity_nightlight_10km_2.assets.Value];
entity_nightlight_10km.assets.lon = [entity_nightlight_10km.assets.lon entity_nightlight_10km_2.assets.lon];
entity_nightlight_10km.assets.lat = [entity_nightlight_10km.assets.lat entity_nightlight_10km_2.assets.lat];

% filter out points within AMSS polygon (648 points)
polygon_AMSS_buffer = climada_shape_selector(gcf,1);
polygon_AMSS_buffer.lon = polygon_AMSS_buffer.X; polygon_AMSS_buffer.lat = polygon_AMSS_buffer.Y;
is_inside = inpoly([entity_nightlight_10km.assets.lon; entity_nightlight_10km.assets.lat]', [polygon_AMSS_buffer.lon; polygon_AMSS_buffer.lat]');
sum(is_inside)

% figure
% plot(entity_nightlight_10km.assets.lon,entity_nightlight_10km.assets.lat,'x')
% hold on
% plot(entity_nightlight_10km.assets.lon(is_inside),entity_nightlight_10km.assets.lat(is_inside),'or')

% create low_res assets (9 points)
entity_nightlight_10km.assets.Value_orig = entity_nightlight_10km.assets.Value;
entity_nightlight_10km.assets.Value(~is_inside)= 0;
entity_low_res = entity_high_res;
assets = entity_nightlight_10km.assets;
assets.lon = entity_nightlight_10km.assets.lon(is_inside);
assets.lat = entity_nightlight_10km.assets.lat(is_inside);
assets.Value = entity_nightlight_10km.assets.lat(is_inside);
assets.lon = assets.lon(1:9);
assets.lat = assets.lat(1:9);
assets.Value = assets.lat(1:9);
assets.DamageFunID = ones(size(assets.Value))*121;
assets.Deductible = zeros(size(assets.Value));
assets.Cover = zeros(size(assets.Value));
assets = rmfield(assets,'Value_orig');

scale_Value = [0 -1.0159e8 2.1351e7 sum(entity_high_res.assets.Value)];
assets.Value = scale_Value(1) + scale_Value(2)*assets.Value + scale_Value(3)*assets.Value.^2;
assets.comment=sprintf('%s: y = %2.2f + %2.2f*x^1 + %2.2f*x^2',mfilename,scale_Value(1:3));
if length(scale_Value)==4
    assets.Value = assets.Value/sum(assets.Value)*scale_Value(4); % normalize, multiply
    assets.comment=[assets.comment sprintf(', normalized, then *%2.2f',scale_Value(4))];
end
assets.Cover = assets.Value;
entity_low_res.assets = assets;
entity_low_res.measures = rmfield(entity_mid_res.measures,'regional_scope');
entity_low_res.measures.regional_scope = logical(ones(7,9));

climada_global.markersize = 60;
climada_figuresize(0.6,0.8);climada_map_plot(entity_low_res)
hold on; climada_shapeplotter(polygon_AMSS,'','lon','lat')
climada_figure_axis_limits_equal_for_lat_lon([-89.35 -89.03 13.629 13.84]); climada_figure_scale_add('',1,1)

% for i=1:9
%     hold on
%     text(assets.lon(i),assets.lat(i),sprintf('%d',i))
% end
% assets.Value = [20 50 65 10 27 64 45 15 40];


% EDS low resolution
annotation_name = 'low resolution assets';
EDS(3) = climada_EDS_calc(entity_low_res,hazard,annotation_name);

climada_figuresize(0.6,0.8); climada_map_plot(EDS(3),'ED_at_centroid','','');
hold on; climada_shapeplotter(polygon_AMSS,'','lon','lat')
climada_figure_axis_limits_equal_for_lat_lon([-89.35 -89.03 13.629 13.84]); climada_figure_scale_add('',1,1)

% adaptation measures low resolution
climada_global.font_scale = 1.4;
measures_impact_reference = 'no';
measures_impact_low_res = climada_measures_impact(entity_low_res,hazard,measures_impact_reference);
climada_figuresize(0.4,0.9); climada_adaptation_cost_curve(measures_impact_low_res)


% save
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'TC_entity_low_res.mat'],'entity_low_res')
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'TC_EDS.mat'],'EDS')
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'TC_measures_impact_low_res.mat'],'measures_impact_low_res')


%%
