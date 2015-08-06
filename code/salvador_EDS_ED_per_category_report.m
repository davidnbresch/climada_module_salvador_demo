function output_report = salvador_EDS_ED_per_category_report(entity,EDS,xls_file,sheet)
% salvador_EDS_ED_per_category_report
% MODULE:
%   salvador_demo
% NAME:
%   salvador_EDS_ED_per_category_report
% PURPOSE:
%   Write out ED per category for one EDS structures into xls file
%   previous call: climada_EDS_calc, or climada_EDS_ED_at_centroid_report_xls
% CALLING SEQUENCE:
%   output_report = salvador_EDS_ED_per_category_report(entity,EDS,xls_file,sheet)
% EXAMPLE:
%   output_report = salvador_EDS_ED_per_category_report(entity,climada_EDS_calc(entity,hazard))
% INPUTS:
%   entity: climada entity structure, with fields entity.assets.Category and entity.assets.Unit
%   EDS: either an event damage set, as e.g. returned by climada_EDS_calc or
%       a file containing such a structure
%       SPECIAL: we also accept a structure which contains an EDS, like
%       measures_impact.EDS
%       if EDS has the field annotation_name, the legend will show this
%       > promted for if not given
% OPTIONAL INPUT PARAMETERS:
%   xls_file: filename (and path) to save the report to (as .xls), if
%       empty, prompted for.Can be set to 'NO_xls_file' to omit creation of
%       xls file instead only creates the cell "output_report"
%   sheet: sheet name for xls file, if empty, default excel name is "Sheet1"
% OUTPUTS:
%   output_report: cell including header and ED values
%   report file written as .xls
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20150806, init
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('entity'            ,'var'), entity             = []; end
if ~exist('EDS'     ,'var'),    EDS     =[];	end
if ~exist('xls_file','var'),    xls_file='';    end
if ~exist('sheet'   ,'var'),    sheet   ='';    end

% PARAMETERS

% prompt for entity if not given
if isempty(entity),entity = climada_entity_load;end
if isempty(entity),return;end

% prompt for EDS if not given
if isempty(EDS) % local GUI
    EDS=[climada_global.data_dir filesep 'results' filesep '*.mat'];
    [filename, pathname] = uigetfile(EDS, 'Select EDS:');
    if isequal(filename,0) || isequal(pathname,0)
        return; % cancel
    else
        EDS=fullfile(pathname,filename);
    end
end

% load the entity, if a filename has been passed
if ~isstruct(EDS)
    EDS_file=EDS;EDS=[];
    load(EDS_file);
end

if exist('measures_impact','var') % if a results file is loaded
    EDS=measures_impact.EDS;
end

if isfield(EDS,'EDS')
    EDS      = EDS.EDS;
end

% do not save in an xls_file
if ~strcmp(xls_file,'NO_xls_file')
    if isempty(xls_file)
        xls_file=[climada_global.data_dir filesep 'results' filesep 'ED_report.xls'];
        [filename, pathname] = uiputfile(xls_file, 'Save ED at centroid report as:');
        if isequal(filename,0) || isequal(pathname,0)
            xls_file='';
        else
            xls_file=fullfile(pathname,filename);
        end
    end
end

%% check that field Category exists
if ~isfield(entity.assets,'Category')
    fprintf('No Category field in entity.assets. Unable to proceed. \n')
    return
end

% get all categories for this peril ID
unit_criterium = '';
category_criterium = '';
[is_selected,~,unit_list,category_criterium]...
             = salvador_assets_select(entity,EDS.peril_ID,unit_criterium,category_criterium);
if ~any(is_selected)    
    fprintf('Invalid selection. \n'),return
end  

header_row    = 1;
output_report = cell(numel(category_criterium)+numel(unit_list)+header_row,4);

% set header names
output_report{1,1} = 'Category';
output_report{1,2} = sprintf('Total values (%s)',sprintf('%s ',unit_list{:}));
output_report{1,3} = sprintf('Total damages (%s)',sprintf('%s ',unit_list{:}));
output_report{1,4} = sprintf('Total damages (%%)');
output_report{1,5} = 'Unit';
output_report{1,6} = 'Peril ID';

for c_i = 1:numel(category_criterium)
    [is_selected,peril_criterum,unit_criterium] =...
        salvador_assets_select(entity,EDS.peril_ID,'',category_criterium(c_i));
    if any(is_selected)   
        output_report(c_i+1,1) = num2cell(category_criterium(c_i));
        output_report(c_i+1,2) = num2cell(sum(entity.assets.Value(is_selected)));
        output_report(c_i+1,3) = num2cell(sum(EDS.ED_at_centroid(is_selected)));
        output_report(c_i+1,4) = num2cell(sum(EDS.ED_at_centroid(is_selected))...
                                         /sum(entity.assets.Value(is_selected)));
        output_report{c_i+1,5} = unit_criterium{1};       
        output_report{c_i+1,6} = peril_criterum; 
    end  
end %c_i 

for u_i = 1:numel(unit_list)
    [is_selected,peril_criterum,unit_criterium,category_criterium] =...
        salvador_assets_select(entity,EDS.peril_ID,unit_list{u_i},'');
    if any(is_selected)   
        output_report{c_i+u_i+1+1,1} = sprintf('%d, ',category_criterium);
        output_report(c_i+u_i+1+1,2) = num2cell(sum(entity.assets.Value(is_selected)));
        output_report(c_i+u_i+1+1,3) = num2cell(sum(EDS.ED_at_centroid(is_selected)));
        output_report(c_i+u_i+1+1,4) = num2cell(sum(EDS.ED_at_centroid(is_selected))...
                                               /sum(entity.assets.Value(is_selected)));
        output_report{c_i+u_i+1+1,5} = unit_list{u_i};       
        output_report{c_i+u_i+1+1,6} = peril_criterum; 
    end  
end

% do not save in an xls_file
if ~strcmp(xls_file,'NO_xls_file')
  
    warning('off','MATLAB:xlswrite:AddSheet'); % suppress warning message
    try
        xlswrite(xls_file,output_report,sheet)
    catch
        % probably too large for old excel, try writing to .xlsx instead
        try
            xlsx_file = [xls_file 'x'];
            xlswrite(xlsx_file,output_report,sheet)
        catch
            % probably too large for new excel, write to textfile instead
            cprintf([1 0 0],'FAILED\n')
            fprintf('attempting to write to text file instead... ')
            txt_file = strrep(xlsx_file,'.xlsx','.txt');
            writetable(cell2table(output_report),txt_file)
            fclose all;
        end
    end

    fprintf('done\n')
    fprintf('report written to sheet %s of %s\n',sheet,xls_file);
    
end

return
