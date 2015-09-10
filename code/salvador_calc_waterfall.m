function salvador_calc_waterfall(nametag,assets_file,damfun_file,results_dir, growth_rate_eco, growth_rate_people)


% calculate waterfall graph
%   - for San Salvador 
%   - salvador_calc_waterfall.m
%   - calculate EDS for today, economic development,
%   2040 moderate and 2040 extreme cc
%   - for USD and for people
      

% peril_ID = 'LS';
peril_ID = 'FL';
% peril_ID = 'TC';
cc_scenario = 'no';
% cc_scenario = 'moderate';
% cc_scenario = 'extreme';
timehorizon = 2015;

force_re_encode = 1;


global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('nametag', 'var'), nametag = ''; end
if ~exist('assets_file', 'var'), assets_file = ''; end
if ~exist('damfun_file', 'var'), damfun_file = []; end
if ~exist('results_dir', 'var'), results_dir = ''; end
if ~exist('growth_rate_eco', 'var'), growth_rate_eco = ''; end
if ~exist('growth_rate_people', 'var'), growth_rate_people = ''; end


% PARAMETERS
if isempty(nametag), nametag='unknown';end
if isempty(results_dir), results_dir =[climada_global.project_dir filesep sprintf('%s_waterfall_',datestr(now,'YYYYmmdd')) nametag];end
if isempty(growth_rate_eco), growth_rate_eco = 0.04; end
if isempty(growth_rate_people), growth_rate_people = 0.2/100; end

[pathstr, name, ext] = fileparts(results_dir);
if isempty(pathstr)
    pathstr = climada_global.project_dir;
    results_dir = fullfile(pathstr, name);
end

% create results dir
if ~exist(results_dir,'dir')
    mkdir(results_dir)
    fprintf('New results directory created.\n')
else
    fprintf('This directoy already exists. Please use another name.\n')
    return
end



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


%% set consultant_data_entity_dir
consultant_data_entity_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity'];
switch peril_ID
    case 'FL'
        if isempty(assets_file)
            assets_file = ['20150721' filesep 'entity_AMSS_NEW.xls'];
        end
        if isempty(damfun_file)
            damfun_file = ['20150910' filesep 'DamageFunction_150910.xlsx'];
            % damfun_file = ['20150910' filesep 'DamageFunction_150910_other_way.xlsx'];
            % damfun_file = ['20150910' filesep 'DamageFunction_150910.xlsx'];
            % damfun_file = ['20150806' filesep 'DamageFunction_FL_2ndRUN.xlsx'];
            % consultant_data_damage_fun_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep '20150811_TC'];
        end
        %if isempty(measures_file)
        %    measures_file = ['20150909' filesep 'Medidas parametrizadas_2m_150908 aumentada precio mejorad y mantenimiento.xlsx'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150818'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150828'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150901'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150903'];
            %consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150909'];
        %end
        %entity_file_xls = [consultant_data_entity_dir filesep 'entity_AMSS_NEW.xls'];
    case 'LS'
        consultant_data_entity_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep '20150806_LS'];
        entity_file_xls = [consultant_data_entity_dir filesep 'entity_AMSS_DESLIZAMIENTO.xlsx'];
end
% load shp files
load([climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS'])


% peril_description = {'flood in Rio Acelhuate' 'hurricane winds in AMSS' 'landslides in Ilopango'};


%% read entity
% entity today
entity = climada_entity_read([consultant_data_entity_dir filesep assets_file],hazard);
entity.assets.reference_year = 2015;
entity.assets = rmfield(entity.assets,'VALNaN');
entity.damagefunctions = climada_damagefunctions_read([consultant_data_entity_dir filesep damfun_file]);

entity_filename = [climada_global.project_dir filesep 'Salvador_entity_2015_no_measures' peril_ID '.mat'];
entity.assets.filename = entity_filename;
save(entity_filename,'entity')

% % future entity, 2040
% load([climada_global.project_dir filesep 'Salvador_entity_2040.mat'])
% % % is_selected = climada_assets_select(entity,hazard.peril_ID,'USD');
% % is_selected = climada_assets_select(entity,hazard.peril_ID,'people');
% % sum(entity.assets.Value(is_selected))
% load([climada_global.project_dir filesep 'Salvador_entity_2015.mat'])


%% calculate waterfall graph
n_years = climada_global.future_reference_year - climada_global.present_reference_year+1;

% risk today
annotation_name = 'FL, risk today';
% annotation_name = sprintf('%s, %s climate change',peril_ID,cc_scenario);
% hazard_set_file = sprintf('Salvador_hazard_%s_%d_%s_cc', peril_ID, timehorizon, cc_scenario);
EDS(1) = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);

force_re_encode = 0;

% 2040, economic growth
% entity_future = entity;
% USD  
growth_factor = (1+growth_rate_eco)^n_years;
[is_selected,peril_criterum,unit_criterium,category_criterium] = ...
       climada_assets_select(entity,hazard.peril_ID,'USD','');
entity.assets.Value(is_selected) = entity.assets.Value(is_selected) * growth_factor;
% people
growth_factor = (1+growth_rate_people)^n_years;
[is_selected,peril_criterum,unit_criterium,category_criterium] = ...
       climada_assets_select(entity,hazard.peril_ID,'people','');
entity.assets.Value(is_selected) = entity.assets.Value(is_selected) * growth_factor;

entity.assets.reference_year = 2040;
entity_filename = [results_dir filesep 'Salvador_entity_2040.mat'];
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

% set annotations
EDS(1).hazard.comment = 'FL, 2015';
EDS(2).hazard.comment = 'FL, 2015';
EDS(3).hazard.comment = 'FL, 2040, moderate cc';
EDS(4).hazard.comment = 'FL, 2040, extreme cc';
EDS(1).reference_year = 2015;
EDS(2).reference_year = 2015;


%% create report
benefit_flag = 0;
EDS(5) = EDS(1);
xls_file = [results_dir filesep 'ED_FL_2015_2040_' datestr(now,'YYYYmmdd') '_' nametag];
output_report = salvador_EDS_ED_per_category_report(entity, EDS, xls_file,'ED_per_category',benefit_flag);


%% create waterfall AED (for times, once for USD, once for people, for moderate and for extreme climate change)
unit_criterium = '';
category_criterium = '';
[~,~,unit_list,category_criterium]...
             = climada_assets_select(entity,hazard.peril_ID,unit_criterium,category_criterium);
cc_scenario_names = {'moderate' 'extreme'};

for u_i = 1:numel(unit_list)
    [is_selected,peril_criterum,unit_criterium,category_criterium] =...
             climada_assets_select(entity,EDS(1).peril_ID,unit_list{u_i});  
    for EDS_i = 1:numel(EDS)
        EDS(EDS_i).ED = sum(EDS(EDS_i).ED_at_centroid(is_selected));
        EDS(EDS_i).Value = sum(EDS(EDS_i).assets.Value(is_selected));
        EDS(EDS_i).Value_unit = unit_criterium{1};
    end
    
    for cc_i = 1:numel(cc_scenario_names)
        switch cc_scenario_names{cc_i}
            case 'moderate'
                fig = climada_waterfall_graph(EDS(1),EDS(2),EDS(3),'AED');
            case 'extreme'
                fig = climada_waterfall_graph(EDS(1),EDS(2),EDS(4),'AED');
        end
        pdf_filename = sprintf('Waterfall_FL_%s_cc_%s_%s.pdf',cc_scenario_names{cc_i},unit_criterium{1},nametag);
        print(fig,'-dpdf',[results_dir filesep pdf_filename])
    end
end


    

% %% unit_criterium = 'USD';
% unit_criterium = 'people';
% % cc_scenario = 'moderate';
% cc_scenario = 'extreme';
% [is_selected,peril_criterum,unit_criterium,category_criterium] =...
%             climada_assets_select(entity,EDS(1).peril_ID,unit_criterium);        
% for EDS_i = 1:numel(EDS)
%     EDS(EDS_i).ED = sum(EDS(EDS_i).ED_at_centroid(is_selected));
%     EDS(EDS_i).Value = sum(EDS(EDS_i).assets.Value(is_selected));
%     EDS(EDS_i).Value_unit = unit_criterium{1};
% end
% EDS(1).hazard.comment = 'FL, 2015';
% EDS(2).hazard.comment = 'FL, 2015';
% EDS(3).hazard.comment = 'FL, 2040, moderate cc';
% EDS(4).hazard.comment = 'FL, 2040, extreme cc';
% EDS(1).reference_year = 2015;
% EDS(2).reference_year = 2015;
% switch cc_scenario
%     case 'moderate'
%         fig = climada_waterfall_graph(EDS(1),EDS(2),EDS(3),'AED');
%     case 'extreme'
%         fig = climada_waterfall_graph(EDS(1),EDS(2),EDS(4),'AED');
% end
% pdf_filename = sprintf('Waterfall_FL_%s_cc_%s.pdf',cc_scenario,unit_criterium{1});
% print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])









%% calculate damage
% 
% EDS = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);
% % save([climada_global.project_dir filesep 'Salvador_EDS_FL_2015_new_damagefun'],'EDS')
% % EDS(2) = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);
% 
% 
% 
% %% create ED report
% % timehorizon = 2015;
% % peril_ID    = 'FL';
% ED_filename = sprintf('ED_%s_%d_cc_%s_%s.xls', peril_ID, timehorizon,cc_scenario,datestr(now,'YYYYmmdd'));
% climada_EDS_ED_at_centroid_report_xls(EDS, [climada_global.project_dir filesep 'REPORTS' filesep ED_filename],'ED_at_centroid')
% output_report = salvador_EDS_ED_per_category_report(entity, EDS, [climada_global.project_dir filesep 'REPORTS' filesep ED_filename],'ED_per_category');
% % output_report = salvador_EDS_ED_per_category_report(entity, EDS,'NO_xls_file');



% %% create maps for selected fieldnames (assets or damage), peril FL, units (USD or people), and per category
% fieldname_list = {'assets' 'damage' 'damage_relative'};
% % peril_list = 'FL';
% unit_list = {'USD' 'people'};
% category_list = unique(entity.assets.Category(salvador_assets_select(entity,peril_ID)));
% % print_figure = 1;
% print_figure = 0;
% 
% for f_i = 1%:numel(fieldname_list)
%     for c_i = 1:numel(category_list)
%         fig = salvador_map_plot(entity,EDS,fieldname_list{f_i},peril_ID,'',category_list(c_i),print_figure);
%         cbar = plotclr(hazard.lon, hazard.lat, hazard.intensity(end-1,:),...
%                's',0.5,1,0,6,climada_colormap('FL'));
%         pdf_filename= sprintf('Assets_orig_cat_%d.png',c_i);   
%         print(fig,'-dpng',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])
%     end %c_i
% end %f_i
% close all

% % fieldname_to_plot = 'assets';
% % peril_criterium = 'FL';
% % unit_criterium = 'USD';
% % category_criterium = '';
% % salvador_map_plot(entity,'',fieldname_to_plot,peril_criterium,unit_criterium,category_criterium,print_figure);
% 
% 
% %% create figure assets FL and hazard FL
% fig = climada_figuresize(0.5,0.9);
% is_selected = salvador_assets_select(entity,'FL','USD');
% 
% % shape_plotter(shape_rivers(indx_rivers_in_San_Salvador),'','X_ori','Y_ori','linewidth',0.2,'color',[0.0   0.6039   0.8039])
% % shape_plotter(shape_roads(indx_roads_in_San_Salvador),'','','','linewidth',0.02,'color',[234 234 234]/255) %[0.3176 0.3176 0.3176])
% cbar = plotclr(hazard.lon, hazard.lat, hazard.intensity(end-1,:),...
%     's',0.5,1,0,6,climada_colormap('FL'));
% % plot(hazard.lon(logical(hazard.intensity(end,:))), hazard.lat(logical(hazard.intensity(end,:))),...
% %     's','markersize',0.5,'color','b');
% 
% % cbar = plotclr(entity.assets.lon(is_selected), entity.assets.lat(is_selected), entity.assets.Value(is_selected)/100000,...
% %     'p',0.5,1,0,1,climada_colormap('assets'));
% hold on
% plot(entity.assets.lon(is_selected), entity.assets.lat(is_selected),...
%     '.','markersize',0.02,'color',[255 97 3]./255);
% ax_limits = [-89.26 -89.15 13.67 13.71];
% climada_figure_axis_limits_equal_for_lat_lon(ax_limits)
% box on
% climada_figure_scale_add('',4,1)
% % set(get(cbar,'ylabel'),'String', '100 year flood (m)','fontsize',13);
% % title('Assets (Flood, 2015) and 100 year flood','fontsize',13)
% title('Assets (Flood, 2015) and 50 year flood','fontsize',13)
% % print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep 'Salvador_entity_assets_FL_2015_hazard_100_year.pdf'])
% print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep 'Salvador_entity_assets_FL_2015_hazard_50_year.pdf'])
% 
% 
% 
% %% create entity figure
% % fig = climada_figuresize(0.5,0.8);
% % climada_entity_plot(entity,4)
% % shape_plotter(shape_rivers(indx_rivers_in_San_Salvador),'','','','linewidth',0.2,'color',[0.0   0.6039   0.8039])
% % % shape_plotter(shape_roads(indx_roads_in_San_Salvador),'','','','linewidth',0.02,'color',[234 234 234]/255) %[0.3176 0.3176 0.3176])
% % box on
% % ax_limits = [-89.3 -89.05 13.64 13.81];
% % climada_figure_axis_limits_equal_for_lat_lon(ax_limits)
% % climada_figure_scale_add('',0,1)
% % title('Assets 2015','fontsize',13)
% % print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep 'Salvador_entity_assets_2015.pdf'])
% 
% 
% 
% %% create damage frequency curve (DFC)
% fig = climada_figuresize(0.4, 0.6);
% plot(1./EDS.frequency, EDS.damage*10^-6,'.-')
% grid off
% xlabel('Return period (years)')
% ylabel('Damage (USD m)')
% title('Damage versus return period for Flood Rio Acelhuate, 2015')
% axis([0 105 0 85])
% textstr = {sprintf('Total values: USD %4.1f m', sum(entity.assets.Value(indx_assets))*10^-6); ...
%            sprintf('Annual expected damage: USD %4.1f m', EDS.ED*10^-6);...
%            sprintf('Annual expected damage: %4.1f %%', EDS.ED/sum(entity.assets.Value(indx_assets))*100)};
% text(2.5,82, textstr, 'verticalalignment','top','HorizontalAlignment','left','fontsize',11)
% print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep 'Salvador_DFC_FL_2015.pdf'])
% 
% % DFC = climada_EDS2DFC(EDS);
% % [fig,legend_str,return_period,sorted_damage] = climada_EDS_DFC(EDS);
% 
% 

