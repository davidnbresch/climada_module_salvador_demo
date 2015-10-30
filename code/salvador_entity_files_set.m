function [assets_file, damfun_file, measures_file, m_file] = salvador_entity_files_set(assets_file,damfun_file,measures_file,peril_ID,m_file)
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
% OPTIONAL INPUT PARAMETERS:
%   assets_file: empty
%   damfun_file: empty
%   measures_file: empty
%   peril_ID: default is 'TC'
%   m_file: string, e.g. 'AB1', to tage the measures version in case of FL
% OUTPUTS:
%   assets_file: filename of assets, e.g. '20150917_TC\entity_AMSS_WIND_NEW.xlsx' 
%   damfun_file: filename of damagefunctions
%   measures_file: filename of measures
% RESTRICTIONS:
% MODIFICATION HISTORY:
% Lea Mueller,  muellele@gmail.com, 20150924, init
% Jacob Anz,    j.anz@gmx.net,      20151020, added input m_file and cleanup
% Lea Mueller, muellele@gmail.com, 20151022, add m_file option
% Lea Mueller, muellele@gmail.com, 20151022, default m_file is '', only for FL it is 'AB1'
% Lea Mueller, muellele@gmail.com, 20151030, enable to select any entity/assets,damfun (uigetfile)
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('peril_ID', 'var'), peril_ID = ''; end
if ~exist('m_file', 'var'), m_file = ''; end
% PARAMETERS
if isempty(peril_ID), peril_ID = 'TC'; end
if isempty(m_file), m_file = ''; end

% project_dir is default, so probably we have an unexperienced user, where
% we want to ask where to find the data, instead of using the defaults
if strcmp(climada_global.project_dir, climada_global.data_dir)
    % prompt for entity_file if not given
    if isempty(assets_file) % local GUI
        assets_file = [climada_global.data_dir filesep 'entities' filesep '*.xls*'];
        [filename, pathname] = uigetfile(assets_file, 'Select entity (assets):');
        if isequal(filename,0) || isequal(pathname,0)
            return; % cancel
        else
            assets_file = fullfile(pathname,filename);
        end
    end
    
    if isempty(damfun_file) % local GUI
        damfun_file = [climada_global.data_dir filesep 'entities' filesep '*.xls*'];
        [filename, pathname] = uigetfile(damfun_file, 'Select damagefunction:');
        if isequal(filename,0) || isequal(pathname,0)
            return; % cancel
        else
            damfun_file = fullfile(pathname,filename);
        end
    end
    
    if isempty(measures_file) % local GUI
        measures_file = [climada_global.data_dir filesep 'entities' filesep '*.xls*'];
        [filename, pathname] = uigetfile(measures_file, 'Select measures:');
        if isequal(filename,0) || isequal(pathname,0)
            return; % cancel
        else
            measures_file = fullfile(pathname,filename);
        end
        
        if ~isempty(strfind(measures_file,'A_B_1'))
            m_file = 'AB1';
        elseif ~isempty(strfind(measures_file,'A_B_2'))
            m_file = 'AB2';
        end
    end

else

    switch peril_ID

        case 'FL'
            if isempty(assets_file)
                assets_file = ['20150916_FL' filesep 'entity_AMSS_FL.xls'];
            end
            if isempty(damfun_file)
                damfun_file = ['20150910_FL' filesep 'DamageFunction_150910.xlsx'];
            end
            if isempty(measures_file)
                if isempty(m_file), m_file = 'AB1';end
                if strcmp(m_file,'AB1')   
                    measures_file = ['20151015_FL' filesep 'measures_template_for_measures_location_A_B_1.xls'];
                elseif strcmp(m_file,'AB2')
                    measures_file = ['20151015_FL' filesep 'measures_template_for_measures_location_A_B_2.xls'];
                end
            end


        case 'TC'
            if isempty(assets_file)
                assets_file = ['20150925_TC' filesep 'entity_AMSS_WIND-AMSS_250915_v2.xlsx'];
            end
            if isempty(damfun_file)
                damfun_file = ['20150925_TC' filesep 'entity_AMSS_WIND-AMSS_250915_v2.xlsx'];
            end  

            if isempty(measures_file)
                measures_file=['20151014_TC' filesep 'entity_AMSS_WIND-AMSS_141015_FINAL_COSTS.xlsx'];
            end

        case 'LS_las_canas'
            if isempty(assets_file)
               %assets_file = ['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_LASCANAS_141015_NEW.xls'];
               assets_file = ['20150925_LS' filesep 'entity_AMSS_DESLIZAMIENTO_LAS_CANAS2.xls'];
            end 
            if isempty(damfun_file)
                damfun_file = ['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_ACELHUATE_141015_NEW.xls'];
            end
            if isempty(measures_file)
               % measures_file=['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_LASCANAS_141015_NEW.xls']; 
                measures_file=['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_LAS_CANAS2.xls'];
            end

        case 'LS_acelhuate'
            if isempty(assets_file)
               assets_file = ['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_ACELHUATE_141015_NEW.xls'];
            end 
            if isempty(damfun_file)
                damfun_file = ['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_ACELHUATE_141015_NEW.xls'];
            end
            if isempty(measures_file)
                measures_file=['20151014_LS' filesep 'entity_AMSS_DESLIZAMIENTO_ACELHUATE_141015_NEW.xls'];
            end

    end %switch peril_ID
end

fprintf('\t - assets: %s\n', assets_file)
fprintf('\t - damagefunctions: %s\n', damfun_file)
fprintf('\t - measures: %s\n', measures_file)







