
// ============================================================================
// SIMPLIFIED PARAMETRIC TURBINE GENERATOR
// ============================================================================

// ============================================================================
// PARAMETRIC VARIABLES
// ============================================================================

// --- Central Hub ---
hub_radius     = 30;          // Radius of the central hub
hub_height     = 30;          // Height of the hub
hub_hollow     = true;        // Make hub hollow?
hub_bore       = 10;          // Inner bore radius (if hollow)

// --- Blades ---
num_blades     = 25;           // Number of blades
blade_length   = 25;          // Length of each blade (from hub surface)
blade_width    = 3;          // Width of blade at root
blade_thickness = 32;           // Blade thickness
blade_taper    = 0.1;         // Tip width = root_width * taper (0.4 = 40% of root)
blade_twist    = 0;          // Total twist angle (°) from root to tip

// --- Path Type ---
path_type = "circular";         // "circular" or "spiral"
spiral_pitch = 0;            // Height per full revolution (only for spiral)

// --- Render Quality ---
$fn = 48;                     // Global resolution
blade_segments = 62;          // Segments per blade (higher = smoother)

// ============================================================================
// MAIN ASSEMBLY
// ============================================================================

turbine_assembly();

// ----------------------------------------------------------------------------
// MODULES
// ----------------------------------------------------------------------------

// Main assembly
module turbine_assembly() {
    central_hub();
    generate_blades();
}

// Central hub (cylinder)
module central_hub() {
    difference() { 
       
        cylinder(r1 = hub_radius, r2 = hub_radius/2, h = hub_height*2, center = false);
        
        
        if (hub_hollow) 
            translate([0,0,-1])
                cylinder(r = hub_bore, h = 2*hub_height+2, center = false);
    }
}

// Generate all blades
module generate_blades() {
    angle_step = 360 / num_blades;
    
    for (i = [0 : num_blades-1]) {
        base_angle = i * angle_step;
        
        if (path_type == "circular") {
            rotate([0,0,base_angle])
                translate([hub_radius, 0, 0])
                    blade();
        }
        else { // spiral
            spiral_blade(base_angle);
        }
    }
}

// ---------------------------------------
// SINGLE BLADE (for circular path)
// ---------------------------------------
module blade() {
    for (seg = [0 : blade_segments-1]) {
        t1 = seg   / blade_segments;
        t2 = (seg+1) / blade_segments;
        
        // Position along blade
        pos1 = t1 * blade_length;
        pos2 = t2 * blade_length;
        
        // Twist (root = 0°, tip = blade_twist)
        twist1 = t1 * blade_twist;
        twist2 = t2 * blade_twist;
        
        // Taper (width decreases from root to tip)
        w1 = blade_width * lerp(1, blade_taper, t1);
        w2 = blade_width * lerp(1, blade_taper, t2);
        
        hull() {
            // Segment 1
            translate([pos1,0,0])
                rotate([0,0,twist1])
                scale([1, w1/blade_width, 1])
                    blade_profile();
            
            // Segment 2
            translate([pos2,0,0])
                rotate([0,0,twist2])
                scale([1, w2/blade_width, 1])
                    blade_profile();
        }
    }
}

// ---------------------------------------
// BLADE FOR SPIRAL PATH
// ---------------------------------------
module spiral_blade(base_angle) {
    for (seg = [0 : blade_segments-1]) {
        t1 = seg   / blade_segments;
        t2 = (seg+1) / blade_segments;
        
        // Spiral calculations
        angle1 = base_angle + t1 * 22.5;                // 1 revolution per blade
        angle2 = base_angle + t2 * 22.5;
        z1     = t1 * spiral_pitch;                   // Height
        z2     = t2 * spiral_pitch;
        r1     = hub_radius/2 + t1 * blade_length;       // Radius from center
        r2     = hub_radius/2 + t2 * blade_length;
        
        // Twist & taper (same as circular)
        twist1 = t1 * blade_twist;
        twist2 = t2 * blade_twist;
        w1 = blade_width * lerp(1, blade_taper, t1);
        w2 = blade_width * lerp(1, blade_taper, t2);
        
        hull() {
            // Segment 1
            translate([r1*cos(angle1), r1*sin(angle1), z1])
                rotate([0,0,angle1+90])      // Align blade radially
                rotate([0,twist1,0])
                scale([1, w1/blade_width, 1])
                    blade_profile();
            
            // Segment 2
            translate([r2*cos(angle2), r2*sin(angle2), z2])
                rotate([0,0,angle2+120])
                rotate([0,twist2,0])
                scale([1, w2/blade_width, 1])
                    blade_profile();
        }
    }
}

// ---------------------------------------
// 2D BLADE PROFILE (extruded to 3D)
// ---------------------------------------
module blade_profile() {
    rotate([90,0,0])                     // Make profile vertical
        linear_extrude(height = 0.1)       // Very thin extrusion
            curved_profile();              // 2‑D shape
}

// Simple curved blade profile
module curved_profile() {
    // A rounded rectangle (airfoil‑like)
    difference() {
        // Base rectangle
        square([blade_width, blade_thickness]);
        
        // Round the leading edge
        translate([-blade_width/2, -blade_thickness])
            circle(r = blade_thickness/2, $fn=24);
    }
}

// ============================================================================
// FUNCTIONS
// ============================================================================

// Linear interpolation
function lerp(a, b, t) = a + (b - a) * t;
