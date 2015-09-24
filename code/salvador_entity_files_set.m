function [assets_file, damfun_file, measures_file] = salvador_entity_files_set(assets_file,damfun_file,measures_file,peril_ID)
% set assets_file, damfun_file and measures_file for San Salvador, depending on peril_ID
% NAME:
%   salvador_entity_files_set
% PURPOSE:
%   set assets_file, damfun_file and measures_file for San Salvador, depending on peril_ID
% CALLING SEQUENCE:
%   assets_file, damfun_file, measures_file] = salvador_entity_files_set(peril_ID,assets_file,damfun_file,measures_file)
% EXAMPLE:
%   assets_file, damfun_file, measures_file] = salvador_entity_files_set('TC','','','')
% INPUTS:
%   assets_file: empty
%   damfun_file: empty
%   measures_file: empty
% OPTIONAL INPUT PARAMETERS:
%   peril_ID: default is 'TC'
% OUTPUTS:
%   assets_file: filename of assets, e.g. '20150917_TC\entity_AMSS_WIND_NEW.xlsx' 
%   damfun_file: filename of damagefunctions
%   measures_file: filename of measures
% RESTRICTIONS:
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20150924, init
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('peril_ID', 'var'), peril_ID = ''; end

% PARAMETERS
if isempty(peril_ID), peril_ID = 'TC'; end


switch peril_ID
    case 'FL'
        if isempty(assets_file)
            assets_file = ['20150916_FL' filesep 'entity_AMSS_FL.xls'];
        end
        if isempty(damfun_file)
            damfun_file = ['20150910_FL' filesep 'DamageFunction_150910.xlsx'];
        end
        if isempty(measures_file)
            measures_file = ['20150918' filesep 'measures_template_for_measures_location_A_B_2.xls'];
            %measures_file = ['20150918' filesep 'measures_template_for_measures_location_A_B_1.xls'];
            %measures_file = ['20150914' filesep 'measures_template_for_measures_location_A_B_2.xls'];
            %measures_file = ['20150914' filesep 'measures_template_for_measures_location_A_B_1.xls'];
            % measures_file = ['20150909' filesep 'Medidas parametrizadas_2m_150908 aumentada precio mejorad y mantenimiento.xlsx'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150818'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150828'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150901'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150903'];
            % consultant_data_measures_dir = [fileparts(climada_global.project_dir) filesep 'consultant_data' filesep 'entity' filesep 'measures' filesep '20150909'];
        end

    case 'TC'
        if isempty(assets_file)
            assets_file = ['20150917_TC' filesep 'entity_AMSS_WIND_NEW.xlsx'];
        end
        if isempty(damfun_file)
            damfun_file = ['20150811_TC' filesep 'entity_AMSS_WIND-10ms.xlsx'];
        end  
        
    case 'LS_las_canas'
        if isempty(assets_file)
           assets_file = ['20150806_LS_las_canas' filesep 'entity_AMSS_DESLIZAMIENTO.xlsx'];
        end 
        if isempty(damfun_file)
            damfun_file = ['damage_functions' filesep 'entity_AMSS_DESLIZAMIENTO_NEW.xlsx'];
        end
        
    case 'LS_acelhuate'
        if isempty(assets_file)
           assets_file = ['20150921_LS_acelhuate' filesep 'entity_AMSS_LS_acelhuate.xls'];
        end 
        if isempty(damfun_file)
            damfun_file = ['20150921_LS_acelhuate' filesep 'entity_AMSS_LS_acelhuate.xls'];
        end
end

fprintf('\t - assets: %s\n', assets_file)
fprintf('\t - damagefunctions: %s\n', damfun_file)
fprintf('\t - measures: %s\n', measures_file)







