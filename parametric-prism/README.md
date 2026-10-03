# Parametric Prism

A parametric OpenSCAD prism with customizable screw and magnet holes.

## Features

- Base prism: 25cm (height) × 1cm (width) × 1cm (length)
- 45-degree cut in the NW corner on the XY axis (sloping along height)
- Configurable screw holes (M2 or M3) starting from N, S, W, or E sides
- Configurable magnet holes (default 5mm × 3mm) on N, S, or E sides
- Holes start at specific heights with parametric offsets from center
- 0.01mm clearance on all holes for clean rendering

## Parameters

### Dimensions
- `prism_height`: Total height (default: 250mm = 25cm)
- `prism_width`: Width W-E (default: 10mm = 1cm)
- `prism_length`: Length N-S (default: 10mm = 1cm)

### Screw Holes
- `screw_type`: "M2" or "M3" (default: "M3")
- `screw_hole_small`: Small pilot hole diameter (default: 2mm)
- `screw_hole_cone`: Add cone section to screw hole (default: true)
- `n_screw_heights`: Array of heights for N-side screw holes (default: [25, 75, 125, 175, 225])
- `s_screw_heights`: Array of heights for S-side screw holes (default: [])
- `w_screw_heights`: Array of heights for W-side screw holes (default: [50, 100, 150, 200])
- `e_screw_heights`: Array of heights for E-side screw holes (default: [])
- `screw_offset`: Offset from center (default: 0)

### Magnet Holes
- `magnet_diameter`: Magnet diameter (default: 5mm)
- `magnet_height`: Magnet height (default: 3mm)
- `n_magnet_heights`: Array of heights for N-side magnet holes (default: [35, 215])
- `s_magnet_heights`: Array of heights for S-side magnet holes (default: [])
- `e_magnet_heights`: Array of heights for E-side magnet holes (default: [])
- `magnet_offset`: Offset from center (default: 0)

## Usage

Open in OpenSCAD and adjust parameters as needed. Preview with F5, render with F6.

## Customization

Modify the parameter values at the top of `main.scad` to customize:
- Dimensions
- Screw hole positions and types
- Magnet hole positions and sizes
- Offsets from center
