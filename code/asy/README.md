# Asymmetric-reservoir pipeline (`code/asy/`)

This is the from-scratch MATLAB pipeline for the **asymmetric** reservoir
(W ≠ Wᵀ) studied in the paper. The same script layout is used for all three
target systems. The quasi-periodic target additionally uses the sibling
`quasi_ensemble/` and `quasi_ensemble_Wonly/` folders for the seed-ensemble
aggregation step.

Each target folder is self-contained: the trajectory is generated from scratch
and every `func_*.m` helper lives inside the folder. The only external
dependency is MATLAB's **Global Optimization Toolbox** (`surrogateopt`, used by
the optional hyper-parameter optimization step).

## Pipeline (per target system)

```
gen_<system>_data.m        generate the target trajectory (ODE integration + normalization)
        │
        ▼
opt_chua_no_para.m         hyper-parameter optimization (surrogateopt)
        │   writes opt_Logi_<timestamp>.mat  ──► [rename to] opt_data_testnum_10.mat
        │                                          + min_rng_set_testnum_10.mat
        ▼
scan_rho.m  →  scan_rho_function.m       sweep ρ (spectral radius); per ρ:
        │   ├── func_train_chua_no_para.m      build reservoir, ridge-regression readout
        │   ├── func_dynamic_test_error.m      forecasting RMSE + prediction time T_ex
        │   └── func_LES_test.m
        │        ├── func_calculate_train_LES.m   teacher-forced direction-resolved FTLE
        │        └── func_calculate_test_LES.m    closed-loop FTLE
        │   saves data_<system>_asy_*.mat  (train_LEs_set, std_train_set,
        │                                   train_LEs_transient_set, Predict_time, error)
        ▼
{auto,driven,closed}_RC/RC_theory_<regime>.m    max-Lyapunov scan of the
        │                                        isolated / teacher-forced / closed reservoir
        │   saves RC_data_<regime>_asy_<system>.mat  (maxLE_set, eig_rho_range)
        ▼
plot_*.m / (Python) ../plotting/plot_fig*.py    figures
```

The three regimes correspond to the three Jacobians analyzed in the paper:

- **bare / auto** — isolated reservoir (no input): `D = (1-a)I + sech²(z)(1-a)W`
- **teacher-forced / driven** — driven by the target: same Jacobian form, evaluated along the input-driven trajectory
- **closed-loop / closed** — autonomous generation with readout feedback: `D = (1-a)I + sech²(z)(1-a)(W + Win·Wout)`

## SETI (computed in the Python plotting scripts)

$$\mathrm{SETI}(\rho) = \frac{1}{N}\sum_{i=1}^{N} \max(0,-\bar\lambda_i(\rho))\;\sigma_i(\rho)$$

where $\bar\lambda_i$ is the long-time average of direction $i$'s finite-time
Lyapunov exponent (FTLE) and $\sigma_i = \mathrm{Std}_t[\lambda_i(t)]$ is its
fluctuation amplitude. The ingredients (`train_LEs_set` = $\bar\lambda_i$,
`std_train_set` = $\sigma_i$) are produced by the MATLAB pipeline above; the
index itself is formed in `plotting/plot_fig2.py`, `plot_fig3.py`, and
`plot_fig4.py` (this is the authoritative implementation).

## Reservoir construction (`func_train_chua_no_para.m`)

- 500-node leaky-integrator echo-state network: `x ← (1-a)x + a·tanh(Win·u + W·x)`
- **Asymmetric** W: each nonzero edge drawn independently at random
- Input gain, leak rate `a`, spectral radius ρ, ridge parameter, and density
  are set inside `func_train_chua_no_para.m` / `scan_rho_function.m` — see
  those files for the exact values used for each target.
- Readout: ridge regression `Wout = Y·Xᵀ (X·Xᵀ + reg·I)⁻¹`

## Direction-resolved FTLE (`func_calculate_train_LES.m`)

1. Initialize a random orthonormal basis Q.
2. Per step: form the Jacobian D and evolve Q ← D·Q.
3. Periodically re-orthonormalize via QR: `[Q, R] = qr(Q, 0)`.
4. Window FTLE = `log|diag(R)| / window_T`.
5. Two outputs: `train_LEs_transient` (per-window FTLE → drives σᵢ) and
   `train_LEs` (running mean → $\bar\lambda_i$).

## Notes on reproducibility

- **`opt_chua_no_para.m` writes to a timestamped filename.** Downstream scripts
  load `opt_data_testnum_10.mat` and `min_rng_set_testnum_10.mat`; copy/rename
  the optimizer output accordingly before running `scan_rho.m`. (Small input
  `.mat` files shipping a representative optimized hyper-parameter set are
  included in each target folder so the scan can be run directly.)
- Full ρ-scans and the `RC_theory_*.m` Lyapunov scans are compute-heavy (tens
  of minutes to hours per target). The committed lightweight data under
  `plotting/data/code_mirror/` lets the figures be reproduced without rerunning
  them.
- This release ships the **asymmetric** pipeline only. The symmetric reservoir
  (W = Wᵀ) used as a control in the paper is represented in the figures via the
  committed mirror data; its pipeline is identical in structure with a symmetric
  W construction.
