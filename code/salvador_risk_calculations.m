
nametag = 'measures_LS_las_canas_v2';
assets_file = ['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_LASCANAS_141015_NEW.xls'];
damfun_file = ['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_ACELHUATE_141015_NEW.xls'];
measures_file = assets_file;
results_dir = '';
peril_ID = 'LS_las_canas';
salvador_calc_measures(nametag,assets_file,damfun_file,measures_file,results_dir,peril_ID)

nametag = 'waterfall_LS_las_canas_v2';
growth_rate_eco =  '';
growth_rate_people = '';
results_dir = ''; %results_dir = 'LS_las_canas_v1';
EDS = salvador_calc_waterfall(nametag,assets_file,damfun_file,results_dir, growth_rate_eco, growth_rate_people,peril_ID);


nametag = 'measures_LS_acelhuate';
assets_file = ['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_ACELHUATE_141015_NEW.xls'];
damfun_file = assets_file;
measures_file = assets_file;
results_dir = '';
peril_ID = 'LS_acelhuate';
salvador_calc_measures(nametag,assets_file,damfun_file,measures_file,results_dir,peril_ID)

nametag = 'waterfall_LS_acelhuate';
growth_rate_eco =  '';
growth_rate_people = '';
results_dir = ''; %results_dir = 'LS_las_canas_v1';
EDS = salvador_calc_waterfall(nametag,assets_file,damfun_file,results_dir, growth_rate_eco, growth_rate_people,peril_ID);

nametag = 'measures_TC_v1';
assets_file = ['20150925_TC' filesep 'entity_AMSS_WIND-AMSS_250915_v2.xlsx'];
damfun_file = assets_file;
measures_file = ['20151014_TC' filesep 'entity_AMSS_WIND-AMSS_141015_FINAL_COSTS.xlsx'];
results_dir = '';
peril_ID = 'TC';
salvador_calc_measures(nametag,assets_file,damfun_file,measures_file,results_dir,peril_ID)


nametag = 'regional_scope_of_measures_A_B_1';
assets_file= '';
damfun_file = '';
measures_file = ['20150918' filesep 'measures_template_for_measures_location_A_B_1.xls'];
% measures_file = '';
% measures_file = ['20150909' filesep 'medidas selection'];
results_dir = '';
salvador_calc_measures(nametag,assets_file,damfun_file,measures_file,results_dir)

nametag = 'v1';
growth_rate_eco =  '';
growth_rate_people = '';
results_dir = ''; %results_dir = 'LS_las_canas_v1';
assets_file = '';
damfun_file = '';
peril_ID = 'FL';
% peril_ID = 'LS_acelhuate';
% peril_ID = 'LS_las_canas';
growth_rate_people = 0.008;
% assets_file = ['20150921_LS_acelhuate' filesep 'entity_AMSS_LS_acelhuate.xls'];
% damfun_file = ['20150921_LS_acelhuate' filesep 'entity_AMSS_LS_acelhuate.xls'];
EDS = salvador_calc_waterfall(nametag,assets_file,damfun_file,results_dir, growth_rate_eco, growth_rate_people,peril_ID);
% EDS=salvador_calc_waterfall(nametag,assets_file,damfun_file,results_dir, growth_rate_eco, growth_rate_people,peril_ID)


nametag = '';
growth_rate_eco =  '';
growth_rate_people = '';
results_dir = 'TC_new_format';
assets_file = '';
damfun_file = '';
EDS = salvador_calc_waterfall(nametag,assets_file,damfun_file,results_dir, growth_rate_eco, growth_rate_people,'FL');
% EDS=salvador_calc_waterfall(nametag,assets_file,damfun_file,results_dir, growth_rate_eco, growth_rate_people,peril_ID)




% for i = 1:8
%     figure; 
%     plotclr(entity.assets.lon,entity.assets.lat,...
%         measures_impact_USD(3).EDS(end).ED_at_centroid-measures_impact_USD(3).EDS(i).ED_at_centroid,'','',1);
% end



%% salvador risk calculations

% peril_ID = 'LS';
peril_ID = 'FL';
% peril_ID = 'TC';
cc_scenario = 'no';
% cc_scenario = 'moderate';
% cc_scenario = 'extreme';
timehorizon = 2015;

force_re_encode = 1;

nametag = '2m_new_costs';


%%
annotation_name = sprintf('%s, %s climate change',peril_ID,cc_scenario);
hazard_set_file = sprintf('Salvador_hazard_%s_%d_%s_cc', peril_ID, timehorizon, cc_scenario);

% load(hazard_set_file)
load([climada_global.project_dir filesep 'Salvador_hazard_FL_2015'])
% load([climada_global.project_dir filesep 'Salvador_hazard_FL_2040_moderate_cc'])
% load([climada_global.project_dir filesep 'Salvador_hazard_FL_2040_extreme_cc'])
% % load TC hazard
% load([climada_global.project_dir filesep 'Salvador_hazard_TC_2015'])   
% hazard.reference_year = 2040;
% save([climada_global.project_dir filesep hazard_set_file],'hazard')


% % load entity 2015
% load([climada_global.project_dir filesep 'Salvador_entity_2015'])


% set consultant_data_entity_dir
switch peril_ID
    case 'FL'
        consultant_data_entity_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep '20150721'];
        consultant_data_damage_fun_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep '20150806'];
        % consultant_data_damage_fun_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep '20150811_TC'];
        % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150818'];
        % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150828'];
        % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150901'];
        % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150903'];
        consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150909'];
        entity_file_xls = [consultant_data_entity_dir filesep 'entity_AMSS_NEW.xls'];
    case 'LS'
        consultant_data_entity_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep '20150806_LS'];
        entity_file_xls = [consultant_data_entity_dir filesep 'entity_AMSS_DESLIZAMIENTO.xlsx'];
end
% load shp files
load([climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS'])


% peril_description = {'flood in Rio Acelhuate' 'hurricane winds in AMSS' 'landslides in Ilopango'};



%% read entity
% entity today
entity = climada_entity_read(entity_file_xls,hazard);
entity.assets.reference_year = 2015;
entity.assets = rmfield(entity.assets,'VALNaN');
entity.damagefunctions = climada_damagefunctions_read([consultant_data_damage_fun_dir filesep 'DamageFunction_FL_2ndRUN.xlsx']);
% entity.damagefunctions = climada_damagefunctions_read([consultant_data_damage_fun_dir filesep 'entity_AMSS_WIND-5ms.xlsx']);
% entity.damagefunctions = climada_damagefunctions_read([consultant_data_damage_fun_dir filesep 'entity_AMSS_WIND-10ms.xlsx']);
% entity.damagefunctions = rmfield(entity.damagefunctions,'VALNaN');
% % climada_damagefunctions_plot(entity)
% % entity = climada_assets_encode(entity,hazard);

% entity = climada_assets_encode(entity,hazard);
% entity.measures = climada_measures_read([consultant_data_measures_dir filesep 'Medidas_Climada_inundation_DRAFT.xlsx']);
% entity.measures.cost = entity.measures.cost(1:3);
% entity.measures = climada_measures_read([consultant_data_measures_dir filesep 'Medidas parametrizadas.xlsx']);
% entity.measures = climada_measures_read([consultant_data_measures_dir filesep 'Medidas parametrizadas_2m.xlsx']);
% entity.measures = climada_measures_read([consultant_data_measures_dir filesep 'Medidas parametrizadas_4m.xlsx']);
% entity.measures = climada_measures_read([consultant_data_measures_dir filesep 'Medidas parametrizadas_A+B_MS.xlsx']);
% entity.measures = climada_measures_read([consultant_data_measures_dir filesep 'Medidas parametrizadas_A+B_MS_2m.xlsx']);
entity.measures = climada_measures_read([consultant_data_measures_dir filesep 'Medidas parametrizadas_2m_150908 aumentada precio mejorad y mantenimiento.xlsx']);

% overwrite measures hazard intensity impact, high frequency cutoff
entity.measures.hazard_intensity_impact_b = zeros(size(entity.measures.hazard_intensity_impact_b));
entity.measures.hazard_high_frequency_cutoff = zeros(size(entity.measures.hazard_high_frequency_cutoff));

entity_filename = [climada_global.project_dir filesep 'Salvador_entity_2015_' peril_ID '.mat'];
entity.assets.filename = entity_filename;
save(entity_filename,'entity')

% % future entity, 2040
% load([climada_global.project_dir filesep 'Salvador_entity_2040.mat'])
% % % is_selected = climada_assets_select(entity,hazard.peril_ID,'USD');
% % is_selected = climada_assets_select(entity,hazard.peril_ID,'people');
% % sum(entity.assets.Value(is_selected))
% load([climada_global.project_dir filesep 'Salvador_entity_2015.mat'])


%% measures
% entity.measures.hazard_intensity_impact_b = -entity.measures.hazard_intensity_impact;
u_i = 1;
sanity_check = 1;
% entity.assets = rmfield(entity.assets,'hazard');
measures_impact(u_i) = climada_measures_impact(entity,hazard,'no','','',sanity_check);
measures_impact_filename = [climada_global.project_dir filesep sprintf('measures_impact_%s.mat',datestr(now,'YYYYmmdd'))];
% save(measures_impact_filename,'measures_impact')




ED_filename = sprintf('ED_%s_%d_%s_cc_measures_%s_%s.xls', peril_ID, timehorizon,cc_scenario,datestr(now,'YYYYmmdd'),nametag);
xls_file = [climada_global.project_dir filesep 'REPORTS' filesep ED_filename];
climada_EDS_ED_at_centroid_report_xls(measures_impact(u_i).EDS, xls_file, 'ED_at_centroid')
output_report = salvador_EDS_ED_per_category_report(entity, measures_impact(u_i).EDS, xls_file,'ED_per_category',1,1);


% ED_filename = sprintf('ED_%s_%d_%s_cc_measures_%s_orig.xls', peril_ID, timehorizon,cc_scenario,datestr(now,'YYYYmmdd'));
% output_report = salvador_EDS_ED_per_category_report(entity, EDS(1), [climada_global.project_dir filesep 'REPORTS' filesep ED_filename],'ED_per_category',0,0);



% % hazard frequency
% [sorted_damage,exceedence_freq,cumulative_probability,sorted_freq,event_index_out]=...
%     climada_damage_exceedence([1 2 3 4 5 6],hazard.frequency,[1 2 3 4 5 6]);




%% adaptation cost curve (twice, once for USD, once for people)
unit_criterium = '';
category_criterium = '';
[~,~,unit_list,category_criterium]...
             = climada_assets_select(entity,hazard.peril_ID,unit_criterium,category_criterium);
% entity.measures.color_RGB = jet(numel(entity.measures.name));
orig_discount_rate = entity.discount.discount_rate;

for u_i = 1:numel(unit_list)
    
    climada_global.Value_unit = unit_list{u_i}; 
    if strcmp(unit_list{u_i},'people')
        entity.discount.discount_rate = orig_discount_rate*0;
    end
    measures_impact_both(u_i) = climada_measures_impact_discount(entity,measures_impact,'no','unit',unit_list{u_i});
    measures_impact_both(u_i).Value_unit = unit_list{u_i};
    
    %sheet_name = sprintf('Benefit_costs_%s',unit_list{u_i});
    %output_report = climada_measures_impact_report(measures_impact_both(u_i),xls_file,sheet_name);

%     fig = climada_figuresize(0.5,1.2);
%     climada_adaptation_cost_curve(measures_impact_both(u_i),'',30,10)
%     pdf_filename = sprintf('Adaptation_cost_curve_%s_2015_%s_%s.pdf',measures_impact_both(u_i).peril_ID,measures_impact_both(u_i).Value_unit,nametag);
%     print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])
    
    sort_measures = 1;
    fig = climada_adaptation_bar_chart(measures_impact_both(u_i),'',sort_measures);
    pdf_filename = sprintf('Adaptation_bar_chart_%s_2015_%s_%s_sorted.pdf',measures_impact_both(u_i).peril_ID,measures_impact_both(u_i).Value_unit,nametag);
    print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])
    
    entity.discount.discount_rate = orig_discount_rate;
end


% fig = climada_adaptation_bar_chart(measures_impact_both(2),measures_impact_both(1),sort_measures);

% save(measures_impact_filename,'measures_impact_both')
% load(measures_impact_filename)



%% risk analysis, waterfall graph
% risk today
annotation_name = 'FL, risk today';
% annotation_name = sprintf('%s, %s climate change',peril_ID,cc_scenario);
% hazard_set_file = sprintf('Salvador_hazard_%s_%d_%s_cc', peril_ID, timehorizon, cc_scenario);
EDS(1) = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);

% 2040, economic growth
% entity_future = entity;
% USD
growth_rate = 0.04;
growth_factor = (1+growth_rate)^(2040-2015+1);
[is_selected,peril_criterum,unit_criterium,category_criterium] = ...
       climada_assets_select(entity,hazard.peril_ID,'USD','');
entity.assets.Value(is_selected) = entity.assets.Value(is_selected) * growth_factor;
% people
% growth_rate = 0.014;
growth_rate = 0.2/100;
growth_factor = (1+growth_rate)^(2040-2015+1);
[is_selected,peril_criterum,unit_criterium,category_criterium] = ...
       climada_assets_select(entity,hazard.peril_ID,'people','');
entity.assets.Value(is_selected) = entity.assets.Value(is_selected) * growth_factor;

entity.assets.reference_year = 2040;
entity_filename = [climada_global.project_dir filesep 'Salvador_entity_2040.mat'];
entity.assets.filename = entity_filename;
save(entity_filename,'entity')
annotation_name = 'Economic growth';
load([climada_global.project_dir filesep 'Salvador_hazard_FL_2015'])
EDS(2) = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);

% 2040, moderate cc
timehorizon = 2040;
cc_scenario = 'moderate';
hazard_set_file = sprintf('Salvador_hazard_%s_%d_%s_cc', peril_ID, timehorizon, cc_scenario);
hazard = [];
load([climada_global.project_dir filesep hazard_set_file])
annotation_name = sprintf('%s climate change',cc_scenario);
EDS(3) = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);


% 2040, extreme cc
timehorizon = 2040;
cc_scenario = 'extreme';
hazard_set_file = sprintf('Salvador_hazard_%s_%d_%s_cc', peril_ID, timehorizon, cc_scenario);
hazard = [];
load([climada_global.project_dir filesep hazard_set_file])
annotation_name = sprintf('%s climate change',cc_scenario);
EDS(4) = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);

% create waterfall AED for USD
% unit_criterium = 'USD';
unit_criterium = 'people';
% cc_scenario = 'moderate';
cc_scenario = 'extreme';
[is_selected,peril_criterum,unit_criterium,category_criterium] =...
            climada_assets_select(entity,EDS(1).peril_ID,unit_criterium);        
for EDS_i = 1:numel(EDS)
    EDS(EDS_i).ED = sum(EDS(EDS_i).ED_at_centroid(is_selected));
    EDS(EDS_i).Value = sum(EDS(EDS_i).assets.Value(is_selected));
    EDS(EDS_i).Value_unit = unit_criterium{1};
end
EDS(1).hazard.comment = 'FL, 2015';
EDS(2).hazard.comment = 'FL, 2015';
EDS(3).hazard.comment = 'FL, 2040, moderate cc';
EDS(4).hazard.comment = 'FL, 2040, extreme cc';
EDS(1).reference_year = 2015;
EDS(2).reference_year = 2015;
switch cc_scenario
    case 'moderate'
        fig = climada_waterfall_graph(EDS(1),EDS(2),EDS(3),'AED');
    case 'extreme'
        fig = climada_waterfall_graph(EDS(1),EDS(2),EDS(4),'AED');
end
pdf_filename = sprintf('Waterfall_FL_%s_cc_%s.pdf',cc_scenario,unit_criterium{1});
print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])

benefit_flag = 0;
EDS(5) = EDS(1);
xls_file = [climada_global.project_dir filesep 'REPORTS' filesep 'ED_FL_2015_2040_' datestr(now,'YYYYmmdd')];
output_report = salvador_EDS_ED_per_category_report(entity, EDS, xls_file,'ED_per_category',benefit_flag);



%% calculate damage

EDS = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);
% save([climada_global.project_dir filesep 'Salvador_EDS_FL_2015_new_damagefun'],'EDS')
% EDS(2) = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);



%% create ED report
% timehorizon = 2015;
% peril_ID    = 'FL';
ED_filename = sprintf('ED_%s_%d_cc_%s_%s.xls', peril_ID, timehorizon,cc_scenario,datestr(now,'YYYYmmdd'));
climada_EDS_ED_at_centroid_report_xls(EDS,[climada_global.project_dir filesep 'REPORTS' filesep ED_filename],'ED_at_centroid')
output_report = salvador_EDS_ED_per_category_report(entity, EDS, [climada_global.project_dir filesep 'REPORTS' filesep ED_filename],'ED_per_category');
% output_report = salvador_EDS_ED_per_category_report(entity, EDS,'NO_xls_file');



%% create maps for selected fieldnames (assets or damage), peril FL, units (USD or people), and per category
fieldname_list = {'assets' 'damage' 'damage_relative'};
% peril_list = 'FL';
unit_list = {'USD' 'people'};
category_list = unique(entity.assets.Category(salvador_assets_select(entity,peril_ID)));
% print_figure = 1;
print_figure = 0;

for f_i = 2%1%:numel(fieldname_list)
    for c_i = 1:numel(category_list)
        fig = salvador_map_plot(entity,EDS(1),fieldname_list{f_i},peril_ID,'',category_list(c_i),print_figure);
        %cbar = plotclr(hazard.lon, hazard.lat, hazard.intensity(end-1,:),...
        %       's',0.5,1,0,6,climada_colormap('FL'));
        pdf_filename= sprintf('Assets_orig_cat_%d.png',c_i);   
        print(fig,'-dpng',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])
    end %c_i
end %f_i
close all

% fieldname_to_plot = 'assets';
% peril_criterium = 'FL';
% unit_criterium = 'USD';
% category_criterium = '';
% salvador_map_plot(entity,'',fieldname_to_plot,peril_criterium,unit_criterium,category_criterium,print_figure);


%% create figure assets FL and hazard FL
fig = climada_figuresize(0.5,0.9);
is_selected = salvador_assets_select(entity,'FL','USD');

% shape_plotter(shape_rivers(indx_rivers_in_San_Salvador),'','X_ori','Y_ori','linewidth',0.2,'color',[0.0   0.6039   0.8039])
% shape_plotter(shape_roads(indx_roads_in_San_Salvador),'','','','linewidth',0.02,'color',[234 234 234]/255) %[0.3176 0.3176 0.3176])
cbar = plotclr(hazard.lon, hazard.lat, hazard.intensity(end-1,:),...
    's',0.5,1,0,6,climada_colormap('FL'));
% plot(hazard.lon(logical(hazard.intensity(end,:))), hazard.lat(logical(hazard.intensity(end,:))),...
%     's','markersize',0.5,'color','b');

% cbar = plotclr(entity.assets.lon(is_selected), entity.assets.lat(is_selected), entity.assets.Value(is_selected)/100000,...
%     'p',0.5,1,0,1,climada_colormap('assets'));
hold on
plot(entity.assets.lon(is_selected), entity.assets.lat(is_selected),...
    '.','markersize',0.02,'color',[255 97 3]./255);
ax_limits = [-89.26 -89.15 13.67 13.71];
climada_figure_axis_limits_equal_for_lat_lon(ax_limits)
box on
climada_figure_scale_add('',4,1)
% set(get(cbar,'ylabel'),'String', '100 year flood (m)','fontsize',13);
% title('Assets (Flood, 2015) and 100 year flood','fontsize',13)
title('Assets (Flood, 2015) and 50 year flood','fontsize',13)
% print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep 'Salvador_entity_assets_FL_2015_hazard_100_year.pdf'])
print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep 'Salvador_entity_assets_FL_2015_hazard_50_year.pdf'])



%% create entity figure
% fig = climada_figuresize(0.5,0.8);
% climada_entity_plot(entity,4)
% shape_plotter(shape_rivers(indx_rivers_in_San_Salvador),'','','','linewidth',0.2,'color',[0.0   0.6039   0.8039])
% % shape_plotter(shape_roads(indx_roads_in_San_Salvador),'','','','linewidth',0.02,'color',[234 234 234]/255) %[0.3176 0.3176 0.3176])
% box on
% ax_limits = [-89.3 -89.05 13.64 13.81];
% climada_figure_axis_limits_equal_for_lat_lon(ax_limits)
% climada_figure_scale_add('',0,1)
% title('Assets 2015','fontsize',13)
% print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep 'Salvador_entity_assets_2015.pdf'])



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




%% meausures, additional information from Jacob
%set the directories again
%present entity
consultant_data_entity_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep '20150721'];
entity_file_xls = [consultant_data_entity_dir filesep 'entity_AMSS_NEW.xls'];

%future entity
%entity_file_xls = [consultant_data_entity_dir filesep 'xxx'];


%FLOOD FL
%present hazard
haz_file='Salvador_hazard_FL_2015.mat';

%future hazard
haz_file='Salvador_hazard_FL_2040_moderate_cc.mat';
haz_file='Salvador_hazard_FL_2040_extreme_cc.mat';

%Tropical storm TC
%present hazard
haz_file='Salvador_hazard_TC_2015';

%future hazard


%LANDSLIDE LS
%present hazard


%future hazard 

%measures file
consultant_data_measures_dir=       [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures'];
measures_file_xls= [consultant_data_measures_dir filesep 'Medidas_Climada_inundation_DRAFT.xlsx'];

%load hazard
hazard_file= [climada_global.project_dir filesep haz_file];
load(hazard_file);

%create entity, combine with seperate measures
entity = climada_entity_read(entity_file_xls,hazard);
entity.measures=climada_measures_read(measures_file_xls);

%encode
%entity = climada_assets_encode(entity,hazard);

%present impact
measures_impact = climada_measures_impact(entity,hazard,'no');

% measures impact future scenario (climate change + economic growth)
measures_impact_future = climada_measures_impact(entity_future,hazard_cc,measures_impact);



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


%..... EDS future
% EDS moderate cc
entity_source=[climada_global.project_dir filesep 'Salvador_entity_2015.mat'];
load(entity_source);
hazard_source=[climada_global.project_dir filesep 'Salvador_hazard_FL_2015_moderate_cc.mat'];
load(hazard_source);

EDS_mod = climada_EDS_calc(entity,hazard,'',1);

% EDS extreme cc
entity_source=[climada_global.project_dir filesep 'Salvador_entity_2015.mat'];
load(entity_source);
hazard_source=[climada_global.project_dir filesep 'Salvador_hazard_FL_2015_extreme_cc.mat'];
load(hazard_source);

EDS_extr = climada_EDS_calc(entity,hazard,'',1);


%plot the damages

fieldname_list = {'assets' 'damage' 'damage_relative'};
% peril_list = 'FL';
 peril_ID = 'FL';
unit_list = {'USD' 'people'};
category_list = unique(entity.assets.Category(salvador_assets_select(entity,peril_ID)));
print_figure = 0;

for f_i = 1:numel(fieldname_list)
    for c_i = 1:numel(category_list)
        salvador_map_plot(entity,EDS_extr,fieldname_list{f_i},peril_ID,'',category_list(c_i),print_figure);
        name=sprintf('Damage_cat_%d_%d_extr_cc',f_i,c_i);
        print(gcf,name,'-dpng')
    end %c_i
end

%close all figure
%close all
%.....
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



