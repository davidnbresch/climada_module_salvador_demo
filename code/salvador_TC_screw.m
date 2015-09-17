    %moderate cc screw
    
    screw_mod(1).hazard_fld         = 'frequency';
    screw_mod(1).change             = 1.011;
    screw_mod(1).year               = 2040;
    screw_mod(1).hazard_crit        = 'category';
    screw_mod(1).criteria           = [4 5];
    screw_mod(1).bsxfun_op          = @times;

    %decrease overall frequency of all storms (0 up to category 5)
    screw_mod(2).hazard_fld         = 'frequency';
    screw_mod(2).change             = 1.011;
    screw_mod(2).year               = 2040;
    screw_mod(2).hazard_crit        = 'category';
    screw_mod(2).criteria           = [0 1 2 3];
    screw_mod(2).bsxfun_op          = @times;
    
    %increase global mean maximum wind speed (intensity)
    screw_mod(3).hazard_fld         = 'intensity';
    screw_mod(3).change             = 1.0184;
    screw_mod(3).year               = 2040;
    screw_mod(3).hazard_crit        = 'category';
    screw_mod(3).criteria           = [0 1 2 3 4 5];
    screw_mod(3).bsxfun_op          = @times;
    
    %extreme cc screw
    
    screw_ext(1).hazard_fld         = 'frequency';
    screw_ext(1).change             = 1.0184;
    screw_ext(1).year               = 2040;
    screw_ext(1).hazard_crit        = 'category';
    screw_ext(1).criteria           = [4 5];
    screw_ext(1).bsxfun_op          = @times;

    %decrease overall frequency of all storms (0 up to category 5)
    screw_ext(2).hazard_fld         = 'frequency';
    screw_ext(2).change             = 1.0184;
    screw_ext(2).year               = 2040;
    screw_ext(2).hazard_crit        = 'category';
    screw_ext(2).criteria           = [0 1 2 3];
    screw_ext(2).bsxfun_op          = @times;
    
    %increase global mean maximum wind speed (intensity)
    screw_ext(3).hazard_fld         = 'intensity';
    screw_ext(3).change             = 1.0331;
    screw_ext(3).year               = 2040;
    screw_ext(3).hazard_crit        = 'category';
    screw_ext(3).criteria           = [0 1 2 3 4 5];
    screw_ext(3).bsxfun_op          = @times;