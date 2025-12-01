/*
    Miniature Japanese Torii Gate GPU Sag Riser
    Based on reference image style (4-pillar support structure).

    Usage:
    1. Adjust 'target_min_height' to be slightly shorter than your GPU gap.
    2. Render and export the "Torii Top Assembly" (STL 1).
    3. Render and export the "Threaded Base Screw" (STL 2).
    4. Print. The Torii Top will likely need supports for the overhangs.
    5. Screw the base into the Torii to adjust height.

    Note: Thread tolerance varies by printer. Adjust 'thread_tolerance' if too tight/loose.
*/

$fn = 64; // Smoothness level for rendering

// --- Main Configuration Parameters ---

// The minimum height of the riser when fully screwed in (mm)
// Measure your GPU gap and make this about 10mm shorter.
target_min_height = 70; 

// The diameter of the adjustment screw mechanism (needs to be sturdy)
screw_diameter = 18; 
screw_travel = 35; // How much height adjustment range you want

// Thread fit tolerance. Increase if screw is too tight.
thread_tolerance = 0.3; 

// Aesthetic scale of the Torii relative to the mechanism
torii_scale = 1.0; 

// Selection: Choose what to view/render
// "both", "top", or "base"
part_to_show = "both";


// --- Derived Dimensions & Colors ---
torii_red = [0.8, 0.1, 0.1];
stone_grey = [0.3, 0.3, 0.35];
roof_black = [0.15, 0.15, 0.15];

// Scaling aesthetic dimensions
p_main_r = 7 * torii_scale; // Main pillar radius
p_main_h = target_min_height * 0.65; // Main pillar height relative to total
gate_width_top = 90 * torii_scale;
pillar_spacing = gate_width_top * 0.55;
pillar_angle = 4; // Slight inward tilt


// ============================================
//  PART SELECTION LOGIC
// ============================================

if (part_to_show == "both") {
    translate([0, 0, screw_travel + 5]) torii_top_assembly();
    threaded_base_screw();
} else if (part_to_show == "top") {
    torii_top_assembly();
} else if (part_to_show == "base") {
    threaded_base_screw();
}


// ============================================
//  MODULES: Torii Aesthetics
// ============================================

module base_stone(r) {
    color(stone_grey)
    resize([r*2.4, r*2.4, r*1.5])
    sphere(r=r);
}

module main_pillar_structure() {
    // Base stones
    translate([-pillar_spacing/2, 0, 0]) base_stone(p_main_r);
    translate([pillar_spacing/2, 0, 0]) base_stone(p_main_r);

    // Pillars
    color(torii_red) {
        // Left Pillar
        translate([-pillar_spacing/2, 0, p_main_r*0.5])
        rotate([0, pillar_angle, 0])
        cylinder(h=p_main_h, r1=p_main_r, r2=p_main_r*0.85);

        // Right Pillar
        translate([pillar_spacing/2, 0, p_main_r*0.5])
        rotate([0, -pillar_angle, 0])
        cylinder(h=p_main_h, r1=p_main_r, r2=p_main_r*0.85);
    }
}

module nuki_lower_lintel() {
    // The straight lower beam passing through pillars
    beam_h = p_main_r * 1.8;
    beam_d = p_main_r * 1.2;
    beam_w = pillar_spacing + p_main_r * 8;
    
    lift_z = p_main_h * 0.75;

    color(torii_red)
    translate([0, 0, lift_z])
    cube([beam_w, beam_d, beam_h], center=true);
}

module side_supports() {
    // The smaller outer pillars and their roofs, specific to the image style
    supp_r = p_main_r * 0.6;
    supp_h = p_main_h * 0.6;
    supp_offset = pillar_spacing/2 + p_main_r * 2.5;
    
    module single_support() {
        // Stone
        base_stone(supp_r);
        // Pillar
        color(torii_red)
        translate([0,0,supp_r*0.5])
        cylinder(h=supp_h, r1=supp_r, r2=supp_r*0.9);
        
        // Little Roof on top connecting to Nuki level
        roof_w = supp_r * 3;
        roof_d = supp_r * 3.5;
        translate([0, 0, supp_h + supp_r]) {
            color(roof_black)
            rotate([0,0,90])
            linear_extrude(height = roof_w, center = true, scale=[0.6, 1])
            polygon(points=[[-roof_d/2, 0], [roof_d/2, 0], [0, roof_d/3]]);
            
            // Connector block under roof
            color(torii_red)
            translate([0,0,-supp_r/2])
            cube([supp_r*1.8, supp_r*1.8, supp_r], center=true);
        }
    }

    translate([-supp_offset, 0, 0]) single_support();
    translate([supp_offset, 0, 0]) single_support();
}

module kasagi_top_lintel() {
    // The complex curved top beam
    lift_z = p_main_h * 0.98;
    beam_w = gate_width_top;
    beam_h_center = p_main_r * 2.5;
    beam_d = p_main_r * 1.6;
    
    curve_radius = beam_w * 1.5;
    
    translate([0,0,lift_z]) {
        color(torii_red) {
            // Main curved body using difference
            difference() {
                // Base block
                translate([0,0, beam_h_center/2])
                cube([beam_w*0.9, beam_d, beam_h_center*1.5], center=true);
                
                // Cutout cylinder for bottom curve
                translate([0, beam_d, -curve_radius + beam_h_center*0.2])
                rotate([90,0,0])
                cylinder(h=beam_d*3, r=curve_radius, center=true, $fn=128);
                 // Cutout cylinder for top curve (slightly shallower)
                 translate([0, beam_d, -curve_radius + beam_h_center*1.2])
                rotate([90,0,0])
                cylinder(h=beam_d*3, r=curve_radius*1.02, center=true, $fn=128);
            }
            
            // Flared Ends (Shimaki tips)
            end_offset = beam_w*0.42;
            translate([-end_offset, 0, beam_h_center*0.6])
            rotate([0, 25, 0])
            cube([beam_w*0.15, beam_d*1.05, beam_h_center*0.5], center=true);

            translate([end_offset, 0, beam_h_center*0.6])
            rotate([0, -25, 0])
            cube([beam_w*0.15, beam_d*1.05, beam_h_center*0.5], center=true);
        }
        
        // Top Roof Cap (black part)
        color(roof_black)
        translate([0,0, beam_h_center*0.8])
        difference() {
             translate([0,0,0])
             resize([beam_w*1.05, beam_d*1.2, beam_h_center*0.4])
             cylinder(r=beam_w/2, h=1, center=true);
             
             // Curve the bottom of the roof cap to match lintel
             translate([0, beam_d, -curve_radius - beam_h_center*0.1])
             rotate([90,0,0])
             cylinder(h=beam_d*4, r=curve_radius, center=true, $fn=128);
        }
        
        // Central support strut (Gakuzuka)
        color(torii_red)
        translate([0,0, -beam_h_center*0.8])
        cube([p_main_r, p_main_r, beam_h_center*0.8], center=true);
    }
}

// ============================================
//  MODULES: Functional Mechanics (Thread)
// ============================================

// A functional, coarse triangular thread for easy printing
module coarse_thread_profile(d, pitch) {
    // 2D Profile of the thread cutting tool
    polygon(points = [
        [d/2 - pitch*0.3, -pitch/2],
        [d/2 + pitch*0.3, 0],
        [d/2 - pitch*0.3, pitch/2],
        [d/2 - pitch*0.6, pitch/2],
        [d/2 - pitch*0.6, -pitch/2]
    ]);
}

module functional_thread_bolt(d, h, pitch) {
    // Central core
    cylinder(r=d/2 - pitch*0.2, h=h);
    // The helical thread
    linear_extrude(height = h, twist = -360 * (h/pitch), slices = h*4)
    coarse_thread_profile(d, pitch);
}

module functional_thread_nut_cutout(d, h, pitch, tol) {
    // Slightly larger profile for tolerance
    d_eff = d + tol;
    cylinder(r=d_eff/2 - pitch*0.2, h=h+1);
    linear_extrude(height = h+1, twist = -360 * ((h+1)/pitch), slices = (h+1)*4)
    offset(r=tol/2) // Add tolerance to the profile
    coarse_thread_profile(d, pitch);
}


// ============================================
//  ASSEMBLY MODULES
// ============================================

module torii_top_assembly() {
    // The visible Torii gate, acting as the "nut"
    
    nut_boss_h = p_main_h * 0.8;
    nut_z_pos = p_main_r; // Start slightly above base stones
    
    difference() {
        union() {
            // Aesthetics
            main_pillar_structure();
            nuki_lower_lintel();
            side_supports();
            kasagi_top_lintel();
            
            // Functional Boss (Hidden block to hold threads)
            color(torii_red)
            translate([0,0, nut_z_pos + nut_boss_h/2])
            cylinder(h=nut_boss_h, r=screw_diameter/2 + 6, center=true);
        }
        
        // Cut the internal thread into the center
        translate([0,0, -1]) // Cut from very bottom
        functional_thread_nut_cutout(screw_diameter, screw_travel + nut_boss_h, 4, thread_tolerance);
    }
}


module threaded_base_screw() {
    // The separate base part that screws in
    base_h = 8;
    base_r = gate_width_top * 0.3;
    screw_len = screw_travel + p_main_h*0.5;

    color(stone_grey) {
        // Wide stable base foot
        difference() {
            cylinder(h=base_h, r=base_r, r2=base_r*0.9);
            // Grip notches
            for(i=[0:45:360]) rotate([0,0,i]) translate([base_r,0,base_h/2]) cube([5,2,base_h], center=true);
        }
        
        // The threaded rod extending upwards
        translate([0,0,base_h])
        functional_thread_bolt(screw_diameter, screw_len, 4);
    }
}