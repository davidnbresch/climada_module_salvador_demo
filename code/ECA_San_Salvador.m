function [hazard_sets,EDS,centroids,entity]=ECA_San_Salvador(admin_name,...
    adm_lvl,force_centroids_recalc,force_entity_recalc,force_hazard_recalc, check_plots)
% climada
% MODULE:
% NAME:
%   ECA_hazard_analysis
% PURPOSE:
%   calculate hazard event sets for desired peril for any region of any
%   country in the world...
% CALLING SEQUENCE:
%   [hazard, EDS, centroids, entity] = ECA_hazard_analysis
% EXAMPLE:
% INPUTS:
% OPTIONAL INPUT PARAMETERS:
%   adm_lvl: Specify the admin level of interest
%       Default:set to level 2
%   force_centroids_entity_recalc: Automatically set to 0. Set to 1 if you
%       wish to recalculate the centroids and entity, despite the relevant
%       files already existing - calculation will take longer.
%   force_hazard_recalc: Automatically set to 0. Set to 1 if you
%       wish to recalculate the hazards, despite the relevant
%       files already existing - calculation will take longer.
% OUTPUTS:
%   hazard_sets:    Struct with fields for each peril, e.g.
%             .TS:    Storm surge hazard set (with usual fields)
%             .TC:    Tropical cyclone hazard set
%   EDS:            Struct with fields for each peril, e.g.
%             .TS:    Storm surge event damage set
%             .TC:    Tropical cyclone event damage set
%   centroids:  High resolution centroids
%   entity:     High resolution entity
% MODIFICATION HISTORY:
% Gilles Stassen, gillesstassen@hotmail.com, 20150508 init
%-

hazard_sets=[]; EDS = []; centroids = []; entity = []; % init output

global climada_global
if ~climada_init_vars(1),return;end % init/import global variables

% Check input variables
if ~exist('admin_name',             'var'),	admin_name = '';                    end
if ~exist('adm_lvl',                'var'),	adm_lvl='';                         end
if ~exist('force_entity_recalc',    'var'),	force_entity_recalc = 0;            end
if ~exist('force_centroids_recalc', 'var'),	force_centroids_recalc = 0;         end
if ~exist('force_hazard_recalc',    'var'),	force_hazard_recalc = 0;            end
if ~exist('check_plots',            'var'),	check_plots = 1;                    end

% PARAMETERS
%
% set global variables (be careful, they should be reset, see bottom of code)

if ~isfield(climada_global,'climada_global_ori')
    climada_global.climada_global_ori = climada_global; % store for reset
end
climada_global.EDS_at_centroid = 1;
climada_global.waitbar = 0; % suppress waitbar
climada_global.tc.default_min_TimeStep = 1/4;
%
% the module's data folder:
module_data_dir=[fileparts(fileparts(mfilename('fullpath'))) filesep 'data'];
%
% country info
[country_name, ISO3, country_shape_ndx] = climada_country_name('El Salvador');
%
% the shape file with higher resolution for country
country_shapefile=[module_data_dir filesep 'system' filesep ISO3 '_adm' filesep ISO3 '_adm0.shp'];
%
% The shape file with detailed border info
admin_regions_shapefile = [module_data_dir filesep 'system' filesep ISO3 '_adm' filesep ISO3 '_adm' num2str(adm_lvl) '.shp'];
%
% If we want to add geographical details to the entity plot, set to 1
details_check = 0;
%
% name of the tropical cyclone track file:
tc_track_region = 'atl';
tc_track_file   = ['tracks.' tc_track_region '.txt'];
%
% Define whether we run the simulation using only historical tracks, or
% generate the full probabilistic TC hazard
probabilistic = 1;

[admin_name,admin_shapes,country_shapes,location] = climada_admin_name(country_name,admin_name,adm_lvl);
centroids_rect =[min(admin_shapes.X) max(admin_shapes.X) min(admin_shapes.Y) max(admin_shapes.Y)];

[fP,fN] = fileparts(admin_regions_shapefile);
admin_regions_matfile = [fP filesep fN '.mat']; % for plotting

garrobo_shapefile = [module_data_dir filesep 'system' filesep 'garrobo.shp'];
garrobo_shapes = climada_shaperead(garrobo_shapefile);
[garrobo_shapes.X,garrobo_shapes.Y] = utm2ll_salvador(garrobo_shapes.X,garrobo_shapes.Y);
[garrobo_shapes.x,garrobo_shapes.y] = utm2ll_salvador(garrobo_shapes.x,garrobo_shapes.y);

% 1) Centroids for study region
% -----------------------------
% Define the file with centroids (geo-locations of the points we later
% evaluate and store storm surge heights at), as well as the entity file
% directories.
% see climada_create_GDP_entity to create centroids file
admin_name_lvl  =   [strrep(admin_name,' ','_') '_',num2str(adm_lvl)];
centroids_file  =   [module_data_dir filesep 'system' filesep admin_name_lvl '_centroids.mat'];
% entity_file     =   [module_data_dir filesep 'entities' filesep admin_name_lvl '_entity.mat'];
entity_file     =   [module_data_dir filesep 'entities' filesep 'entity_AMSS.mat'];
% entity_file_xls =   [module_data_dir filesep 'entities' filesep admin_name_lvl '_entity.xls'];
entity_file_xls =   [module_data_dir filesep 'entities' filesep 'entity_AMSS.xls'];

% 2) Tropical cyclone (TC) tracks
% -------------------------------
% Set UNISYS TC track data file (for info, see climada_tc_read_unisys_database)
unisys_file     = [climada_global.data_dir filesep 'tc_tracks' filesep tc_track_file];

% 3) Bathymetry parameters are set in tc_surge_hazard_create
DEM_img_file    = [module_data_dir filesep 'system' filesep 'dem-MUNICIPIOSll.txt'];
DEM_save_file   = [module_data_dir filesep 'system' filesep strcat(strrep(admin_name,' ','_'),'_',num2str(adm_lvl),'_DEM.mat')];

% 4) Surge hazard event set
% -------------------------
% Define the hazard event set file to store the admin region TC and TS hazard
% event sets
hazard_set_file_tc = [module_data_dir filesep 'hazards' filesep admin_name_lvl '_hazard_TC.mat'];
hazard_set_file_ts = [module_data_dir filesep 'hazards' filesep admin_name_lvl '_hazard_TS.mat'];
hazard_set_file_tr = [module_data_dir filesep 'hazards' filesep admin_name_lvl '_hazard_TR.mat'];
hazard_set_file_rf = [module_data_dir filesep 'hazards' filesep admin_name_lvl '_hazard_RF.mat'];
hazard_set_file_fl = [module_data_dir filesep 'hazards' filesep admin_name_lvl '_hazard_FL.mat'];
hazard_set_file_ms = [module_data_dir filesep 'hazards' filesep admin_name_lvl '_hazard_MS.mat'];
hazard_set_file_eq = [module_data_dir filesep 'hazards' filesep admin_name_lvl '_hazard_EQ.mat'];
hazard_set_file_vq = [module_data_dir filesep 'hazards' filesep admin_name_lvl '_hazard_VQ.mat'];
% M:\BGCC\CHR\RK\RS\A_Sustainable_Development\Projects\ECA\SanSalvador\consultant_data\Info_base_de_datos_DACGER\shape_AUPs
% CALCULATIONS
% ==============
% 1) Read the centroids
% ---------------------

% Load existing centroids and entity files if it exists, and unless user
% specifies to recaulculate the centroids & entity
if isempty(force_centroids_recalc)
    force_centroids_recalc=0;
elseif force_centroids_recalc == 1 && force_hazard_recalc == 0
    cprintf([0.25 0.25 1],'NOTE: recalculation of centroids mandates regeneration of hazard sets \n');
    force_hazard_recalc = 1;
end

if exist(centroids_file,'file') &&  ~force_centroids_recalc
    fprintf('loading centroids from %s \n',centroids_file)
    load(centroids_file)    % load centroids
    fprintf('loading digital elevation model from %s \n', DEM_save_file)
    load(DEM_save_file)     % load DEM
else
    % Get high resolution centroids for admin region
    centroid_resolution_km  = [0.100 0.090];
    % output from geodistance in m, hence division by 1000 for conversion to km
    clear centroid_number_UB length_x length_y
    
%     centroids = climada_generate_centroids(admin_shapes,centroid_resolution_km(adm_lvl),-1,'NO_SAVE',0);
    centroids = climada_generate_centroids(garrobo_shapes,centroid_resolution_km(adm_lvl),0,'NO_SAVE',0);
    [DEM, centroids] = climada_read_srtm_DEM('DL',centroids, DEM_save_file, 1, 0);

    % 10m resolution DEM for San Salvador
    if ~exist(DEM_save_file,'file')
        DEM     = climada_ascii_read(DEM_img_file,1);
        fprintf('saving DEM to %s\n',DEM_save_file)
        save(DEM_save_file,'DEM') % faster later
    else
        fprintf('loading DEM from %s\n',DEM_save_file)
        load(DEM_save_file)
    end
    
    % crop to rect
    lon_crop_ndx    = centroids_rect(1) <= DEM.lon & DEM.lon <= centroids_rect(2);
    lat_crop_ndx    = centroids_rect(3) <= DEM.lat & DEM.lat <= centroids_rect(4);
    lon_crop        = DEM.lon(lon_crop_ndx & lat_crop_ndx);
    lat_crop        = DEM.lat(lon_crop_ndx & lat_crop_ndx);
    elev_crop       = DEM.value(lon_crop_ndx & lat_crop_ndx);
    
    % scattered interpolant to assign elevation to centroids
    F_DEM = scatteredInterpolant(lon_crop',lat_crop',elev_crop','natural');
    centroids.elevation_m = F_DEM(centroids.lon',centroids.lat')';
        
    % assign country name etc. to centroids
    centroids.country_name(1:end)   =  {country_name};
    centroids.admin0_ISO3           =   ISO3;
    centroids.admin0_NAME           =   country_name;
    
    centroids = climada_fl_centroids_prepare(centroids,0,1);
    
    centroids = salvador_vegetation(centroids);
    
%     centroids = climada_centroids_crop(centroids,garrobo_shapes);
    
    fprintf('saving centroids to %s \n',centroids_file)
    centroids.filename = centroids_file;
    save(centroids_file, 'centroids')
end

if isempty(force_entity_recalc), force_entity_recalc=0; end

if (exist(entity_file,'file') || exist(entity_file_xls,'file')) && ~force_entity_recalc
    if exist(entity_file,'file') && exist(entity_file_xls,'file')
        xls_dir = dir(entity_file_xls); mat_dir = dir(entity_file);
        if xls_dir.datenum - mat_dir.datenum >0 % Read excel file only if it is newer
            fprintf('loading entity from %s \n',entity_file_xls)
            entity = climada_entity_read(entity_file_xls);  % Read existing entity Excel file
            save(entity_file,'entity') % Save any updates made to excel file in mat file
        else
            fprintf('loading entity from %s \n',entity_file)
            load(entity_file)
        end
    else
        fprintf('loading entity from %s \n',entity_file)
        load(entity_file)
    end % load entity
else
    % Get enitity for the whole of country (such that the asset values
    % are scales to GDP
    country_entity_file = [module_data_dir filesep 'entities' filesep ISO3 '_entity.mat'];
    if exist(country_entity_file,'file')
        load(country_entity_file)       % Load existing file
    else
        % Entity from high resolution night lights
        entity = climada_nightlight_entity(country_name,admin_name,1);
        save(country_entity_file,'entity');     % Save for next time
    end
    
    % Clip the centroids and entity to the bounding box (centroids_rect) of
    % the desired region. Increase the resolution of centroids (also
    % possible for assets, but not really necessary)
    entity = climada_entity_crop(entity, centroids_rect,1);
    
    % Encode each asset to nearest on-land centroid for damage calculations
    temp_centroids=centroids;
    temp_centroids.centroid_ID(centroids.onLand ~=1)= - temp_centroids.centroid_ID(centroids.onLand ~=1);
    entity.assets = climada_assets_encode(entity.assets,temp_centroids);
    clear temp_centroids % Free up memory
    
    save(entity_file, 'entity')
    climada_entity_save_xls(entity,entity_file_xls,1,0,0);
    % The last three input args define whether damage functions, measures
    % and discounts are overwritten, respectively. Assets are always
    % overwritten.
end

% for nicer plotting, replace the map border shape file (be careful, they should be reset)
climada_global.map_border_file = admin_regions_matfile;

% Plot entity assets
if check_plots
    entity.assets.reference_year = 2014;
    figure('name',['Asset distribution ' admin_name],'color','w')
    climada_plot_entity_assets(entity);
    hold on
    % Plot centroids
    if isfield(centroids,'onLand')
        ndx = centroids.onLand ==1;
        plot(centroids.lon(ndx),centroids.lat(ndx),'.g','markersize',1);
        plot(centroids.lon(~ndx),centroids.lat(~ndx),'.b','markersize',1);
    end
    % Plot location
    % if ~isempty(location)
    %     text(location.longitude+0.05,location.latitude,10,location.name,'fontsize',14,'color',[1 0 0],'backgroundcolor',[1 1 1])
    %     plot3(location.longitude,location.latitude,10,'or','markersize',40, 'linewidth', 3);
    % end
    % Plot details
    if details_check
        climada_shp_explorer([module_data_dir filesep 'entities' filesep ISO3 '_shapes' filesep 'buildings.shp']);
    end
    axis equal
    axis(centroids_rect)
    hold off
end
% reset, otherwise we may run into trouble
climada_global.map_border_file = climada_global.climada_global_ori.map_border_file;


% % 2) Create TC hazard event set
% % -----------------------------------
% % Do complete calculation if no TC hazard set file exists, or if demanded
% % by user, else load existing file.
% if (~exist(hazard_set_file_tc,'file') || force_hazard_recalc)
%     % Load historical tracks
%     tc_track = climada_tc_read_unisys_database(unisys_file);
%     if probabilistic % Do complete probabilistic calculation
%         if exist('climada_tc_track_wind_decay_calculate','file')
%             % Wind speed decay at track nodes after landfall
%             [~, p_rel]  = climada_tc_track_wind_decay_calculate(tc_track,0);
%         else
%             fprintf('No inland decay, consider module tc_hazard_advanced\n');
%         end
%         
%         % Expand set of tracks by generating probabilistic tracks
%         % See function header for more details on generating probabilistic
%         % tracks, such as specifying ensemble size, max angle etc.
%         tc_track = climada_tc_random_walk(tc_track);
%         if exist('climada_tc_track_wind_decay_calculate','file')
%             % Add the inland decay correction to all probabilistic nodes
%             tc_track   = climada_tc_track_wind_decay(tc_track, p_rel,0);
%         end
%         
%         % Plot the tracks
%         if check_plots
%             figure('Name','TC tracks','Color',[1 1 1]);
%             hold on
%             for event_i=1:length(tc_track) % plot all tracks
%                 plot(tc_track(event_i).lon,tc_track(event_i).lat,'-b');
%             end % event_i
%             % Overlay historic (to make them visible, too)
%             for event_i=1:length(tc_track)
%                 if tc_track(event_i).orig_event_flag
%                     plot(tc_track(event_i).lon,tc_track(event_i).lat,'-r');
%                 end
%             end % event_i
%             climada_plot_world_borders(2)
%             box on
%             axis equal
%             axis(centroids_rect);
%             xlabel('blue: probabilistic, red: historic');
%         end
%     end
%     % Generate all the wind footprints: create TC hazard set
%     hazard_tc = climada_tc_hazard_set(tc_track, hazard_set_file_tc, centroids);
%     hazard_tc.units     = 'm/s'; % Set the units for the plot
%     hazard_sets.TC  = hazard_tc;
% else
%     fprintf('loading TC wind hazard set from %s\n',hazard_set_file_tc);
%     load(hazard_set_file_tc); % Load existing hazard
%     if ~exist('hazard_tc','var')
%         hazard_tc = hazard; clear hazard;
%     end
%     hazard_sets.TC  = hazard_tc;
% end

% % 4) Create TR hazard set
% if (~exist(hazard_set_file_tr, 'file')  || force_hazard_recalc)
%     if ~exist('tc_track','var')
%         tc_track = climada_tc_read_unisys_database(unisys_file);
%         if probabilistic
%             if exist('climada_tc_track_wind_decay_calculate','file')
%                 [~, p_rel]  = climada_tc_track_wind_decay_calculate(tc_track,0);
%             else fprintf('No inland decay, consider module tc_hazard_advanced\n'); end
%             
%             tc_track = climada_tc_random_walk(tc_track);
%             close
%             if exist('climada_tc_track_wind_decay_calculate','file')
%                 tc_track   = climada_tc_track_wind_decay(tc_track, p_rel,0);
%             end
%         end
%     end
%     hazard_tr = climada_tr_hazard_set(tc_track, hazard_set_file_tr,centroids);
%     rain_hazard = hazard_tr;
%     hazard_sets.TR  = hazard_tr;
% else
%     fprintf('loading TR rain hazard set from %s\n',hazard_set_file_tr);
%     load(hazard_set_file_tr);
%     if ~exist('hazard_tr','var')
%         hazard_tr = hazard; clear hazard;
%     end
%     rain_hazard = hazard_tr;
%     hazard_sets.TR  = hazard_tr;
% end

% 5) Create rainfall hazard set
if (~exist(hazard_set_file_rf,'file') || force_hazard_recalc) 
    hazard_rf = climada_rf_hazard_set(centroids,'',[],[],[],hazard_set_file_rf,check_plots);
    rain_hazard = hazard_rf; % default for fl
    hazard_sets.RF  = hazard_rf;
else
    fprintf('loading RF rain hazard set from %s \n',hazard_set_file_rf);
    load(hazard_set_file_rf);
    hazard_rf = hazard; clear hazard;
    rain_hazard = hazard_rf; % default for fl
    hazard_sets.RF  = hazard_rf;
end

% 7) Create mudslide hazard set
if (~exist(hazard_set_file_ms,'file') || force_hazard_recalc)
    hazard_ms = climada_ms_hazard_set(rain_hazard,centroids,hazard_set_file_ms);
    hazard_sets.MS  = hazard_ms;
else
    fprintf('loading MS mudslide hazard set from %s \n',hazard_set_file_ms);
    load(hazard_set_file_ms);
    hazard_ms = hazard; clear hazard;
    hazard_sets.MS  = hazard_ms;
end

% for nicer plotting, replace the map border shape file (be careful, they should be reset)
climada_global.map_border_file = admin_regions_matfile;

if check_plots
    % Plot the hazard sets for largest event
    for hazard_i = 1: length(fieldnames(hazard_sets))
        [~,max_event]=max(sum(hazard_sets.(peril_IDs{hazard_i}).intensity,2).* hazard_sets.(peril_IDs{hazard_i}).orig_event_flag');
        max_event_fig_title = sprintf('%s %s admin %i for largest event # %i in the year %i',...
            hazard_sets.(peril_IDs{hazard_i}).peril_ID,admin_name,adm_lvl,max_event,hazard_sets.(peril_IDs{hazard_i}).yyyy(max_event));
        
        figure('Name',max_event_fig_title,'Color',[1 1 1])
        climada_hazard_plot_hr(hazard_sets.(peril_IDs{hazard_i}),max_event);
        hold off
    end
end

% Generate damage sets
% ----------------------------------------------

% Ensure asset covers are set to asset values, deductibles set to zero for
% reasonable damage calculation (the equivalent of ignoring insurance
% policies altogether)
entity.assets.Cover = entity.assets.Value;
entity.assets.Deductible = entity.assets.Value .* 0;

entity = climada_assets_encode(entity,centroids);

peril_IDs_str = peril_IDs{1};
for peril_i = 2: length(peril_IDs)
    peril_IDs_str = [peril_IDs_str ', ' peril_IDs{peril_i}];
end

fprintf('calculating event damage sets for %s hazards \n',peril_IDs_str)
for hazard_i = 1:length(peril_IDs)
    EDS.(peril_IDs{hazard_i}) = climada_EDS_calc(entity,hazard_sets.(peril_IDs{hazard_i}));
    
    if check_plots
        climada_EDS_plot_3d(hazard_sets.(peril_IDs{hazard_i}),EDS.(peril_IDs{hazard_i}));
    end
end

% reset global variables
if isfield(climada_global, 'climada_global_ori')
    climada_global = climada_global.climada_global_ori;
end