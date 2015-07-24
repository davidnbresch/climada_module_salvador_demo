

%% LOAD THE FINAL PREPARED SHAREDFILES
% - shapes                   : adm2
% - shape_rios               : rivers in El Salvador
% - indx_rios_in_San_Salvador: indx to select rivers within San Salvador center
% - polygon_LS               : polygon that roughly defines San Salvador center, used for landslide susceptibility map
% - polygon_rio_acelhuate    : polygon that roughly defines the Rio Acelhuate, used for focus area for flood hazard
salvador_module_system_dir = ['\\CHRB1065.CORP.GWPNET.COM\homes\X\S3BXXW\Documents\lea\climada_git\climada_modules\salvador_demo\data\system'];
load([salvador_module_system_dir filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS.mat'])





%% san salvador prepare shapefiles

%% set data directories, load adm2, polygon_LS and rivers
salvador_data_dir   = [climada_global.data_dir filesep 'results' filesep 'SanSalvador' filesep 'LS' filesep];
salvador_module_system_dir = ['\\CHRB1065.CORP.GWPNET.COM\homes\X\S3BXXW\Documents\lea\climada_git\climada_modules\salvador_demo\data\system'];

% load shp admin 2, polygon LS and centroids LS
load([climada_global.data_dir filesep 'entities' filesep 'SLV_adm' filesep 'SLV_adm2.mat'])
load([salvador_data_dir filesep 'polygon_LS'])

shape_rios = climada_shaperead([salvador_module_system_dir filesep 'rios_25k_polyline_WGS84.shp']);



%% prepare river shapefile (apply shift in lat/lon)

% find rivers that are in San Salvador center
indx_rios_in_San_Salvador = zeros(1,numel(shape_rios));
for s_i = 1:numel(shape_rios)
    shape_rios(s_i).X(isnan(shape_rios(s_i).X)) = [];
    shape_rios(s_i).Y(isnan(shape_rios(s_i).Y)) = [];
    inpoly_indx = inpoly([shape_rios(s_i).X' shape_rios(s_i).Y'],[polygon_LS.lon polygon_LS.lat]);
    if any(inpoly_indx)
        indx_rios_in_San_Salvador(s_i) = 1;
    end
end
indx_rios_in_San_Salvador = logical(indx_rios_in_San_Salvador);


%% copy original values before shift
% save original values, rivers
for s_i = 1:numel(shape_rios)
    shape_rios(s_i).X_ori = shape_rios(s_i).X;
    shape_rios(s_i).Y_ori = shape_rios(s_i).Y;
end

% save original values, adm 2
for s_i = 1:numel(shapes)
    shapes(s_i).X_ori = shapes(s_i).X;
    shapes(s_i).Y_ori = shapes(s_i).Y;
end


%% apply shift in lon/lat for rios
shift_lon = 0.02/4;
shift_lat = -0.02/6;
for s_i = 1:numel(shape_rios)
    % rivers
    shape_rios(s_i).X = shape_rios(s_i).X_ori + shift_lon;
    shape_rios(s_i).Y = shape_rios(s_i).Y_ori + shift_lat;
end
for s_i = 1:numel(shapes)  
    % admin level 2
    shapes(s_i).X = shapes(s_i).X_ori - shift_lon;
    shapes(s_i).Y = shapes(s_i).Y_ori - shift_lat;
end


%% create polygon for rio acelhaute

% load inundation hazard
foldername = 'M:\BGCC\CHR\RK\RS\A_Sustainable_Development\Projects\ECA\SanSalvador\consultant_data\hazards\inundation\20150723_rio_acelhuate_rio_garrobo_2D\';
asci_file = [foldername 'flood_gar_2yr_10m.asc'];
load(strrep(asci_file,'.asc','.mat'))

figure
plot(hazard.lon, hazard.lat,'x');
hold on
indx = hazard.intensity(end,:)>0;
plot(hazard.lon(indx), hazard.lat(indx),'ro');
[poygon_rio_acelhuate.lon, poygon_rio_acelhuate.lat]= ginput;
plot(poygon_rio_acelhuate.lon, poygon_rio_acelhuate.lat,'-.c');


%% save shp results
save([salvador_module_system_dir filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS.mat'],'shapes','shape_rios','indx_rios_in_San_Salvador','polygon_LS','polygon_rio_acelhuate')


