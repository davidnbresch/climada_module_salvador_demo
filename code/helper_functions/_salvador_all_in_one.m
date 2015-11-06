%Salvador calculate all results, graphs and final overview
%set entities in
%open salvador_entity_files_set


%waterfall
EDS =salvador_calc_waterfall('TC',[],[],[], [], [],'TC');
EDS =salvador_calc_waterfall('FL',[],[],[], [], [],'FL');
EDS =salvador_calc_waterfall('LS_canas',[],[],[], [], [],'LS_las_canas');
EDS =salvador_calc_waterfall('LS_acelhuate',[],[],[], [], [],'LS_acelhuate');


%cascade/measures calc
salvador_calc_measures('TC',[],[],[], [],'TC');
salvador_calc_measures('FL_AB1',[],[],[], [],'FL','AB1');
salvador_calc_measures('FL_AB2',[],[],[], [],'FL','AB2');
salvador_calc_measures('LS_canas',[],[],[], [],'LS_las_canas');
salvador_calc_measures('LS_acelhuate',[],[],[],[],'LS_acelhuate');

%Summary of results from all perils in !up_to_date waterfall folder
uiwait(msgbox('Please move all generated waterfall folders into the folder "!waterfall up to date" and than click ok'))
filepath=salvador_results_overview;
winopen(filepath)
msgbox('After checking the sourcefile destinations, delete them and use the format painter,to bring the file in a nice format')


