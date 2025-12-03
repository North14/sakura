
$fn = 200;


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

support_height = column_height * 0.6;
support_dia = column_dia * 0.6;
support_spacing = column_spacing * 0.6;

roof_length = column_spacing * 2.0;          // Total width
curve_radius = 900;  // Radius of the arch (Lower = more curve)
roof_depth = 10;    // Y-axis thickness
roof_height = 8;    // Z-axis thickness


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

module main_roof() {
  translate([0, 0, column_height*0.85]) {
    cube([column_spacing, column_dia*0.6, column_dia*0.6], center=true);
    translate([-(column_dia*0.6)/2, 0, 0])
    cube([column_dia*0.6, column_dia*0.6, column_height*0.15]);
  }
    
    // --- Geometry ---
    intersection() {
        // 1. The Infinite Curve (A large torus section)
        translate([0, 0, curve_radius+column_height]) // Move pivot point UP to create "smile"
        rotate([90, 0, 0])              // Rotate to stand upright
        rotate_extrude(angle = 360)     // Create the ring
        translate([curve_radius, 0])    // Offset by radius
        rotate([0, 0, 180])              // Orient profile
            
            // The Cross-Section (Trapezoid: Wider at top, like the image)
            polygon([
                [-roof_height/2, -roof_depth/2 + 2], // Bottom Left (narrower)
                [roof_height/2, -roof_depth],      // Top Left
                [roof_height/2, roof_depth],       // Top Right
                [-roof_height/2, roof_depth/2 - 2]   // Bottom Right (narrower)
            ]);

        // 2. The Bounding Box (Cuts the ring to specific length)
        // This automatically creates the vertical end cuts seen in the photo
        translate([0, 0, column_height+roof_height]) 
        cube([roof_length, roof_height*4, roof_depth*2], center=true);
    }
    translate([0,0,roof_height*0.5])
    scale([1.1,1.2,1])
    rotate([0,0,0])
    intersection() {
        // 1. The Infinite Curve (A large torus section)
        translate([0, 0, curve_radius+column_height]) // Move pivot point UP to create "smile"
        rotate([90, 0, 0])              // Rotate to stand upright
        rotate_extrude(angle = 360)     // Create the ring
        translate([curve_radius, 0])    // Offset by radius
        rotate([0, 0, 180])              // Orient profile
            
            // The Cross-Section (Trapezoid: Wider at top, like the image)
            polygon([
                [-roof_height/2, -roof_depth/2 + 2], // Bottom Left (narrower)
                [roof_height/2, -roof_depth],      // Top Left
                [roof_height/2, roof_depth],       // Top Right
                [-roof_height/2, roof_depth/2 - 2]   // Bottom Right (narrower)
            ]);

        // 2. The Bounding Box (Cuts the ring to specific length)
        // This automatically creates the vertical end cuts seen in the photo
        translate([0, 0, column_height+roof_height]) 
        cube([roof_length, roof_height*4, roof_depth*2], center=true);
    }
}

module support_column() {
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

module support_roof() {
    translate([0, support_spacing, support_height])
    cube([support_dia*2.5,support_dia*2.5,3], center=true);
    translate([0, support_spacing, support_height+3/2])
    linear_extrude(height=5, scale=0)
    square([support_dia*2.5, support_dia*2.5], center=true);

    translate([0, -support_spacing, support_height])
    cube([support_dia*2.5,support_dia*2.5,3], center=true);
    translate([0, -support_spacing, support_height+3/2])
    linear_extrude(height=5, scale=0)
    square([support_dia*2.5, support_dia*2.5], center=true);

    translate([0, 0, support_height*0.65])
    cube([support_dia*0.8,support_spacing*2,support_dia*0.8], center=true);

}

module supports() {
    translate([column_spacing/2, 0, 0]) support_column();
    translate([-column_spacing/2, 0, 0]) support_column();
    translate([column_spacing/2, 0, 0]) support_roof();
    translate([-column_spacing/2, 0, 0]) support_roof();
}


// --- Assembling structure ---

module torii_assemble() {
    main_pillars();
    main_roof();
    supports();
}
