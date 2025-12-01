
$fn = 64;


riser_height = 110;
riser_width = 80;


column_dia = 10;
small_col_dia = 5;



// --- Derived Dimensions & Colors ---
torii_red = [0.8, 0.1, 0.1];
stone_grey = [0.3, 0.3, 0.35];
roof_black = [0.15, 0.15, 0.15];


// scaling
column_spacing = riser_width * 0.65;
column_height = riser_height * 0.75;
column_angle = 0;

torii_assemble();

module base_stone(r) {
    color(stone_grey)
    cube([r*2.2, r*2.2, r*0.5], center=true);
}

module main_pillars() {
    translate([column_spacing/2, 0, 0]) base_stone(column_dia);
    translate([-column_spacing/2, 0, 0]) base_stone(column_dia);
    
    color(torii_red) {
        
        translate([column_spacing/2, 0, 0])
        rotate([0, -column_angle, 0])
        cylinder(h=column_height, d=column_dia);
        translate([-column_spacing/2, 0, 0])
        rotate([0, column_angle, 0])
        cylinder(h=column_height, d=column_dia);
    }
}

module support_pillars() {
    support_height = column_height * 0.6;
    support_dia = column_dia * 0.6;
    support_spacing = column_spacing * 0.6;
    
    module single_support() {
        translate([0, support_spacing, 0])
        base_stone(support_dia);
        translate([0, -support_spacing, 0])
        base_stone(support_dia);
        
        color(torii_red) {
            
        translate([0, -support_spacing, 0])
            rotate([0, -0, 0])
            cylinder(h=support_height, d=support_dia);
        translate([0, support_spacing, 0])
            rotate([0, 0, 0])
            cylinder(h=support_height, d=support_dia);
        }
        
    }
    translate([column_spacing/2, 0, 0]) single_support();
    translate([-column_spacing/2, 0, 0]) single_support();
}


/*

module top_roof() {
}

*/



// --- Assembling structure ---

module torii_assemble() {
    main_pillars();
    support_pillars();
}