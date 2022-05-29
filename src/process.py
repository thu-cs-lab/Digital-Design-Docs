import sys
import re

lines = open(sys.argv[1]).readlines()
with open(sys.argv[1], 'w') as f:
	for line in lines:
		if "shape=record, label=" in line:
			print(line)
			line = re.sub(r'\$[0-9]+\\n\$_+([A-Z0-9_]+)_+', r'\1', line)
			print(line)
		print(line, end='', file=f)