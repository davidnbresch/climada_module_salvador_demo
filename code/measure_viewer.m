function varargout = measure_viewer(varargin)
% MEASURE_VIEWER MATLAB code for measure_viewer.fig
%      MEASURE_VIEWER, by itself, creates a new MEASURE_VIEWER or raises the existing
%      singleton*.
%
%      H = MEASURE_VIEWER returns the handle to a new MEASURE_VIEWER or the handle to
%      the existing singleton*.
%
%      MEASURE_VIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEASURE_VIEWER.M with the given input arguments.
%
%      MEASURE_VIEWER('Property','Value',...) creates a new MEASURE_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before measure_viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to measure_viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% MODULE:
%   viewer
% NAME:
%   measure_viewer
% PURPOSE:
%   plots entities, assets and damage
% CALLING SEQUENCE:
%   measure_viewer
%EXAMPLE
%   measure_viewer
% INPUT:
%   (all inputs are asked for by the GUI)
%   entity: an entity structure, see e.g. climada_entity_load and climada_entity_read
%   measures_impact: a measures_impact structure, e.g. produced by salvador_calc_measures
%   type: must be specified from 'assets','benefits' and 'damage'
%   unit: must be specified from 'USD' or 'people'
%   timestamp: can be specified from
%                  1- current state
%                  2- economic growth
%                  3- moderate climate change
%                  4- extreme climate change
%                    (default is 1)
%  index_measures:  can be selected from a certain measure (see measure list in the measures_impactfile), default =1;
%  categories:      Select a certain category from the list
%
%
% OUTPUTS:
%   Graphical result
% OPTIONAL OUTPUTS:
%   A .mat file with the current selection
%   An excel with the curretn selection
%   A .kmz file with the current selection

% MODIFICATION HISTORY:
% Jacob Anz, j.anz@gmx.net, 20151106 init
% Lea Mueller, muellele@gmail.com, 20151110, save kmz to data/results
%-

% Last Modified by GUIDE v2.5 05-Nov-2015 14:22:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @measure_viewer_OpeningFcn, ...
    'gui_OutputFcn',  @measure_viewer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% gui varibale initialization
function measure_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to measure_viewer (see VARARGIN)
%global container
%global climada_global
% Choose default command line output for measure_viewer
handles.output = hObject;
global container
%climada_global = evalin('base', 'climada_global');
%if ~climada_init_vars,return;end % init/import global variables

%climada picture
climada_logo(hObject, eventdata, handles)

% Update handles structure
%set all initial paramters
container.set_axis=0;
%imagesc(uipanel8
guidata(hObject, handles);

function climada_logo(hObject, eventdata, handles)
global climada_global
try
    path_now=pwd;
    cd([ climada_global.modules_dir '\climada_modules_salvador_demo\docs']);
    axes(handles.axes2)
    set(handles.axes2,'visible','off')
    hold on;
    imagesc(imread('climada_sign.png'));
    set(handles.axes2,'YDir','reverse');
    %axis visibility off
    set(handles.axes2,'color','none')
    %set(handles.axes2,'xtick','off')
    cd(path_now);
end

% --- Outputs from this function are returned to the command line.
function varargout = measure_viewer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
global container

if length(container.measures_impact)>1
    for i=1:length(container.measures_impact(1).EDS)
        measures{i,1}=container.measures_impact(1).EDS(i).annotation_name;
    end
else
    for i=1:length(container.measures_impact.EDS)
        measures{i,1}=container.measures_impact.EDS(i).annotation_name;
    end
end

set(handles.listbox1,'String',measures);
container.index_measures = get(hObject,'Value');
assignin('base','container',container);
assignin('base','index_measures',container.index_measures);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
global container

categories=unique(container.entity.assets.Category);
categories(length(categories)+1)=length(categories)+1;
for i=1:length(categories)
    cat{i}=num2str(categories(i));
end

set(handles.listbox2,'Max',length(cat));
set(handles.listbox2,'String',cat);

contents = cellstr(get(hObject,'String'));
select= contents{get(hObject,'Value')};
container.index_categories=str2double(select);
assignin('base','container',container);
assignin('base','index_categories',container.index_categories);

%automatical detection of value_unit: USD or people
for i=1:length(categories)-1
    pos=(find(container.entity.assets.Category==categories(i)));
    posi=pos(1);
    position{i}=container.entity.assets.Value_unit{posi};
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
index_USD(index_USD==0)=[];
index_people(index_people==0)=[];
container.category_list_usd=categories(index_USD)';
container.category_list_people=categories(index_people)';
set(handles.listbox2,'String',string_vec);

if ismember(container.index_categories,container.category_list_usd)
    container.rb5=0;
    container.rb4=0;
    set(handles.radiobutton4,'Value',1);    %USD
    set(handles.radiobutton5,'Value',0);
    container.rb4=1;
elseif ismember(container.index_categories,container.category_list_people)
    container.rb5=0;
    container.rb4=0;
    set(handles.radiobutton4,'Value',0);
    set(handles.radiobutton5,'Value',1);
    container.rb5=1;
end

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- category: Damage.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global container
container.rb1=get(hObject,'Value');
if container.rb1==1
    set(handles.radiobutton2,'Value',0);
    set(handles.radiobutton3,'Value',0);
    container.rb2=0;
    container.rb3=0;
    container.type='damage';
end

% --- category: Assets
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global container
container.rb2=get(hObject,'Value');
if container.rb2==1
    set(handles.radiobutton1,'Value',0);
    set(handles.radiobutton3,'Value',0);
    container.rb1=0;
    container.rb3=0;
    container.type='assets';
end

% --- category: Entity
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global container
container.rb3=get(hObject,'Value');
%calculate the benefit
for i=1:length(container.measures_impact(1).EDS)
    container.benefit{i}=container.measures_impact(1).EDS(length(container.measures_impact(1).EDS)).ED_at_centroid-container.measures_impact(1).EDS(i).ED_at_centroid;
end
if container.rb3==1
    set(handles.radiobutton2,'Value',0);
    set(handles.radiobutton1,'Value',0);
    container.rb2=0;
    container.rb1=0;
    container.type='benefit';
end

% USD
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global container
container.rb4=get(hObject,'Value');
if container.rb4==1
    set(handles.radiobutton5,'Value',0);
    container.rb5=0;
end

% People
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global container
container.rb5=get(hObject,'Value');
if container.rb5==1
    set(handles.radiobutton4,'Value',0);
    container.rb4=0;
end

% flood
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global container
rb_flood=get(hObject,'Value');
if rb_flood==1
    container.rb_6=1;
    container.rb_peril='FL';
end

if container.rb_6==1
    set(handles.radiobutton7,'Value',0);
    set(handles.radiobutton8,'Value',0);
    container.rb7=0;
    container.rb8=0;
end
check_peril(hObject, eventdata, handles)

% cylcone
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global container
rb_storm=get(hObject,'Value');
if rb_storm==1
    container.rb_7=1;
    container.rb_peril='TC';
end
if container.rb_7==1
    set(handles.radiobutton6,'Value',0);
    set(handles.radiobutton8,'Value',0);
    container.rb6=0;
    container.rb8=0;
end
check_peril(hObject, eventdata, handles)

% landslides
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global container
rb_landslide=get(hObject,'Value');
if rb_landslide==1
    container.rb_8=1;
    container.rb_peril='LS';
end
if container.rb_8==1
    set(handles.radiobutton6,'Value',0);
    set(handles.radiobutton7,'Value',0);
    container.rb6=0;
    container.rb7=0;
end
check_peril(hObject, eventdata, handles)

%load measure impact file
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% prompt for file if not given
global container
%load measures impact file
set(handles.figure1, 'pointer', 'watch')
drawnow;
% [filename, pathname] = uigetfile({'*.mat'}, 'Select measures_impact file:');
% filename_tot = fullfile(pathname,filename);
% 
% temp=open(filename_tot);
%container.measures_impact=temp.measures_impact;
container.measures_impact=climada_measures_impact_load;
clear filename pathname filename_tot

%load entity
container.entity = climada_entity_load;
% [filename, pathname] = uigetfile({'*.mat'}, 'Select entity file:');
% filename_tot = fullfile(pathname,filename);
% container.entity=open(filename_tot);

%recognize peril_ID
container.rb_peril=container.measures_impact(1).peril_ID;
message=sprintf('recognized %s peril',container.rb_peril);
if container.rb_peril=='FL'
    container.measures_impact_FL=container.measures_impact;
    container.entity_FL=container.entity;
elseif container.rb_peril=='TC'
    container.measures_impact_TC=container.measures_impact;
    container.entity_TC=container.entity;
elseif container.rb_peril=='LS'
    container.measures_impact_LS=container.measures_impact;
    container.entity_LS=container.entity;
end
msgbox(message);

listbox1_Callback(hObject, eventdata, handles);
listbox2_Callback(hObject, eventdata, handles);
display('done');
set(handles.figure1, 'pointer', 'arrow')

%execute each function to return the current state
radiobutton4_Callback(hObject, eventdata, handles)
radiobutton5_Callback(hObject, eventdata, handles)

function check_peril(hObject, eventdata, handles)
%Selection of peril
global container
if container.rb_peril=='FL'
    container.measures_impact=container.measures_impact_FL;
    container.entity=container.entity_FL;
elseif container.rb_peril=='TC'
    container.measures_impact=container.measures_impact_TC;
    container.entity=container.entity_TC;
elseif container.rb_peril=='LS'
    container.measures_impact=container.measures_impact_LS;
    container.entity=container.entity_LS;
end

listbox1_Callback(hObject, eventdata, handles);
listbox2_Callback(hObject, eventdata, handles);
radiobutton4_Callback(hObject, eventdata, handles)
radiobutton5_Callback(hObject, eventdata, handles)
display('Peril loaded');

% plotting
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global container

%default values=
container.unit_criterium='';

set(handles.figure1, 'pointer', 'watch')
drawnow;
cla reset
clear cbar
cla (handles.axes1,'reset')
axes(handles.axes1);
markersize=2;
miv=0.1;

%select for USD or people
if container.rb4 ==1 && container.rb5 ==1
    container.unit_criterium='';
    set(handles.text15,'String','Please select either USD or People');
    
elseif container.rb4 ==1
    container.unit_criterium='USD';
    if container.index_categories==length(unique(container.entity.assets.Category))+1;
        temp_ind_cat=container.category_list_usd;
    else
        
    end
elseif container.rb5 ==1
    container.unit_criterium='people';
    if container.index_categories==length(unique(container.entity.assets.Category))+1;
        temp_ind_cat=container.category_list_people;
    else
        %        container.index_categories='';                                      %deaktiviert categories selection
    end
else
    container.unit_criterium='';
end

%check if Peril id matches selection
if ~isfield(container,'rb_peril')
    set(handles.text15,'String','Please select a peril');
    
elseif container.measures_impact(container.timestamp).peril_ID ~=container.rb_peril
    set(handles.text15,'String','Selected peril does not match measures impact file, please select a different peril');
    return
end

%special case to get sum over all categories (USD/people) (artificial last category)
if container.index_categories==length(unique(container.entity.assets.Category))+1;
    selection= climada_value_sum(container.entity,container.measures_impact,container.type,container.unit_criterium,container.timestamp,container.index_measures,handles);
end

is_selected = climada_assets_select(container.entity,container.rb_peril,container.unit_criterium,container.index_categories);
container.is_selected=is_selected;

%Message if no entity selected
if ~isfield(container, 'rb1') && ~isfield(container, 'rb2') && ~isfield(container, 'rb3')
    message='Please select an entity';
    set(handles.text15,'String',message);
else
    %check for small values <1 that make problems if plotting on exponential scale and miv is set
    
    %damage
    if container.rb1==1;
        if strcmp(container.rb_peril,'FL'); container.peril_color='FL';
        elseif strcmp(container.rb_peril,'TC'); container.peril_color='TC';
        elseif strcmp(container.rb_peril,'TC'); container.peril_color='MS';
        end
        if container.index_categories==9;
            if max(selection.point_value)<1;miv=[]; end
            container.plot_lon=selection.point_lon;container.plot_lat=selection.point_lat;container.plot_value=selection.point_value;
        else
            
            if max(container.measures_impact(container.timestamp).EDS(container.index_measures).ED_at_centroid(is_selected))<1;miv=[];end
            container.plot_lon=container.measures_impact(container.timestamp).EDS(container.index_measures).assets.lon(is_selected);
            container.plot_lat=container.measures_impact(container.timestamp).EDS(container.index_measures).assets.lat(is_selected);
            container.plot_value=container.measures_impact(container.timestamp).EDS(container.index_measures).ED_at_centroid(is_selected);
        end
        set(handles.text1,'String',sum(container.measures_impact(1).EDS(container.index_measures).assets.lat(is_selected)));
        
        %assets
    elseif  container.rb2==1;
        container.peril_color='assets';
        if container.index_categories==9;
            if max(selection.point_value)<1;miv=[]; end
            container.plot_lon=selection.point_lon;container.plot_lat=selection.point_lat;container.plot_value=selection.point_value;
        else
            if max(container.measures_impact(container.timestamp).EDS(container.index_measures).assets.Value(is_selected))<1;miv=[];end
            container.plot_lon=container.measures_impact(container.timestamp).EDS(container.index_measures).assets.lon(is_selected);
            container.plot_lat=container.measures_impact(container.timestamp).EDS(container.index_measures).assets.lat(is_selected);
            container.plot_value=container.measures_impact(container.timestamp).EDS(container.index_measures).assets.Value(is_selected);
        end
        set(handles.text2,'String',sum(container.measures_impact(1).EDS(container.index_measures).assets.Value(is_selected)));
        
        %benefit
    elseif container.rb3==1;
        container.peril_color='benefit';
        if container.index_categories==9;
            if max(selection.point_value)<1;miv=[]; end
            container.plot_lon=selection.point_lon;container.plot_lat=selection.point_lat;container.plot_value=selection.point_value;
        else
            if max(container.benefit{1,container.index_measures}(is_selected))<1;miv=[]; end
            container.plot_lon=container.measures_impact(container.timestamp).EDS(container.index_measures).assets.lon(is_selected);
            container.plot_lat=container.measures_impact(container.timestamp).EDS(container.index_measures).assets.lat(is_selected);
            container.plot_value=container.benefit{1,container.index_measures}(is_selected);
        end
        set(handles.text3,'String',sum(container.benefit{1,container.index_measures}(is_selected)));
    end
    if sum(container.plot_value)==0;
        message='no values to plot, all selected values are 0';
    else
        cbar=plotclr(container.plot_lon,container.plot_lat,container.plot_value,'s',markersize,1,miv,[],climada_colormap(container.peril_color),[],1);
        set(get(cbar,'ylabel'),'String', 'value per pixel (exponential scale)' ,'fontsize',12);
        message='values plotted';
    end
    set(handles.text15,'String',message);
    set(gcf,'toolbar','figure');
    set(gcf,'menubar','figure');
    climada_figure_scale_add
    title(container.measures_impact(container.timestamp).EDS(container.index_measures).annotation_name);
    
    if container.set_axis==1
        if isfield(container, 'axis_ol') && isfield(container, 'axis_or') && isfield(container, 'axis_ul') && isfield(container, 'axis_ur')
            climada_figure_axis_limits_equal_for_lat_lon([container.axis_ul container.axis_ur container.axis_ol container.axis_or])
            
        else
            set(handles.text15,'String','Please enter axis limits');
        end
        
    end
    hold on
end

if ~isfield(container, 'plot_river')&& get(handles.checkbox1,'Value')==1;
    set(handles.text15,'String','Please load a shape file first');
    
elseif isfield(container, 'plot_river')&& container.plot_river==1 && isfield(container, 'shapes');
    shape_plotter(container.shapes.shape_rivers)
    
end

if ~isfield(container, 'plot_roads') && get(handles.checkbox2,'Value')==1;
    set(handles.text15,'String','Please load a shape file first');
elseif isfield(container, 'plot_roads')&& container.plot_roads==1 && isfield(container, 'shapes');
    shape_plotter(container.shapes.shape_roads)
end
set(handles.figure1, 'pointer', 'arrow');
climada_logo(hObject, eventdata, handles);

%shapes
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global container
[filename, pathname] = uigetfile({'*.mat'}, 'Select shape file:');
filename_tot = fullfile(pathname,filename);
container.shapes=open(filename_tot);

% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function text3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% plot river
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global container
container.plot_river=get(hObject,'Value') ;

% plot roads
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global container
container.plot_roads=get(hObject,'Value');

%Save matlab selection in .mat file
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global container
answer=inputdlg('Enter a filename','save to matfile');

matfile.lon=container.plot_lon;
matfile.lat=container.plot_lat;
matfile.value=container.plot_value;
container.matfile=matfile;

save(answer{1},'matfile')

% Export to excel
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton6_Callback(hObject, eventdata, handles)

global container
filename=inputdlg('Enter a filename','Export to excel');
filename=filename{1};
sheet = 1;

xlRange = 'A1';
category{1}='longitude';
xlswrite(filename,category,sheet,xlRange)

xlRange = 'A2';
xlswrite(filename,container.matfile.lon,sheet,xlRange)

xlRange = 'B1';
category{1}='latitude';
xlswrite(filename,category,sheet,xlRange)

xlRange = 'B2';
xlswrite(filename,container.matfile.lat,sheet,xlRange)

xlRange = 'C1';
category{1}='value';
xlswrite(filename,category,sheet,xlRange)

xlRange = 'C2';
xlswrite(filename,container.matfile.value,sheet,xlRange)

% google earth
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global climada_global container
container.set_axis=1;
pushbutton2_Callback(hObject, eventdata, handles);
path_now=pwd;

% this line is not used, can lead to errors
% 1) use filesep instead of \, as this works on different operating systems (Windows, Mac)
% 2) do not use hardwired module names as this can be changed by the user
%cd([ climada_global.modules_dir '\climada_module_kml_toolbox\code']);
% do actively set the directory where the kmz file is stored, I suggest to
% use data/results
% Jacob, please set a usefule name, so that the user find the created kmz results and know what he/she plotted
plot_name = 'set_as_useful_name';
google_earth_save = [climada_global.data_dir filesep 'results' filesep plot_name '.kmz'];
% save kmz file
k = kml(google_earth_save);
% k = kml;
%manually adjust the kml output to the topography (E.g. rivers) as the
%default is off
%west, east, south, north extension and layer angle (rotation) can be set
offset.west=+0.023;
offset.east=+0.019;
offset.south=+0.05;       
offset.north=-0.0025;     
k.transfer(handles.axes1,offset,'rotation',+3)
k.run

%run
uiwait(msgbox('Please open the .kmz file manually from its folder, its stored in the code folder of the climada_module_kml_toolbox'));
cd(path_now);

% Load file
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global container

pos=get(hObject,'Value');
contents = cellstr(get(hObject,'String')); %returns popupmenu1 contents as cell array

%load selected file

[filename, pathname] = uigetfile({'*.mat','Please select a MAT-file (*.mat)';'*.xls','Please select an Excel-File (*.xls)';'*.xlsx','Please select an Excel-File (*.xlsx)'});
filename_tot = fullfile(pathname,filename);

if pos==2
    if filename==0; filename_tot='entity_flood_file.xls';end
    if regexp(filename,'.xls','once') ||regexp(filename,'.xlsx','once')
        file = climada_entity_read(filename_tot);
    elseif regexp(filename,'.mat','once')
        file = load(filename_tot);
    else
        msgbox('Invalid file format');
    end
    container.assets=file;container.assets.filepath=filename_tot;
    set(handles.text8,'String',filename);
elseif pos==3
    if filename==0; filename_tot='Salvador_hazard_FL_2015.mat';end
    if regexp(filename,'.mat','once')
        file = load(filename_tot);
    else
        msgbox('Invalid file format');
    end
    container.hazard=file;container.hazard.filepath=filename_tot;
    set(handles.text10,'String',filename);
elseif pos==4
    if filename==0; filename_tot='Damage_function_file.xlsx';end
    if regexp(filename,'.xls','once') ||regexp(filename,'.xlsx','once')
        file=climada_damagefunctions_read(filename_tot);
    elseif regexp(filename,'.mat','once')
        file = load(filename_tot);
    else
        msgbox('Invalid file format');
    end
    container.dam_fun=file;container.dam_fun.filepath=filename_tot;
    set(handles.text12,'String',filename);
elseif pos==5
    if filename==0; filename_tot='Measures_file.xlsx';end
    if regexp(filename,'.xls','once') ||regexp(filename,'.xlsx','once')
        file= climada_measures_read(filename_tot);
    elseif regexp(filename,'.mat','once')
        file = load(filename_tot);
    else
        msgbox('Invalid file format');
    end
    container.measures=file;container.measures.filepath=filename_tot;
    set(handles.text14,'String',filename);
end

assignin('base','ent',file);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Plot object
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
global container
markersize=2;
pos=get(hObject,'Value');
cla reset
axes(handles.axes1);

if pos==1
    set(handles.text15,'String','Please select an object from the list');
elseif pos==2
    cbar=plotclr(container.assets.assets.lon,container.assets.assets.lat,container.assets.assets.Value,'s',markersize,1,[],[],[],[],1);
elseif pos==3 %damage
    if length(full(container.hazard.hazard.intensity(:,1)))>1
        event=inputdlg('Enter an event number');
        event=str2num(event{1});
        if event>0 && length(full(container.hazard.hazard.intensity(:,1)) )>event
            cbar=plotclr(container.hazard.hazard.lon,container.hazard.hazard.lat,full(container.hazard.hazard.intensity(event,:)),'s',markersize,1,[],[],[],[],1);
            pit=1;
        else
            mes=sprintf('Select a valid event number between 1 and %d',length(full(container.hazard.hazard.intensity(:,1))));
            set(handles.text15,'String',mes);
            pit=0;
        end
    else
        event=1;
    end
    
elseif pos==4  %damage functions
    description=unique(container.dam_fun.Description,'stable');
    damfun_id=unique(container.dam_fun.DamageFunID);
    [choice,OK] = listdlg('PromptString','Select a damage function:','ListString',description);
    select=find(container.dam_fun.DamageFunID ==damfun_id(choice));
    
    plot(container.dam_fun.Intensity(select),container.dam_fun.MDD(select),'b')
    hold on
    plot(container.dam_fun.Intensity(select),container.dam_fun.PAA(select),'r')
    
end
set(gcf,'toolbar','figure');
set(gcf,'menubar','figure');
if pos==2 || pos==3 && pit==1 ||pos==5
    climada_figure_scale_add;
end

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Open object
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
global container
pos=get(hObject,'Value');

if pos==1
    set(handles.text15,'String','Please select an object from the list');
elseif pos==2
    if regexp(container.assets.filepath,'.xls','once') ||regexp(container.assets.filepath,'.xlsx','once')
        winopen(container.assets.filepath);
    elseif regexp(container.assets.filepath,'.mat','once')
        open(container.assets.filepath);
    else
        msgbox('Invalid file format');
    end
elseif pos==3
    if regexp(container.hazard.filepath,'.mat','once')
        open(container.hazard.filepath);
    elseif regexp(container.hazard.filepath,'.xls','once') ||regexp(container.hazard.filepath,'.xlsx','once')
        winopen(container.hazard.filepath);
    else
        msgbox('Invalid file format');
    end
elseif pos==4
    if regexp(container.dam_fun.filepath,'.xls','once') ||regexp(container.dam_fun.filepath,'.xlsx','once')
        winopen(container.dam_fun.filepath);
    elseif regexp(container.dam_fun.filepath,'.mat','once')
        open(container.dam_fun.filepath);
    else
        msgbox('Invalid file format');
    end
elseif pos==5
    if regexp(container.measures.filepath,'.xls','once') ||regexp(container.measures.filepath,'.xlsx','once')
        winopen(container.measures.filepath);
    elseif regexp(container.measures.filepath,'.mat','once')
        open(container.measures.filepath);
    else
        msgbox('Invalid file format');
    end
end

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global container
container.axis_ol=str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
global container
container.axis_or=str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
global container
container.axis_ul=str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
global container
container.axis_ur=str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
global container
container.set_axis=get(hObject,'Value');

% --- timestamp now.
function radiobutton9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton9
global container
container.rb_9=get(hObject,'Value');
if container.rb_9==1
    container.timestamp=1;
    set(handles.radiobutton10,'Value',0);
    set(handles.radiobutton11,'Value',0);
    set(handles.radiobutton12,'Value',0);
    container.rb10=0;
    container.rb11=0;
    container.rb12=0;
end

% --- timestamp economic growth
function radiobutton10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton10
global container
container.rb_10=get(hObject,'Value');
if container.rb_10==1
    container.timestamp=2;
    set(handles.radiobutton9,'Value',0);
    set(handles.radiobutton11,'Value',0);
    set(handles.radiobutton12,'Value',0);
    container.rb9=0;
    container.rb11=0;
    container.rb12=0;
end

% --- timestamp moderate climate change
function radiobutton11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton11
global container
container.rb_11=get(hObject,'Value');
if container.rb_11==1
    container.timestamp=3;
    set(handles.radiobutton9,'Value',0);
    set(handles.radiobutton10,'Value',0);
    set(handles.radiobutton12,'Value',0);
    container.rb9=0;
    container.rb10=0;
    container.rb12=0;
end

% --- timestep extreme climate change
function radiobutton12_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton12
global container
container.rb_12=get(hObject,'Value');
if container.rb_12==1
    container.timestamp=4;
    set(handles.radiobutton9,'Value',0);
    set(handles.radiobutton11,'Value',0);
    set(handles.radiobutton10,'Value',0);
    container.rb9=0;
    container.rb11=0;
    container.rb10=0;
end
