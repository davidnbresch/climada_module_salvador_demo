
% prepare inunation hazard for San Salvador Rio Acelhuate (MARN data)
% salvador inundation hazard
% but MARN data is based on a 1D visualisation, so data is not useful for
% flood damage modelling


%% read DEM grid (dem-municipios.txt)

foldername = 'M:\BGCC\CHR\RK\RS\A_Sustainable_Development\Projects\ECA\SanSalvador\consultant_data\hazards\mudslides\system\';
% asci_file = [foldername 'dem-municipiosll.txt'];
asci_file = [foldername 'dem-municipios.txt'];
row_count = 6;
row_counter = 0;
fid=fopen(asci_file,'r');
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

%%

% read asci-file
delimiter = '';
% delimiter = ' ';
% delimiter = '\t';

% shift in DEM
shift_x = 473460.90240-473437.90240;
shift_y = 283998.50000-283883.50000;

% apply shift in x and y
xllcorner = xllcorner+shift_x;
yllcorner = yllcorner+shift_y; 

% 473437.90240 + shift_x
% 283883.50000 + shift_y
% 456064.365625+shift_x
% 267347.04962761+shift_y
dem.X = dem.X+shift_x;
dem.Y = dem.Y+shift_y;

dem_grid = flipud(dlmread(asci_file,delimiter,row_count,0));
% set nodata values to 0
dem_grid(dem_grid==NODATA_value) = 0;
x_dem = linspace(xllcorner,xllcorner+cellsize*ncols,ncols);
y_dem = linspace(yllcorner,yllcorner+cellsize*nrows,nrows);
%         [lon_min, lat_min] = utm2ll_shift(xllcorner, yllcorner);
%         [lon_max, lat_max] = utm2ll_shift(xllcorner+cellsize*ncols, yllcorner+cellsize*nrows);
dem_comment = asci_file;


dem_grid_100m = dem_grid(1:10:end, 1:10:end);
dem_grid_100m(end,:) = [];
dem_grid_100m(:,end) = [];
dem_grid_100m(dem_grid_100m==NODATA_value) = 0;
cellsize = cellsize*10;
x_dem = linspace(xllcorner,xllcorner+cellsize*410,410);
y_dem = linspace(yllcorner,yllcorner+cellsize*435,435);
[X, Y ] = meshgrid(x_dem,y_dem);
dem.X = reshape(X,1,numel(x_dem)*numel(y_dem));
dem.Y = reshape(Y,1,numel(x_dem)*numel(y_dem));  
dem.value = reshape(dem_grid_100m,1,numel(x_dem)*numel(y_dem));
[dem.lon, dem.lat] = utm2ll_salvador(dem.X, dem.Y);
dem.comment = sprintf('DEM on 100 m resolution, read from %s, including shift',dem_comment);
dem.unit    = 'masl';
save([climada_global.data_dir filesep 'system' filesep 'dem_san_savlador_100m_full_shift'],'dem');


%% create vectors, .lon, .lat, .value

% create meshgrid dem 
[X, Y ] = meshgrid(x_dem,y_dem);
dem.X = reshape(X,1,numel(x_dem)*numel(y_dem));
dem.Y = reshape(Y,1,numel(x_dem)*numel(y_dem));  
dem.value = reshape(dem_grid,1,numel(x_dem)*numel(y_dem));

% only use dem values that are close to the hazard
indx_valid = dem.X>473800 & dem.X<482600 & dem.Y>284400 & dem.Y<286500;
% sum(indx_valid)
% figure
% hold on
% plot(dem.lon(indx_valid),dem.lat(indx_valid),'.')
dem.X       = dem.X(indx_valid);
dem.Y       = dem.Y(indx_valid);
dem.value   = dem.value(indx_valid);
dem.comment = sprintf('DEM on 10 m resolution, read from %s',dem_comment);
dem.unit    = 'masl';
% transformation of UTM to lat lon coordinates
[dem.lon, dem.lat] = utm2ll_salvador(dem.X, dem.Y);


%% plot dem
figure
contourf(x_dem,y_dem,dem_grid,[550:10:850],'edgecolor','none')
colorbar
% caxis([579 818])


%% save dem
save([climada_global.data_dir filesep 'system' filesep 'dem_san_savlador_10m'],'dem');
% save([climada_global.data_dir filesep 'system' filesep 'dem_san_savlador_10m_full_shift'],'dem');
save([climada_global.data_dir filesep 'system' filesep 'dem_san_savlador_10m_full_shift'],'dem');


%% read inundation grid (TR50A0_test.txt)
foldername = 'M:\BGCC\CHR\RK\RS\A_Sustainable_Development\Projects\ECA\SanSalvador\consultant_data\hazards\inundation\rio_acelhuate\';
% asci_file = [foldername 'TR50A0.asc'];
asci_file = [foldername 'TR50A0_test.asc'];
row_count = 6;
row_counter = 0;
fid=fopen(asci_file,'r');
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

% read asci-file
delimiter = '';
% delimiter = ' ';
% delimiter = '\t';

event_grid = flipud(dlmread(asci_file,delimiter,row_count,0));
% set nodata values to 0
event_grid(event_grid==NODATA_value) = nan;
event_grid(event_grid==0) = nan;
x = linspace(xllcorner,xllcorner+cellsize*ncols,ncols);
y = linspace(yllcorner,yllcorner+cellsize*nrows,nrows);



%% plot event inundation
figure
% hold on
contour(x,y,event_grid,[550:10:850])
colorbar

figure
contourf(x,y,event_grid,'edgecolor','none')



%% create meshgrid event_grid 
[X, Y ]  = meshgrid(x,y);
hazard.X = reshape(X,1,numel(x)*numel(y));
hazard.Y = reshape(Y,1,numel(x)*numel(y));  
hazard.intensity      = zeros(size(hazard.X)); %init
hazard.intensity_ori  = zeros(size(hazard.X)); %init
hazard.intensity_masl = reshape(event_grid,1,numel(x)*numel(y));
% use only positive values
indx_valid = ~isnan(hazard.intensity_masl);
% sum(indx_valid)
hazard.X   = hazard.X(indx_valid);
hazard.Y   = hazard.Y(indx_valid);
hazard.intensity      = hazard.intensity(indx_valid);
hazard.intensity_ori  = hazard.intensity_ori(indx_valid);
hazard.intensity_masl = hazard.intensity_masl(indx_valid);
hazard.dem = zeros(size(hazard.X));
hazard.dem = zeros(size(hazard.X));

% transformation of UTM to lat lon coordinates
[hazard.lon, hazard.lat] = utm2ll_salvador(hazard.X, hazard.Y);


%% find nearest neighbour and this dem value
indx       = knnsearch([dem.X' dem.Y'],[hazard.X' hazard.Y']);
hazard.dem = dem.value(indx);

% calculate inuundation depht and normalize
hazard.intensity_ori  = hazard.intensity_masl-hazard.dem;

% normalize
max_depth = 4.5; % just a guess
hazard.intensity = hazard.intensity_ori -min(hazard.intensity_ori);
hazard.intensity = hazard.intensity/max(hazard.intensity)*max_depth;

% add hazard fields
hazard.frequency = 1/50;
hazard.peril_ID  = 'FL';
hazard.datenum   = now;
hazard.orig_event_flag = 1;
hazard.event_ID  = 1;
hazard.unit      = 'm';
hazard.comment   = 'Modelled by MARN, 1D, 3m resolution, 50 year return period';


%% save hazard
save([climada_global.data_dir filesep 'hazards' filesep 'hazard_Acelhuate_50yr'],'hazard');



%% plot indundation
fig = climada_figuresize(0.4,0.8);
plotclr(hazard.lon, hazard.lat, hazard.intensity,'','',1)
hold on
box on
title({'Flood Rio Acelhuate'; '50 years return period, normalized to 0 and 4.5m '; '1D from MARN, 3m resolution'})
% plot(hazard.lon(end), hazard.lat(end), 'rx')
% hazard.intensity(end)
foldername = sprintf('%sresults%sSanSalvador%sFlood_Rio_Acelhuate_%d_return_period.pdf', filesep,filesep,filesep,1/hazard.frequency(1));
print(fig,'-dpdf',[climada_global.data_dir foldername])

% climada_hazard_plot_hr(hazard,1,[],[],[],0)

fig = climada_figuresize(0.4,0.8);
plotclr(hazard.lon, hazard.lat, hazard.intensity_ori,'','',1)
hold on
box on
title({'Flood Rio Acelhuate'; '50 years return period, not normalized '; '1D from MARN, 3m resolution'})
% plot(hazard.lon(end), hazard.lat(end), 'rx')
% hazard.intensity(end)
foldername = sprintf('%sresults%sSanSalvador%sFlood_Rio_Acelhuate_%d_return_period_not_normalized.pdf', filesep,filesep,filesep,1/hazard.frequency(1));
print(fig,'-dpdf',[climada_global.data_dir foldername])


% % just to check for nearest neighbour
% plot(dem.lon(indx(end)), dem.lat(indx(end)), 'bo','markersize',10)
% plot(dem.lon(indx(end)-1), dem.lat(indx(end)-1), 'bo','markersize',10)
% plot(dem.lon(indx(end)+1), dem.lat(indx(end)+1), 'bo','markersize',10)
% plot(dem.lon, dem.lat, 'bo','markersize',2)
% 
% figure
% plotclr(dem.lon, dem.lat, dem.value)



%%








