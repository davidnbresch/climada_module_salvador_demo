function salvador_plot
% climada
% MODULE
%   salvador_demo
% NAME:
%   Salvador_plot
% PURPOSE:
%   plot Salvador, el Garrobo map, including all relevant information (AMSS GIS, BCC wards 
%   polygon and open data). Hardwired for San Salvador.
% CALLING SEQUENCE:
%   Salvador_plot
% EXAMPLE:
%   Salvador_plot
% INPUTS:
%   none, all hardwired for Salvador
% OUTPUTS:
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20150511
%-

global climada_global % access to global variables
if ~climada_init_vars,return;end % init/import global variables


%parameters
% check_printplot = 0;
check_printplot = 1;
axislim         = [-89.27 -89.13 13.63 13.7]; %salvador close up

% locate the module's data
% module_data_dir  = [fileparts(fileparts(mfilename('fullpath'))) filesep 'data'];
% % for testing
% module_data_dir  = '\\CHRB1065.CORP.GWPNET.COM\homes\X\S3BXXW\Documents\lea\climada_git\climada_data';
module_data_dir  = '\\CHRB1065.CORP.GWPNET.COM\homes\X\S3BXXW\Documents\lea\climada_git\climada_modules\salvador_demo\data';
% % GIS_dir          = 'M:\BGCC\CHR\RK\RS\A_Sustainable_Development\Projects\ECA\BarisalBangladesh\Barisal_GIS\WGS1984';
GIS_dir          = 'M:\BGCC\CHR\RK\RS\A_Sustainable_Development\Projects\ECA\SanSalvador\consultant_data\admin_shps\';
GIS_open_dat_dir = [climada_global.data_dir filesep 'entities' filesep 'SLV_adm'];
% GIS_open_dat_dir = [module_data_dir filesep 'entities' filesep 'SLV_adm'];


%% read shape files
%% AMSS boundaries
AMSS_file = 'AMSS.shp'; 
AMSS      = climada_shaperead([GIS_dir filesep 'Data_Lea' filesep AMSS_file],0,1,0,1); % 0 for no-save
%transform local coordinates (GCS  Everest 1830) to WGS1984
[AMSS(1).lon,AMSS(1).lat] = utm2ll_salvador(AMSS(1).X, AMSS(1).Y);
%save AMSS
AMSS_savename = [climada_global.data_dir filesep 'entities' filesep 'AMSS_border.mat'];
save(AMSS_savename,'AMSS')


%% El Garrobo
% focus_file = 'garrobo.shp';
% focus_shp  = climada_shaperead([GIS_dir filesep 'Data_Lea' filesep focus_file],0,1,0,1); % 0 for no-save
% %transform local coordinates (GCS  Everest 1830) to WGS1984
% [focus_shp.lon,focus_shp.lat] = utm2ll_salvador(focus_shp.X, focus_shp.Y);
% %save El Garrobo
% focus_savename = [climada_global.data_dir filesep 'entities' filesep 'Garrobo.mat'];
% save(focus_savename,'focus_shp')



%% Rios
% river_file = 'rios_25k.shp';
% river_shp  = climada_shaperead([GIS_dir 'Data_Lea' filesep river_file],0,1,0,1); % 0 for no-save
% river_file = 'Export_Output_2.shp';
% river_shp  = climada_shaperead([GIS_dir river_file],0,1,0,1); % 0 for no-save
% %transform local coordinates (GCS  Everest 1830) to WGS1984
% [river_shp.lon,river_shp.lat] = utm2ll_salvador(river_shp.X, river_shp.Y);
% %save rivers
% river_savename = [climada_global.data_dir filesep 'entities' filesep 'river_shp.mat'];
% save(river_savename,'river_shp')


%% climada_admin_name
% admin 2, open GIS data
shp_file_= 'SLV_adm'; i = 2;
shp_file = sprintf('%s%d.shp',shp_file_,i);
shapes   = climada_shaperead([GIS_open_dat_dir filesep shp_file],0,1,0,1); % 0 for no-save
% run climada_admin_name('El Salvador','San Salvador',2) if gis-file not
% available to download the required files into climada_global.data
% dir/entities/SLV
    

%% read entity
% entity_file = [climada_global.data_dir filesep 'entities' filesep 'entity_AMSS.mat'];
% if exist(entity_file,'file')
%     load(entity_file)
% end



%% load hazard flood depth
hazard_set_file = [module_data_dir filesep 'hazards' filesep 'acelhuate_hazard_FL'];  
% hazard_set_file = [climada_global.data_dir filesep 'hazards' filesep 'acelhuate_hazard_FL'];   
% hazard_set_file = [climada_global.data_dir filesep 'hazards' filesep 'Salvador_Garrobo_hazard_FL_depth'];   
reference_year = 2015;
hazard_set_file_ = sprintf('%s_%d.mat',hazard_set_file,2015);
load(hazard_set_file_);

%transform to lat/lon
[hazard.lon hazard.lat] = utm2ll_salvador(hazard.lon, hazard.lat);
hazard.intensity(isnan(hazard.intensity)) = 0;
hazard.intensity = sparse(hazard.intensity);
hazard.units = 'm';

%% plot rio acelhuate flood events
% % plot all asset categories with all 9 flood events
% close all
% entity.assets.reference_year = 2015;
% categories     = unique(entity.assets.Category);
% category_names = entity.assets.Category_names(categories);
% % category_names = entity.assets.Categories(categories);
% category_units = entity.assets.Unit(categories);
% markersize     = 8;
% marker         = {'o' 'd' '^' 'p'};
caxis_range    = [0 5];
% markercolor_   = [255  99  71;...   %tomato 
%                   238 154   0; ...  %orange 2
%                   154 205  50; ...  %olivedrab 3
%                    34 139  34]/255; %forestgreen

return

hazard_ = hazard;
hazard_.intensity = hazard.intensity(1,:);
hazard_.event_count = 1;
hazard_.name = {'50 year'};
hazard_.peril_ID = 'FL';
climada_hazard2ge(hazard_, 'test.kmz',1)

google_earth_save = [climada_global.data_dir filesep 'results' filesep 'SanSalvador' filesep 'Rio_Acelhuate.kmz'];
k = kml(google_earth_save);
% values = full(hazard.intensity(step_i,:));
k.plot(hazard.lon, hazard.lat, 'lineColor','50B4B414'); %blue
k.run 
               
for i = 1:length(hazard.event) %9
    % create figure
    %fig = climada_figuresize(0.8,1);
    fig = climada_figuresize(0.4,0.8);
    
    % plot hazard event
    %i = 1;
    %climada_hazard_plot(hazard, i,'',caxis_range);
    colorbar_on = 1;
    [cmap c_ax] = climada_colormap('FL');
    miv = 0; mav = 4;
    plotclr(hazard.lon, hazard.lat, hazard.intensity(i,:),'s',1,colorbar_on, miv, mav, cmap);
    hold on 
    set(get(colorbar,'ylabel'),'string',sprintf('hazard intensity (%s)',hazard.units),'fontsize',12)
    %caxis([0 4])
    
    
    %axislim = [-89.2265 -89.182 13.655 13.69];
    axislim = [-89.25 -89.15 13.678 13.7];
    axis(axislim)
    box on
    axis equal
    %if cat_i == 1
    %    %axis(axislim)
    %end
    
    % shape files
    %plot(focus_shp.lon,focus_shp.lat,'color','k','linewidth',1);%black  
    %plot(AMSS.lon,AMSS.lat,'color',[173 173 173]/255,'linewidth',1);%grey    

    %for cat_i = length(categories):-1:1
    %    indx = entity.assets.Category == categories(cat_i);  
    %    h(cat_i) = plot(entity.assets.lon(indx), entity.assets.lat(indx),marker{cat_i},'markerfacecolor',markercolor_(cat_i,:), 'MarkerEdgeColor', 'none');
    %end
    % set(get(cbar,'ylabel'),'String', sprintf('Value per pixel (%s)', unit) ,'fontsize',12);  
    %titlestr = sprintf('San Salvador, El Garrobo');
    titlestr = sprintf('San Salvador, Rio Acelhuate, %s', hazard.event{i});
    title(titlestr)
    %climada_plot_world_borders(0.5,'','',1);
    %box on
    %legend(h,category_names,'location','southoutside')
    
    
%     % % colors for admin 0,1,2
%     colors_        = [139 139 122;...   % lightyellow 4
%                         0 104 139;...   % deepskyblue 4
%                       135 206 235]/255; % skyblue
%     % plot administrative boundaries
%     shp_file_ = 'SLV_adm';
%     for ii = 2:-1:0
%         shp_file = sprintf('%s%d.shp',shp_file_,ii);
%         shapes   = climada_shaperead([GIS_open_dat_dir filesep shp_file],0,1,0,1); % 0 for no-save
%         for shape_i=1:length(shapes)
%             h(ii+1) = plot(shapes(shape_i).X,shapes(shape_i).Y,'color',colors_(ii+1,:));
%             %pos=find(~isnan(shapes(shape_i).X)); % remove NaN to fill
%             %plot(shapes(shape_i).X(pos),shapes(shape_i).Y(pos));
%             %fill(shapes(shape_i).X(pos),shapes(shape_i).Y(pos),color_list(color_i)),hold on
%         end % shape_i
%     end
%     %legend(h,'SLV admin 0','SLV admin 1','SLV admin 2')
    
%     % set title
%     if i >6
%         titlestr = sprintf('San Salvador, El Garrobo, Flood %s', hazard.name{i});
%     else
%         titlestr = sprintf('San Salvador, El Garrobo, Flood return period %d years', 1/hazard.frequency(i));
%     end
%     title(titlestr)

%     if i>6
%         foldername = sprintf('%sresults%sSanSalvador%sFlood_El_Garrobbo_%s.pdf', filesep,filesep,filesep,hazard.name{i});
%     else
%         foldername = sprintf('%sresults%sSanSalvador%sFlood_El_Garrobbo_%d_year_return_period.pdf', filesep,filesep,filesep,1/hazard.frequency(i));
%     end
    foldername = sprintf('%sresults%sSanSalvador%sFlood_Rio_Acelhuate_%s.pdf', filesep,filesep,filesep,hazard.event{i});
    print(fig,'-dpdf',[climada_global.data_dir foldername])
    %close
end
   


%%
               
for i = 1 %9
    % create figure
    %fig = climada_figuresize(0.8,1);
    fig = climada_figuresize(0.4,0.8);
    
    % plot hazard event
    %i = 1;
    %climada_hazard_plot(hazard, i,'',caxis_range);
    colorbar_on = 1;
    %[cmap c_ax] = climada_colormap('FL');
    cmap = jet;
    miv = []; mav = [];
    plotclr(hazard.lon, hazard.lat, hazard.intensity(i,:),'s',1,colorbar_on, miv, mav, cmap);
    hold on 
    set(get(colorbar,'ylabel'),'string',sprintf('hazard intensity (%s)','m difference between indundation and DEM'),'fontsize',12)
    %caxis([0 4])
    
    
    %axislim = [-89.2265 -89.182 13.655 13.69];
    axislim = [-89.25 -89.15 13.678 13.7];
    axis(axislim)
    box on
    axis equal
    %if cat_i == 1
    %    %axis(axislim)
    %end
    
    % shape files
    %plot(focus_shp.lon,focus_shp.lat,'color','k','linewidth',1);%black  
    %plot(AMSS.lon,AMSS.lat,'color',[173 173 173]/255,'linewidth',1);%grey    

    %for cat_i = length(categories):-1:1
    %    indx = entity.assets.Category == categories(cat_i);  
    %    h(cat_i) = plot(entity.assets.lon(indx), entity.assets.lat(indx),marker{cat_i},'markerfacecolor',markercolor_(cat_i,:), 'MarkerEdgeColor', 'none');
    %end
    % set(get(cbar,'ylabel'),'String', sprintf('Value per pixel (%s)', unit) ,'fontsize',12);  
    %titlestr = sprintf('San Salvador, El Garrobo');
    titlestr = sprintf('San Salvador, Rio Acelhuate, %s', hazard.event{i});
    title(titlestr)
    %climada_plot_world_borders(0.5,'','',1);
    %box on
    %legend(h,category_names,'location','southoutside')
    
    
%     % % colors for admin 0,1,2
%     colors_        = [139 139 122;...   % lightyellow 4
%                         0 104 139;...   % deepskyblue 4
%                       135 206 235]/255; % skyblue
%     % plot administrative boundaries
%     shp_file_ = 'SLV_adm';
%     for ii = 2:-1:0
%         shp_file = sprintf('%s%d.shp',shp_file_,ii);
%         shapes   = climada_shaperead([GIS_open_dat_dir filesep shp_file],0,1,0,1); % 0 for no-save
%         for shape_i=1:length(shapes)
%             h(ii+1) = plot(shapes(shape_i).X,shapes(shape_i).Y,'color',colors_(ii+1,:));
%             %pos=find(~isnan(shapes(shape_i).X)); % remove NaN to fill
%             %plot(shapes(shape_i).X(pos),shapes(shape_i).Y(pos));
%             %fill(shapes(shape_i).X(pos),shapes(shape_i).Y(pos),color_list(color_i)),hold on
%         end % shape_i
%     end
%     %legend(h,'SLV admin 0','SLV admin 1','SLV admin 2')
    
%     % set title
%     if i >6
%         titlestr = sprintf('San Salvador, El Garrobo, Flood %s', hazard.name{i});
%     else
%         titlestr = sprintf('San Salvador, El Garrobo, Flood return period %d years', 1/hazard.frequency(i));
%     end
%     title(titlestr)

%     if i>6
%         foldername = sprintf('%sresults%sSanSalvador%sFlood_El_Garrobbo_%s.pdf', filesep,filesep,filesep,hazard.name{i});
%     else
%         foldername = sprintf('%sresults%sSanSalvador%sFlood_El_Garrobbo_%d_year_return_period.pdf', filesep,filesep,filesep,1/hazard.frequency(i));
%     end
    foldername = sprintf('%sresults%sSanSalvador%sFlood_Rio_Acelhuate_%s.pdf', filesep,filesep,filesep,'Original_difference_indundation_DEM');
    print(fig,'-dpdf',[climada_global.data_dir foldername])
    %close
end
   

%% prepare figure
% close all; h=[];
% fig = climada_figuresize(0.5,0.7);
% % h(1) = plot(BCC(1).X,BCC(1).Y,'color',[240 128 128]/255);
% h(1) = plot(BCC(1).lon,BCC(1).lat,'color',[240 128 128]/255);
% hold on

% % plot admin4
% for shape_i=1:length(AMSS)
%     h(2)= plot(AMSS(shape_i).X,AMSS(shape_i).Y,'color',[191 191 191]/255);%grey
% end

% % plot BCC wards (fill polygons)
% color_ = jet(length(BCC_wards));
% for w_i=1:length(BCC_wards)
%     %h(3)= plot(BCC_wards(w_i).lon,BCC_wards(w_i).lat,'color',[244 164 96 ]/255,'linewidth',2);%sandybrown
%     h(3)= plot(BCC_wards(w_i).lon,BCC_wards(w_i).lat,'color','k','linewidth',1);%sandybrown
%     %fill(BCC_wards(w_i).lon,BCC_wards(w_i).lat,color_(w_i,:));%sandybrown
% end
% % add labels (ward names)
% for w_i=1:length(BCC_wards)
%     text(mean(BCC_wards(w_i).lon), mean(BCC_wards(w_i).lat), BCC_wards(w_i).UNION_NAME)
% end

% climada_plot_world_borders(0.5)
           
%% plot figure for every asset class
% axislim        = [-89.27 -89.13 13.63 13.7]; %salvador close up close all
% entity.assets.reference_year = 2015; 
% categories     = unique(entity.assets.Category); 
% category_names = entity.assets.Category_names(categories); 
% % category_names = entity.assets.Categories(categories); 
% category_units = entity.assets.Unit(categories);
% markersize     = 8; 
% marker         = {'o' 'd' '^' 'p'}; 
% 
% for cat_i = 1:length(categories)
%     indx  = entity.assets.Category == categories(cat_i); 
%     unit  = category_units{cat_i}; 
%     indx2 = ismember(entity.assets.Category,categories(strcmp(category_units,unit)));
%     miv   = min(entity.assets.Value(indx2)); 
%     mav   = max(entity.assets.Value(indx2));
%     
%     % create figure 
%     fig = climada_figuresize(0.5,0.83); 
%     %hold on 
%     cbar  = plotclr(entity.assets.lon(indx), entity.assets.lat(indx), entity.assets.Value(indx),marker{cat_i},markersize,1,...
%             miv,mav,[],0,0);
%     grid off
%     plot(focus_shp.lon,focus_shp.lat,'color','k','linewidth',1);%black
%     plot(AMSS.lon,AMSS.lat,'color',[173 173 173]/255,'linewidth',1);%grey
%     %plot(rios.lon,rios.lat,'color',[173 173 173]/255,'linewidth',1);%grey
%     
%     axis(axislim) 
%     %axis equal 
%     %if cat_i == 1
%     %    axis(axislim)
%     %end
%     
%     % plot administrative boundaries 
%     shp_file_ = 'SLV_adm'; 
%     for i = 2:-1:0
%         shp_file = sprintf('%s%d.shp',shp_file_,i);
%         shapes   = climada_shaperead([GIS_open_dat_dir filesep shp_file],0,1,0,1); %0 for no-save 
%         for shape_i=1:length(shapes)
%             h(i+1)   = plot(shapes(shape_i).X,shapes(shape_i).Y,'color',colors_(i+1,:));
%             %pos=find(~isnan(shapes(shape_i).X)); % remove NaN to fill
%             %plot(shapes(shape_i).X(pos),shapes(shape_i).Y(pos));
%             %fill(shapes(shape_i).X(pos),shapes(shape_i).Y(pos),color_list(color_i)),hold on
%         end % shape_i
%     end
% end
% legend(h,'SLV admin 0','SLV admin 1','SLV admin 2')
% 
% %axislim = [-89.27 -89.17 13.63 13.7]; %salvador close up 
% %daspect
% %pbaspect
% 
% set(get(cbar,'ylabel'),'String', sprintf('Value per pixel (%s)', unit) ,'fontsize',12); 
% titlestr = sprintf('San Salvador, El Garrobo, %s (Total %2.3g %s)', category_names{cat_i}, sum(entity.assets.Value(indx)), unit); 
% title(titlestr)
% %climada_plot_world_borders(0.5,'','',1); 
% box on
% foldername = sprintf('%sresults%sSanSalvador%sValues_AMSS_%s.pdf', filesep,filesep,filesep,category_names{cat_i});
% print(fig,'-dpdf',[climada_global.data_dir foldername])
% close
    



return




