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

% read asci-file
delimiter = '';
% delimiter = ' ';
% delimiter = '\t';

dem_grid = flipud(dlmread(asci_file,delimiter,row_count,0));
% set nodata values to 0
dem_grid(dem_grid==NODATA_value) = 0;
x_dem = linspace(xllcorner,xllcorner+cellsize*ncols,ncols);
y_dem = linspace(yllcorner,yllcorner+cellsize*nrows,nrows);
%         [lon_min, lat_min] = utm2ll_shift(xllcorner, yllcorner);
%         [lon_max, lat_max] = utm2ll_shift(xllcorner+cellsize*ncols, yllcorner+cellsize*nrows);

%% read inundation grid (dem-municipiosll.txt)
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


%% plot dem and event inundation
figure
contourf(x_dem,y_dem,dem_grid,[550:10:850],'edgecolor','none')
colorbar

% caxis([579 818])
% colorbar
figure
% hold on
contour(x,y,event_grid,[550:10:850])
colorbar

figure
contourf(x,y,event_grid,'edgecolor','none')

%% create vectors, .lon, .lat, .value

% create meshgrid dem 
[X, Y ] = meshgrid(x_dem,y_dem);
dem.lon = reshape(X,1,numel(x_dem)*numel(y_dem));
dem.lat = reshape(Y,1,numel(x_dem)*numel(y_dem));  
dem.value = reshape(dem_grid,1,numel(x_dem)*numel(y_dem));

% only use dem values that are close to the hazard
indx_valid = dem.lon>473800 & dem.lon<482600 & dem.lat>284400 & dem.lat<286500;
% sum(indx_valid)
% figure
% hold on
% plot(dem.lon(indx_valid),dem.lat(indx_valid),'.')
dem.lon = dem.lon(indx_valid);
dem.lat = dem.lat(indx_valid);
dem.value = dem.value(indx_valid);


% create meshgrid event_grid 
[X, Y ] = meshgrid(x,y);
hazard.lon = reshape(X,1,numel(x)*numel(y));
hazard.lat = reshape(Y,1,numel(x)*numel(y));  
hazard.intensity = reshape(event_grid,1,numel(x)*numel(y));
% use only positive values
indx_valid = ~isnan(hazard.intensity);
% sum(indx_valid)
hazard.lon = hazard.lon(indx_valid);
hazard.lat = hazard.lat(indx_valid);
hazard.intensity = hazard.intensity(indx_valid);
hazard.dem = zeros(size(hazard.lon));
hazard.dem = zeros(size(hazard.lon));



%% find nearest neighbour and this dem value
indx = knnsearch([dem.lon' dem.lat'],[hazard.lon' hazard.lat']);
hazard.dem = dem.value(indx);

% calculate inuundation depht and normalize
hazard.intensity_ori = hazard.intensity;
hazard.intensity = hazard.intensity_ori-hazard.dem;

% % normalize
% max_depth = 4.5;
% hazard.intensity = hazard.intensity+-min(hazard.intensity);
% hazard.intensity = hazard.intensity/max(hazard.intensity)*max_depth;

% add hazard fields
hazard.peril_ID = '';
hazard.datenum  = now;
hazard.orig_event_flag = 0;
hazard.event_ID = 1;

% climada_hazard_plot_hr(hazard,1,[],[],[],0)


%%

% figure
% plotclr(hazard.lon, hazard.lat, hazard.intensity,'','',1)
% hold on
% plot(hazard.lon(end), hazard.lat(end), 'rx')
% hazard.intensity(end)

% % just to check for nearest neighbour
% plot(dem.lon(indx(end)), dem.lat(indx(end)), 'bo','markersize',10)
% plot(dem.lon(indx(end)-1), dem.lat(indx(end)-1), 'bo','markersize',10)
% plot(dem.lon(indx(end)+1), dem.lat(indx(end)+1), 'bo','markersize',10)
% plot(dem.lon, dem.lat, 'bo','markersize',2)
% 
% figure
% plotclr(dem.lon, dem.lat, dem.value)











%%
% switch utm_transformation
%     case 'barisal'
%         % only for Barisal: transformation of UTM to lat lon coordinates (including shift)
%         [lon_min, lat_min] = utm2ll_shift(xllcorner, yllcorner);
%         [lon_max, lat_max] = utm2ll_shift(xllcorner+cellsize*ncols, yllcorner+cellsize*nrows);
%         
%     case 'salvador'
%         % only for El Salvador: transformation of UTM to lat lon coordinates
%         [lon_min, lat_min] = utm2ll_salvador(xllcorner, yllcorner);
%         [lon_max, lat_max] = utm2ll_salvador(xllcorner+cellsize*ncols, yllcorner+cellsize*nrows);  
%     % original conversion from UTM to lat lon
%     % [lon_min, lat_min] = btm2ll(xllcorner, yllcorner);
%     % [lon_max, lat_max] = btm2ll(xllcorner+cellsize*ncols, yllcorner+cellsize*nrows); 
%     
%     case '' % without transformation
%         lon_min = xllcorner;
%         lat_min = yllcorner;
%         lon_max = xllcorner+cellsize*ncols;
%         lat_max = yllcorner+cellsize*nrows;
% end



% % create meshgrid
% [X, Y ] = meshgrid(linspace(lon_min,lon_max,ncols), ...
%                    linspace(lat_min,lat_max,nrows));







%%








