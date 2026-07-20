# SETI — Stability–Expressivity Transfer Index for reservoir forecasting

Reference code and data for the paper:

> **Beyond the Edge of Chaos: Stability–Expressivity Transfer in Reservoir Forecasting**

## What this repository contains

The paper introduces the **Stability–Expressivity Transfer Index (SETI)**, a
design criterion computed from the *teacher-forced* reservoir's direction-
resolved finite-time Lyapunov spectrum, which predicts the spectral radius
ρ of the recurrent weight matrix W that is optimal for *autonomous*
forecasting — without running any forecasting scan. SETI is benchmarked on
three target systems (Lorenz, Chen, and a quasiperiodic torus), contrasting an
**asymmetric** reservoir (W ≠ Wᵀ) with a **symmetric** one (W = Wᵀ).

```
SETI/
├── README.md                 this file
├── LICENSE                   MIT (code); figure data under CC-BY-4.0 (see note)
├── CITATION.cff              how to cite this repository
├── DATA.md                   provenance of every data file + how to regenerate the large ones
├── code/
│   └── asy/                  from-scratch MATLAB pipeline, asymmetric reservoir
│       ├── lorenz/           three target systems share the same script layout
│       ├── chen/
│       ├── quasi/            (the quasi-periodic pipeline also uses the sibling
│       ├── quasi_ensemble/    quasi_ensemble/ and quasi_ensemble_Wonly/ folders)
│       └── quasi_ensemble_Wonly/
├── plotting/                 Python scripts that produce every paper figure
│   ├── config.py             paths, colors, shared style
│   ├── run_all.py            regenerate all figures in one command
│   ├── plot_fig1.py … plot_fig4.py
│   ├── plot_figS_ftle.py  plot_figS_closed.py  plot_figS_mean_ingredients.py
│   └── data/
│       ├── code_mirror/      committed lightweight figure data (see below)
│       ├── ftle_comparison.mat
│       └── extract_figure_data.py   documents how code_mirror/ was produced
└── figures/                  the figure PDFs as they appear in the paper (reference output)
```

## Quick start — regenerate the paper figures

Requirements: Python 3 with `numpy`, `scipy`, `matplotlib` (and, optionally, a
Times-New-Roman-ish serif font for exact typography).

```bash
cd plotting
python3 run_all.py
```

This reproduces all figure PDFs into `../figures/`. Each script can also be run
individually, e.g. `python3 plot_fig1.py`.

The scripts read from `plotting/data/code_mirror/` by default — a committed,
**lightweight** mirror of the large MATLAB outputs that contains *only* the
variables each figure actually uses (total ≈ 34 MB instead of ≈ 12 GB of raw
`.mat`). See `plotting/data/extract_figure_data.py` for exactly how it was
built. No MATLAB run is needed to reproduce the figures.

## Figure ↔ script ↔ data

| Paper figure | Script | Output | Data read |
|---|---|---|---|
| Fig. 1 (3 regimes × 3 targets) | `plot_fig1.py` | `fig1_three_regime.pdf` | `RC_data_*` LE curves + scan/prediction files |
| Fig. 2 (FTLE traces + ingredients) | `plot_fig2.py` | `fig3-nnew.pdf` | `asy/lorenz/data_lorenz_asy_W_a_0.7.mat` |
| Fig. 3 (SETI vs forecasting horizon) | `plot_fig3.py` | `fig3_SEAI.pdf` | 6 prediction/SETI files |
| Fig. S1 (sy vs asy FTLE traces) | `plot_figS_ftle.py` | `figS_ftle_traces.pdf` | `data/ftle_comparison.mat` |
| Fig. S2 (closed-loop trajectories) | `plot_figS_closed.py` | `figS_closed_trajectories.pdf` | sy closed-loop trajectory + LE files |
| (extra) 4-point ρ comparison | `plot_fig4.py` | `fig_four_points_comparison.pdf` | asy `RC_data_*` + asy scan files |
| (extra) scan-wise ingredients | `plot_figS_mean_ingredients.py` | `figS_mean_ingredients.pdf` | `asy/lorenz/data_lorenz_asy_W_a_0.7.mat` |

The five figures used in the submission are Fig. 1, 2, 3, S1, S2.
(`plot_fig4.py` and `plot_figS_mean_ingredients.py` are additional analyses;
`run_all.py` regenerates all of them.)

> Note on filenames: `fig3-nnew.pdf` is the paper's **Fig. 2**, and
> `fig3_SEAI.pdf` is the paper's **Fig. 3**. The `fig3` prefix is a historical
> label; the mapping above is the authoritative one.

## From-scratch reproduction (the asymmetric-reservoir pipeline)

The `code/asy/` tree is a self-contained MATLAB pipeline that regenerates the
large `.mat` outputs from scratch, for each of the three target systems. The
script layout is identical across `lorenz/`, `chen/`, and the `quasi*/` family.
See `code/asy/README.md` for the per-script pipeline and the role of each
`func_*.m` helper.

To plot from your own from-scratch run instead of the committed mirror, point
the plotting scripts at your regenerated `code/` tree:

```bash
export SETI_CODE_BASE=/path/to/your/code
cd plotting && python3 run_all.py
```

## Requirements

- **Python ≥ 3.8** with `numpy`, `scipy`, `matplotlib` — for the figures.
- **MATLAB** (developed on R2023a) with the **Global Optimization Toolbox**
  (`surrogateopt` is used by the hyper-parameter optimization step) — only
  needed for the from-scratch `code/asy/` pipeline.

## License

- **Code** (MATLAB under `code/`, Python under `plotting/`): MIT, see
  `LICENSE`.
- **Figure data** (`plotting/data/`, `figures/`): released under
  CC-BY-4.0. The figure PDFs in `figures/` are provided as reference output;
  the manuscript itself is not included here.

## Citation

If this code or data is useful to your work, please cite both the paper and
this repository (see `CITATION.cff`).
