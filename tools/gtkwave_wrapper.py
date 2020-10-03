#!/usr/bin/env python3

import argparse
import glob
import os.path
import subprocess


def expand_template(input_file, output_file, substitution_dict):
  with open(input_file, 'r') as i_f, open(output_file, 'w') as o_f:
    for old_line in i_f.readlines():
      new_line = old_line
      for old, new in substitution_dict.items():
        new_line = new_line.replace(old, new)

      o_f.write(new_line)


def main():
  parser = argparse.ArgumentParser(description='Configure and start GTKwave.')
  parser.add_argument('--tcl_template', required=True,
                      help='Template Tcl file for GTKwave configuration.')
  parser.add_argument('--tcl_output', required=True,
                      help='Tcl filename to which to write the GTKwave configuration.')
  parser.add_argument('--vcd_dir', required=True, help='Directory of VCD files.')
  parser.add_argument('--open_level', type=int, default=2,
                      help='Hierarchy level to display by default.')
  parser.add_argument('tests', nargs='*', help='Test names to display. Globs allowed.')

  args = parser.parse_args()

  if not args.tests:
    args.tests = ['*']

  vcd_files = []
  for test in args.tests:
    path = os.path.join(args.vcd_dir, test + '.vcd')
    vcd_files.extend(glob.glob(path))

  load_files = '\n'.join(['gtkwave::loadFile "{:s}"'.format(f) for f in vcd_files])
  expand_template(args.tcl_template, args.tcl_output,
      {'@LOAD_FILES@': load_files, '@OPEN_LEVEL@': str(args.open_level)})

  gtkwave_args = [
      'gtkwave',
      '-S',
      args.tcl_output,
      '--rcvar',
      'initial_window_x 2000',
      '--rcvar',
      'initial_window_y 1200',
  ]

  if vcd_files:
    try:
      subprocess.run(gtkwave_args)
    except KeyboardInterrupt:
      pass
  else:
    print('No traces in "{}" match {}.'.format(args.vcd_dir, args.tests))


if __name__ == '__main__':
  main()
