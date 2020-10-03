#!/usr/bin/env python3

import argparse
import glob
import os
import os.path
import re
import shutil
import subprocess
import sys
import tempfile


def get_config(modes, engine, top, srcs):
  config_str = ''
  config_str = '[tasks]\n'
  tasks = ['task_{}'.format(m) for m in modes]
  config_str += '\n'.join(tasks)
  config_str += '\n\n'

  config_str += '[options]\n'
  options = ['task_{}: mode {}'.format(m, m) for m in modes]
  config_str += '\n'.join(options)
  config_str += '\n\n'

  config_str += '[engines]\n'
  config_str += '{}\n'.format(engine)
  config_str += '\n'

  config_str += '[script]\n'
  for f in srcs:
    _, extension = os.path.splitext(f)
    sv_flag = ' -sv' if extension == '.sv' else ''
    config_str += 'read -formal{} {}\n'.format(sv_flag, os.path.basename(f))
  config_str += 'prep -top {}\n'.format(top)
  config_str += '\n'

  config_str += '[files]\n'
  config_str += '\n'.join(srcs)

  return config_str


def main():
  parser = argparse.ArgumentParser(description='Configure and run symbiyosys.')
  parser.add_argument('--modes', nargs='+', required=True, help='Task modes.')
  parser.add_argument('--engine', default='smtbmc', help='Proof engine.')
  parser.add_argument('--top', required=True, help='Top module name.')
  parser.add_argument('--vcd_dir', help='Directory for output trace files.')
  parser.add_argument('--ignore_failure', action='store_true',
      help='Do not report error code from Symbiyosys.')
  parser.add_argument('srcs', nargs='+', help='(System) verilog sources.')

  args = parser.parse_args()

  with tempfile.TemporaryDirectory() as directory:
    with open(os.path.join(directory, 'config.sby'), 'w') as f:
      config = get_config(args.modes, args.engine, args.top, args.srcs)
      f.write(config)

    bin_path = '/usr/local/bin/'

    sby_args = [
        os.path.join(bin_path, 'sby'),
        '--yosys',
        os.path.join(bin_path, 'yosys'),
        '--abc',
        os.path.join(bin_path, 'yosys-abc'),
        '--smtbmc',
        os.path.join(bin_path, 'yosys-smtbmc'),
        os.path.join(directory, 'config.sby'),
    ]

    completed = subprocess.run(sby_args)

    if args.vcd_dir:
      try:
        os.mkdir(args.vcd_dir)
      except FileExistsError:
        pass

      traces = glob.glob(os.path.join(directory, 'config_task_*/engine_0/*.vcd'))

      for trace in traces:
        match = re.search(r'config_task_(\w+)', trace)
        if not match:
          raise RuntimeError('Malformed trace file: {:s}'.format(trace))

        mode = match.group(1)
        name = '{:s}_{:s}'.format(mode, os.path.basename(trace))
        shutil.copyfile(trace, os.path.join(args.vcd_dir, name))

    if not args.ignore_failure:
      sys.exit(completed.returncode)


if __name__ == '__main__':
  main()
