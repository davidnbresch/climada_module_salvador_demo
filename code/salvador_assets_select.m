function is_selected = salvador_assets_select(entity,peril_criterum,unit_criterium, category_criterium)
%  Create a selection array to select a subset of asset locations
% MODULE:
%   salvador_demo
% NAME:
%   salvador_entity_selection
% PURPOSE:
%   Create a selection array to select a subset of asset locations, that
%   match a peril, a unit and a category (e.g. FL, USD, Category 7). Selected assets must fullfil ALL
%   criterias. However empty criterium will select all assets.
% CALLING SEQUENCE:
%   is_selected = salvador_entity_selection(entity,peril_criterum,unit_criterium, category_criterium)
% EXAMPLE:
%   is_selected = salvador_entity_selection(entity,'FL','USD',6)
% INPUTS:
% OPTIONAL INPUT PARAMETERS:
%   entity:  climada entity structure, with fields entity.assets.Unit
%            and entity.damagefunctions.peril_ID
%   peril_criterum: a string, e.g. 'FL' or 'TC'
%   unit_criterium: a string, e.g. 'USD' or 'people'
%   category_criterium: a string or a number, e.g. 7
% OUTPUTS:
%   is_selected: a logical array that points to the selected asset locations
% MODIFICATION HISTORY:
%   Lea Mueller, muellele@gmail.com, 20150730
% -


% poor man's version to check arguments
if ~exist('entity'            ,'var'), entity             = []; end
if ~exist('peril_criterum'    ,'var'), peril_criterum     = []; end
if ~exist('unit_criterium'    ,'var'), unit_criterium     = []; end
if ~exist('category_criterium','var'), category_criterium = []; end

% prompt for entity if not given
if isempty(entity            ), entity             = climada_entity_load; end
if isempty(peril_criterum    ), peril_criterum     = ''; end    
if isempty(unit_criterium    ), unit_criterium     = ''; end 
if isempty(category_criterium), category_criterium = ''; end 

is_selected = logical(entity.assets.lon); %init
is_unit     = logical(entity.assets.lon);
is_category = logical(entity.assets.lon);


% find peril in entity.damagefunctions.peril_ID
if ~isempty(peril_criterum)
    if isfield(entity, 'damagefunctions')
        if isfield(entity.damagefunctions, 'peril_ID')
            is_peril    = strcmp(entity.damagefunctions.peril_ID,peril_criterum);
            selected_damagefunctionID = unique(entity.damagefunctions.DamageFunID(is_peril));
            is_selected = ismember(entity.assets.DamageFunID,selected_damagefunctionID);
        end
    end
end

% find unit in entity.assets.Unit
if ~isempty(unit_criterium)
    if isfield(entity.assets, 'Unit')
        is_unit = strcmp(entity.assets.Unit, unit_criterium);
    end
end

% find category in entity.assets.Category
if ~isempty(category_criterium)
    if isfield(entity.assets, 'Category')
        if ischar(category_criterium)
            is_category  = strcmp(entity.assets.Category, category_criterium);
        elseif isnumeric(category_criterium)
            is_category  = ismember(entity.assets.Category, category_criterium);
            category_criterium = num2str(category_criterium);
        end
    end
end


% combine the three logical arrays, selected assets must fullfil ALL
% criterias
is_selected = logical(is_selected .* is_unit .* is_category);

fprintf('%d locations selected (%s, %s, %s)\n',sum(is_selected),peril_criterum, unit_criterium, category_criterium)

