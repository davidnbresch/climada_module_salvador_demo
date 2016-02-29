function fig = climada_map_plot_salvador(entity,EDS,fieldname_to_plot,peril_criterum,unit_criterium,category_criterium,print_figure)
% create a map, for selected assets, plot either asset values or damage
% MODULE:
%   salvador_demo
% NAME:
%   salvador_map_plot
% PURPOSE:
%   create a map, for selected assets, plot either asset values or damage,
%   select a subset of assets depending on peril_ID ('FL', 'TC'), units 
%   ('USD' or 'people') and or category (4 or 7)   
% CALLING SEQUENCE:
%   salvador_map_plot(entity,EDS,fieldname_to_plot,peril_criterum,unit_criterium,category_criterium, print_figure)
% EXAMPLE:
%   salvador_map_plot(entity,EDS,'damage','FL','USD')
%   salvador_map_plot(entity,EDS,'damage','FL','USD',1)
%   salvador_map_plot(entity,'','assets','FL','people')
% INPUTS:
%   entity: an entity (see climada_entity_read)
%       > promted for if not given
%   EDS: an EDS struct, needed only for 'damage'
% OPTIONAL INPUT PARAMETERS:
%   fieldname_to_plot : a string to specify the field to be plotted, 'assets', 'damage' or 'damage_relative'
%   peril_criterum    : a string to select a peril_ID, e.g. 'FL', or empty, see salvador_assets_select
%   unit_criterium    : a string to select a unit, e.g. 'USD', 'people' or empty
%   category_criterium: a scalar to select a category, e.g. 1
%   print_figure      : set to 1 to save as a pdf in [climada_global.project_dir filesep 'PLOTS']
% OUTPUTS:
%   a figure 
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20150731, init
% Lea Mueller, muellele@gmail.com, 20150801, return if invalid selection
% Lea Mueller, muellele@gmail.com, 20150804, differentiate axis_limits for TC and FL
% Lea Mueller, muellele@gmail.com, 20160229, rename to climada_shapeplotter from shape_plotter
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('entity'            ,'var'), entity             = []; end
if ~exist('EDS'               ,'var'), EDS                = []; end
if ~exist('fieldname_to_plot' ,'var'), fieldname_to_plot  = []; end
if ~exist('peril_criterum'    ,'var'), peril_criterum     = []; end
if ~exist('unit_criterium'    ,'var'), unit_criterium     = []; end
if ~exist('category_criterium','var'), category_criterium = []; end
if ~exist('print_figure'      ,'var'), print_figure       = []; end

fig = []; %init

% prompt for entity if not given
if isempty(entity),entity = climada_entity_load;end
if isempty(entity),return;end

if isempty(fieldname_to_plot),fieldname_to_plot = 'assets';end
if ~strcmp(fieldname_to_plot,'assets') 
    if isempty(EDS),return;end
end

if isempty(peril_criterum    ), peril_criterum     = ''; end
if isempty(unit_criterium    ), unit_criterium     = ''; end
if isempty(category_criterium), category_criterium = ''; end
if isempty(print_figure      ), print_figure       = 0 ; end


% set default if not selection is given
if isempty(peril_criterum) & isempty(unit_criterium) & isempty(category_criterium)
    peril_criterum = 'FL';
    unit_criterium = 'USD';
end

% load shape files
shp_file = [climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS.mat'];
if exist(shp_file,'file')
    load([climada_global.project_dir filesep 'system' filesep 'san_salvador_shps_adm2_rivers_salvador_polygon_LS'])
end

timehorizon  = 2015;
[is_selected, peril_criterum, unit_criterium]...
             = salvador_assets_select(entity,peril_criterum, unit_criterium, category_criterium);
if ~any(is_selected)    
    fprintf('Invalid selection. \n'),return
end         
if iscell(unit_criterium); unit_criterium = unit_criterium{1}; end
if iscell(peril_criterum); peril_criterum = peril_criterum{1}; end
cbar_string  = sprintf('%s (%s)', regexprep(strrep(fieldname_to_plot,'_',' '),'(\<[a-z])','${upper($1)}'), unit_criterium);

% set pdf filename
pdf_filename = sprintf('Salvador_%s_%s_cat_%d_%s_%d_%s.pdf',peril_criterum,fieldname_to_plot,...
                                                         category_criterium,unit_criterium,timehorizon, datestr(now,'YYYYmmdd'));  


%% use million figures for unit USD
if strcmp(unit_criterium,'people')
    nice_figure_factor = 1;
    nice_figure_factor_str = '';
else
    nice_figure_factor = 10^-6;
    nice_figure_factor_str = 'm';
end

% create title string
% case 'assets'
if strcmp(fieldname_to_plot,'assets')
    titlestr  = {sprintf('Asset values (cat. %d) exposed to %s, %d', ...
                        category_criterium, peril_criterum, timehorizon); ...
                 sprintf('Total value: %3.1f %s %s', ...
                         sum(entity.assets.Value(is_selected))*nice_figure_factor, nice_figure_factor_str, unit_criterium) };
end

% case damage or damage_relative
if strcmp(fieldname_to_plot,'damage') | strcmp(fieldname_to_plot,'damage_relative')
    titlestr     = {sprintf('Annual expected damage to cat. %d due to %s, %d', ...
                        category_criterium, peril_criterum, timehorizon); ...
                    sprintf('Total damage: %3.2f %s %s (%1.2f%%)', ...
                        sum(EDS.ED_at_centroid(is_selected))*nice_figure_factor, nice_figure_factor_str, unit_criterium, ...
                        sum(EDS.ED_at_centroid(is_selected))/sum(entity.assets.Value(is_selected))*100) };
    if strcmp(fieldname_to_plot,'damage_relative')            
        cbar_string  = sprintf('%s (%s)', regexprep(strrep(fieldname_to_plot,'_',' '),'(\<[a-z])','${upper($1)}'), '%');
    end
end

if strcmp(peril_criterum,'TC')
    AX_LIMITS  = [-89.32 -89.02 13.62 13.85];
    MARKERSIZE = 2;
    right_corner = 1;
    
elseif strcmp(peril_criterum,'FL')
    AX_LIMITS  = [-89.25 -89.16 13.66 13.71];
    MARKERSIZE = 1;
    right_corner = 2;
    
else
    AX_LIMITS  = [-89.32 -89.02 13.62 13.85];
    MARKERSIZE = 2;
    right_corner = 1;
    
end

%% set plotting parameters depending on fieldname to plot
switch fieldname_to_plot
    case 'damage_relative'
        value = EDS.ED_at_centroid./ entity.assets.Value *100;
        cmap = climada_colormap('damage');
        miv  = 0;
        mav  = 30;
        
    case 'damage'
        value = EDS.ED_at_centroid;
        cmap = climada_colormap('damage');
        miv  = 0;
        mav  = 2000;
        if strcmp(unit_criterium,'people')
            mav = 0.05;
        end
        
    case 'assets'
        value = entity.assets.Value;
        cmap = climada_colormap('assets');
        miv  = 0;
        mav  = 10*10^4;
end


%% set figure parameters
FONTSIZE  = 13;
FIGURE_HEIGHT = 0.38;
FIGURE_WIDTH  = 0.85;


%% create figure

fig = climada_figuresize(FIGURE_HEIGHT,FIGURE_WIDTH);
cbar = plotclr(entity.assets.lon(is_selected), entity.assets.lat(is_selected), value(is_selected),...
       's',MARKERSIZE,1,miv,mav,cmap);
if exist(shp_file,'file')
    climada_shapeplotter(shape_rivers,'','X','Y','linewidth',0.2,'color',[0.0   0.6039   0.8039])
    %climada_shapeplotter(shape_rivers(indx_rivers_in_San_Salvador),'','X','Y','linewidth',0.2,'color',[0.0   0.6039   0.8039])
    %climada_shapeplotter(shape_rivers(indx_rivers_in_San_Salvador),'','X_ori','Y_ori','linewidth',0.2,'color',[0.0   0.6039   0.8039])
end
climada_figure_axis_limits_equal_for_lat_lon(AX_LIMITS)
set(get(cbar,'ylabel'),'String', cbar_string,'fontsize',13);
title(titlestr,'fontsize',FONTSIZE)
box on
climada_figure_scale_add('',4,right_corner)

if print_figure
    print(fig,'-dpdf',[climada_global.project_dir filesep 'PLOTS' filesep pdf_filename])
end




