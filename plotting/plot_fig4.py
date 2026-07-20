#!/usr/bin/env python3
"""
plot_fig4.py
Figure 4: Quantitative comparison of 4 rho values for 3 asymmetric systems.
  - Bare Lyapunov edge
  - Teacher-forced Lyapunov edge
  - SETI-predicted optimum
  - Actual forecasting optimum

Bar chart with legend. Single-column PRL width (~86 mm).
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
    'xtick.major.width': 0.4,
    'ytick.major.width': 0.4,
    'legend.fontsize':   5,
})

# ══════════════════════════════════════════════════════════════
# Helpers
# ══════════════════════════════════════════════════════════════

def find_crossing_rho(rho, LE):
    """First rho where LE crosses zero (negative to positive)."""
    valid = ~np.isnan(LE)
    rho_v, le_v = rho[valid], LE[valid]
    for i in range(len(le_v) - 1):
        if le_v[i] <= 0 < le_v[i + 1]:
            return rho_v[i] + (rho_v[i+1] - rho_v[i]) * (0 - le_v[i]) / (le_v[i+1] - le_v[i])
    return np.nan

def load_le(regime, system):
    path = os.path.join(CODE_BASE, 'asy', system,
                        f'{regime}_RC', f'RC_data_{regime}_asy_{system}.mat')
    m = loadmat(path)
    le = np.array([float(x.ravel()[0]) if x.size > 0 else np.nan
                   for x in m['maxLE_set'].ravel()])
    rho = m['eig_rho_range'].ravel().astype(float)
    return rho, le

def compute_seti_peak(system):
    if system in ('lorenz', 'chen'):
        if system == 'lorenz':
            path = os.path.join(CODE_BASE, 'asy', 'lorenz',
                                'data_lorenz_asy_W_a_0.7.mat')
        else:
            path = os.path.join(CODE_BASE, 'asy', 'chen',
                                'data_chen_a_0.7_asy.mat')
        m = loadmat(path)
        rho = np.arange(0, 1.6, 0.1)
        SETI = np.zeros(len(rho))
        for j in range(len(rho)):
            les = m['train_LEs_set'].ravel()[j].ravel()
            std = m['std_train_set'].ravel()[j].ravel()
            SETI[j] = np.mean(np.maximum(0, -les) * std)
        return rho[np.argmax(SETI)]
    else:
        path = os.path.join(CODE_BASE, 'asy', 'quasi_ensemble_Wonly',
                            'data_quasi_Wonly_ensemble_merged.mat')
        m = loadmat(path)
        rho = m['eig_rho_set'].ravel()
        SETI = m['SEBI_mean'].ravel()
        return rho[np.argmax(SETI)]

def compute_prediction_optimal(system):
    if system in ('lorenz', 'chen'):
        if system == 'lorenz':
            path = os.path.join(CODE_BASE, 'asy', 'lorenz',
                                'data_lorenz_asy_W_a_0.7.mat')
        else:
            path = os.path.join(CODE_BASE, 'asy', 'chen',
                                'data_chen_a_0.7_asy.mat')
        m = loadmat(path)
        rho = np.arange(0, 1.6, 0.1)
        T = m['Predict_time'].ravel()[:len(rho)]
        return rho[np.argmax(T)]
    else:
        path = os.path.join(CODE_BASE, 'asy', 'quasi_ensemble_Wonly',
                            'data_quasi_Wonly_ensemble_merged.mat')
        m = loadmat(path)
        rho = m['eig_rho_set'].ravel()
        T = m['time_filt_mean'].ravel()
        return rho[np.argmax(T)]

# ══════════════════════════════════════════════════════════════
# Compute all values
# ══════════════════════════════════════════════════════════════
sys_labels = ['Lorenz', 'Chen', 'Quasi']

rho_auto, rho_driven, rho_seti, rho_opt = [], [], [], []

for sys in SYSTEMS:
    r, le_a = load_le('auto', sys)
    _, le_d = load_le('driven', sys)

    rho_auto.append(find_crossing_rho(r, le_a))
    rho_driven.append(find_crossing_rho(r, le_d))
    rho_seti.append(compute_seti_peak(sys))
    rho_opt.append(compute_prediction_optimal(sys))

    print(f'{sys}: auto={rho_auto[-1]:.2f}, driven={rho_driven[-1]:.2f}, '
          f'SETI={rho_seti[-1]:.2f}, opt={rho_opt[-1]:.2f}')

# ══════════════════════════════════════════════════════════════
# Plot
# ══════════════════════════════════════════════════════════════
fig_w_mm = 86
fig_h_mm = 50

fig, ax = plt.subplots(figsize=(fig_w_mm / 25.4, fig_h_mm / 25.4),
                        facecolor='white')
fig.subplots_adjust(left=0.12, right=0.97, bottom=0.18, top=0.93)

x = np.arange(len(SYSTEMS))
w = 0.18

c_auto   = SY_COLOR    # blue
c_driven = '#E78AC3'   # pink
c_seti   = OPT_COLOR   # green
c_opt    = '#7B3294'   # purple

bars1 = ax.bar(x - 1.5*w, rho_auto,   w, color=c_auto,   edgecolor='none', zorder=3)
bars2 = ax.bar(x - 0.5*w, rho_driven, w, color=c_driven, edgecolor='none', zorder=3)
bars3 = ax.bar(x + 0.5*w, rho_seti,   w, color=c_seti,   edgecolor='none', zorder=3)
bars4 = ax.bar(x + 1.5*w, rho_opt,    w, color=c_opt,    edgecolor='none', zorder=3)

ax.set_xticks(x)
ax.set_xticklabels(sys_labels)
ax.set_ylabel(r'$\rho$')
ax.set_ylim(0, max(max(rho_auto), max(rho_driven), max(rho_seti), max(rho_opt)) * 1.15)
ax.tick_params(direction='in', which='both')

ax.legend([bars1, bars2, bars3, bars4],
          [r'$\Lambda_b=0$', r'$\Lambda_c=0$',
           r'$\rho_{\mathrm{SETI}}$', r'$\rho_{\mathrm{opt}}$'],
          loc='upper left', fontsize=5, ncol=2,
          handlelength=1.2, handletextpad=0.3, columnspacing=0.8)

out = os.path.join(FIG_DIR, 'fig_four_points_comparison.pdf')
fig.savefig(out, dpi=300, pad_inches=0.03)
plt.close(fig)
print(f'Saved -> {out}')
