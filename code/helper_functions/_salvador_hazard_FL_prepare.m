

% -- not used anymore ------



%% LOAD INDUNDATION HAZARD AND CREATE FIGURES



%% set directories  and load the data
foldername = 'M:\BGCC\CHR\RK\RS\A_Sustainable_Development\Projects\ECA\SanSalvador\consultant_data\hazards\inundation\20150723_rio_acelhuate_rio_garrobo_2D\';
% asci_file = [foldername 'TR50A0.asc'];
asci_file = [foldername 'flood_gar_2yr_10m.asc'];

% load relevant shapes (adm2, rivers, polygon_LS, polygon_rio_acelhuate)
load([climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS.mat'])

% load inundation hazard
load([climada_global.project_dir filesep 'Salvador_hazard_FL_2015'])




%% create figures
% climada_hazard_plot_hr(hazard,3);


max_flood_m = 7;
markersize  = 1;
for e_i = 1:6
    fig = climada_figuresize(0.4,0.8);
    plotclr(hazard.lon, hazard.lat, hazard.intensity(e_i,:),'s',markersize,1,0,max_flood_m,climada_colormap(hazard.peril_ID));
    hold on
    shape_plotter(shape_rios(indx_rios_in_San_Salvador),'','X_ori','Y_ori','linewidth',1,'color',[135 206 235]/255) % grey % blue [58 95 205]/255
    box on
    axis([min(hazard.lon) max(hazard.lon) min(hazard.lat) max(hazard.lat)])
    title({['Flood Rio Acelhuate (m), ' sprintf('%d year return period',1./hazard.frequency(e_i))]; '1D from MARN, 2D from GFA, 10m resolution'})
    x_y_ratio = climada_geo_distance(-89,14,-89.001,14)/climada_geo_distance(-89,14,-89,14.001);
    x_ = max(hazard.lon)-min(hazard.lon);
    y_ = max(hazard.lat)-min(hazard.lat);
    set(gca, 'PlotBoxAspectRatio', [x_ y_*x_y_ratio 1]);
    climada_figure_scale_add(gca,5,1)

    foldername = sprintf('%sresults%sSanSalvador%sFlood_Rio_Acelhuate_%d_return_period_max_flood_%dm_%s.pdf', filesep,filesep,filesep,1./hazard.frequency(e_i),max_flood_m,datestr(now,'YYYYmmDD'));
    print(fig,'-dpdf',[climada_global.data_dir foldername])
    
end


%% difference in flood meter

max_flood_m = 100;
min_flood_m = 0;
for e_i = 1:5
    
    value = (hazard.intensity(e_i+1,:)-hazard.intensity(e_i,:))./hazard.intensity(e_i,:)*100;
    value(isnan(value)) = 0;
    
    fig = climada_figuresize(0.3,0.8);
    plotclr(hazard.lon, hazard.lat, value,'s',1,1,min_flood_m,max_flood_m,climada_colormap(hazard.peril_ID));
    hold on
    shape_plotter(shape_rios(indx_rios_in_San_Salvador),'','X_ori','Y_ori','linewidth',1,'color',[135 206 235]/255) % grey % blue [58 95 205]/255
    box on
    axis([min(hazard.lon) max(hazard.lon) min(hazard.lat) max(hazard.lat)])
    title({['Differnce in flood height (m), ' sprintf('%d - %d year return period',1./hazard.frequency(e_i),1./hazard.frequency(e_i+1))]; '1D from MARN, 2D from GFA, 10m resolution'})
    x_y_ratio = climada_geo_distance(-89,14,-89.001,14)/climada_geo_distance(-89,14,-89,14.001);
    x_ = max(hazard.lon)-min(hazard.lon);
    y_ = max(hazard.lat)-min(hazard.lat);
    set(gca, 'PlotBoxAspectRatio', [x_ y_*x_y_ratio 1]);
    climada_figure_scale_add(gca,5,1)

    foldername = sprintf('%sresults%sSanSalvador%sFlood_Rio_Acelhuate_%d_%d_return_period_diff_m_%s.pdf', filesep,filesep,filesep,1./hazard.frequency(e_i),1./hazard.frequency(e_i+1),datestr(now,'YYYYmmDD'));
    print(fig,'-dpdf',[climada_global.data_dir foldername])
    
end





%% read inunation hazard for San Salvador Rio Acelhuate and Rio Garrobo
%(MARN data 1D and from Maxime/GFA put )

%present, future moderate and future extreme

foldername = 'M:\BGCC\CHR\RK\RS\A_Sustainable_Development\Projects\ECA\SanSalvador\consultant_data\hazards\inundation';
data_name{1}='Salvador_hazard_FL_2015';
data_name{2}='Salvador_hazard_FL_2040_moderate_cc';
data_name{3}='Salvador_hazard_FL_2040_extreme_cc';

for i=1:3

    % set directories
    if      i==1
        asci_file = [foldername filesep '20150723_rio_acelhuate_rio_garrobo_2D' filesep 'flood_gar_2yr_10m.asc'];
       
    elseif  i==2
       asci_file = [foldername filesep '201508_rio_acelhuate_rio_garrobo_2D_2040_moderate_cc' filesep '4%_2yr.txt'];
 
    elseif  i==3
        asci_file = [foldername filesep '201508_rio_acelhuate_rio_garrobo_2D_2040_extreme_cc' filesep '10%_2yr.txt'];
    
    end

    % load relevant shapes (adm2, rivers, polygon_LS, polygon_rio_acelhuate)
    load([climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS.mat'])

    % read hazard
    hazard = climada_asci2hazard(asci_file, 6, 'salvador');

    % set ordering and frequencies
    order_indx       = [4 6 2 3 5 1];
    hazard.intensity = hazard.intensity(order_indx,:);
    hazard.name      = hazard.name(order_indx);
    hazard.frequency = 1./[2 5 10 25 50 100];
    hazard.orig_years= 100;
    hazard.comment   = '1D modelled by MARN, 2D modelled by GFA';
    hazard.peril_ID  = 'FL';
    hazard.units     = 'm';
    hazard.filename  = '';

    % cut out relevant area for rio acelhuate
    hazard = climada_hazard_focus_area(hazard,polygon_rio_acelhuate);

    % save flood hazard rio acelhuate
    save_name = [climada_global.project_dir filesep data_name{i}];
    hazard.filename  = save_name;
    save(save_name,'hazard')
    fprintf('Save hazard in %s\n',save_name)

end





%% prepare inundation hazard for San Salvador Rio Acelhuate (MARN data)
% salvador inundation hazard
% but MARN data is based on a 1D visualisation, so data is not useful for
% flood damage modelling




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








