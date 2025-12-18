// Basic Hexagonal Lattice Example
module hex_grid(size, count_x, count_y, wall) {
    for (x = [0 : count_x]) {
        for (y = [0 : count_y]) {
            // Offset every other row for hexagonal packing
            translate([x * size * 2 * ((y % 2)), y * size * 2, 0])
            rotate(90)
                difference() {
                    circle(d = size * 2, $fn = 6);
                    circle(d = (size * 2) - (wall * 2), $fn = 6);
                }
        }
    }
}

hex_grid(size=10, count_x=5, count_y=5, wall=2);
