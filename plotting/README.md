# Paper Figure Scripts

Python scripts that produce every figure in the paper
*"Beyond the Edge of Chaos: Stability–Expressivity Transfer in Reservoir
Forecasting"* (Du & Wang, PRL submitted).

## Quick start

```bash
cd plotting
python3 run_all.py          # regenerate all figures into ../figures/
```

Or one figure at a time:

```bash
python3 plot_fig1.py
python3 plot_fig2.py
...
```

Requirements: Python 3 with `numpy`, `scipy`, `matplotlib`.

## Where the data comes from

All scripts read via paths defined in `config.py`. By default they read from
**`data/code_mirror/`**, a committed lightweight mirror of the MATLAB pipeline
outputs (only the variables each figure uses). No MATLAB run is needed.

To plot instead from a full from-scratch `code/` tree (produced by
`code/asy/`):

```bash
export SETI_CODE_BASE=/path/to/your/code
python3 run_all.py
```

See `data/extract_figure_data.py` for exactly how the lightweight mirror was
built, and `../DATA.md` for the full figure↔data↔source provenance.

## Files

```
plotting/
├── config.py            # paths (auto-detected), colors, shared matplotlib style
├── run_all.py           # regenerate all figures
├── plot_fig1.py         # Fig. 1  — 3 regimes × 3 targets (LE vs ρ)
├── plot_fig2.py         # Fig. 2  — representative FTLE traces + scan-wise ingredients
├── plot_fig3.py         # Fig. 3  — SETI vs forecasting horizon (6 panels)
├── plot_fig4.py         # extra   — 4-point ρ comparison (bar chart)
├── plot_figS_ftle.py    # Fig. S1 — sy vs asy FTLE traces at 3 ρ values
├── plot_figS_closed.py  # Fig. S2 — closed-loop prediction trajectories
├── plot_figS_mean_ingredients.py  # extra — scan-wise mean ingredients (asy/Lorenz)
├── README.md            # this file
└── data/
    ├── code_mirror/        # lightweight figure data (committed)
    ├── ftle_comparison.mat # Fig. S1 source data (trimmed)
    └── extract_figure_data.py
```

## Figure ↔ script ↔ output

| Paper figure | Script | Output PDF |
|---|---|---|
| Fig. 1 | `plot_fig1.py` | `fig1_three_regime.pdf` |
| Fig. 2 | `plot_fig2.py` | `fig3-nnew.pdf` |
| Fig. 3 | `plot_fig3.py` | `fig3_SEAI.pdf` |
| Fig. S1 | `plot_figS_ftle.py` | `figS_ftle_traces.pdf` |
| Fig. S2 | `plot_figS_closed.py` | `figS_closed_trajectories.pdf` |
| extra | `plot_fig4.py` | `fig_four_points_comparison.pdf` |
| extra | `plot_figS_mean_ingredients.py` | `figS_mean_ingredients.pdf` |

> `fig3-nnew.pdf` is the paper's **Fig. 2** and `fig3_SEAI.pdf` is **Fig. 3**
> (the `fig3` prefix is a historical label; the table above is authoritative).

## Style

All scripts share a consistent style defined in `config.py`:
- Font: Times New Roman / STIX math
- Inward ticks; symmetric reservoir = blue (`#2166AC`), asymmetric = red (`#B2182B`)
- 300 DPI
