"""
Supplement figure: Scan-wise mean expressivity and mean stability margin
for asymmetric reservoir on Lorenz only.

1 panel showing both ingredients and SETI.
"""
import numpy as np
import scipy.io as sio
import matplotlib.pyplot as plt
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent))
from config import CODE_BASE, FIG_DIR, ASY_COLOR, OPT_COLOR, SEAI_COLOR, PRL_STYLE

plt.rcParams.update(PRL_STYLE)
plt.rcParams.update({
    'xtick.labelsize': 6,
    'ytick.labelsize': 6,
    'axes.labelsize': 7,
    'legend.fontsize': 5,
})


def normalize(y):
    y_valid = y[np.isfinite(y)]
    ymin, ymax = np.min(y_valid), np.max(y_valid)
    return (y - ymin) / (ymax - ymin) if ymax > ymin else y


# Load Lorenz asymmetric data
fpath = Path(CODE_BASE) / "asy/lorenz/data_lorenz_asy_W_a_0.7.mat"
m = sio.loadmat(fpath)
les_set = m["train_LEs_set"].ravel()
std_set = m["std_train_set"].ravel()
pred_time = m["Predict_time"].ravel()
n_rho = len(les_set)
rho = np.arange(0, n_rho * 0.1, 0.1)

mean_sigma = np.full(n_rho, np.nan)
mean_m = np.full(n_rho, np.nan)
seti = np.full(n_rho, np.nan)

for j in range(n_rho):
    les = les_set[j].ravel()
    sig = std_set[j].ravel()
    m_i = np.maximum(0, -les)
    mean_sigma[j] = np.mean(sig)
    mean_m[j] = np.mean(m_i)
    seti[j] = np.mean(m_i * sig)

opt_idx = np.nanargmax(pred_time)

# Plot: single panel
PANEL_W_MM = 55
PANEL_H_MM = 45

fig, ax = plt.subplots(1, 1, figsize=(PANEL_W_MM / 25.4, PANEL_H_MM / 25.4),
                        facecolor='white')
fig.subplots_adjust(left=0.15, right=0.95, bottom=0.18, top=0.92)

colors_sig = "#E41A1C"
colors_m = "#377EB8"
colors_seti = "#111111"

ax.plot(rho, normalize(mean_sigma), "-o", color=colors_sig, lw=0.7, ms=1.8,
        label=r"$\langle \sigma_i \rangle$", zorder=3)
ax.plot(rho, normalize(mean_m), "-s", color=colors_m, lw=0.7, ms=1.8,
        label=r"$\langle m_i \rangle$", zorder=3)
ax.plot(rho, normalize(seti), "-^", color=colors_seti, lw=0.7, ms=1.8,
        label="SETI", zorder=3)

ax.axvline(rho[opt_idx], color="gray", ls="--", lw=0.5, alpha=0.6)

ax.set_xlabel(r"$\rho$")
ax.set_ylabel("Normalized value", fontsize=7)
ax.set_ylim(-0.05, 1.1)
ax.tick_params(direction='in', which='both')
ax.legend(fontsize=5.5, loc="upper right")

out_pdf = Path(FIG_DIR) / "figS_mean_ingredients.pdf"
fig.savefig(out_pdf, bbox_inches="tight", dpi=300)
print(f"Saved: {out_pdf}")

out_png = Path(FIG_DIR) / "figS_mean_ingredients.png"
fig.savefig(out_png, bbox_inches="tight", dpi=300)
print(f"Saved: {out_png}")
