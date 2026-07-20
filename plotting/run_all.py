#!/usr/bin/env python3
"""
run_all.py — Regenerate all paper figures.

Usage:
    cd paper_latest/plotting/
    python3 run_all.py
"""

import subprocess
import sys
import os

scripts = [
    'plot_fig1.py',
    'plot_fig2.py',
    'plot_fig3.py',
    'plot_fig4.py',
    'plot_figS_ftle.py',
    'plot_figS_closed.py',
]

here = os.path.dirname(os.path.abspath(__file__))

for s in scripts:
    path = os.path.join(here, s)
    print(f'\n{"="*60}')
    print(f'  Running {s} ...')
    print(f'{"="*60}')
    result = subprocess.run([sys.executable, path], cwd=here)
    if result.returncode != 0:
        print(f'  ERROR: {s} failed with return code {result.returncode}')
        sys.exit(1)

print(f'\n{"="*60}')
print('  All figures regenerated successfully.')
print(f'{"="*60}')
