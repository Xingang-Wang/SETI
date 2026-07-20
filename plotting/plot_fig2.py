#!/usr/bin/env python3
"""
plot_fig2.py
Teacher-rewritten Fig. 2: representative FTLE traces and scan-wise ingredients.

Output matches manus_shoucuo_0716.tex:
  figures/fig3-nnew.png

Layout:
  One-column horizontal layout:
    (a) selected finite-time Lyapunov traces gamma_i(k) for asy/Lorenz at rho=0.7
    (b) normalized <m_i>, <sigma_i>, and SETI versus rho
"""

import os
import sys
sys.path.insert(0, os.path.dirname(__file__))
from config import *

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.io import loadmat


plt.rcParams.update(PRL_STYLE)
plt.rcParams.update({
    'font.size': 7,
    'axes.labelsize': 8,
    'xtick.labelsize': 6.5,
    'ytick.labelsize': 6.5,
    'legend.fontsize': 5.4,
})

REP_RHO = 0.7
RHO_MAX = 1.5
SETI_FIG2_COLOR = '#111111'
DIR_STEP = 10


def normalize(y):
    y = np.asarray(y, dtype=float)
    finite = np.isfinite(y)
    ymin, ymax = np.min(y[finite]), np.max(y[finite])
    return (y - ymin) / (ymax - ymin) if ymax > ymin else y


data_path = os.path.join(CODE_BASE, 'asy', 'lorenz',
                         'data_lorenz_asy_W_a_0.7.mat')
data = loadmat(data_path, squeeze_me=True)

les_set = np.ravel(data['train_LEs_set'])
std_set = np.ravel(data['std_train_set'])
transient_set = np.ravel(data['train_LEs_transient_set'])

rho_all = np.arange(0, len(les_set) * 0.1, 0.1)
scan_mask = rho_all <= RHO_MAX + 1e-9
rho = rho_all[scan_mask]

rho_idx = int(np.argmin(np.abs(rho_all - REP_RHO)))
if not np.isclose(rho_all[rho_idx], REP_RHO):
    raise RuntimeError(f'Cannot find rho={REP_RHO} in {data_path}')

ftle_trans = np.asarray(transient_set[rho_idx], dtype=float)
les = np.ravel(les_set[rho_idx]).astype(float)
order = np.argsort(les)[::-1]

mean_m = []
mean_sigma = []
seti = []
for j in np.where(scan_mask)[0]:
    les_j = np.ravel(les_set[j]).astype(float)
    sigma_j = np.ravel(std_set[j]).astype(float)
    m_j = np.maximum(0, -les_j)
    mean_m.append(np.mean(m_j))
    mean_sigma.append(np.mean(sigma_j))
    seti.append(np.mean(m_j * sigma_j))

mean_m = np.asarray(mean_m)
mean_sigma = np.asarray(mean_sigma)
seti = np.asarray(seti)


fig_w_mm = 86
fig_h_mm = 43
fig, axes = plt.subplots(1, 2, figsize=(fig_w_mm / 25.4, fig_h_mm / 25.4),
                         facecolor='white')
fig.subplots_adjust(left=0.105, right=0.985, bottom=0.24, top=0.92,
                    wspace=0.36)

# Panel (a): representative finite-time Lyapunov traces.
ax = axes[0]
start = 250
n_show = 400
n_avail = min(n_show, ftle_trans.shape[0] - start)
k_axis = np.arange(n_avail)

ftle_window = ftle_trans[start:start + n_avail, order]

# Plot every 10th ordered mode, following the dense FTLE-trace style of Fig. S1(d).
mode_ranks = list(range(0, min(500, len(order)), DIR_STEP))
np.random.seed(42)
trace_colors = [np.random.rand(3) for _ in mode_ranks]
for color, rank in zip(trace_colors, mode_ranks):
    idx = order[rank]
    ax.plot(k_axis, ftle_trans[start:start + n_avail, idx],
            lw=0.50, color=color, alpha=0.70, zorder=3)

ax.axhline(0, color='black', lw=0.35, ls='--', zorder=2)
ax.set_xlim(-k_axis[-1] * 0.02, k_axis[-1] * 1.02)
ax.set_xticks(np.arange(0, k_axis[-1] + 1, 200))
vals = ftle_window[:, mode_ranks].ravel()
ylo, yhi = np.min(vals), np.max(vals)
y_range = yhi - ylo
ax.set_ylim(ylo - y_range * 0.12, yhi + y_range * 0.30)
ax.set_xlabel(r'window index $k$')
ax.set_ylabel(r'$\gamma_i(k)$')
ax.tick_params(direction='in', which='both')
ax.text(0.03, 0.965, '(a)', transform=ax.transAxes, fontsize=8,
        ha='left', va='top', fontweight='bold')

# Panel (b): normalized scan-wise ingredients and SETI.
ax = axes[1]
ax.plot(rho, normalize(mean_m), '-o', color=PERF_COLOR, lw=0.75, ms=2.1,
        mfc=PERF_COLOR, mec=PERF_COLOR, label=r'$\langle m_i\rangle$')
ax.plot(rho, normalize(mean_sigma), '-s', color=SEAI_COLOR, lw=0.75, ms=2.1,
        mfc=SEAI_COLOR, mec=SEAI_COLOR, label=r'$\langle\sigma_i\rangle$')
ax.plot(rho, normalize(seti), '-^', color=SETI_FIG2_COLOR, lw=0.75, ms=2.2,
        mfc=SETI_FIG2_COLOR, mec=SETI_FIG2_COLOR, label='SETI')
ax.axvline(REP_RHO, color='#666666', lw=0.55, ls='--', alpha=0.75)

ax.set_xlim(-0.08, RHO_MAX)
ax.set_xticks(np.arange(0, RHO_MAX + 0.01, 0.5))
ax.set_ylim(-0.05, 1.28)
ax.set_xlabel(r'$\rho$')
ax.set_ylabel('normalized value')
ax.tick_params(direction='in', which='both')
ax.text(0.03, 0.965, '(b)', transform=ax.transAxes, fontsize=8,
        ha='left', va='top', fontweight='bold')
ax.legend(loc='center right', handlelength=1.2, handletextpad=0.35,
          labelspacing=0.25)

out_png = os.path.join(FIG_DIR, 'fig3-nnew.png')
out_pdf = os.path.join(FIG_DIR, 'fig3-nnew.pdf')
fig.savefig(out_png, dpi=450, bbox_inches='tight', pad_inches=0.01)
fig.savefig(out_pdf, dpi=300, bbox_inches='tight', pad_inches=0.01)
plt.close(fig)
print(f'Saved -> {out_png}')
print(f'Saved -> {out_pdf}')
print(f'Figure size: {fig_w_mm:.0f} x {fig_h_mm:.0f} mm')
