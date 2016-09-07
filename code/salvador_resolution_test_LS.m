%
% Resolution sensitivity analysis for climada applied to 
% landslides and tropical cyclones in San Salvador
% Lea Mueller, 20160219

% Perform sensitivity analysis for different resolutions for two cases, 
% 1) landslides in Las Ca?as neighborhood in San Salvador and 
% 2) tropical cyclones in the metropolitan area of San Salvador (AMSS). 
% Analyzed resolutions range from high resolution (~50 meter), mid 
% resolution (~1 km) to low resolution (~10 km).
% Lea Mueller, muellele@gmail.com, 20160229, rename to climada_shapeplotter from shape_plotter
%-

%% landslides


climada_global.max_encoding_distance_m = 10^6;

% load shps files
load([climada_global.data_dir filesep 'results' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS.mat'])

% landslide hazard las canas
LS_hazard_file = [climada_global.data_dir filesep 'hazards' filesep 'Salvador_hazard_LS_las_canas_2015.mat'];
hazard = climada_hazard_load('Salvador_hazard_LS_las_canas_2015.mat');
hazard = rmfield(hazard,'name');
climada_map_plot(hazard)

hazard.intensity_all = sum(hazard.intensity,1);
figure; climada_map_plot(hazard,'intensity_all'); hold on; climada_shapeplotter(polygon_canas,'','lon','lat')
hold on; plot(entity_mid_res.assets.lon, entity_mid_res.assets.lat,'x','markersize',12)

return_periods = [50 500 1000]; check_plot = 0;
hazard_stats = climada_hazard_stats(hazard,return_periods,check_plot);


% high resolution assets
LS_entity_file = [climada_global.data_dir filesep 'entities' filesep 'LS_entity_las_canas.xls'];
entity = climada_entity_read(LS_entity_file,'NOENCODE');
climada_global.markersize = 3;
climada_figuresize(0.6,0.8); climada_map_plot(entity_high_res,'Value','',{'Cat. 31' 'Cat. 32' 'Cat. 33' 'Cat. 34' 'Cat. 35' 'Cat. 36'}); 
% hold on; climada_shapeplotter(polygon_canas,'','lon','lat')
climada_geo_distance(entity_high_res.assets.lon(1), entity_high_res.assets.lat(1), entity_high_res.assets.lon(2), entity_high_res.assets.lat(2))
% figure;climada_shapeplotter(polygon_ilopango,'','lon','lat')
% climada_shapeplotter(shape_rivers)
% rios_25k_shapes = climada_shaperead([salvador_data_dir filesep 'system' filesep 'rios_25k_polyline_WGS84.shp'],1);


% EDS high resolution
annotation_name = 'high resolution assets';
EDS = climada_EDS_calc(entity,hazard,annotation_name);
climada_figuresize(0.6,0.8); climada_map_plot(EDS,'ED_at_centroid','','',{'Cat. 31' 'Cat. 32' 'Cat. 33' 'Cat. 34' 'Cat. 35' 'Cat. 36'});

% adaptation measures high resolution
measures_impact_reference = 'no';
measures_impact_high_res = climada_measures_impact(entity,hazard,measures_impact_reference);
climada_figuresize(0.4,0.9); climada_adaptation_cost_curve(measures_impact_high_res)

% save
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'entity_high_res.mat'],'entity_high_res')
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'measures_impact_high_res.mat'],'measures_impact_high_res')


%% mid resolution (1km)
% mid resolution assets
admin0_name = 'El Salvador'; admin1_name = 'San Salvador'; p.nightlight_transform_poly=[1 0];
entity_nightlight = climada_nightlight_entity(admin0_name,admin1_name,p);
figure;climada_map_plot(entity_nightlight)
hold on; climada_shapeplotter(polygon_canas,'','lon','lat')
climada_geo_distance(entity.assets.lon(1), entity.assets.lat(1), entity.assets.lon(2), entity.assets.lat(2))
climada_geo_distance(entity_mid_res.assets.lon(2), entity_mid_res.assets.lat(2), entity_mid_res.assets.lon(3), entity_mid_res.assets.lat(3))

% filter out 18 points within las ca?as
% is_inside = inpoly([entity_nightlight.assets.lon; entity_nightlight.assets.lat]', [shapes.lon; shapes.lat]');
is_inside = inpoly([entity_nightlight.assets.lon; entity_nightlight.assets.lat]', [polygon_canas.lon; polygon_canas.lat]');

% create mid_res assets (18 points)
entity_nightlight.assets.Value_orig = entity_nightlight.assets.Value;
entity_nightlight.assets.Value(~is_inside)= 0;
entity_mid_res = entity_high_res;
assets = entity_nightlight.assets;
assets.lon = entity_nightlight.assets.lon(is_inside);
assets.lat = entity_nightlight.assets.lat(is_inside);
assets.Value = entity_nightlight.assets.Value(is_inside);
assets.DamageFunID = entity_nightlight.assets.DamageFunID(is_inside);
assets.DamageFunID = assets.DamageFunID*131;
assets.Deductible = entity_nightlight.assets.Deductible(is_inside);
assets.Cover = entity_nightlight.assets.Cover(is_inside);
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

climada_global.markersize = 65;
climada_figuresize(0.6,0.8);climada_map_plot(entity_mid_res)
hold on; climada_shapeplotter(polygon_canas,'','lon','lat')
climada_figure_axis_limits_equal_for_lat_lon([-89.145 -89.10 13.6895 13.727]); climada_figure_scale_add('',1,1)


% EDS mid resolution
annotation_name = 'mid resolution assets';
EDS(2) = climada_EDS_calc(entity_mid_res,hazard,annotation_name);

climada_global.markersize = 35;
climada_figuresize(0.6,0.8); climada_map_plot(EDS(2),'ED_at_centroid','','');
hold on; climada_shapeplotter(polygon_canas,'','lon','lat')
% axis([-89.145 -89.095 13.6895 13.732])
climada_figure_axis_limits_equal_for_lat_lon([-89.145 -89.10 13.6895 13.727]); climada_figure_scale_add('',1,1)


% adaptation measures mid resolution
climada_global.font_scale = 1.4;
measures_impact_reference = 'no';
measures_impact_mid_res = climada_measures_impact(entity_mid_res,hazard,measures_impact_reference);
climada_figuresize(0.4,0.9); climada_adaptation_cost_curve(measures_impact_mid_res)

% save
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'entity_mid_res.mat'],'entity_mid_res')
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'EDS.mat'],'EDS')
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'measures_impact_mid_res.mat'],'measures_impact_mid_res')


%% low resolution

% assets, just one point
entity_low_res = entity_mid_res;
entity_low_res.assets.lon = [mean(entity_mid_res.assets.lon) entity_mid_res.assets.lon(:)'];
entity_low_res.assets.lat = [mean(entity_mid_res.assets.lat) entity_mid_res.assets.lat(:)'];
entity_low_res.assets.Value = [sum(entity_mid_res.assets.Value) zeros(1,18)];
entity_low_res.assets.Cover = entity_low_res.assets.Value;
entity_low_res.assets.DamageFunID = [131 zeros(1,18)]; 
entity_low_res.assets.Deductible = [0 zeros(1,18)]; 

climada_global.markersize = 120;
climada_figuresize(0.6,0.8);climada_map_plot(entity_low_res)
hold on; climada_shapeplotter(polygon_canas,'','lon','lat')
% axis([-89.145 -89.095 13.6895 13.732])
climada_figure_axis_limits_equal_for_lat_lon([-89.145 -89.10 13.6895 13.727]); climada_figure_scale_add('',1,1)

% EDS low resolution
annotation_name = 'low resolution assets';
EDS(3) = climada_EDS_calc(entity_low_res,hazard,annotation_name);

climada_figuresize(0.6,0.8); climada_map_plot(EDS(3),'ED_at_centroid','','');
hold on; climada_shapeplotter(polygon_canas,'','lon','lat')
climada_figure_axis_limits_equal_for_lat_lon([-89.145 -89.10 13.6895 13.727]); climada_figure_scale_add('',1,1)

% adaptation measures low resolution
climada_global.font_scale = 1.4;
measures_impact_reference = 'no';
measures_impact_low_res = climada_measures_impact(entity_low_res,hazard,measures_impact_reference);
climada_figuresize(0.4,0.9); climada_adaptation_cost_curve(measures_impact_low_res)


% save
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'entity_low_res.mat'],'entity_low_res')
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'EDS.mat'],'EDS')
save([climada_global.data_dir filesep 'results' filesep 'resolution_test' filesep 'measures_impact_low_res.mat'],'measures_impact_low_res')







%%
figure;climada_entity_plot(entity_nightlight)



LS_entity_file = [climada_global.data_dir filesep 'entities' filesep 'LS_entity_las_canas.xls'];
entity = climada_entity_read(LS_entity_file,'NOENCODE');
climada_global.markersize = 3;
climada_figuresize(0.6,0.8); climada_map_plot(entity,'Value','',{'Cat. 31' 'Cat. 32' 'Cat. 33' 'Cat. 34' 'Cat. 35' 'Cat. 36'});
climada_geo_distance(entity.assets.lon(1), entity.assets.lat(1), entity.assets.lon(2), entity.assets.lat(2))
% figure;climada_shapeplotter(polygon_LS,'','lon','lat')
% figure;climada_shapeplotter(polygon_ilopango,'','lon','lat')
% climada_shapeplotter(shape_rivers)
% rios_25k_shapes = climada_shaperead([salvador_data_dir filesep 'system' filesep 'rios_25k_polyline_WGS84.shp'],1);


