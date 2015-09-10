function output_report = salvador_EDS_ED_per_category_report(entity,EDS,xls_file,sheet,benefit_flag, percentage_flag)
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
% Lea Mueller, muellele@gmail.com, 20150831, introduce benefit_flag to calculate benefit (difference AED with measure and AED without measure)
% Lea Mueller, muellele@gmail.com, 20150831, rename climada_assets_select from salvador_assets_select
% Lea Mueller, muellele@gmail.com, 20150831, enhance to cope with multiple EDS
% Lea Mueller, muellele@gmail.com, 20150910, enhance to cope with Category names (cell) instead of numbers
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('entity'            ,'var'), entity             = []; end
if ~exist('EDS'     ,'var'),    EDS     =[];	end
if ~exist('xls_file','var'),    xls_file='';    end
if ~exist('sheet'   ,'var'),    sheet   ='';    end
if ~exist('benefit_flag','var'),benefit_flag = 1; end
if ~exist('percentage_flag','var'),percentage_flag = 0; end


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

category_cell= 0;
if iscell(entity.assets.Category(1))
    category_cell = 1;
end
    
% get all categories for this peril ID
% use EDS(1) to get all categories
unit_criterium = '';
category_criterium = '';
[is_selected,~,unit_list,category_criterium]...
             = climada_assets_select(entity,EDS(1).peril_ID,unit_criterium,category_criterium);
if ~any(is_selected)    
    fprintf('Invalid selection. \n'),return
end  

% check units
unit_on = 1; %init
if isempty(unit_list)
    unit_list = {'Unit'};
    unit_on = 0;
end

header_row    = 1;
static_column_no = 6;
output_report = cell(numel(category_criterium)+numel(unit_list)+header_row,static_column_no);

% additional information below the table
row_no = numel(category_criterium)+numel(unit_list)+6;
output_report{row_no+1,1} = 'Further information';
output_report{row_no+2,1} = 'AED';
output_report{row_no+2,2} = ' = Annual expected damage';
output_report{row_no+3,1} = 'Benefit';
output_report{row_no+3,2} = ' = Averted damage = AED control - AED with a specific measure';
output_report{row_no+4,1} = 'Benefit in percentage ';
output_report{row_no+4,2} = 'in relation to AED control, this is to describe the efficiency of a measure';


% set header names
output_report{1,1} = 'Category';
output_report{1,2} = sprintf('Total values (%s)',sprintf('%s ',unit_list{:}));
output_report{1,3} = 'Value unit';
output_report{1,4} = 'Peril ID';
output_report{1,5} = sprintf('AED %s (%s)', EDS(end).annotation_name, sprintf('%s ',unit_list{:}));
output_report{1,6} = sprintf('AED %s (%%)', EDS(end).annotation_name);


EDS_no = numel(EDS);
if percentage_flag == 1
    variable_column_no = 2;
else
    variable_column_no = 1;
end
for EDS_i = 1:EDS_no
    column_position = static_column_no + (EDS_i-1)*variable_column_no;
    if benefit_flag == 1
        output_report{1,column_position+1} = sprintf('Benefit %s (%s)', EDS(EDS_i).annotation_name, sprintf('%s ',unit_list{:}));
        if percentage_flag == 1
            output_report{1,column_position+2} = sprintf('Benefit %s (%%)', EDS(EDS_i).annotation_name);
        end
    else
        output_report{1,column_position+1} = sprintf('AED %s (%s)', EDS(EDS_i).annotation_name, sprintf('%s ',unit_list{:}));
        if percentage_flag == 1
            output_report{1,column_position+2} = sprintf('AED %s (%%)', EDS(EDS_i).annotation_name);
        end
    end
end

% single_Value_col = 1; 
% sim_ndx = ones(1,length(EDS(1).assets.filename)); % init
% for e_i = 1:length(EDS)
%     if any(EDS(e_i).assets.Value ~= EDS(1).assets.Value),    single_Value_col = 0;   end
% %     sim_ndx = sim_ndx & (EDS(e_i).assets.filename == EDS(1).assets.filename);
% end

% loop over EDS (mutliple measures, the end measure is the baseline/control scenario)
for EDS_i = 1:EDS_no
    % loop over different categories
    for c_i = 1:numel(category_criterium)
        %[is_selected,peril_criterum,unit_criterium] = climada_assets_select(entity,EDS(EDS_i).peril_ID,'',category_criterium(c_i));
        [is_selected,peril_criterum,unit_criterium] =...
            climada_assets_select(entity,EDS(EDS_i).peril_ID,'',category_criterium(c_i));
        if any(is_selected)  
            if EDS_i==1 % fill static columns
                if category_cell
                    output_report{c_i+1,1} = category_criterium{c_i};
                else
                    output_report(c_i+1,1) = num2cell(category_criterium(c_i));
                end
                output_report(c_i+1,2) = num2cell(sum(entity.assets.Value(is_selected)));
                if ~isempty(unit_criterium); output_report{c_i+1,3} = unit_criterium{1};end      
                if ~isempty(peril_criterum); output_report{c_i+1,4} = peril_criterum;end
                output_report(c_i+1,5) = num2cell(sum(EDS(end).ED_at_centroid(is_selected)));
                output_report(c_i+1,6) = num2cell(sum(EDS(end).ED_at_centroid(is_selected))...
                                                              /sum(entity.assets.Value(is_selected)));
            end  
            % write variable columns for all EDS_i/measures
            column_position = static_column_no + (EDS_i-1)*variable_column_no;
            if benefit_flag == 1
                benefit = sum(EDS(end).ED_at_centroid(is_selected)) - sum(EDS(EDS_i).ED_at_centroid(is_selected));
                benefit_percentage = benefit / sum(EDS(end).ED_at_centroid(is_selected));
                output_report(c_i+1,column_position+1) = num2cell(benefit);   
                if percentage_flag == 1
                    output_report(c_i+1,column_position+2) = num2cell(benefit_percentage);
                end
            else
                output_report(c_i+1,column_position+1) = num2cell(sum(EDS(EDS_i).ED_at_centroid(is_selected)));
                if percentage_flag == 1
                    output_report(c_i+1,column_position+2) = num2cell(sum(EDS(EDS_i).ED_at_centroid(is_selected))...
                                                              /sum(entity.assets.Value(is_selected)));
                end
            end
        end  
    end %c_i 
end

if unit_on
    for EDS_i = 1:EDS_no
        for u_i = 1:numel(unit_list)
            [is_selected,peril_criterum,unit_criterium,category_criterium] =...
                climada_assets_select(entity,EDS(EDS_i).peril_ID,unit_list{u_i},'');
            if any(is_selected)
                if EDS_i==1
                    output_report{c_i+u_i+1+1,1} = sprintf('%d, ',category_criterium);
                    output_report(c_i+u_i+1+1,2) = num2cell(sum(entity.assets.Value(is_selected)));
                    output_report{c_i+u_i+1+1,3} = unit_list{u_i};       
                    output_report{c_i+u_i+1+1,4} = peril_criterum; 
                    output_report(c_i+u_i+1+1,5) = num2cell(sum(EDS(end).ED_at_centroid(is_selected)));
                    output_report(c_i+u_i+1+1,6) = num2cell(sum(EDS(end).ED_at_centroid(is_selected))...
                                                                           /sum(entity.assets.Value(is_selected)));
                end
                column_position = static_column_no + (EDS_i-1)*variable_column_no;
                if benefit_flag == 1
                    % benefit per measures (averted AED)
                    benefit = sum(EDS(end).ED_at_centroid(is_selected)) - sum(EDS(EDS_i).ED_at_centroid(is_selected));
                    benefit_percentage = benefit / sum(EDS(end).ED_at_centroid(is_selected));
                    output_report(c_i+u_i+1+1,column_position+1) = num2cell(benefit);   
                    if percentage_flag == 1
                        output_report(c_i+u_i+1+1,column_position+2) = num2cell(benefit_percentage);
                    end
                else
                    % AED with measure
                    output_report(c_i+u_i+1+1,column_position+1) = num2cell(sum(EDS(EDS_i).ED_at_centroid(is_selected)));
                    if percentage_flag == 1
                        output_report(c_i+u_i+1+1,column_position+2) = num2cell(sum(EDS(EDS_i).ED_at_centroid(is_selected))...
                                                                               /sum(entity.assets.Value(is_selected)));
                    end
                end
            end  
        end
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
