function [dem, resolution_m] = salvador_dem_read(dem_filename, resolution_m, check_plot)
% Read dem grid and create dem structure for a given resolution (m)
% MODULE:
%   salvador_demo
% NAME:
%   salvador_dem_read
% PURPOSE:
%   Read dem grid and create dem structure for a given resolution (m)
% CALLING SEQUENCE:
%   [dem, resolution_m] = salvador_dem_read(dem_filename, resolution_m, check_plot)
% EXAMPLE:
%   dem = salvador_dem_read
% INPUTS:
% OPTIONAL INPUT PARAMETERS:
%   dem_filename: dem filename (txt or asci), > prompted for if not given
%   resolution_m: default is 50m, finest resolution is 10m
%   check_plot:   set to 1 if figure wanted 
% OUTPUTS:
%   dem: a struct, with the fields
%       .lon: the longitude of each location
%       .lat: the latitude of each location
%       .value: the elevation in masl for each location
%       .resolution_m: resolution value in m
%       .unit: unit of dem values (default masl)
%       .comment: a free comment, normally containing the time the hazard
%           event set has been generated
%       .date_created: time when the dem structure has been generated
% MODIFICATION HISTORY:
%   Lea Mueller, muellele@gmail.com, 20150729, init
% -

dem          = []; % init

global climada_global
if ~climada_init_vars, return; end

% check arguments
if ~exist('dem_filename' ,'var'), dem_filename = []; end
if ~exist('resolution_m' ,'var'), resolution_m = []; end
if ~exist('check_plot'   ,'var'), check_plot   = []; end

% set module data directory
% module_data_dir=[fileparts(fileparts(mfilename('fullpath'))) filesep 'data'];

% default dem_file on the shared drive
foldername = 'M:\BGCC\CHR\RK\RS\A_Sustainable_Development\Projects\ECA\SanSalvador\consultant_data\hazards\landslides\system\';
asci_file  = [foldername 'dem-municipios.txt'];
% asci_file = [foldername 'dem-municipiosll.txt'];

if isempty(dem_filename)
    dem_filename = asci_file;
end
if isempty(resolution_m), resolution_m = 50; end
if isempty(check_plot  ), check_plot   =  0; end
  

%% read DEM grid (dem-municipios.txt)
row_count   = 6;
row_counter = 0;
fid = fopen(dem_filename,'r');
% file does not exist
if fid <= 0
    fprintf('File does not exist. Please check that the default file still exists.\n')
    return
end
for i = 1:row_count
    line=fgetl(fid);
    if length(line)>0
       [token, remain] = strtok(line,' ');
       if ~isempty(remain)
           if strfind(token,'ncols'       ); ncols        = str2num(remain);end
           if strfind(token,'nrows'       ); nrows        = str2num(remain);end
           if strfind(token,'xllcorner'   ); xllcorner    = str2num(remain);end
           if strfind(token,'yllcorner'   ); yllcorner    = str2num(remain);end
           if strfind(token,'cellsize'    ); cellsize     = str2num(remain);end
           if strfind(token,'NODATA_value'); NODATA_value = str2num(remain);end
           row_counter = row_counter+1;
       end
    end
end
fclose(fid);

% set delimiter
delimiter = '';
% delimiter = ' ';
% delimiter = '\t';

dem_grid_ori = flipud(dlmread(dem_filename,delimiter,row_count,0));

% check that dimension of grid corresponds to ncols and nrows
[dem_i, dem_j ] = size(dem_grid_ori);
if dem_i ~= nrows
    fprintf('Dimension do not agree. Please check dimension of grid, e.g. parameter "row_count".\n')
    return
end
if dem_j ~= ncols
    fprintf('Dimension do not agree. Please check dimension of grid, e.g. parameter "row_count".\n')
    return
end  


%% create DEM grid on required resolution
resolution_factor = ceil(resolution_m/cellsize);
dem_grid          = dem_grid_ori(1:resolution_factor:end, 1:resolution_factor:end);
dem_grid(end,:)   = [];
dem_grid(:,end)   = [];
dem_grid(dem_grid == NODATA_value) = 0;
cellsize          = cellsize*resolution_factor;
[dem_i, dem_j ]   = size(dem_grid);

%% create dem struct (vectors lon, lat, value)
x_dem     = linspace(xllcorner, xllcorner+cellsize*dem_j, dem_j);
y_dem     = linspace(yllcorner, yllcorner+cellsize*dem_i, dem_i);
[X, Y ]   = meshgrid(x_dem,y_dem);
dem.lon   = zeros(1,dem_j*dem_i); %init
dem.lat   = zeros(1,dem_j*dem_i); %init
dem.X     = reshape(X,1,numel(x_dem)*numel(y_dem));
dem.Y     = reshape(Y,1,numel(x_dem)*numel(y_dem));  
dem.value = reshape(dem_grid,1,numel(x_dem)*numel(y_dem));
dem.unit  = 'masl';
dem.resolution_m   = resolution_m;
dem.comment        = sprintf('DEM on %dm resolution, read from %s',resolution_m, dem_filename);
%transform to lat/lon
[dem.lon, dem.lat] = utm2ll_salvador(dem.X, dem.Y);



%% save dem
% both on shared drive as well as in project folder
filename = sprintf('%s_%dm.mat',strrep(dem_filename,'.txt',''),resolution_m);
save(filename,'dem');

% in project folder
if isfield(climada_global, 'project_dir')
    filename = [climada_global.project_dir filesep 'system' filesep 'Salvador_dem_' int2str(resolution_m) 'm_' datestr(now,'YYYYmmdd') '.mat'];
    save(filename,'dem');
    fprintf('dem struct saved in \n \t %s\n',filename)
end



%% plot dem
if check_plot
    climada_figuresize(0.4, 0.7);
    contourf(x_dem,y_dem,dem_grid,[550:10:850],'edgecolor','none')
    [lon_dem, ~] = utm2ll_salvador(x_dem, ones(size(x_dem))*y_dem(1));
    [~, lat_dem] = utm2ll_salvador(ones(size(y_dem))*x_dem(1), y_dem);
    %contourf(lon_dem,lat_dem,dem_grid,[550:10:850],'edgecolor','none')
    contourf(lon_dem,lat_dem,dem_grid,[400:10:1000],'edgecolor','none')
    cbar = colorbar;
    set(get(cbar,'ylabel'),'String', '(masl)','fontsize',12);
    titlestr = sprintf('Digital elevation model (%dm resolution)', resolution_m);
    title(titlestr,'fontsize',13)
    % caxis([579 818])
    grid on
    hold on
    climada_figure_scale_add('',1,1)
    
    
    shp_file = [climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS.mat'];
    if exist(shp_file,'file')
        load(shp_file)
        shape_plotter(shape_rios(indx_rios_in_San_Salvador),'','','','linewidth',1,'color',[135 206 235]/255) % grey % blue [58 95 205]/255
        shape_plotter(polygon_LS,'','lon','lat')
    end
    
    %axis equal
    %axis([-89.35 -89.00 13.62 13.83])
end




%% shift in DEM
% shift_x = 473460.90240-473437.90240;
% shift_y = 283998.50000-283883.50000;
% 
% % apply shift in x and y
% xllcorner = xllcorner+shift_x;
% yllcorner = yllcorner+shift_y; 

% % 473437.90240 + shift_x
% % 283883.50000 + shift_y
% % 456064.365625+shift_x
% % 267347.04962761+shift_y
% dem.X = dem.X+shift_x;
% dem.Y = dem.Y+shift_y;

%% only use dem values that are close to the hazard
% indx_valid = dem.X>473800 & dem.X<482600 & dem.Y>284400 & dem.Y<286500;
% % sum(indx_valid)
% % figure
% % hold on
% % plot(dem.lon(indx_valid),dem.lat(indx_valid),'.')
% dem.X       = dem.X(indx_valid);
% dem.Y       = dem.Y(indx_valid);
% dem.value   = dem.value(indx_valid);
% 
% % transformation of UTM to lat lon coordinates
% [dem.lon, dem.lat] = utm2ll_salvador(dem.X, dem.Y);

