
hex_width = 12;
hex_x_count = 4;
hex_y_count = 4;
hex_wall = 1;
hex_height = 2;

insert_width = hex_width - hex_wall;
insert_line = 1;

led_list_w = 10;

frame_width = 2;
frame_height = hex_height * 4 + led_list_w;



module hex_grid(size, count_x, count_y, wall, solid=false) {
    // Calculate geometric spacing for "Pointy Top" hexagons (rotate(90))
    // Horizontal spacing (flat-to-flat distance): sqrt(3) * radius
    spacing_x = sqrt(3) * size; 
    
    // Vertical spacing (3/2 * radius for nesting)
    spacing_y = size * 1.5; 

    for (x = [0 : count_x], y = [0 : count_y]) {
            // Apply offset: Odd rows shift right by half the X spacing
      if (!((y % 2 == 1) && (x == count_x))) {
            x_pos = (x * spacing_x) + ((y % 2) * (spacing_x / 2));
            y_pos = y * spacing_y;

            translate([x_pos, y_pos, 0])
            rotate(90)
                difference() {
                    // Changed to 'r' syntax for cleaner reading, mathematically identical to your 'd'
                    circle(r = size, $fn = 6);
                    if (!solid) {
                      circle(r = size - wall, $fn = 6);
                    }
                }
      }
    }
}

module hex_frame(size, count_x, count_y, wall) {
    // Calculate geometric spacing for "Pointy Top" hexagons (rotate(90))
    // Horizontal spacing (flat-to-flat distance): sqrt(3) * radius
color("gray")
  linear_extrude(height=frame_height) {
    difference() {
      offset(r=2, chamfer=false) {
        hex_grid(size=size, count_x=count_x, count_y=count_y, wall=wall, solid=true);     
      }
      hex_grid(size=size, count_x=count_x, count_y=count_y, wall=wall, solid=true);
    }
  }
  // top lip
  color("lightgray")
  translate([0,0,frame_height-hex_height]) {
    linear_extrude(height=hex_height) {
      difference() {
        hex_grid(size=size, count_x=count_x, count_y=count_y, wall=wall, solid=true); 
        offset(r=-2, chamfer=false) {
          hex_grid(size=size, count_x=count_x, count_y=count_y, wall=wall, solid=true);   
        }
      }
    }
  }

  // middle lip
  color("lightgray")
  translate([0,0,frame_height-hex_height*3]) {
    linear_extrude(height=hex_height) {
      difference() {
        hex_grid(size=size, count_x=count_x, count_y=count_y, wall=wall, solid=true); 
        offset(r=-1, chamfer=false) {
          hex_grid(size=size, count_x=count_x, count_y=count_y, wall=wall, solid=true);    
        }
      }
    }
  }

  // bottom lip
  color("darkgray")
  translate([0,0,0.0]) {
    linear_extrude(height=hex_height) {
      difference() {
        hex_grid(size=size, count_x=count_x, count_y=count_y, wall=wall, solid=true); 
        offset(r=-5, chamfer=false) {
          hex_grid(size=size, count_x=count_x, count_y=count_y, wall=wall, solid=true);    
        }
      }
    }
  }
}

module hex_insert_frame(size, wall, line) {
  difference() {
    circle(r = size, $fn = 6);
    circle(r = size - wall, $fn = 6);
  }
}

module hex_insert_star(size, wall, line) {
  hex_insert_frame(size=size, wall=wall, line=line);
  difference() {
    circle(r = size, $fn = 3);
    circle(r = size - line, $fn = 3);
  }
  rotate(180)
  difference() {
    circle(r = size, $fn = 3);
    circle(r = size - line, $fn = 3);
  }
}

module hex_insert_seigaiha(size, wall, line) {
  color("green")
  hex_insert_frame(size=size, wall=wall, line=line);

  color("green")
  intersection() {
    rotate(90)
    union() {
    for (i = [0:1.3:15]) {
      translate([0,i,0])
      difference() {
        circle(r = size-i);
        circle(r = size-i-line);
      }
    }
    translate([0,size/2])
    circle(r = size-5.5);
    }
    circle(r = size, $fn = 6);
  }
}

module hex_insert_shippo(size, wall, line) {
    color("red")
    hex_insert_frame(size=size, wall=wall, line=line);

    color("green")
      difference() {
        circle(r = (sqrt(3)/2)*size-line*2);
        circle(r = ((sqrt(3)/2)*size)-line*3);
    }
    color("green")
    intersection() {
      union() {
        for (i = [-(size/2+(size-line)/2),(size/2+(size-line)/2)],
        j = [-(size/2+(size-line)/2),(size/2+(size-line)/2)]) {
          translate([i,j,0])
          difference() {
            circle(r = size);
            circle(r = size-line);
          }
        }
      }
      circle(r = size, $fn = 6);
    }
}

module hex_insert_shokko(size, wall, line) {
    color("red")
    hex_insert_frame(size=size, wall=wall, line=line);
    inner_square = 6;
    color("green")
      intersection() {

        union() {
          difference() {
            square(inner_square, center=true);
            square(inner_square-line*2, center=true);
          }
          square([line,(sqrt(3)/2*size)*2], center=true);
          square([size*2,line], center=true);
          difference() {
            union() {
              union() {
                translate([-inner_square/2,inner_square/2,0])
                rotate(60)
                translate([-line/2,-line,0])
                square([line, size]);

                translate([inner_square/2,inner_square/2,0])
                rotate(-60)
                translate([-line/2,-line,0])
                square([line, size]);
              }
              mirror([0,1,0]) {
              union() {
                translate([-inner_square/2,inner_square/2,0])
                rotate(60)
                translate([-line/2,-line,0])
                square([line, size]);

                translate([inner_square/2,inner_square/2,0])
                rotate(-60)
                translate([-line/2,-line,0])
                square([line, size]);
              }
            }
            }
            square(inner_square, center=true);
          }
        }
      circle(r=size, $fn = 6);
      }
}


module main() {
  // 1. Create hexagonal grid

  // color("white")
  // translate([0,0,frame_height-hex_wall*3])
  // linear_extrude(height=hex_height) {
  //   hex_grid(size=hex_width, count_x=hex_x_count, count_y=hex_y_count, wall=hex_wall);
  // }

  // 2. Create frame surrounding the outside hexagonal grid
  // - frame should have screw holes
  // - frame should have space for led list insert

  // hex_frame(size=hex_width, count_x=hex_x_count, count_y=hex_y_count, wall=hex_wall);

  // 3. Create hexagonal inserts
  // - Atleast:
  //      - One light, one medium, one dark
  // color("purple")
  // translate([0,0,frame_height-hex_wall*3])
  // linear_extrude(height=hex_height) {
  //   translate([31,18,0])
  //   rotate(90)
  //   hex_insert_seigaiha(size=insert_width, wall=hex_wall, line=insert_line);
  // }

  // color("pink")
  // translate([0,0,frame_height-hex_wall*3])
  // linear_extrude(height=hex_height) {
  //   translate([31+21,18,0])
  //   rotate(90)
  //   hex_insert_shippo(size=insert_width, wall=hex_wall, line=insert_line);
  // }

  color("red")
  translate([0,0,frame_height-hex_wall*3])
  linear_extrude(height=hex_height) {
    translate([31+21*2-0.3,18,0])
    rotate(90)
    hex_insert_shokko(size=insert_width, wall=hex_wall, line=insert_line);
  }
}

main();
