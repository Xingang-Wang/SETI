#!/usr/bin/env python3
"""
plot_figS_closed.py
Supplementary figure: prediction trajectories at selected rho values.

2 rows x 2 columns time series:
  (a) Lorenz rho=0.8 (correct prediction, Lambda_g>0)
  (b) Lorenz rho=2.5 (prediction failure, Lambda_g<0)
  (c) Quasi rho=0.8 (correct torus prediction)
  (d) Quasi rho=1.9 (chaotic drift, Lambda_g>>0)

Each panel: gray = true test trajectory, colored = RC predicted output.
Vertical dashed line marks end of teacher-forced warmup.
X-axis in physical time units.
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

DT_LOR = 0.02    # Lorenz sampling interval
DT_QUA = 0.005   # Quasi sampling interval

# -- Load prediction data --
lor = loadmat(os.path.join(CODE_BASE, 'sy', 'lorenz', 'closed_RC',
                           'prediction_trajectory_sy_lorenz.mat'))
lor_pred = lor['predicted_set'].ravel()
lor_true = lor['true_set'].ravel()
lor_rhos = lor['selected_rho'].ravel()
drive_num = int(lor['drive_num'].ravel()[0])

qua = loadmat(os.path.join(CODE_BASE, 'sy', 'quasi', 'closed_RC',
                           'prediction_trajectory_sy_quasi.mat'))
qua_pred = qua['predicted_set'].ravel()
qua_true = qua['true_set'].ravel()
qua_rhos = qua['selected_rho'].ravel()

# -- Closed-loop LE values (from existing data) --
lor_le_data = loadmat(os.path.join(CODE_BASE, 'sy', 'lorenz', 'closed_RC',
                                   'RC_data_closed_sy_lorenz.mat'))
lor_le = np.array([float(x.ravel()[0]) if x.size > 0 else np.nan
                   for x in lor_le_data['maxLE_set'].ravel()])
lor_rho_range = lor_le_data['eig_rho_range'].ravel()

qua_le_data = loadmat(os.path.join(CODE_BASE, 'sy', 'quasi', 'closed_RC',
                                   'RC_data_closed_sy_quasi.mat'))
qua_le = np.array([float(x.ravel()[0]) if x.size > 0 else np.nan
                   for x in qua_le_data['maxLE_set'].ravel()])
qua_rho_range = qua_le_data['eig_rho_range'].ravel()

def get_LE(rho, rho_range, le_arr):
    idx = np.argmin(np.abs(rho_range - rho))
    return le_arr[idx]

for k in range(len(lor_rhos)):
    le = get_LE(lor_rhos[k], lor_rho_range, lor_le)
    print(f'Lorenz rho={lor_rhos[k]:.1f}: Lambda_g={le:.4f}')
    p, t = lor_pred[k], lor_true[k]
    print(f'  Pred x1 range: [{p[0].min():.3f}, {p[0].max():.3f}]')
    print(f'  True x1 range: [{t[0].min():.3f}, {t[0].max():.3f}]')
    n_overlap = min(p.shape[1], t.shape[1])
    mae = np.mean(np.abs(p[0, drive_num:n_overlap] - t[0, drive_num:n_overlap]))
    print(f'  MAE after warmup: {mae:.4f}')

for k in range(len(qua_rhos)):
    le = get_LE(qua_rhos[k], qua_rho_range, qua_le)
    print(f'Quasi rho={qua_rhos[k]:.1f}: Lambda_g={le:.4f}')
    p, t = qua_pred[k], qua_true[k]
    print(f'  Pred x1 range: [{p[0].min():.3f}, {p[0].max():.3f}]')
    print(f'  True x1 range: [{t[0].min():.3f}, {t[0].max():.3f}]')
    n_overlap = min(p.shape[1], t.shape[1])
    mae = np.mean(np.abs(p[0, 1:n_overlap] - t[0, 1:n_overlap]))
    print(f'  MAE: {mae:.4f}')

# ══════════════════════════════════════════════════════════════
# Plot
# ══════════════════════════════════════════════════════════════
fig_w_mm = 86
fig_h_mm = 72

fig, axes = plt.subplots(2, 2, figsize=(fig_w_mm / 25.4, fig_h_mm / 25.4),
                          facecolor='white')
fig.subplots_adjust(left=0.14, right=0.97, bottom=0.14, top=0.92,
                    wspace=0.42, hspace=0.52)

C_CORRECT = SY_COLOR      # blue
C_FAIL    = ASY_COLOR     # red
C_TRUE    = TRUE_COLOR    # gray

def plot_panel(ax, pred, true, rho, le_val, label, title, color, dt,
               n_show_pred=None, warmup_line=None, legend_loc='upper right',
               legend_anchor=None):
    """Plot prediction vs true trajectory.
    n_show_pred: truncate prediction to this many steps (None = all).
    warmup_line: step index for vertical dashed line (None = use drive_num).
    """
    if n_show_pred is not None:
        pred = pred[:, :n_show_pred]
    wl = warmup_line if warmup_line is not None else drive_num

    n_pred = pred.shape[1]
    n_true = true.shape[1]
    t_pred = np.arange(n_pred) * dt
    t_true = np.arange(n_true) * dt
    ax.plot(t_true, true[0], '-', color=C_TRUE, lw=0.4, alpha=0.5, label='True')
    ax.plot(t_pred, pred[0], '-', color=color, lw=0.4, alpha=0.7, label='Predicted')
    ax.axvline(wl * dt, color='black', lw=0.4, ls=':', alpha=0.5)
    ax.set_xlabel('$t$')
    ax.set_ylabel(r'$y_1(t)$')
    ax.tick_params(direction='in', which='both')
    # Use explicit sign rendering to ensure minus signs display correctly
    sign = '+' if le_val >= 0 else '-'
    abs_val = abs(le_val)
    ax.set_title(rf'({label}) {title}' + '\n' +
                 rf'$\rho={rho:.1f}$, $\Lambda_g={sign}{abs_val:.3f}$',
                 fontsize=6.2, loc='left', pad=2)
    legend_kwargs = {}
    if legend_anchor is not None:
        legend_kwargs['bbox_to_anchor'] = legend_anchor
    ax.legend(fontsize=5, loc=legend_loc, handlelength=1.2,
              frameon=True, framealpha=0.80, borderpad=0.2,
              **legend_kwargs)

# (a) Lorenz rho=0.8 -- only show 1000 steps
le_a = get_LE(lor_rhos[0], lor_rho_range, lor_le)
plot_panel(axes[0, 0], lor_pred[0], lor_true[0], lor_rhos[0], le_a, 'a',
           'Lorenz: correct', C_CORRECT, DT_LOR, n_show_pred=1000)

# (b) Lorenz rho=2.5 -- full 5000 steps to show transient -> convergence
le_b = get_LE(lor_rhos[1], lor_rho_range, lor_le)
plot_panel(axes[0, 1], lor_pred[1], lor_true[1], lor_rhos[1], le_b, 'b',
           'Lorenz: collapse', C_FAIL, DT_LOR)

# (c) Quasi rho=0.8 -- teacher-forced warmup then self-predict
le_c = get_LE(qua_rhos[0], qua_rho_range, qua_le)
plot_panel(axes[1, 0], qua_pred[0], qua_true[0], qua_rhos[0], le_c, 'c',
           'Quasiperiodic: correct', C_CORRECT, DT_QUA)

# (d) Quasi rho=1.9 -- chaotic drift
le_d = get_LE(qua_rhos[1], qua_rho_range, qua_le)
plot_panel(axes[1, 1], qua_pred[1], qua_true[1], qua_rhos[1], le_d, 'd',
           'Quasiperiodic: drift', C_FAIL, DT_QUA,
           legend_loc='upper left', legend_anchor=(0.02, 0.98))

out = os.path.join(FIG_DIR, 'figS_closed_trajectories.pdf')
fig.savefig(out, dpi=300, pad_inches=0.03)
plt.close(fig)
print(f'\nSaved -> {out}')
