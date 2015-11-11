function selection= climada_value_sum(entity,measures_impact,type,unit,timestamp,index_measures,handles)
% % MODULE:
%   viewer
% NAME:
%   climada_value_sum
% PURPOSE:
%   Select all values for a specific output of one unit (USD/people) 
%   like assets, benefit or damage
% CALLING SEQUENCE:
%   selection= climada_value_sum(entity,measures_impact,type,unit,timestamp,index_measures,handles)
%EXAMPLE
%   selection= climada_value_sum(entity,measures_impact,'assets','USD',1);
% INPUT:
%   entity: an entity structure, see e.g. climada_entity_load and
%       climada_entity_read
%   measures_impact: a measures_impact structure, e.g. produced by salvador_calc_measures
%   type: must be specified from 'assets','benefits' and 'damage'
%   unit: must be specified from 'USD' or 'people'
%   timestamp: can be specified from
%                  1- current state
%                  2- economic growth
%                  3- moderate climate change
%                  4- extreme climate change
%                    (default is 1)
%  index_measures: can be selected from a certain measure (see measure list in the measures_impactfile), default =1;
%  
%                 
% OPTIONAL INPUT PARAMETERS:
%   handles: only used if called from the GUI (measures_viewer)
% OUTPUTS:
%   selection: structure with .lon (.point_lon), .lat (.point_lat) and .value (.point_value) variables from the
%   current selected values.
% MODIFICATION HISTORY:
% Jacob Anz, j.anz@gmx.net, 20151106 init
%-

if ~climada_init_vars,return;end % init/import global variables

%initialize
stopper=0;

%derive list of measures
    for i=1:length(measures_impact(1).EDS)
        index_measures_list{i,1}=measures_impact(1).EDS(i).annotation_name;
    end

%default values
if ~exist('unit','var'); unit='USD';end
if ~exist('timestamp','var'); timestamp=1;end
if ~exist('type','var'); type='assets';end
if ~exist('index_measures','var'); index_measures=1;end

%detection of peril
if exist('measures_impact','var')
    rb_peril=measures_impact(1).peril_ID;
    message1=sprintf('recognized %s peril',rb_peril);
    message2=sprintf('Measure %s selected',index_measures_list{index_measures,1});
    message=[message1 ' and ' message2];
    
    %interaction with GUI (measures_viewer)
    try 
        set(handles.text15,'String',message);
    catch
        msgbox(message);
    end
end

categories=unique(entity.assets.Category);
categories(length(categories)+1)=length(categories)+1;

%automatical detection of position of value_unit: USD or people
for i=1:length(categories)-1 
    pos=(find(entity.assets.Category==categories(i)));
    posi=pos(1);
    position{i}=entity.assets.Value_unit{posi};
end
    position{length(position)+1}='all categories with same unit';
for i=1:length(categories)
    string_vec{i}=[num2str(categories(i)) ' - ' position{i}];
end

for i=1:length(string_vec)-1
    if findstr(string_vec{i},'USD')>=1
        index_USD(i)=i;
    elseif findstr(string_vec{i},'people')>=1
        index_people(i)=i;
    end
end
index_USD(index_USD==0)=[];index_people(index_people==0)=[];
category_list_usd=categories(index_USD)';category_list_people=categories(index_people)';

if strcmp(unit,'USD')
    temp_ind_cat=category_list_usd; 
elseif strcmp(unit,'people')
    temp_ind_cat=category_list_people;
end

    t.coord_tot=[];t.value_tot=[];
    for index_cat=temp_ind_cat
        is_selected = climada_assets_select(entity,rb_peril,unit,index_cat);
        
        if strcmp(type,'assets');
            coord(:,1)=entity.assets.lon(is_selected);
            coord(:,2)=entity.assets.lat(is_selected);
            value=entity.assets.Value(is_selected);
        elseif strcmp(type,'damage');
           coord(:,1)= measures_impact(timestamp).EDS(index_measures).assets.lon(is_selected);
           coord(:,2)= measures_impact(timestamp).EDS(index_measures).assets.lat(is_selected);
           value=measures_impact(1).EDS(1).ED_at_centroid(is_selected);
        elseif strcmp(type,'benefit');
            stopper=stopper+1;
            if stopper==1;
                for i=1:length(measures_impact(1).EDS)
                    benefit{i}=measures_impact(1).EDS(length(measures_impact(1).EDS)).ED_at_centroid-measures_impact(1).EDS(i).ED_at_centroid;
                end
            end
           coord(:,1)= measures_impact(timestamp).EDS(index_measures).assets.lon(is_selected);
           coord(:,2)= measures_impact(timestamp).EDS(index_measures).assets.lat(is_selected);
           value= benefit{1,index_measures}(is_selected);
        end
        
           t.coord_tot=[t.coord_tot;coord];
           t.value_tot=[t.value_tot;value];
           clear is_selected coord value
     end
    
    [~,~,idx]=unique(t.coord_tot,'rows','stable');
    t_max=max(idx);
    for j=1:t_max
        t_indx{j}=find(idx==j);
    end
    
    for j=1:length(t_indx)
            selection.point_value(j)=sum(t.value_tot(t_indx{j}));
            selection.point_lon(j)=unique(t.coord_tot(t_indx{j},1));
            selection.point_lat(j)=unique(t.coord_tot(t_indx{j},2));
    end
end