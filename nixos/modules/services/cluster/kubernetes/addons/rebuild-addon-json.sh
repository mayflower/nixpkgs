#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Packages.pyyaml

import json
import re
import subprocess
import sys
import yaml
from pathlib import Path

if 1 == len(sys.argv):
    print('Addon name is missing as first argument')
    exit(1)

name = sys.argv[1]
nixpkgs = Path(__file__).resolve().parents[6]
   
kubernetes = subprocess.run(
    ['nix-build', '--no-out-link', nixpkgs, '-A', 'kubernetes.src'],
    stdout=subprocess.PIPE)

source = str(kubernetes.stdout.strip(), 'utf-8')
path = Path(source) / 'cluster/addons' / name

if not path.exists():
    print('Addon %s does not exist at path %s' %(name, path))
    exit(1)

for yamlfile in path.glob('*.yaml'):
    for data in yaml.load_all(yamlfile.read_text()):
        meta = re.sub('[^a-zA-Z0-9.]', '-', data.get('metadata').get('name'))
        kind = data.get('kind').lower()
        file = Path(name) / Path('%s-%s.json' %(kind, meta))
        file.parent.mkdir(0o755, True, True)
        file.write_text(json.dumps(data, indent=2))
