"""
config.py — Shared configuration for all figure scripts.

All paths are resolved relative to this file, so the scripts work unchanged
after a fresh `git clone`.

Data source
-----------
By default the figure scripts read from `data/code_mirror/`, a committed
lightweight mirror of the original MATLAB pipeline outputs (only the variables
each figure actually uses; see data/extract_figure_data.py). This lets every
figure regenerate in seconds without running the multi-hour MATLAB pipeline.

To instead plot from a FULL from-scratch run of the asymmetric-reservoir
pipeline (code/asy/), set the environment variable:

    export SETI_CODE_BASE=/path/to/a/checkout/code

and the scripts will read the regenerated large .mat files directly.
"""

import os

# ----------------------------------------------------------------------
# Paths — auto-detected from this file's location
# ----------------------------------------------------------------------
PLOT_DIR = os.path.dirname(os.path.abspath(__file__))   # .../SETI/plotting
REPO_ROOT = os.path.dirname(PLOT_DIR)                    # .../SETI/
FIG_DIR = os.path.join(REPO_ROOT, 'figures')             # output figures
DATA_DIR = os.path.join(PLOT_DIR, 'data')                # ftle_comparison.mat + code_mirror/

# Default: committed lightweight data mirror. Override with SETI_CODE_BASE to
# point at a full code/ tree produced by the MATLAB pipeline.
CODE_BASE = os.environ.get('SETI_CODE_BASE', os.path.join(DATA_DIR, 'code_mirror'))

# ----------------------------------------------------------------------
# Colors — consistent across all figures
# ----------------------------------------------------------------------
SY_COLOR = '#2166AC'      # blue — symmetric reservoir
ASY_COLOR = '#B2182B'     # red  — asymmetric reservoir
OPT_COLOR = '#4DAF4A'     # green — optimal marker
SEAI_COLOR = '#B2182B'    # red — SEAI curve (dual axis)
PERF_COLOR = '#2166AC'    # blue — performance curve
TRUE_COLOR = '#666666'    # gray — true trajectory

# ----------------------------------------------------------------------
# Matplotlib style — consistent academic look
# ----------------------------------------------------------------------
PRL_STYLE = {
    'font.family':      'serif',
    'font.serif':       ['Times New Roman'],
    'mathtext.fontset': 'stix',
    'font.size':        7,
    'axes.linewidth':   0.5,
    'axes.labelsize':   8,
    'xtick.direction':  'in',
    'ytick.direction':  'in',
    'xtick.major.size': 2.5,
    'ytick.major.size': 2.5,
    'xtick.major.width': 0.35,
    'ytick.major.width': 0.35,
    'xtick.labelsize':  6.5,
    'ytick.labelsize':  6.5,
    'legend.fontsize':  5.5,
    'legend.frameon':   False,
    'figure.dpi':       300,
    'savefig.dpi':      300,
}

# ----------------------------------------------------------------------
# Target system constants
# ----------------------------------------------------------------------
LAMBDA_MAX_LORENZ = 0.9056 / 5   # in Lyapunov time units
LAMBDA_MAX_CHEN = 2.5676 / 2

SYSTEMS = ['lorenz', 'chen', 'quasi']
REGIMES = ['auto', 'driven', 'closed']
ARCHS = ['sy', 'asy']
