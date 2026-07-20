#!/usr/bin/env python3
"""
plot_fig3.py
Figure 3: SETI vs forecasting horizon across 3 systems x 2 architectures.

3 rows (Lorenz, Chen, Quasi-periodic) x 2 columns (sy, asy).
Each panel: dual y-axis -- forecasting horizon T (left, blue) and SETI (right, red).

Single-column PRL width (~86 mm). Fixed label overlaps.
Style: Times New Roman, ticks inward.
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
    'font.size':        9,
    'axes.labelsize':   9.5,
    'xtick.labelsize':  8,
    'ytick.labelsize':  8,
    'legend.fontsize':  7,
})

# ══════════════════════════════════════════════════════════════
# Data loading
# ══════════════════════════════════════════════════════════════

def load_lorenz_chen(arch, system):
    if arch == 'sy':
        path = os.path.join(CODE_BASE, arch, system, f'data_in_{system}.mat')
    else:
        # Asymmetric data lives in separate files
        if system == 'lorenz':
            path = os.path.join(CODE_BASE, 'asy', 'lorenz',
                                'data_lorenz_asy_W_a_0.7.mat')
        else:
            path = os.path.join(CODE_BASE, 'asy', 'chen',
                                'data_chen_a_0.7_asy.mat')
    m = loadmat(path)
    rho = np.arange(0, 1.6, 0.1)
    n = len(rho)
    T = m['Predict_time'].ravel()[:n]
    SEAI = np.zeros(n)
    for j in range(n):
        les = m['train_LEs_set'].ravel()[j].ravel()
        std = m['std_train_set'].ravel()[j].ravel()
        m_j = np.maximum(0, -les)
        SEAI[j] = np.mean(m_j * std)
    if system == 'lorenz':
        # The asymmetric Lorenz scan stores prediction time in the scale used
        # by the original asy plotting script, without the additional /5 factor.
        factor = 0.9056 if arch == 'asy' else LAMBDA_MAX_LORENZ
        Lambda = T * factor
    else:
        Lambda = T * LAMBDA_MAX_CHEN
    return rho, Lambda, SEAI


def load_quasi(arch):
    if arch == 'sy':
        path = os.path.join(CODE_BASE, 'sy', 'quasi_ensemble_Wonly',
                             'data_quasi_Wonly_ensemble_filtered.mat')
    else:
        path = os.path.join(CODE_BASE, 'asy', 'quasi_ensemble_Wonly',
                             'data_quasi_Wonly_ensemble_merged.mat')
    m = loadmat(path)
    rho = m['eig_rho_set'].ravel()
    T_mean = m['time_filt_mean'].ravel() / 4
    SEAI_mean = m['SEBI_mean'].ravel()
    return rho, T_mean, SEAI_mean


# ══════════════════════════════════════════════════════════════
# Build figure: 3 rows x 2 columns
# ══════════════════════════════════════════════════════════════
fig_w_mm = 110
fig_h_mm = 120

fig, axes = plt.subplots(3, 2, figsize=(fig_w_mm / 25.4, fig_h_mm / 25.4),
                          facecolor='white')
fig.subplots_adjust(left=0.11, right=0.86, bottom=0.07, top=0.94,
                    wspace=0.53, hspace=0.30)

systems = [('lorenz', 'Lorenz'), ('chen', 'Chen'), ('quasi', 'Quasiperiodic')]
archs   = [('sy', 'Symmetric'), ('asy', 'Asymmetric')]

panel_labels = ['(a)', '(b)', '(c)', '(d)', '(e)', '(f)']
pidx = 0

for row, (sys_key, sys_label) in enumerate(systems):
    for col, (arch_key, arch_label) in enumerate(archs):
        ax = axes[row, col]

        if sys_key in ('lorenz', 'chen'):
            rho, perf, sebi = load_lorenz_chen(arch_key, sys_key)
        else:
            rho, perf, sebi = load_quasi(arch_key)

        # Left axis: performance
        ax.plot(rho, perf, '-o', color=PERF_COLOR, lw=0.7, ms=2.5,
                mfc=PERF_COLOR, mec=PERF_COLOR, zorder=3)
        ax.set_ylabel(r'$T$', color=PERF_COLOR, labelpad=2)
        ax.tick_params(axis='y', labelcolor=PERF_COLOR, pad=1)
        if row == 2:
            ax.set_xlabel(r'$\rho$', labelpad=2)
        ax.tick_params(direction='in', which='both', pad=1)

        # Right axis: SEAI
        ax2 = ax.twinx()
        ax2.plot(rho, sebi, '-s', color=SEAI_COLOR, lw=0.7, ms=2.5,
                 mfc=SEAI_COLOR, mec=SEAI_COLOR, zorder=3)
        ax2.set_ylabel('SETI', color=SEAI_COLOR, labelpad=2)
        ax2.tick_params(axis='y', labelcolor=SEAI_COLOR, direction='in',
                        which='both', labelsize=8, pad=1)
        ax2.spines['right'].set_color(SEAI_COLOR)
        ax2.spines['left'].set_color(PERF_COLOR)

        # Panel label -- placed inside top-left
        ax.text(0.03, 0.94, panel_labels[pidx],
                transform=ax.transAxes, fontsize=9.5,
                ha='left', va='top', fontweight='bold')
        pidx += 1

        # Column header -- only top row
        if row == 0:
            ax.set_title(arch_label, fontsize=9.5, pad=4, color='#333')

# -- Save --
out = os.path.join(FIG_DIR, 'fig3_SEAI.pdf')
fig.savefig(out, dpi=300, bbox_inches='tight', pad_inches=0.02)
plt.close(fig)
print(f'Saved -> {out}')
print(f'Figure size: {fig_w_mm:.0f} x {fig_h_mm:.0f} mm')
