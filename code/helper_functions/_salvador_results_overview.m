function filepath=salvador_results_overview
% NAME:
%   salvador_results_overview
% PURPOSE:
%   Create summary report of all hazards based on the saved EDS
% CALLING SEQUENCE:
%   none
% EXAMPLE:
%   salvador_results_overview
% INPUTS:
%   none
% OPTIONAL INPUT PARAMETERS:
%   none
% OUTPUTS:
%   printed excel file
% RESTRICTIONS:
% MODIFICATION HISTORY:
% Jacob Anz, j.anz@gmx.net,20150929, init
% Lea Mueller, muellele@gmail.com, 20151106, rename to climada_EDS_ED_per_category_report from salvador_EDS_ED_per_category_report


%load the different EDS for the different perils
%Code is preassigened for a maximum of 4 different EDS sets (perils/areas)
peril_container{1}='_FL';       peril_ID{1}='FL';
peril_container{2}='_TC';       peril_ID{2}='TC';
peril_container{3}='_LS_ace';   peril_ID{3}='LS';
peril_container{4}='_LS_can';   peril_ID{4}='LS';



path='N:\RM\sustainability\SanSalvador\salvador_climada_data\!waterfall up to date';
results_dir=path;
listing = dir(path);

for k=1:length(peril_container)
    for i=1:length(listing)
        if findstr(listing(i).name,peril_container{k})
            path_mat=[path filesep listing(i).name];
            listing_mat = dir(path_mat);
            for j=1:length(listing_mat)
                if findstr(listing_mat(j).name, '.mat')
                  path_mat_file{k}= [path_mat filesep listing_mat(j).name];   
                end
            end
        end    
    end
end


nametag='summary';
benefit_flag = 0;
assets_flag = 1;
output_container{1}=[];output_container{2}=[];output_container{3}=[];output_container{4}=[];

for i=1:length(path_mat_file)
    load(path_mat_file{i})          %loads EDS
    load(EDS(1).assets.filename)    %loads original entity
    
    xls_file = [results_dir filesep 'ED_' peril_ID{i} '_2015_2040_' datestr(now,'YYYYmmdd') '_' nametag '.xlsx'];
    output_report = climada_EDS_ED_per_category_report_summary(entity, EDS, xls_file,'ED_per_category',benefit_flag,0,assets_flag);
    output_container{i}=output_report;
    clear output_report xls_file EDS entity
end

output_report=[output_container{1};output_container{2};output_container{3};output_container{4}];

%write to excel
xls_file = [results_dir filesep 'ED_all_perils_2015_2040_' datestr(now,'YYYYmmdd') '_' nametag '.xlsx'];
sheet='ED_per_category';
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
filepath=xls_file;
end
