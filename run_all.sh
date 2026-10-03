#!/bin/sh
# Reproduces every experiment, table and figure of the v2 manuscript.
# Requirements: GNU Octave 8.4 + octave-image, mkoctfile (octave-dev), Python 3 with
# numpy, pandas, scipy, matplotlib, pillow. Runtime: about 4 h on one CPU core.
# Every experiment script is resumable: re-running skips runs already in results/.
set -e
cd "$(dirname "$0")/code"
[ -f fs_halftone_mex.mex ] || mkoctfile --mex fs_halftone_mex.c
for e in exp1_sprint3_diagnostics exp2_iterations exp3_optimizers exp4_images exp9_iteration3 exp10_posterization_check exp5_final_build exp6_weight_sensitivity exp7_perceptual_color exp8_viewing_sensitivity exp11_perceptual_all exp12_iteration4 exp12b_budget exp13_kodak; do
  echo "=== $e"; octave-cli -q $e.m
done
python3 make_figures.py && python3 make_fig_framework.py && python3 make_fig_kodak.py
