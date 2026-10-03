# OpenSCAD Projects Repository

This repository contains small OpenSCAD projects and libraries for 3D modeling and design.

## Repository Structure

Each project is organized in its own subdirectory:
```
open-scad-3d/
├── project-name-1/
│   ├── README.md
│   ├── main.scad
│   └── ... (project files)
├── project-name-2/
│   ├── README.md
│   ├── main.scad
│   └── ... (project files)
└── libraries/
    ├── library-name/
    │   ├── README.md
    │   └── library-file.scad
    └── ...
```

## Project Guidelines

- Each project should have its own subdirectory
- Include a README.md in each project directory describing the purpose and usage
- Use descriptive names for project directories
- Main OpenSCAD files should be named clearly (e.g., `main.scad`, `model.scad`)
- Libraries should be placed in the `libraries/` directory for reuse across projects

## OpenSCAD Development

When working with OpenSCAD files:
- Use the OpenSCAD IDE or compatible editor
- Test models by compiling and previewing before committing
- Document custom modules and parameters in comments
- Consider using `use <>` or `include <>` for library dependencies

## Building/Rendering

OpenSCAD files can be rendered using:
- OpenSCAD GUI: File → Export → STL/OBJ/AMF
- Command line: `openscad -o output.stl input.scad`
