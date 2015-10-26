function salvador_calc_measures(nametag,assets_file,damfun_file,measures_file,results_dir,peril_ID,m_file)
% calculate measures for salvador FL (for now)
% NAME:
%   salvador_calc_measures
% PURPOSE:
%   calc measures and save reports and figures in a newly created directory
%   in results/...
% CALLING SEQUENCE:
%   salvador_calc_measures(nametag,assets_file,damfun_file,measures_file,results_dir)
% EXAMPLE:
%   salvador_calc_measures('FL_v2',assets_file,damfun_file,measures_file,'20150922_measures_FL_v2')
%   salvador_calc_measures('FL',[],[],[], [],'FL','AB2');
% INPUTS:
% OPTIONAL INPUT PARAMETERS:
% OUTPUTS:
%   reports and figures 
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20150910, init
% Lea Mueller, muellele@gmail.com, 20150921, use new assets for FL
% Lea Mueller, muellele@gmail.com, 20150921, use new functions salvador_hazard_future_save, salvador_entity_files_set, 
%              add diary file, add future scenarios (2040 eco. development, 2040 moderate cc, 2040 extreme cc)
% Lea Mueller, muellele@gmail.com, 20150925, add urban planning (set to nil for 2015), use different 
%              hazard_intensity_impact_a for today, moderate and extreme cc
% Lea Mueller, muellele@gmail.com, 20150930, add adaptation_cost_curve for 2040, moderate cc
% Lea Mueller, muellele@gmail.com, 20150930, add special xlim for medidas 1 FL
% Lea Mueller, muellele@gmail.com, 20151020, add switch for peril_IDs (FL, TC, LS_las_canas, LS_acelhuate)
% Lea Mueller, muellele@gmail.com, 20151020, add special xlim for LS_las_canas people
% Lea Mueller, muellele@gmail.com, 20151020, add special xlim for LS_acelhuate people
% Jacob Anz,   j.anz@gmx.net     , 20151021, add input parameter m_file
% Jacob Anz,   j.anz@gmx.net     , 20151026, set xlim_value for TC and cleanup
% Jacob Anz,   j.anz@gmx.net     , 20151026, set special m_file limits only for peril FL
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('nametag', 'var'), nametag = ''; end
if ~exist('assets_file', 'var'), assets_file = ''; end
if ~exist('damfun_file', 'var'), damfun_file = []; end
if ~exist('measures_file', 'var'), measures_file = ''; end
if ~exist('results_dir', 'var'), results_dir = ''; end
if ~exist('peril_ID', 'var'), peril_ID = ''; end
if ~exist('m_file', 'var'), m_file = ''; end

% PARAMETERS
if isempty(nametag), nametag = ''; end
if isempty(results_dir), results_dir =[climada_global.project_dir filesep sprintf('%s_',datestr(now,'YYYYmmdd')) nametag];end
if isempty(peril_ID), peril_ID = 'FL'; end
if isempty(m_file), m_file = ''; end

% create results dir
if ~exist(results_dir,'dir')
    mkdir(results_dir)
    diary_file = [results_dir filesep sprintf('Diary_measures_%s_%s.csv',peril_ID,datestr(now,'YYYYmmdd'))];
    diary(diary_file)
    fprintf('New results directory created.\n')
else
    fprintf('This directoy already exists. Please use another name.\n')
    return
end

% load shp files
load([climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS'])

% set parameters
climada_global.present_reference_year = 2015;
climada_global.future_reference_year = 2040;
force_re_encode = 1;
timehorizon = climada_global.present_reference_year;
cc_scenario = 'no';
% cc_scenario = 'moderate';
% cc_scenario = 'extreme';



%% Hazard selection
annotation_name = sprintf('%s, %s climate change',peril_ID,cc_scenario);
hazard_set_file = sprintf('Salvador_hazard_%s_%d.mat', peril_ID, timehorizon);
% load hazard
load([climada_global.project_dir filesep hazard_set_file])
hazard.reference_year = climada_global.present_reference_year;

% create and save future cc hazards (TC, LS_las_canas and LS_acelhuate)
if strcmp(peril_ID,'TC') | strcmp(peril_ID,'LS_las_canas') | strcmp(peril_ID,'LS_acelhuate') | strcmp(peril_ID,'LS')
    salvador_hazard_future_save(peril_ID)
end


%% Entity selection
% set consultant_data_entity_dir
consultant_data_entity_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity'];
[assets_file, damfun_file, measures_file, m_file] = salvador_entity_files_set(assets_file,damfun_file,measures_file,peril_ID,m_file);

% read entity assets today
entity = climada_entity_read([consultant_data_entity_dir filesep assets_file],hazard);
entity.assets.reference_year = climada_global.present_reference_year;
if isfield(entity.assets,'VALNaN') entity.assets = rmfield(entity.assets,'VALNaN'); end
% encode assets, encode to 20 m if peril FL
if strcmp(peril_ID,'FL')
    climada_global.max_distance_to_hazard = 20;
else
    climada_global.max_distance_to_hazard = 10^6;
end
entity = climada_assets_encode(entity,hazard,climada_global.max_distance_to_hazard);
force_re_encode = 0;

% read damagefunctions
entity.damagefunctions = climada_damagefunctions_read([consultant_data_entity_dir filesep damfun_file]);
% check damage functions are defined for the given hazard intensity range
silent_mode = 1;
entity_out = climada_damagefunctions_check(entity,hazard,silent_mode);
entity.damagefunctions = entity_out.damagefunctions;

% read measures
switch peril_ID
    case 'FL'
        entity.measures = climada_measures_read([consultant_data_entity_dir filesep 'measures' filesep measures_file]);
    case 'TC'
        entity.measures = climada_measures_read([consultant_data_entity_dir filesep 'measures' filesep measures_file]);
    otherwise
        entity.measures = climada_measures_read([consultant_data_entity_dir filesep measures_file]);
end
% do not use special damagefunctions in measures
if isfield(entity.measures,'damagefunctions')
    entity.measures = rmfield(entity.measures,'damagefunctions');
end
% overwrite measures hazard intensity impact, high frequency cutoff
entity.measures.hazard_intensity_impact_b = zeros(size(entity.measures.hazard_intensity_impact_b));
entity.measures.hazard_high_frequency_cutoff = zeros(size(entity.measures.hazard_high_frequency_cutoff));

% save entity
% entity_filename = [climada_global.project_dir filesep 'Salvador_entity_2015_' peril_ID '.mat'];
entity_filename = [results_dir filesep 'Salvador_entity_2015_' peril_ID '.mat'];
entity.assets.filename = entity_filename;
save(entity_filename,'entity')


%% special case for urban planning measure
measures_ori = entity.measures;
if strcmp(peril_ID,'FL')
    % overwrite for 2040 no change scenario with 'nil'
    is_nil = strcmp(entity.measures.assets_file,'nil');
    if any(~is_nil)
        entity.measures.assets_file{~is_nil} = 'nil';
    end
end


%% calculate measures impact
% entity.measures.hazard_intensity_impact_b = -entity.measures.hazard_intensity_impact;
sanity_check = 1;
% entity.assets = rmfield(entity.assets,'hazard');
measures_impact = climada_measures_impact(entity,hazard,'no','','',sanity_check);
% measures_impact_filename = [results_dir filesep sprintf('measures_impact_%s_%s.mat',datestr(now,'YYYYmmdd'),nametag)];
% % measures_impact_filename = [climada_global.project_dir filesep sprintf('measures_impact_%s_%s.mat',datestr(now,'YYYYmmdd'),nametag)];
% save(measures_impact_filename,'measures_impact')


%% calculate measures impact, future scenario
% use new assets for urban planning
entity.measures = measures_ori;
entity_future = salvador_entity_future_create(entity, '', '',hazard.peril_ID);

% 2040, economic growth, no cc
measures_impact(2) = climada_measures_impact(entity_future,hazard,'no','','',sanity_check);

% 2040, moderate cc
if strcmp(peril_ID,'FL')
    % use different hazard_intensity_impact_a for moderate cc
    entity_future.measures.hazard_intensity_impact_a = entity_future.measures.hazard_intensity_impact_a_moderate_cc;
end
cc_scenario = 'moderate';
hazard_set_file = sprintf('Salvador_hazard_%s_%d_%s_cc', peril_ID, climada_global.future_reference_year, cc_scenario);
hazard = [];
load([climada_global.project_dir filesep hazard_set_file])
% annotation_name = sprintf('%s climate change',cc_scenario);
% calculate measures impact
measures_impact(3) = climada_measures_impact(entity_future,hazard,'no','','',sanity_check);

% 2040, extreme cc
if strcmp(peril_ID,'FL')
    % use different hazard_intensity_impact_a for moderate cc
    entity_future.measures.hazard_intensity_impact_a = entity_future.measures.hazard_intensity_impact_a_extreme_cc;
end
cc_scenario = 'extreme';
hazard_set_file = sprintf('Salvador_hazard_%s_%d_%s_cc', peril_ID, climada_global.future_reference_year, cc_scenario);
hazard = [];
load([climada_global.project_dir filesep hazard_set_file])
% annotation_name = sprintf('%s climate change',cc_scenario);
% calculate measures impact
measures_impact(4) = climada_measures_impact(entity_future,hazard,'no','','',sanity_check);

% save measures_impacts (today, future moderate cc, future extreme cc)
measures_impact_filename = [results_dir filesep sprintf('measures_impact_%s_%s.mat',datestr(now,'YYYYmmdd'),nametag)];
% measures_impact_filename = [climada_global.project_dir filesep sprintf('measures_impact_%s_%s.mat',datestr(now,'YYYYmmdd'),nametag)];
save(measures_impact_filename,'measures_impact')
fprintf('\t - Measures impact for today, 2040 moderate cc and 2040 extreme cc saved in \n \t %s\n',sprintf('measures_impact_%s_%s.mat',datestr(now,'YYYYmmdd'),nametag))


%% discounted benefits and costs (twice, once for USD, once for people)
unit_criterium = '';
category_criterium = '';
silent_mode = 1;
[~,~,unit_list,category_criterium]...
             = climada_assets_select(entity,hazard.peril_ID,unit_criterium,category_criterium,silent_mode);
% entity.measures.color_RGB = jet(numel(entity.measures.name));
orig_discount_rate = entity.discount.discount_rate;

scenarios = {'2040 no change', '2040 development, no cc' '2040 moderate cc', '2040 extreme cc'};
for scenario_i = 1:numel(scenarios)
    for u_i = 1:numel(unit_list)
        climada_global.Value_unit = unit_list{u_i}; 
        if strcmp(unit_list{u_i},'people')
            entity.discount.discount_rate = orig_discount_rate*0;
            measures_impact_people(scenario_i) = climada_measures_impact_discount(entity,...
                                                  measures_impact(scenario_i),measures_impact(1),'unit',unit_list{u_i});
            measures_impact_people(scenario_i).Value_unit =  climada_global.Value_unit;                               
            %measures_impact_people(scenario_i).title_str_ori = measures_impact_people(scenario_i).title_str;
            measures_impact_people(scenario_i).title_str = scenarios{scenario_i};
        else
            measures_impact_USD(scenario_i) = climada_measures_impact_discount(entity,...
                                                 measures_impact(scenario_i),measures_impact(1),'unit',unit_list{u_i});
            %measures_impact_USD(scenario_i).title_str_ori = measures_impact_USD(scenario_i).title_str;
            measures_impact_USD(scenario_i).title_str = scenarios{scenario_i};
        end
        entity.discount.discount_rate = orig_discount_rate;
    end %u_i
end %scenario_i



%% create adaptation cost curve, 2040, moderate cc
% use 2040, moderate cc
scenario_i = 3;

% set xlim_value
xlim_value = '';
% if strcmp(measures_file,['20151015_FL' filesep 'measures_template_for_measures_location_A_B_1.xls'])
if strcmp(m_file,'AB1') && strcmp(peril_ID,'FL')
    xlim_value = 21e6; %xlim_value = max(measures_impact_USD(4).benefit)*1.4;
    measures_impact_USD(scenario_i).x_axis_max = xlim_value;
    measures_impact_people(scenario_i).x_axis_max = xlim_value/10000;
elseif strcmp(m_file,'AB2') && strcmp(peril_ID,'FL')
    measures_impact_USD(scenario_i).x_axis_max=7e8;
    measures_impact_people(scenario_i).x_axis_max=3e4;
end

% USD
climada_global.font_scale = 1.3;
fig = climada_figuresize(0.5,1.2);
climada_adaptation_cost_curve(measures_impact_USD(scenario_i),'',30,10);
pdf_filename = sprintf('Adaptation_cost_curve_USD_%s_%s.pdf',measures_impact_USD(u_i).peril_ID,strrep(scenarios{scenario_i},' ','_'));
print(fig,'-dpdf',[results_dir filesep pdf_filename])
       
% people
fig = climada_figuresize(0.5,1.2);
climada_adaptation_cost_curve(measures_impact_people(scenario_i),'',30,10);
pdf_filename = sprintf('Adaptation_cost_curve_people_%s_%s.pdf',measures_impact_people(u_i).peril_ID,strrep(scenarios{scenario_i},' ','_'));
print(fig,'-dpdf',[results_dir filesep pdf_filename])
 
 

%% create adaptation bar charts

sort_measures = 3; %use 2040 moderate cc to sort measures
scale_benefit = 1;
benefit_str = '';
% xlim_value = '';
xlim_value = max(measures_impact_USD(4).benefit)*1.005;
if strcmp(measures_file,['20150925_FL' filesep 'measures_template_for_measures_location_A_B_1.xls'])
    xlim_value = max(measures_impact_USD(4).benefit)*1.4;
    xlim_value = 12e6;
end
% if strcmp(measures_file,['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_LASCANAS_141015_NEW.xls'])
%     xlim_value = max(entity.measures.cost)*1.02;
% end
% if strcmp(measures_file,['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_ACELHUATE_141015_NEW.xls'])
%     xlim_value = max(entity.measures.cost)*1.02;
% end
fig = climada_adaptation_bar_chart_v2(measures_impact_USD,sort_measures,scale_benefit,benefit_str,'southeast','','',xlim_value);
pdf_filename = sprintf('Adaptation_bar_chart_USD_sorted_%s_%s.pdf',measures_impact_USD(u_i).peril_ID,nametag);
print(fig,'-dpdf',[results_dir filesep pdf_filename])
       

% set xlim_value for bar chart people
scale_benefit = 10000; %scale_benefit = 20000;
cost_unit = 'USD';
xlim_value = max(measures_impact_people(4).benefit)*1.005;
if strcmp(measures_file,['20150918' filesep 'measures_template_for_measures_location_A_B_1.xls'])
    xlim_value = max(measures_impact_people(4).benefit)*1.5;
    xlim_value = 1200;
end
if strcmp(m_file,'AB1') && strcmp(peril_ID,'FL')
    xlim_value = 1.2e3;
elseif strcmp(m_file,'AB2') && strcmp(peril_ID,'FL') 
    xlim_value = 6e3;
end
if strcmp(measures_file,['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_LASCANAS_141015_NEW.xls'])
    xlim_value = 2*620; %xlim_value = 620;
end
if strcmp(measures_file,['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_ACELHUATE_141015_NEW.xls'])
    xlim_value = 450; % xlim_value = 2*450;
end
if strcmp(measures_file,['20151014_TC' filesep 'entity_AMSS_WIND-AMSS_141015_FINAL_COSTS.xlsx'])
    xlim_value=6.5*10^3;
end

fig = climada_adaptation_bar_chart_v2(measures_impact_people,sort_measures,scale_benefit,benefit_str,'southeast','',cost_unit,xlim_value);
pdf_filename = sprintf('Adaptation_bar_chart_people_sorted_%s_%s.pdf',measures_impact_USD(u_i).peril_ID,nametag);
print(fig,'-dpdf',[results_dir filesep pdf_filename])




%% produce reports and figures
ED_filename = sprintf('ED_%s_%d_measures_%s_%s.xls', peril_ID, climada_global.future_reference_year,datestr(now,'YYYYmmdd'),nametag);
xls_file = [results_dir filesep ED_filename];

% discounted benefits per measure and scenario
sheet_name = sprintf('Benefit_costs_%s',unit_list{1});
output_report = climada_measures_impact_report(measures_impact_USD,xls_file,sheet_name);

sheet_name = sprintf('Benefit_costs_%s',unit_list{2});
output_report = climada_measures_impact_report(measures_impact_people,xls_file,sheet_name);

% ED per category
benefit_flag = 1;
percentage_flag = 1;
for scenario_i = 1:numel(scenarios)
    sheet_name = sprintf('ED_per_category_%s',strrep(scenarios{scenario_i},',',''));
    if numel(sheet_name)>30
        sheet_name = sheet_name(1:30);
    end
    salvador_EDS_ED_per_category_report(entity,measures_impact(scenario_i).EDS,xls_file,sheet_name,benefit_flag,percentage_flag);
end %scenario_i

% write assets to compare measures with different assets
scenario_i = 3;
sheet_name = sprintf('Assets %d',climada_global.future_reference_year);
EDS_output = measures_impact(scenario_i).EDS;
EDS_output(end+1) = measures_impact(1).EDS(end);
EDS_output(end).annotation_name = sprintf('%s, %d',EDS_output(end).annotation_name,EDS_output(end).reference_year);
EDS_output = EDS_output([end 1:end-1]);
salvador_EDS_ED_per_category_report(entity,EDS_output,xls_file,sheet_name,'','',1);

% ED at centroid
scenario_i = 3;
% % xls_file = [climada_global.project_dir filesep 'REPORTS' filesep ED_filename];
sheet_name = sprintf('ED_at_centroid_%s',strrep(scenarios{scenario_i},',',''));
if numel(sheet_name)>30, sheet_name = sheet_name(1:30);end
climada_EDS_ED_at_centroid_report_xls(measures_impact(scenario_i).EDS, xls_file,sheet_name)



%%




