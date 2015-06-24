function hazard = salvador_hazard_read


global climada_global % access to global variables
if ~climada_init_vars,return;end % init/import global variables


%% set names
hazard_names = {'flood_depth'}; 

%climate change scenario
cc_scenario = {'no change'}; 
% cc_scenario = {'no change' 'moderate' 'extreme'}; 

%timehorizon
timehorizon = [2015 2030 2050];

% set foldername
% foldername = 'M:\BGCC\CHR\RK\RS\A_Sustainable_Development\Projects\ECA\SanSalvador\consultant_data\hazards\inundation\';
foldername = 'M:\BGCC\CHR\RK\RS\A_Sustainable_Development\Projects\ECA\SanSalvador\consultant_data\hazards\inundation\rio_acelhuate\';



%% loop over hazards
for h_i = 1:length(hazard_names)
    hazard_name = hazard_names{h_i};
    
    switch hazard_name
        case 'flood_depth';
            filename = 'TR2A0.asc';
            units = 'mm';
            hazard_set_file = [climada_global.data_dir filesep 'hazards' filesep 'Salvador_Garrobo_hazard_FL_depth'];
            
        %case 'flood_depth_cyclone';
        %    filename = 'CycloneMaxInundationDepths1988.asc';  
        %    units = 'm';
        %    hazard_set_file = [climada_global.data_dir filesep 'hazards' filesep 'Barisal_BCC_hazard_FL_depth_cyclone'];
            
        %case 'flood_duration_monsoon';
        %    filename = 'MonsoonMaxInundationDurations1983.asc';
        %    units = 'days';
        %    hazard_set_file = [climada_global.data_dir filesep 'hazards' filesep 'Barisal_BCC_hazard_FL_duration_monsoon'];
            
        %case 'flood_duration_cyclone';
        %    filename = 'CycloneMaxInundationDurations1988.asc';
        %    units = 'days';
        %    hazard_set_file = [climada_global.data_dir filesep 'hazards' filesep 'Barisal_BCC_hazard_FL_duration_cyclone'];
    end   
    
    % loop over climate change scenarios
    for cc_i = 1:length(cc_scenario)
        switch cc_scenario{cc_i}
            case 'no change'
                folder_ = '';
                reference_year = 2015;
                hazard_set_file_ = sprintf('%s_%d.mat',hazard_set_file,2015);
                
            %case 'moderate'
            %    folder_ = 'Floods_2030_CCMod\';
            %    reference_year = 2030;
            %    hazard_set_file_ = sprintf('%s_cc_%d_%s.mat',hazard_set_file,reference_year,cc_scenario{cc_i});
                 
            %case 'extreme'
            %    folder_ = 'Floods_2030_CCHigh\';
            %    reference_year = 2030;
            %    hazard_set_file_ = sprintf('%s_cc_%d_%s.mat',hazard_set_file,reference_year,cc_scenario{cc_i});
        end
        
        % read hazard from asci-file
        hazard = climada_asci2hazard([foldername folder_ filename],6,'salvador');
        hazard = climada_asci2hazard('',6,'salvador');
        
        %for garrobo
        %hazard2 = climada_asci2hazard([foldername folder_ 'AGATHA0.asc'],6);
        %hazard3 = climada_asci2hazard([foldername folder_ 'DT12E0.asc'],6);
        %hazard4 = climada_asci2hazard([foldername folder_ 'IDA0.asc'],6);
        % reordering
        %indx_order = [4 6 2 3 5 1];
        %frequency  = 1./[2 5 10 25 50 100];
        
        %for acelhuate
        %hazard2 = climada_asci2hazard([foldername folder_ 'MAPA_AGATHA0.asc'],6);
        %hazard3 = climada_asci2hazard([foldername folder_ 'MAPA_DT12E0.asc'],6);
        %hazard4 = climada_asci2hazard([foldername folder_ 'MAPA_IDA00.asc'],6);
        %hazard5 = climada_asci2hazard([foldername folder_ 'BUS_ELIMI0.asc'],6);
        % reordering
        indx_order = [5 7 2 3 4 6 1];
        frequency  = 1./[2 5 10 20 25 50 100];
        
        % reordering
        hazard.intensity_ori = hazard.intensity;
        hazard.name_ori      = hazard.name;
        for i=1:6
            hazard.intensity(i,:) = hazard.intensity_ori(indx_order(i),:);
            hazard.frequency(i)   = frequency(i);
            hazard.name(i)        = hazard.name_ori(indx_order(i));
        end
        % fill special fields
        hazard.filename = hazard_set_file_;
        hazard.comment  = sprintf('Modelled by MARN, %s, %s', hazard_name, cc_scenario{cc_i});
        hazard.reference_year = reference_year;
        hazard.peril_ID = 'FL';
        hazard.units    = units;
        
        % add additional rain events
        %hazard.intensity(end+1,:) = hazard2.intensity;
        %hazard.intensity(end+1,:) = hazard3.intensity;
        %hazard.intensity(end+1,:) = hazard4.intensity;
        %hazard.intensity(end+1,:) = hazard5.intensity;
        %hazard.name{end+1} = 'Agatha';
        %hazard.name{end+1} = 'DT12E';
        %hazard.name{end+1} = 'Ida';
        %hazard.name{end+1} = 'Bus eliminado';
        %hazard.frequency(7:9) = 1/50;
        hazard.orig_years  = 100;
        hazard.event_count = 7; %9
        hazard.event_ID    = 1:hazard.event_count;
        hazard.orig_event_count = hazard.event_count;
        hazard.orig_event_flag  = ones(size(hazard.frequency));
        %hazard.datenum(7:9)     = datenum({'29 May 2010' '10 Oct 2011' '4 Nov 2009'});
        %for j = 7:9
        %    hazard.yyyy(j) = str2num(datestr(hazard.datenum(j),'YYYY'));
        %    hazard.mm(j)   = str2num(datestr(hazard.datenum(j),'mm'));
        %    hazard.dd(j)   = str2num(datestr(hazard.datenum(j),'dd'));
        %end
        % divide intensity by 100, so that we have meters
        %hazard.intensity  = hazard.intensity/100;
        hazard = rmfield(hazard,'name_ori');
        hazard = rmfield(hazard,'intensity_ori');
        save(hazard_set_file_, 'hazard'); 
        fprintf('\nHazard saved as %s\n',hazard_set_file_)
    end

end

%%





