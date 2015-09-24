function salvador_hazard_future_save(peril_ID)
% create future hazard for San Salvador (TC, LS_las_canas, LS_acelhuate)
% NAME:
%   salvador_hazard_future_save
% PURPOSE:
%   create and save future hazard for San Salvador, for TC, LS_las_canas,
%   LS_acelhuate, based on climada_global.future_reference_year and
%   salvador_LS_screw and salvador_TC_screw
% CALLING SEQUENCE:
%   salvador_hazard_future_save(peril_ID)
% EXAMPLE:
%   salvador_hazard_future_save
% INPUTS:
%   none, input is hardwired in the code
% OPTIONAL INPUT PARAMETERS:
%   peril_ID: default is 'TC'
% OUTPUTS:
%   none, hazards are created and saved in climada_global.project_dir
% RESTRICTIONS:
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20150923, init
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('peril_ID', 'var'), peril_ID = ''; end

% PARAMETERS
if isempty(peril_ID), peril_ID = 'TC'; end


% Create future hazards TC with climate screw
if strcmp(peril_ID,'TC')
    [screw_mod, screw_ext] = salvador_TC_screw;
    
    %moderate
    load([climada_global.project_dir filesep 'Salvador_hazard_TC_2015'])   
    hazard.reference_year = climada_global.present_reference_year;
    hazard = climada_hazard_climate_screw(hazard,'NO_SAVE',climada_global.future_reference_year,screw_mod);
    save([climada_global.project_dir filesep 'Salvador_hazard_TC_2040_moderate_cc'],'hazard');
    fprintf('Save hazard as %s\n', 'Salvador_hazard_TC_2040_moderate_cc')
    
    %extreme
    load([climada_global.project_dir filesep 'Salvador_hazard_TC_2015'])   
    hazard.reference_year = climada_global.present_reference_year;
    hazard = climada_hazard_climate_screw(hazard,'NO_SAVE',2040,screw_ext);
    save([climada_global.project_dir filesep 'Salvador_hazard_TC_2040_extreme_cc'],'hazard'); 
    fprintf('Save hazard as %s\n', 'Salvador_hazard_TC_2040_extreme_cc')
end


% Create future hazards LS with climate screw
if strcmp(peril_ID,'LS_las_canas') | strcmp(peril_ID,'LS_acelhuate') | strcmp(peril_ID,'LS')
    [screw_mod, screw_ext] = salvador_LS_screw;
    hazard_set_file = sprintf('Salvador_hazard_%s_%d.mat', peril_ID, climada_global.present_reference_year);
    
    % check if files already exist
    cc_scenario = 'moderate';
    hazard_set_file_moderate_cc = sprintf('Salvador_hazard_%s_%d_%s_cc.mat', peril_ID, climada_global.future_reference_year, cc_scenario);
    cc_scenario = 'extreme';
    hazard_set_file_extreme_cc = sprintf('Salvador_hazard_%s_%d_%s_cc.mat', peril_ID, climada_global.future_reference_year, cc_scenario);
    
    if ~exist([climada_global.project_dir filesep hazard_set_file_moderate_cc],'file') 
        % load today's hazard
        load([climada_global.project_dir filesep hazard_set_file])
        if ~exist('hazard','var') & exist('hazard_distance','var'), hazard = hazard_distance; end
        hazard.reference_year = climada_global.present_reference_year;
        if ~isfield(hazard,'category'), hazard.category(1:hazard.event_count) = 1; end
        if ~strcmp([climada_global.project_dir filesep hazard_set_file], hazard.filename)
            hazard.filename = [climada_global.project_dir filesep hazard_set_file];
            save(hazard.filename,'hazard')
            fprintf('Save hazard as %s\n', hazard_set_file)
        end    
    
        % create moderate cc 2040 if not exist
        hazard.reference_year = climada_global.present_reference_year;
        hazard.category(1:hazard.event_count) = 1;
        hazard = climada_hazard_climate_screw(hazard,'NO_SAVE',climada_global.future_reference_year,screw_mod);
        hazard.intensity(hazard.intensity>1) = 1.0;
        hazard.filename = [climada_global.project_dir filesep hazard_set_file_moderate_cc];
        save([climada_global.project_dir filesep hazard_set_file_moderate_cc],'hazard');
        fprintf('Save hazard as %s\n', hazard_set_file_moderate_cc)
    else
        fprintf('Hazard exists already (%s)\n', hazard_set_file_moderate_cc)
    end
    
    if ~exist([climada_global.project_dir filesep hazard_set_file_moderate_cc],'file') 
        % create extreme cc 2040 if not exist
        % load today's hazard
        load([climada_global.project_dir filesep hazard_set_file])
        hazard.reference_year = climada_global.present_reference_year;
        hazard = climada_hazard_climate_screw(hazard,'NO_SAVE',climada_global.future_reference_year,screw_ext);
        hazard.intensity(hazard.intensity>1) = 1;
        hazard.filename = [climada_global.project_dir filesep hazard_set_file_extreme_cc];
        save([climada_global.project_dir filesep hazard_set_file_extreme_cc],'hazard');
        fprintf('Save hazard as %s\n', hazard_set_file_extreme_cc)
    else
        fprintf('Hazard exists already (%s)\n', hazard_set_file_extreme_cc)
    end
end

