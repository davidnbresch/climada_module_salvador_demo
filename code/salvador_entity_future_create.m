function entity = salvador_entity_future_create(entity, growth_rate_eco, growth_rate_people, peril_ID)
% create future entity for San Salvador
% NAME:
%   salvador_entity_future_create
% PURPOSE:
%   create and save future entity for San Salvador, based on a growth rate for USD
%   values and a growth rate for people, for the timespan from
%   climada_global.present_reference_year and climada_global.future_reference_year
% CALLING SEQUENCE:
%   entity = salvador_entity_future_create(entity, growth_rate_eco, growth_rate_people, peril_ID)
% EXAMPLE:
%   entity = salvador_entity_future_create
% INPUTS:
%   none, input is hardwired in the code
% OPTIONAL INPUT PARAMETERS:
%   entity: a climada entity structure
%   growth_rate_eco: default is 0.04 (4% per year)
%   growth_rate_people: default is 0.002 (0.2% per year)
%   peril_ID: default is 'FL'
% OUTPUTS:
%   entity, a climada entity structure with upscaled values (different for
%   USD and people values) for climada_global.future_reference_year
% RESTRICTIONS:
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20150924, init
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('entity', 'var'), entity = ''; end
if ~exist('growth_rate_eco', 'var'), growth_rate_eco = ''; end
if ~exist('growth_rate_people', 'var'), growth_rate_people = ''; end
if ~exist('peril_ID', 'var'), peril_ID = ''; end

% PARAMETERS
if isempty(growth_rate_eco), growth_rate_eco = 0.04; end
if isempty(growth_rate_people), growth_rate_people = 0.2/100; end
if isempty(peril_ID), peril_ID = 'FL'; end
if isempty(entity), entity = climada_entity_load; end

n_years = climada_global.future_reference_year - climada_global.present_reference_year+1;

% 2040, economic growth

% USD  
growth_factor_eco = (1+growth_rate_eco)^n_years;
[is_selected,peril_criterum,unit_criterium,category_criterium] = ...
       climada_assets_select(entity,peril_ID,'USD','');
entity.assets.Value(is_selected) = entity.assets.Value(is_selected) * growth_factor_eco;

% people
growth_factor_people = (1+growth_rate_people)^n_years;
[is_selected,peril_criterum,unit_criterium,category_criterium] = ...
       climada_assets_select(entity,peril_ID,'people','');
entity.assets.Value(is_selected) = entity.assets.Value(is_selected) * growth_factor_people;
entity.assets.reference_year = climada_global.future_reference_year;

% set new reference year
entity.assets.reference_year = climada_global.future_reference_year;

fprintf('\t - future entity (%d), *%1.2f econ. development, *%1.2f population growth \n',...
    climada_global.future_reference_year,growth_factor_eco, growth_factor_people)

% save new entity
[pathstr, name, ext] = fileparts(entity.assets.filename);
name_new = strrep(name,int2str(climada_global.present_reference_year),int2str(climada_global.future_reference_year));
entity.assets.filename = fullfile(pathstr, [name_new ext]);
save(entity.assets.filename,'entity')
fprintf('\t - save San Salvador future entity (%d) in %s\n', climada_global.future_reference_year, [name_new ext])
