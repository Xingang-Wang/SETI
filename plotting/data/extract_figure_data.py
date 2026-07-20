#!/usr/bin/env python3
"""
extract_figure_data.py
----------------------
Builds the lightweight `code_mirror/` data tree consumed by the plotting
scripts, by reading the ORIGINAL (large) .mat outputs of the MATLAB pipeline
and keeping only the variables / slices that the figure code actually reads.

This script is shipped with the repository for **provenance/auditability**: it
documents exactly how each lightweight file in `code_mirror/` was produced.
Running it requires the original large .mat files (not distributed here — they
are regenerable from the MATLAB code under `code/asy/`); set ORIGINAL_ROOT
below to the path of a checkout that contains them.

If you just want to regenerate the paper figures, you do NOT need to run this
script — the `code_mirror/` tree it produces is already committed.

Original large files (sizes on the development machine):
  code/{sy,asy}/{lorenz,chen,quasi}/{auto,driven,closed}_RC/RC_data_*.mat  (0.4–1.1 GB each)
  code/asy/lorenz/data_lorenz_asy_W_a_0.7.mat                              (254 MB)
  code/asy/chen/data_chen_a_0.7_asy.mat                                    (135 MB)
  Writing/paper_latest/plotting/data/ftle_comparison.mat                   (105 MB)
  code/sy/lorenz/closed_RC/RC_data_closed_sy_lorenz.mat                    (1.0 GB)  [subset of RC_data set]
  code/sy/quasi/closed_RC/RC_data_closed_sy_quasi.mat                      (—)       [subset of RC_data set]
"""

import os
import shutil
import numpy as np
from scipy.io import loadmat, savemat

# ---------------------------------------------------------------------------
# Point this at a workspace that holds the original (large) .mat files.
# ---------------------------------------------------------------------------
ORIGINAL_ROOT = os.environ.get(
    'SETI_ORIGINAL_ROOT',
    '/Users/strong/Desktop/research-workspace/projects/current-project')

HERE = os.path.dirname(os.path.abspath(__file__))            # .../plotting/data
MIRROR_ROOT = os.path.join(HERE, 'code_mirror')              # lightweight mirror of code/ tree

REGIMES = ['auto', 'driven', 'closed']
ARCHS = ['sy', 'asy']
SYSTEMS = ['lorenz', 'chen', 'quasi']


def _save_mirror(rel, md):
    dst = os.path.join(MIRROR_ROOT, rel)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    savemat(dst, md, do_compression=True, oned_as='column')
    return dst


def _copy_mirror(rel):
    """Byte-copy a small source file verbatim into the mirror."""
    src = os.path.join(ORIGINAL_ROOT, 'code', rel)
    dst = os.path.join(MIRROR_ROOT, rel)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copyfile(src, dst)
    return dst


def _size_mb(path):
    return os.path.getsize(path) / 1e6


# ---------------------------------------------------------------------------
# 1. RC_data_{regime}_{arch}_{system}.mat  — keep only maxLE_set + eig_rho_range
#    (these are the only variables plot_fig1 / plot_figS_closed read)
# ---------------------------------------------------------------------------
def extract_rc_data():
    print('[1] RC_data files (keep maxLE_set + eig_rho_range)')
    for regime in REGIMES:
        for arch in ARCHS:
            for sys in SYSTEMS:
                rel = f'{arch}/{sys}/{regime}_RC/RC_data_{regime}_{arch}_{sys}.mat'
                src = os.path.join(ORIGINAL_ROOT, 'code', rel)
                if not os.path.exists(src):
                    print(f'    SKIP (missing): {rel}')
                    continue
                m = loadmat(src)
                keep = {k: m[k] for k in ('maxLE_set', 'eig_rho_range') if k in m}
                dst = _save_mirror(rel, keep)
                print(f'    {rel}: {_size_mb(src):.1f} MB -> {_size_mb(dst)/1e3:.2f} KB')


# ---------------------------------------------------------------------------
# 2. asy/lorenz/data_lorenz_asy_W_a_0.7.mat — trim train_LEs_transient_set
#    to the rho=0.7 slice only (index 7). plot_fig2 reads transient_set[7];
#    the other 15 rho entries are never read by any figure script.
# ---------------------------------------------------------------------------
RHO07_IDX = 7  # rho_all = arange(0,1.6,0.1); rho_all[7] = 0.7

def extract_asy_lorenz_scan():
    print('[2] asy/lorenz/data_lorenz_asy_W_a_0.7.mat (trim transient to rho=0.7)')
    rel = 'asy/lorenz/data_lorenz_asy_W_a_0.7.mat'
    src = os.path.join(ORIGINAL_ROOT, 'code', rel)
    m = loadmat(src)
    trans = m['train_LEs_transient_set'].ravel()
    n = len(trans)
    new_trans = np.empty(n, dtype=object)
    for i in range(n):
        new_trans[i] = trans[i] if i == RHO07_IDX else np.empty((0, trans[i].shape[1] if trans[i].ndim == 2 else 0))
    md = {
        'Predict_time': m['Predict_time'],
        'error': m['error'],
        'std_train_set': m['std_train_set'],
        'train_LEs_set': m['train_LEs_set'],
        'train_LEs_transient_set': new_trans,
    }
    dst = _save_mirror(rel, md)
    print(f'    {_size_mb(src):.1f} MB -> {_size_mb(dst):.2f} MB '
          f'(transient[{RHO07_IDX}] shape={trans[RHO07_IDX].shape})')


# ---------------------------------------------------------------------------
# 3. asy/chen/data_chen_a_0.7_asy.mat — no script reads its transient; drop it.
# ---------------------------------------------------------------------------
def extract_asy_chen_scan():
    print('[3] asy/chen/data_chen_a_0.7_asy.mat (drop transient)')
    rel = 'asy/chen/data_chen_a_0.7_asy.mat'
    src = os.path.join(ORIGINAL_ROOT, 'code', rel)
    m = loadmat(src)
    md = {
        'Predict_time': m['Predict_time'],
        'error': m['error'],
        'std_train_set': m['std_train_set'],
        'train_LEs_set': m['train_LEs_set'],
    }
    dst = _save_mirror(rel, md)
    print(f'    {_size_mb(src):.1f} MB -> {_size_mb(dst)/1e3:.2f} KB')


# ---------------------------------------------------------------------------
# 4. Small files — copy verbatim.
# ---------------------------------------------------------------------------
def copy_small_files():
    print('[4] small files (verbatim copy)')
    rels = [
        'asy/quasi_ensemble_Wonly/data_quasi_Wonly_ensemble_merged.mat',
        'sy/lorenz/data_in_lorenz.mat',
        'sy/chen/data_in_chen.mat',
        'sy/quasi_ensemble_Wonly/data_quasi_Wonly_ensemble_filtered.mat',
        'sy/lorenz/closed_RC/prediction_trajectory_sy_lorenz.mat',
        'sy/quasi/closed_RC/prediction_trajectory_sy_quasi.mat',
    ]
    for rel in rels:
        src = os.path.join(ORIGINAL_ROOT, 'code', rel)
        if not os.path.exists(src):
            print(f'    SKIP (missing): {rel}')
            continue
        dst = _copy_mirror(rel)
        print(f'    {rel}: {_size_mb(src):.3f} MB (copied)')


# ---------------------------------------------------------------------------
# 5. ftle_comparison.mat — trim each transient to its first NROW_KEEP rows.
#    plot_figS_ftle reads transient[200:200+500]; 700 rows is a safe superset.
# ---------------------------------------------------------------------------
NROW_KEEP = 700

def extract_ftle_comparison():
    print('[5] ftle_comparison.mat (trim transient rows to first 700)')
    src = os.path.join(ORIGINAL_ROOT, 'Writing/paper_latest/plotting/data/ftle_comparison.mat')
    m = loadmat(src)

    def trim(key):
        arr = m[key].ravel()
        out = np.empty(len(arr), dtype=object)
        for i, e in enumerate(arr):
            out[i] = e[:NROW_KEEP] if e.shape[0] > NROW_KEEP else e
        return out

    md = {
        'sy_transient_set': trim('sy_transient_set'),
        'asy_transient_set': trim('asy_transient_set'),
        'sy_LEs_set': m['sy_LEs_set'],
        'asy_LEs_set': m['asy_LEs_set'],
        'sy_rho_arr': m['sy_rho_arr'],
        'asy_rho_arr': m['asy_rho_arr'],
        'selected_rho': m['selected_rho'],
    }
    dst = os.path.join(HERE, 'ftle_comparison.mat')
    savemat(dst, md, do_compression=True, oned_as='column')
    print(f'    {_size_mb(src):.1f} MB -> {_size_mb(dst):.2f} MB')


if __name__ == '__main__':
    extract_rc_data()
    extract_asy_lorenz_scan()
    extract_asy_chen_scan()
    copy_small_files()
    extract_ftle_comparison()
    print('\nDone. Lightweight data written to:', MIRROR_ROOT)
