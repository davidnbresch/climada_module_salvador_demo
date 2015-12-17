function EDS = salvador_calc_waterfall(nametag,assets_file,damfun_file,results_dir, growth_rate_eco, growth_rate_people,peril_ID)


% calculate waterfall graph 
%   - for San Salvador 
%   - salvador_calc_waterfall.m
%   - calculate EDS for today, economic development,
%     2040 moderate and 2040 extreme cc
%   - for USD and for people
%Example
% EDS=salvador_calc_waterfall_2('','','','','','','TC');
%Input parameter
% peril_ID = 'LS','FL','TC' ;
%
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20150901, init
% Lea Mueller, muellele@gmail.com, 20150924, cleanup and add new functions (salvador_entity_files_set, salvador_entity_future_create, salvador_hazard_future_save) 
% Lea Mueller, muellele@gmail.com, 20150924, add diary_file
% Lea Mueller, muellele@gmail.com, 20150925, check damagefunctions
% Lea Mueller, muellele@gmail.com, 20150925, set max_distance_to_hazard to 10^6 if not FL
% Lea Mueller, muellele@gmail.com, 20151020, do not show legend in waterfall graph
% Lea Mueller, muellele@gmail.com, 20151030, enable to select any entity/assets,damfun (uigetfile)
% Lea Mueller, muellele@gmail.com, 20151106, rename to climada_EDS_ED_per_category_report from salvador_EDS_ED_per_category_report
% Lea Mueller, muellele@gmail.com, 20151217, use climada_global.data_dir instead of project_dir, use climada_assets_read and climada_discount_read instead of climada_entity_read
%-


EDS = []; %init

% set initial parameters
global climada_global
if ~climada_init_vars,return;end % init/import global variables

cc_scenario = 'no';
timehorizon = 2015;
force_re_encode = 1;
climada_global.present_reference_year = 2015;
climada_global.future_reference_year = 2040;


% poor man's version to check arguments
if ~exist('nametag', 'var'), nametag = ''; end
if ~exist('assets_file', 'var'), assets_file = ''; end
if ~exist('damfun_file', 'var'), damfun_file = []; end
if ~exist('results_dir', 'var'), results_dir = ''; end
if ~exist('growth_rate_eco', 'var'), growth_rate_eco = ''; end
if ~exist('growth_rate_people', 'var'), growth_rate_people = ''; end
if ~exist('peril_ID', 'var'), peril_ID = ''; end

% PARAMETERS
% if isempty(nametag), nametag = inputdlg('Enter a name for the file');nametag = nametag{1};end
% if isempty(nametag), nametag = 'unknown';end
if isempty(results_dir) 
    if exist([climada_global.project_dir filesep 'results'],'dir')
        results_dir = [climada_global.project_dir filesep 'results' filesep sprintf('%s_waterfall_',datestr(now,'YYYYmmdd')) nametag];
    else
        results_dir = [climada_global.project_dir filesep sprintf('%s_waterfall_',datestr(now,'YYYYmmdd')) nametag];
    end
end
if isempty(growth_rate_eco), growth_rate_eco = 0.04; end
if isempty(growth_rate_people), growth_rate_people = 0.2/100; end
% if isempty(peril_ID), peril_ID = 'FL'; end

[pathstr, name, ext] = fileparts(results_dir);
if isempty(pathstr)
    pathstr = [climada_global.data_dir filesep 'results'];
    %pathstr = climada_global.project_dir;
    results_dir = fullfile(pathstr, name);
end

% create results dir
if ~exist(results_dir,'dir')
    mkdir(results_dir)
    diary_file = [results_dir filesep sprintf('Diary_waterfall_%s_%s.csv',peril_ID,datestr(now,'YYYYmmdd'))];
    diary(diary_file)
    fprintf('New results directory created.\n')
else
    fprintf('This directoy already exists. Please use another name.\n')
    return
end

if isempty(peril_ID) && strcmp(climada_global.project_dir, climada_global.data_dir)
    peril_name_list = {'FL Acelhuate' 'TC AMSS' 'LS Las Canas' 'LS Acelhuate'};
    peril_list = {'FL' 'TC' 'LS_las_canas' 'LS_acelhuate'};
    [selection,ok] = listdlg('PromptString','Select peril and area:',...
    'ListString',peril_name_list,'SelectionMode','SINGLE');
    pause(0.1)
    if ~isempty(selection)
        peril_ID = peril_list{selection};
    end
end
if isempty(peril_ID), peril_ID = 'TC'; end

% % load shp files
% load([climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS'])

% Hazard selection
annotation_name = sprintf('%s, %s climate change',peril_ID,cc_scenario);
hazard_set_file = sprintf('Salvador_hazard_%s_%d.mat', peril_ID, timehorizon);
% load hazard
if exist([climada_global.project_dir filesep hazard_set_file],'file')
    load([climada_global.project_dir filesep hazard_set_file])
else
    if exist([climada_global.project_dir filesep 'hazards' filesep hazard_set_file],'file')
        load([climada_global.project_dir filesep 'hazards' filesep hazard_set_file])
        hazard_set_file = ['hazards' filesep  sprintf('Salvador_hazard_%s_%d.mat', peril_ID, timehorizon)];
    else
        clear hazard
        hazard = climada_hazard_load;
        if isempty(hazard), return, end
        hazard_set_file = hazard.filename;
        peril_ID = hazard.peril_ID;        
        if strcmp(peril_ID,'LS')
            LS_name = {'las_canas' 'acelhuate'};
            [selection,ok] = listdlg('PromptString','Select Landslide area:',...
            'ListString',LS_name,'SelectionMode','SINGLE');
            pause(0.1)
            if ~isempty(selection)
                peril_ID = ['LS_' LS_name{selection}];
            else
                fprintf('NOTE: no area chosen, aborted\n')
                return
            end
        end
    end
end
hazard.scenario = 'no climate change';
hazard.reference_year = climada_global.present_reference_year;

% create and save future cc hazards (TC, LS_las_canas and LS_acelhuate)
if strcmp(peril_ID,'TC') || strcmp(peril_ID,'LS_las_canas') || strcmp(peril_ID,'LS_acelhuate') || strcmp(peril_ID,'LS')
    salvador_hazard_future_save(peril_ID)
end


%% Entity selection
% set consultant_data_entity_dir
% consultant_data_entity_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity'];
consultant_data_entity_dir = [climada_global.data_dir filesep 'entities'];
measures_file = '';
[assets_file, damfun_file] = salvador_entity_files_set(assets_file,damfun_file,measures_file,peril_ID);

if isempty(assets_file)
    return
end

% read entity
% entity today
if ~isempty(strfind(assets_file,':')) || ~isempty(strfind(assets_file,'\\'))
    % assets_file contains full path already
    entity.assets = climada_assets_read(assets_file,hazard);
else
    entity.assets = climada_assets_read([consultant_data_entity_dir filesep assets_file],hazard);
end
entity.assets.reference_year = climada_global.present_reference_year;
if isfield(entity.assets,'VALNaN'), entity.assets = rmfield(entity.assets,'VALNaN');end

% read damagefunctions
if ~isempty(strfind(damfun_file,':')) || ~isempty(strfind(damfun_file,'\\'))
    entity.damagefunctions = climada_damagefunctions_read(damfun_file);
else
    entity.damagefunctions = climada_damagefunctions_read([consultant_data_entity_dir filesep damfun_file]);
end
% check damage functions are defined for the given hazard intensity range
silent_mode = 1;
entity_out = climada_damagefunctions_check(entity,hazard,silent_mode);
entity.damagefunctions = entity_out.damagefunctions;

% init measures
entity.measures.filename = '';

% save entity
entity_filename = [results_dir filesep 'Salvador_entity_2015_' peril_ID '.mat'];
entity.assets.filename = entity_filename;
save(entity_filename,'entity')


%% calculate waterfall graph
n_years = climada_global.future_reference_year - climada_global.present_reference_year+1;

clear EDS % init

% encode to 20 m if peril FL
if strcmp(peril_ID,'FL')
    climada_global.max_distance_to_hazard = 20;
else
    climada_global.max_distance_to_hazard = 10^6;
end
entity = climada_assets_encode(entity,hazard,climada_global.max_distance_to_hazard);
force_re_encode = 0;

% risk today
EDS(1) = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);

% copy original entity
entity_ori = entity;

% 2040, economic growth
% create future entity
entity = salvador_entity_future_create(entity, growth_rate_eco, growth_rate_people,hazard.peril_ID);
annotation_name = 'Economic growth';
EDS(2) = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);

% 2040, moderate cc
timehorizon = climada_global.future_reference_year;
cc_scenario = 'moderate';
hazard = [];
hazard_set_file = strrep(hazard_set_file,...
        sprintf('%s_%d', peril_ID, climada_global.present_reference_year),...
        sprintf('%s_%d_%s_cc', peril_ID, timehorizon, cc_scenario));
if isempty(strfind(hazard_set_file,':')) || isempty(strfind(hazard_set_file,'\\')) %not yet full path
    %hazard_set_file = sprintf('Salvador_hazard_%s_%d_%s_cc', peril_ID, timehorizon, cc_scenario);
    hazard_set_file = [climada_global.project_dir filesep hazard_set_file];
end
if exist(hazard_set_file,'file')
    load(hazard_set_file)
else
    hazard = climada_hazard_load;
end
annotation_name = sprintf('%s climate change',cc_scenario);
EDS(3) = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);

% 2040, extreme cc
timehorizon = climada_global.future_reference_year;
cc_scenario = 'extreme';
hazard = [];
hazard_set_file = strrep(hazard_set_file,'moderate',cc_scenario);
% if ~isempty(strfind(hazard_set_file,':')) || ~isempty(strfind(hazard_set_file,'\\')) %full path already
% else
%     hazard_set_file = sprintf('Salvador_hazard_%s_%d_%s_cc', peril_ID, timehorizon, cc_scenario);
%     hazard_set_file = [climada_global.project_dir filesep hazard_set_file];
% end
if exist(hazard_set_file,'file')
    load(hazard_set_file)
else
    hazard = climada_hazard_load;
end
annotation_name = sprintf('%s climate change',cc_scenario);
EDS(4) = climada_EDS_calc(entity,hazard,annotation_name,force_re_encode);

% set annotations
EDS(1).hazard.comment = sprintf('%s, 2015 ',peril_ID);
EDS(2).hazard.comment = sprintf('%s, 2040, econ growth',peril_ID);
EDS(3).hazard.comment = sprintf('%s, 2040, moderate cc',peril_ID);
EDS(4).hazard.comment = sprintf('%s, 2040, extreme cc',peril_ID);
EDS(1).reference_year = 2015;
EDS(2).reference_year = 2015;


%% create report
benefit_flag = 0;
assets_flag = 1;
EDS(5) = EDS(1);
xls_file = [results_dir filesep 'ED_' peril_ID '_2015_2040_' datestr(now,'YYYYmmdd') '_' nametag '.xlsx'];
output_report = climada_EDS_ED_per_category_report(entity_ori, EDS, xls_file,'ED_per_category',benefit_flag,0,assets_flag);

% save EDS
EDS_filename = strrep(xls_file,'.xlsx','.mat');
save(EDS_filename,'EDS')
[pathstr, name, ext] = fileparts(EDS_filename);
fprintf('Save EDS waterfall in %s\n',[name ext])


%% create waterfall AED (for times, once for USD, once for people, for moderate and for extreme climate change)
unit_criterium = '';
category_criterium = '';
silent_mode = 1;
[~,~,unit_list,category_criterium]...
             = climada_assets_select(entity,hazard.peril_ID,unit_criterium,category_criterium,silent_mode);
cc_scenario_names = {'moderate' 'extreme'};


for u_i = 1:numel(unit_list)
    [is_selected,peril_criterum,unit_criterium,category_criterium] =...
             climada_assets_select(entity,EDS(1).peril_ID,unit_list{u_i},'',silent_mode);  
    for EDS_i = 1:numel(EDS)
        EDS(EDS_i).ED = sum(EDS(EDS_i).ED_at_centroid(is_selected));
        EDS(EDS_i).Value = sum(EDS(EDS_i).assets.Value(is_selected));
        EDS(EDS_i).Value_unit = unit_criterium{1};
    end
    
    for cc_i = 1:numel(cc_scenario_names)
        switch cc_scenario_names{cc_i}
            case 'moderate'
                fig = climada_figuresize(0.57,0.7);
                climada_waterfall_graph(EDS(1),EDS(2),EDS(3),'AED');
            case 'extreme'
                fig = climada_figuresize(0.57,0.7);
                climada_waterfall_graph(EDS(1),EDS(2),EDS(4),'AED');
        end
        % do not show legend
        legend('off'); %legend(get(fig),'');
        pdf_filename = sprintf('Waterfall_%s_%s_cc_%s_%s.pdf',peril_ID,cc_scenario_names{cc_i},unit_criterium{1},nametag);
        print(fig,'-dpdf',[results_dir filesep pdf_filename])
    end
end

diary off



%plot
%j=1; %can be defind between 1 and 4) 1=today, 2=eco growth, 3=mod.cc 4= extr. cc
%cbar=plotclr(EDS(j).assets.lon,EDS(j).assets.lat,EDS(j).ED_at_centroid,'s',2,1,[],[],[],[],1);






























    

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
% output_report = climada_EDS_ED_per_category_report(entity, EDS, [climada_global.project_dir filesep 'REPORTS' filesep ED_filename],'ED_per_category');
% % output_report = climada_EDS_ED_per_category_report(entity, EDS,'NO_xls_file');



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

