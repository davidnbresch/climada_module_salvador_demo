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



