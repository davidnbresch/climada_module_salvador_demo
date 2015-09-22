function salvador_calc_measures(nametag,assets_file,damfun_file,measures_file,results_dir)
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
% INPUTS:
% OPTIONAL INPUT PARAMETERS:
% OUTPUTS:
%   reports and figures 
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20150910, init
% Lea Mueller, muellele@gmail.com, 20150921, use new assets for FL
%-


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
if ~exist('measures_file', 'var'), measures_file = ''; end
if ~exist('results_dir', 'var'), results_dir = ''; end



% PARAMETERS
if isempty(nametag), nametag = 'unknown'; end
if isempty(results_dir), results_dir =[climada_global.project_dir filesep sprintf('%s_',datestr(now,'YYYYmmdd')) nametag];end


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


% set consultant_data_entity_dir
consultant_data_entity_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity'];
switch peril_ID
    case 'FL'
        if isempty(assets_file)
            assets_file = ['20150916' filesep 'entity_AMSS_FL_TC.xls'];
            % assets_file = ['20150721' filesep 'entity_AMSS_NEW.xls'];
        end
        if isempty(damfun_file)
            damfun_file = ['20150910' filesep 'DamageFunction_150910.xlsx'];
            % damfun_file = ['20150806' filesep 'DamageFunction_FL_2ndRUN.xlsx'];
            % consultant_data_damage_fun_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep '20150811_TC'];
        end
        if isempty(measures_file)
            measures_file = ['20150914' filesep 'measures_template_for_measures_location_A_B_2.xls'];
            %measures_file = ['20150914' filesep 'measures_template_for_measures_location_A_B_1.xls'];
            % measures_file = ['20150909' filesep 'Medidas parametrizadas_2m_150908 aumentada precio mejorad y mantenimiento.xlsx'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150818'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150828'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150901'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150903'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150909'];
        end
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

max_distance_to_hazard = 20;
entity = climada_assets_encode(entity,hazard,max_distance_to_hazard);
force_re_encode = 0;

% read damagefunctions
entity.damagefunctions = climada_damagefunctions_read([consultant_data_entity_dir filesep damfun_file]);

% check damage functions are defined for the given hazard intensity range
silent_mode= 1;
entity_out = climada_damagefunctions_check(entity,hazard,silent_mode);
entity.damagefunctions = entity_out.damagefunctions;

% read measures
entity.measures = climada_measures_read([consultant_data_entity_dir filesep 'measures' filesep measures_file]);

% entity.damagefunctions = climada_damagefunctions_read([consultant_data_damage_fun_dir filesep 'DamageFunction_FL_2ndRUN.xlsx']);
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
% entity.measures = climada_measures_read([consultant_data_measures_dir filesep 'Medidas parametrizadas_2m_150908 aumentada precio mejorad y mantenimiento.xlsx']);

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


%% calcualte measures impact
% entity.measures.hazard_intensity_impact_b = -entity.measures.hazard_intensity_impact;
sanity_check = 1;
% entity.assets = rmfield(entity.assets,'hazard');
measures_impact = climada_measures_impact(entity,hazard,'no','','',sanity_check);
measures_impact_filename = [results_dir filesep sprintf('measures_impact_%s_%s.mat',datestr(now,'YYYYmmdd'),nametag)];
% measures_impact_filename = [climada_global.project_dir filesep sprintf('measures_impact_%s_%s.mat',datestr(now,'YYYYmmdd'),nametag)];
save(measures_impact_filename,'measures_impact')

%% discounted benefits and costs (twice, once for USD, once for people)
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
    entity.discount.discount_rate = orig_discount_rate;
end


%% produce reports and figures
ED_filename = sprintf('ED_%s_%d_%s_cc_measures_%s_%s.xls', peril_ID, timehorizon,cc_scenario,datestr(now,'YYYYmmdd'),nametag);
xls_file = [results_dir filesep ED_filename];
% xls_file = [climada_global.project_dir filesep 'REPORTS' filesep ED_filename];
climada_EDS_ED_at_centroid_report_xls(measures_impact.EDS, xls_file, 'ED_at_centroid')
output_report = salvador_EDS_ED_per_category_report(entity, measures_impact.EDS, xls_file,'ED_per_category',1,1);

for u_i = 1:numel(unit_list)
       
    sheet_name = sprintf('Benefit_costs_%s',unit_list{u_i});
    output_report = climada_measures_impact_report(measures_impact_both(u_i),xls_file,sheet_name);

    fig = climada_figuresize(0.5,1.2);
    climada_adaptation_cost_curve(measures_impact_both(u_i),'',30,10)
    pdf_filename = sprintf('Adaptation_cost_curve_%s_2015_%s_%s.pdf',measures_impact_both(u_i).peril_ID,measures_impact_both(u_i).Value_unit,nametag);
    print(fig,'-dpdf',[results_dir filesep pdf_filename])
    %print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])
    
    % Jacob, please set xlim_value according to maximum benefit or costs if
    % measures 1 are calculated, otherwise set to empty
    xlim_value = '';
    sort_measures = 1;
    fig = climada_adaptation_bar_chart(measures_impact_both(u_i),'',sort_measures,'','',1,'','','',xlim_value);
    pdf_filename = sprintf('Adaptation_bar_chart_%s_2015_sorted_%s_%s.pdf',measures_impact_both(u_i).peril_ID,measures_impact_both(u_i).Value_unit,nametag);
    print(fig,'-dpdf',[results_dir filesep pdf_filename])
    %print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])
    
    sort_measures = 0;
    fig = climada_adaptation_bar_chart(measures_impact_both(u_i),'',sort_measures);
    pdf_filename = sprintf('Adaptation_bar_chart_%s_2015_%s_%s.pdf',measures_impact_both(u_i).peril_ID,measures_impact_both(u_i).Value_unit,nametag);
    print(fig,'-dpdf',[results_dir filesep pdf_filename])
    %print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])
    
    entity.discount.discount_rate = orig_discount_rate;
end

% ED_filename = sprintf('ED_%s_%d_%s_cc_measures_%s_orig.xls', peril_ID, timehorizon,cc_scenario,datestr(now,'YYYYmmdd'));
% output_report = salvador_EDS_ED_per_category_report(entity, EDS(1), [climada_global.project_dir filesep 'REPORTS' filesep ED_filename],'ED_per_category',0,0);



% % hazard frequency
% [sorted_damage,exceedence_freq,cumulative_probability,sorted_freq,event_index_out]=...
%     climada_damage_exceedence([1 2 3 4 5 6],hazard.frequency,[1 2 3 4 5 6]);




% %% adaptation cost curve (twice, once for USD, once for people)
% unit_criterium = '';
% category_criterium = '';
% [~,~,unit_list,category_criterium]...
%              = climada_assets_select(entity,hazard.peril_ID,unit_criterium,category_criterium);
% % entity.measures.color_RGB = jet(numel(entity.measures.name));
% orig_discount_rate = entity.discount.discount_rate;
% 
% for u_i = 1:numel(unit_list)
%     
%     climada_global.Value_unit = unit_list{u_i}; 
%     if strcmp(unit_list{u_i},'people')
%         entity.discount.discount_rate = orig_discount_rate*0;
%     end
%     measures_impact_both(u_i) = climada_measures_impact_discount(entity,measures_impact,'no','unit',unit_list{u_i});
%     measures_impact_both(u_i).Value_unit = unit_list{u_i};
%     
%     %sheet_name = sprintf('Benefit_costs_%s',unit_list{u_i});
%     %output_report = climada_measures_impact_report(measures_impact_both(u_i),xls_file,sheet_name);
% 
% %     fig = climada_figuresize(0.5,1.2);
% %     climada_adaptation_cost_curve(measures_impact_both(u_i),'',30,10)
% %     pdf_filename = sprintf('Adaptation_cost_curve_%s_2015_%s_%s.pdf',measures_impact_both(u_i).peril_ID,measures_impact_both(u_i).Value_unit,nametag);
% %     print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])
%     
%     sort_measures = 1;
%     fig = climada_adaptation_bar_chart(measures_impact_both(u_i),'',sort_measures);
%     pdf_filename = sprintf('Adaptation_bar_chart_%s_2015_%s_%s_sorted.pdf',measures_impact_both(u_i).peril_ID,measures_impact_both(u_i).Value_unit,nametag);
%     print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])
%     
%     entity.discount.discount_rate = orig_discount_rate;
% end


% fig = climada_adaptation_bar_chart(measures_impact_both(2),measures_impact_both(1),sort_measures);

% save(measures_impact_filename,'measures_impact_both')
% load(measures_impact_filename)






