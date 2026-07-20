#!/usr/bin/env python3
"""
plot_fig1.py
Figure 1 for revised PRL: 3 regimes x 3 target systems.

Layout: 3 rows x 3 columns (Lorenz, Chen, Quasi)
Each panel: symmetric (blue) and asymmetric (red) max LE vs rho,
            lambda=0 dashed line, stars at forecasting-optimal rho,
            red dashed lines at asymmetric LE zero-crossing.
All panels show x-axis ticks. Markers at every rho=0.1 step.
Columns labeled (a)-(c). Single-column PRL width (~86 mm).
"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from config import *

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from scipy.io import loadmat

# ══════════════════════════════════════════════════════════════
# Matplotlib style
# ══════════════════════════════════════════════════════════════
plt.rcParams.update(PRL_STYLE)
plt.rcParams.update({
    'axes.labelsize':  8,
    'xtick.labelsize': 6.5,
    'ytick.labelsize': 6.5,
    'legend.fontsize': 5.5,
})

RHO_MAX = 3.0   # show data up to this rho
RHO_PLOT = 3.15  # x-axis upper limit (add padding)

# ══════════════════════════════════════════════════════════════
# Data loading
# ══════════════════════════════════════════════════════════════

def load_le(regime, arch, system):
    """Load max LE vs rho for a given regime/architecture/system."""
    path = os.path.join(CODE_BASE, arch, system,
                        f'{regime}_RC', f'RC_data_{regime}_{arch}_{system}.mat')
    m = loadmat(path)
    le_set = m['maxLE_set'].ravel()
    le = np.array([float(x.ravel()[0]) if x.size > 0 else np.nan
                   for x in le_set])
    rho = m['eig_rho_range'].ravel().astype(float)
    return rho, le


def zero_crossing(rho, le):
    """First rho where LE crosses zero (linear interpolation)."""
    for i in range(len(le) - 1):
        if not (np.isnan(le[i]) or np.isnan(le[i + 1])):
            if le[i] * le[i + 1] < 0:
                return rho[i] - le[i] * (rho[i+1] - rho[i]) / (le[i+1] - le[i])
    return None


def compute_sebi_peak(arch, system):
    """Compute SEBI peak rho for a given configuration."""
    if system in ('lorenz', 'chen'):
        if arch == 'sy':
            path = os.path.join(CODE_BASE, arch, system, f'data_in_{system}.mat')
        else:
            if system == 'lorenz':
                path = os.path.join(CODE_BASE, 'asy', 'lorenz',
                                    'data_lorenz_asy_W_a_0.7.mat')
            else:
                path = os.path.join(CODE_BASE, 'asy', 'chen',
                                    'data_chen_a_0.7_asy.mat')
        m = loadmat(path)
        rho = np.arange(0, 1.6, 0.1)
        n = len(rho)
        SEBI = np.zeros(n)
        for j in range(n):
            les = m['train_LEs_set'].ravel()[j].ravel()
            std = m['std_train_set'].ravel()[j].ravel()
            m_j = np.maximum(0, -les)
            SEBI[j] = np.mean(m_j * std)
    else:  # quasi
        if arch == 'sy':
            path = os.path.join(CODE_BASE, 'sy', 'quasi_ensemble_Wonly',
                                'data_quasi_Wonly_ensemble_filtered.mat')
        else:
            path = os.path.join(CODE_BASE, 'asy', 'quasi_ensemble_Wonly',
                                'data_quasi_Wonly_ensemble_merged.mat')
        m = loadmat(path)
        rho = m['eig_rho_set'].ravel()
        SEBI = m['SEBI_mean'].ravel()

    idx_peak = np.argmax(SEBI)
    return rho[idx_peak]


def compute_prediction_optimal(arch, system):
    """Compute the actual prediction-optimal rho from forecasting performance."""
    if system in ('lorenz', 'chen'):
        if arch == 'sy':
            path = os.path.join(CODE_BASE, arch, system, f'data_in_{system}.mat')
        else:
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
        idx = np.argmax(T)
        return rho[idx]
    else:  # quasi
        if arch == 'sy':
            path = os.path.join(CODE_BASE, 'sy', 'quasi_ensemble_Wonly',
                                'data_quasi_Wonly_ensemble_filtered.mat')
        else:
            path = os.path.join(CODE_BASE, 'asy', 'quasi_ensemble_Wonly',
                                'data_quasi_Wonly_ensemble_merged.mat')
        m = loadmat(path)
        rho = m['eig_rho_set'].ravel()
        T = m['time_filt_mean'].ravel() / 4
        idx = np.argmax(T)
        return rho[idx]


# -- Pre-load all LE data --
le_data = {}
for regime in REGIMES:
    for arch in ARCHS:
        for sys in SYSTEMS:
            le_data[(regime, arch, sys)] = load_le(regime, arch, sys)

# -- Compute prediction-optimal rho (true forecasting optimum) --
rho_opt = {}
for arch in ARCHS:
    for sys in SYSTEMS:
        rho_opt[(arch, sys)] = compute_prediction_optimal(arch, sys)
        print(f'  {arch}/{sys}: prediction-optimal rho = {rho_opt[(arch, sys)]:.1f}')

# ══════════════════════════════════════════════════════════════
# Build figure: 3 rows x 3 columns
# ══════════════════════════════════════════════════════════════
fig_w_mm = 86
fig_h_mm = 96

fig, axes = plt.subplots(3, 3, figsize=(fig_w_mm / 25.4, fig_h_mm / 25.4),
                          facecolor='white')
fig.subplots_adjust(left=0.13, right=0.97, bottom=0.08, top=0.93,
                    wspace=0.34, hspace=0.18)

sys_labels    = ['Lorenz', 'Chen', 'Quasiperiodic']
col_tags       = ['a', 'b', 'c']

ylabel_map = {
    'auto':   r'$\Lambda_b$',
    'driven': r'$\Lambda_c$',
    'closed': r'$\Lambda_g$',
}

for row, regime in enumerate(REGIMES):
    for col, sys in enumerate(SYSTEMS):
        ax = axes[row, col]

        rho_sy, le_sy = le_data[(regime, 'sy', sys)]
        rho_asy, le_asy = le_data[(regime, 'asy', sys)]

        idx_s = rho_sy <= RHO_MAX
        idx_a = rho_asy <= RHO_MAX

        # Prediction-optimal rho markers (stars on LE curves)
        r_opt_sy = rho_opt[('sy', sys)]
        r_opt_asy = rho_opt[('asy', sys)]

        # LE curves -- subsample to every 0.2 rho (both line and markers)
        ax.plot(rho_sy[idx_s][::2], le_sy[idx_s][::2], '-o', color=SY_COLOR,
                lw=0.5, ms=1.2, mfc=SY_COLOR, mec=SY_COLOR,
                zorder=3)
        ax.plot(rho_asy[idx_a][::2], le_asy[idx_a][::2], '-s', color=ASY_COLOR,
                lw=0.5, ms=1.2, mfc=ASY_COLOR, mec=ASY_COLOR,
                zorder=3)

        # Stars at prediction-optimal rho on each curve
        # sy: interpolate LE at r_opt_sy
        le_at_opt_sy = np.interp(r_opt_sy, rho_sy[idx_s], le_sy[idx_s])
        ax.plot(r_opt_sy, le_at_opt_sy, '*', color=SY_COLOR, ms=7,
                mfc=SY_COLOR, mec=SY_COLOR, mew=0.5, zorder=5)
        # asy: interpolate LE at r_opt_asy
        le_at_opt_asy = np.interp(r_opt_asy, rho_asy[idx_a], le_asy[idx_a])
        ax.plot(r_opt_asy, le_at_opt_asy, '*', color=ASY_COLOR, ms=7,
                mfc=ASY_COLOR, mec=ASY_COLOR, mew=0.5, zorder=5)

        # lambda = 0 line
        ax.axhline(0, color='black', lw=0.3, ls='--', zorder=2)

        # Lyapunov edges shown only for asymmetric reservoirs, as in the caption.
        rc_asy = zero_crossing(rho_asy[idx_a], le_asy[idx_a])
        if row != 2 and rc_asy is not None and rc_asy <= RHO_MAX:
            ax.axvline(rc_asy, color=ASY_COLOR, lw=0.6, ls='--', alpha=0.7,
                       zorder=1)

        ax.set_xlim(0, RHO_PLOT)
        ax.set_xticks(np.arange(0, RHO_MAX + 0.01, 1.0))
        ax.set_xticks(np.arange(0, RHO_MAX + 0.01, 0.5), minor=True)
        if col == 0:
            ax.set_ylabel(ylabel_map[regime])
        if row == 2:
            ax.set_xlabel(r'$\rho$', labelpad=1.5)
        # else: keep y tick labels but no ylabel
        ax.tick_params(direction='in', which='both')

        # Column label on top row
        if row == 0:
            ax.set_title(f'({col_tags[col]}) {sys_labels[col]}',
                         fontsize=8, pad=2.5, color='#222')

# Manual legend in panel (a1)
leg_elements = [
    Line2D([0], [0], color=SY_COLOR, lw=0.8, marker='o', ms=2.5,
           markevery=2, label='Symmetric'),
    Line2D([0], [0], color=ASY_COLOR, lw=0.8, marker='s', ms=2.5,
           markevery=2, label='Asymmetric'),
]
axes[0, 0].legend(handles=leg_elements, loc='lower right', fontsize=5.3,
                  handlelength=1.5, handletextpad=0.3, labelspacing=0.35)

# -- Save --
out = os.path.join(FIG_DIR, 'fig1_three_regime.pdf')
fig.savefig(out, dpi=300, bbox_inches='tight', pad_inches=0.03)
plt.close(fig)
print(f'Saved -> {out}')
print(f'Figure size: {fig_w_mm:.0f} x {fig_h_mm:.0f} mm')
