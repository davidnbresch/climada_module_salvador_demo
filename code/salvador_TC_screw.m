function [screw_mod, screw_ext] = salvador_TC_screw
% create moderate and extreme climate change screw for TC San Salvador
% NAME:
%   salvador_TC_screw
% PURPOSE:
%   create moderate and extreme climate change screw for TC San Salvador
% CALLING SEQUENCE:
%   [screw_mod, screw_ext] = salvador_TC_screw
% EXAMPLE:
%   [screw_mod, screw_ext] = salvador_TC_screw
% INPUTS:
%   none, input is hardwired in the code
% OPTIONAL INPUT PARAMETERS:
%   none
% OUTPUTS:
%   screw_mod: a screw structure for moderate climate change, that fits
%   as input for climada_hazard_climate_screw.m. A 1xN structure with fields:
%       .hazard_fld     defines the hazard field to be changed
%       .change         extent of the change at time horizon
%       .year           time horizon
%       .hazard_crit    hazard field to which criteria apply
%       .criteria       criteria for events/locations to change
%       .bsxfun_op      operation of change (e.g. @times,@plus) (function handle)
%   screw_ext: a screw for extreme climate change
% RESTRICTIONS:
% MODIFICATION HISTORY:
% Jacob Anz, 20150923, init
% Lea Mueller, muellele@gmail.com, 20150924, add documentation
%-

%moderate cc screw
%increase overall frequency of all storms (0 up to category 5)
screw_mod(1).hazard_fld         = 'frequency';
screw_mod(1).change             = 1.011;
screw_mod(1).year               = 2040;
screw_mod(1).hazard_crit        = 'category';
screw_mod(1).criteria           = [0 1 2 3 4 5];
screw_mod(1).bsxfun_op          = @times;

%increase global mean maximum wind speed (intensity)
screw_mod(2).hazard_fld         = 'intensity';
screw_mod(2).change             = 1.0184;
screw_mod(2).year               = 2040;
screw_mod(2).hazard_crit        = 'category';
screw_mod(2).criteria           = [0 1 2 3 4 5];
screw_mod(2).bsxfun_op          = @times;
    
%extreme cc screw
%increase overall frequency of all storms (0 up to category 5)
screw_ext(1).hazard_fld         = 'frequency';
screw_ext(1).change             = 1.0184;
screw_ext(1).year               = 2040;
screw_ext(1).hazard_crit        = 'category';
screw_ext(1).criteria           = [0 1 2 3 4 5];
screw_ext(1).bsxfun_op          = @times;
    
%increase global mean maximum wind speed (intensity)
screw_ext(2).hazard_fld         = 'intensity';
screw_ext(2).change             = 1.0331;
screw_ext(2).year               = 2040;
screw_ext(2).hazard_crit        = 'category';
screw_ext(2).criteria           = [0 1 2 3 4 5];
screw_ext(2).bsxfun_op          = @times;
    
    
    