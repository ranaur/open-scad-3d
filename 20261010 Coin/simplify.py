#!/usr/bin/env python3

import argparse
import trimesh
import sys


def main():
    parser = argparse.ArgumentParser(
        description='Simplify a 3D mesh using quadric decimation'
    )
    parser.add_argument(
        'input_file',
        help='Input STL file path'
    )
    parser.add_argument(
        'output_file',
        help='Output STL file path'
    )
    parser.add_argument(
        '--percent',
        '-p',
        type=float,
        default=0.1,
        help='Percentage of faces to retain (0.0 to 1.0, default: 0.1)'
    )

    args = parser.parse_args()

    if not 0 < args.percent <= 1:
        print('Error: percent must be between 0 and 1', file=sys.stderr)
        sys.exit(1)

    print(f'Loading mesh from {args.input_file}...')
    mesh = trimesh.load(args.input_file)

    print(f'Simplifying mesh (retaining {args.percent * 100:.1f}% of faces)...')
    simplified = mesh.simplify_quadric_decimation(percent=args.percent)

    print(f'Exporting simplified mesh to {args.output_file}...')
    simplified.export(args.output_file)

    print('Done!')


if __name__ == '__main__':
    main()

