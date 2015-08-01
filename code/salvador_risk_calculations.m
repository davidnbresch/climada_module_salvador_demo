

%% salvador risk calculations

% load FL hazard
load([climada_global.project_dir filesep 'Salvador_hazard_FL_2015'])

% load entity 2015
load([climada_global.project_dir filesep 'Salvador_entity_2015'])

% load EDS FL
load([climada_global.project_dir filesep 'Salvador_EDS_FL_2015'])

% set consultant_data_entity_dir
consultant_data_entity_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep '20150721'];

% load shp files
load([climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS'])


peril_description = {'flood in Rio Acelhuate' 'hurricane winds in AMSS' 'landslides in Ilopango'};

%% read entity
% entity today
entity_file_xls = [consultant_data_entity_dir filesep 'entity_AMSS_NEW.xls'];
entity = climada_entity_read(entity_file_xls,hazard);
entity.assets.reference_year = 2015;
entity.assets = rmfield(entity.assets,'VALNaN');
entity.damagefunctions = rmfield(entity.damagefunctions,'VALNaN');
% shift assets
shift_lat = 0.01/10*1.1;
entity.assets.lat = entity.assets.lat + shift_lat;
entity = climada_assets_encode(entity,hazard);
entity_filename = [climada_global.project_dir filesep 'Salvador_entity_2015.mat'];
entity.assets.filename = entity_filename;
save(entity_filename,'entity')


%% calculate damage

EDS = climada_EDS_calc(entity,hazard);
save([climada_global.project_dir filesep 'Salvador_EDS_FL_2015'],'EDS')



%% create entity figure
fig = climada_figuresize(0.5,0.8);
climada_entity_plot(entity,4)
shape_plotter(shape_rivers(indx_rivers_in_San_Salvador),'','','','linewidth',0.2,'color',[0.0   0.6039   0.8039])
% shape_plotter(shape_roads(indx_roads_in_San_Salvador),'','','','linewidth',0.02,'color',[234 234 234]/255) %[0.3176 0.3176 0.3176])
box on
ax_limits = [-89.3 -89.05 13.64 13.81];
climada_figure_axis_limits_equal_for_lat_lon(ax_limits)
climada_figure_scale_add('',0,1)
title('Assets 2015','fontsize',13)
print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep 'Salvador_entity_assets_2015.pdf'])


%% create maps for selected fieldnames (assets or damage), peril FL, units (USD or people), and per category

fieldname_list = {'assets' 'damage' 'damage_relative'};
peril_list = 'FL';
unit_list = {'USD' 'people'};
category_list = unique(entity.assets.Category(salvador_assets_select(entity,'FL')));
print_figure = 0;

for f_i = 1:numel(fieldname_list)
    for c_i = 1:numel(category_list)
        salvador_map_plot(entity,EDS,fieldname_list{f_i},peril_list,'',category_list(c_i),print_figure);
    end %c_i
end %f_i

% fieldname_to_plot = 'assets';
% peril_criterium = 'FL';
% unit_criterium = 'USD';
% category_criterium = '';
% salvador_map_plot(entity,'',fieldname_to_plot,peril_criterium,unit_criterium,category_criterium,print_figure);


%% create figure assets FL and hazard FL
fig = climada_figuresize(0.5,0.9);
is_selected = salvador_assets_select(entity,'FL','USD');
cbar = plotclr(entity.assets.lon(is_selected), entity.assets.lat(is_selected), entity.assets.Value(is_selected)/100000,...
    'h',1,1,0,1,climada_colormap('assets'));
shape_plotter(shape_rivers(indx_rivers_in_San_Salvador),'','X_ori','Y_ori','linewidth',0.2,'color',[0.0   0.6039   0.8039])
% shape_plotter(shape_roads(indx_roads_in_San_Salvador),'','','','linewidth',0.02,'color',[234 234 234]/255) %[0.3176 0.3176 0.3176])
cbar = plotclr(hazard.lon, hazard.lat, hazard.intensity(end,:),...
    's',1,1,0,6,climada_colormap('FL'));
ax_limits = [-89.26 -89.15 13.67 13.71];
climada_figure_axis_limits_equal_for_lat_lon(ax_limits)
box on
climada_figure_scale_add('',1,1)
set(get(cbar,'ylabel'),'String', '100 year flood (m)','fontsize',13);
title('Assets (Flood, 2015) and 100 year flood','fontsize',13)
% print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep 'Salvador_entity_assets_FL_2015_hazard_100_year.pdf'])
print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep 'Salvador_entity_assets_FL_2015_hazard_100_year__.pdf'])




%% create ED report
timehorizon = 2015;
peril_ID    = 'FL';
ED_filename = sprintf('ED_%s_%d_%s_2.xls', peril_ID, timehorizon,datestr(now,'YYYYmmdd'));
climada_EDS_ED_at_centroid_report_xls(EDS, [climada_global.project_dir filesep 'REPORTS' filesep ED_filename])


%% create damage frequency curve (DFC)
fig = climada_figuresize(0.4, 0.6);
plot(1./EDS.frequency, EDS.damage*10^-6,'.-')
grid off
xlabel('Return period (years)')
ylabel('Damage (USD m)')
title('Damage versus return period for Flood Rio Acelhuate, 2015')
axis([0 105 0 85])
textstr = {sprintf('Total values: USD %4.1f m', sum(entity.assets.Value(indx_assets))*10^-6); ...
           sprintf('Annual expected damage: USD %4.1f m', EDS.ED*10^-6);...
           sprintf('Annual expected damage: %4.1f %%', EDS.ED/sum(entity.assets.Value(indx_assets))*100)};
text(2.5,82, textstr, 'verticalalignment','top','HorizontalAlignment','left','fontsize',11)
print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep 'Salvador_DFC_FL_2015.pdf'])

% DFC = climada_EDS2DFC(EDS);
% [fig,legend_str,return_period,sorted_damage] = climada_EDS_DFC(EDS);




%%










%%
close all

climada_global.waitbar = 0;

% data dir
salvador_data_dir = [climada_global.modules_dir filesep 'climada_module_salvador_demo' filesep 'data'];

% climada_admin_name('El Salvador','San Salvador',2,1)

%% features
roads_file      = [salvador_data_dir filesep 'system' filesep 'el_salvador_highway.mat'];
rios_25k_file   = [salvador_data_dir filesep 'system' filesep 'rios_25k_polyline_WGS84.mat'];

rios_25k_shapes = climada_shaperead([salvador_data_dir filesep 'system' filesep 'rios_25k_polyline_WGS84.shp'],1);
road_shapes     = climada_shaperead([salvador_data_dir filesep 'system' filesep 'el_salvador_highway.shp'],1);

%% hazard
% hazard today
hazard_file = [salvador_data_dir filesep 'hazards' filesep 'garrobo_hazard_FL.mat'];
load(hazard_file);
hazard.filename = hazard_file;
hazard.comment = sprintf('FL current scenario %d',climada_global.present_reference_year);
% save(hazard_file,'hazard')

% climate change scenario
screw.hazard_fld    = 'frequency'; 
screw.change        = 1.26;
screw.year          = 2081; 
screw.hazard_crit   = 'orig_event_flag'; 
screw.criteria      = 1; 
screw.bsxfun_op     = @times;

% hazard future
hazard_file_cc = strrep(hazard_file,'.mat',['_cc_' num2str(climada_global.future_reference_year) '.mat']);
hazard_cc = climada_hazard_climate_screw(hazard,hazard_file_cc,climada_global.future_reference_year,screw);

%% entity
% entity today
entity_file_xls = [salvador_data_dir filesep 'entities' filesep 'entity_garrobo_today.xls'];
entity = climada_entity_read(entity_file_xls,hazard);
entity.assets.reference_year = climada_global.present_reference_year;
% climada_entity_save_xls(entity,entity_file_xls,1,1,1);
ax_lim = [min(entity.assets.lon) max(entity.assets.lon) min(entity.assets.lat) max(entity.assets.lat)];

% plot entity today
climada_entity_plot(entity,4)
shape_plotter(rios_25k_file,'rivers','plot','linewidth',2,'color',[0.0   0.6039   0.8039])
shape_plotter(roads_file,'roads','plot','linewidth',1,'color',[0.3176 0.3176 0.3176])
axis(ax_lim)

% entity future
entity_future_file_xls = [salvador_data_dir filesep 'entities' filesep 'entity_garrobo_future.xls'];
entity_future = entity;
entity_future.assets.reference_year = climada_global.future_reference_year;
n_years = 1 + climada_global.future_reference_year - climada_global.present_reference_year;
entity_future.assets.Value = entity.assets.Value .* (1.02 ^ n_years);
entity_future.assets.Cover = entity_future.assets.Value;
entity_future.assets.filename = entity_future_file_xls;
% climada_entity_save_xls(entity_future,entity_future_file_xls,1,1,1);

%% event damage set
climada_global.EDS_at_centroid = 1;

% EDS today
EDS = climada_EDS_calc(entity,hazard);

% 3d plot
climada_EDS_plot_3d(hazard,EDS,0,1,...
    rios_25k_file,2,[0.0 0.6039 0.8039],'Rivers',...
    roads_file,1,[0.3176 0.3176 0.3176],'Roads')
print(gcf,'-dpng',[climada_global.data_dir filesep 'results' filesep 'ED_garrobo_2015_3d.png'])

% 2d plot
figure
climada_ED_plot(EDS,0);
shape_plotter(rios_25k_file,'Rivers','','linewidth',2,'color',[0.0   0.6039   0.8039])
shape_plotter(roads_file,'Roads','','linewidth',1,'color',[0.3176 0.3176 0.3176])
print(gcf,'-dpng',[climada_global.data_dir filesep 'results' filesep 'ED_garrobo_2015_2d.png'])

% EDS with entity future, hazard current scenario (socio-economic growth)
EDS_se = climada_EDS_calc(entity_future,hazard);

% EDS with entity future, hazard future scenario (socio-economic growth + climate change)
EDS_cc = climada_EDS_calc(entity_future,hazard_cc);

climada_waterfall_graph(EDS,EDS_se,EDS_cc,'AED')
print(gcf,'-dpng',[climada_global.data_dir filesep 'results' filesep 'waterfall_garrobo.png'])

%% measures
% measures impact in present scenario
measures_impact = climada_measures_impact(entity,hazard,'no');

% measures impact future scenario (climate change + economic growth)
measures_impact_future = climada_measures_impact(entity_future,hazard_cc,measures_impact);

% benefit/cost plots
figure
climada_adaptation_cost_curve(measures_impact,[],[],[],[],[],1,[])
title('Cost-benefit analysis of adaptation measures','Fontsize',14)
print(gcf,'-dpng',[climada_global.data_dir filesep 'results' filesep 'CBA_garrobo.png'])
figure
climada_adaptation_cost_curve(measures_impact_future,[],[],[],[],[],1,[])
title('Cost-benefit analysis of adaptation measures','Fontsize',14)
print(gcf,'-dpng',[climada_global.data_dir filesep 'results' filesep 'CBA_garrobo_cc.png'])
figure
climada_adaptation_cost_curve(measures_impact_future,measures_impact,[],[],[],[],1,[])



