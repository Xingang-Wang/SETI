#!/usr/bin/env python3
"""
plot_figS_ftle.py
Supplementary figure: finite-time LE traces gamma_i(t) at 3 spectral radii,
for symmetric and asymmetric reservoirs (Lorenz target).

Layout: 3 rows x 2 columns
  Row 0: rho = 0.3 (small)
  Row 1: rho = optimal (sy and asy each at their own optimal rho)
  Row 2: rho = 1.5 (large)
  Left column:  symmetric W = W^T
  Right column: asymmetric W != W^T
"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from config import *

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.io import loadmat

# ══════════════════════════════════════════════════════════════
# Matplotlib style
# ══════════════════════════════════════════════════════════════
plt.rcParams.update(PRL_STYLE)
plt.rcParams.update({
    'xtick.major.size': 3,
    'ytick.major.size': 3,
    'xtick.major.width': 0.4,
    'ytick.major.width': 0.4,
})

# Load data
data_path = os.path.join(DATA_DIR, 'ftle_comparison.mat')
data = loadmat(data_path, squeeze_me=True)
sy_transient = [data['sy_transient_set'].flat[i] for i in range(3)]
sy_LEs = [data['sy_LEs_set'].flat[i] for i in range(3)]
sy_rho = data['sy_rho_arr'].ravel().astype(float)
asy_transient = [data['asy_transient_set'].flat[i] for i in range(3)]
asy_LEs = [data['asy_LEs_set'].flat[i] for i in range(3)]
asy_rho = data['asy_rho_arr'].ravel().astype(float)

# -- Parameters --
transient_skip = 200    # skip initial transient windows
n_show_windows = 500    # number of finite-time windows shown
dir_step = 10           # plot every 10th direction

np.random.seed(42)
n_colors = len(range(0, 500, dir_step))
random_colors = [np.random.rand(3) for _ in range(n_colors)]

row_labels = [r'$\rho = {:.1f}$ (small)',
              r'$\rho = {:.2f}$ (optimal)',
              r'$\rho = {:.1f}$ (large)']

def plot_panel(ax, transient, rho, label):
    n_windows = transient.shape[0]
    start = transient_skip
    n_avail = min(n_show_windows, n_windows - start)
    k_axis = np.arange(n_avail)

    dir_indices = list(range(0, 500, dir_step))

    for k, d in enumerate(dir_indices):
        ax.plot(k_axis, transient[start:start + n_avail, d], '-',
                color=random_colors[k], lw=0.5, alpha=0.7)

    ax.axhline(0, color='black', lw=0.4, ls='--')

    # Axis limits with margin so traces don't touch axes
    k_max = k_axis[-1]
    ax.set_xlim(-k_max * 0.02, k_max * 1.02)

    vals = transient[start:start + n_avail, :][:, ::dir_step].ravel()
    ylo = np.min(vals)
    yhi = np.max(vals)
    y_range = yhi - ylo
    ax.set_ylim(ylo - y_range * 0.12, yhi + y_range * 0.12)

    ax.tick_params(direction='in', which='both')
    ax.set_ylabel(r'$\gamma_i(k)$')
    ax.set_title(rf'({label}) $\rho = {rho:.1f}$', fontsize=7, loc='left', pad=1)

# ══════════════════════════════════════════════════════════════
# Figure: 3 rows x 2 columns
# ══════════════════════════════════════════════════════════════
fig_w_mm = 120
fig_h_mm = 130

fig, axes = plt.subplots(3, 2, figsize=(fig_w_mm / 25.4, fig_h_mm / 25.4),
                          facecolor='white')
fig.subplots_adjust(left=0.12, right=0.97, bottom=0.07, top=0.92,
                    wspace=0.25, hspace=0.35)

# Column headers
axes[0, 0].set_title('Symmetric  $W = W^{\\top}$', fontsize=8,
                      fontweight='bold', loc='center', pad=12)
axes[0, 1].set_title('Asymmetric  $W \\neq W^{\\top}$', fontsize=8,
                      fontweight='bold', loc='center', pad=12)

panel_labels = [['a', 'b'], ['c', 'd'], ['e', 'f']]

for row in range(3):
    # Symmetric (left) -- use sy_rho
    plot_panel(axes[row, 0], sy_transient[row], sy_rho[row],
               panel_labels[row][0])

    # Asymmetric (right) -- use asy_rho
    plot_panel(axes[row, 1], asy_transient[row], asy_rho[row],
               panel_labels[row][1])

    if row == 2:
        axes[row, 0].set_xlabel(r'window index $k$')
        axes[row, 1].set_xlabel(r'window index $k$')

out = os.path.join(FIG_DIR, 'figS_ftle_traces.pdf')
fig.savefig(out, dpi=300, pad_inches=0.03)
plt.close(fig)
print(f'Saved -> {out}')
