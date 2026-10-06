# Agile, evaluation-gated design of a pixel-expansion-free color VC scheme — research package (v8, submission version)

# An Evaluation-Gated Agile Framework for Designing a Pixel-Expansion-Free Color Visual Cryptography Scheme — research package

**Authors:** Omar Isam Al-Mrayat, Dyala Ibrahim, Malik Jawarneh, Fawzy Habeeb, Ashraf Alyanbaaw, Ghada Elmarhomy, El Sayed Atlam

**Corresponding author:** Omar Isam Al-Mrayat (o.mrayat@aau.edu.jo)

This repository contains the complete GNU Octave implementation (including the C/MEX Floyd–Steinberg routine), the scripts that reproduce every experiment, table and figure (`run_all.sh`), and the per-seed results reported in the article.

## Contents
| Folder | What it holds |
|---|---|
| `manuscript/` | Revised manuscript (v8) and Supplementary Material, each as Word and PDF |
| `code/` | Complete GNU Octave implementation, C/MEX halftoning routine, experiment scripts, figure/statistics script |
| `images/` | Baboon; Astronaut, Coffee, Chelsea (scikit-image); `kodak/` the 24 Kodak images (from github.com/lemire/kodakimagecollection; six are 500×500 crops in that collection) |
| `results/` | Every CSV result, per-seed run logs, convergence curves, `stats_summary.txt`, generated shares/reconstructions (`images/`) and figures (`figures/`) |
| `archive/` | The original v1 manuscript and code, the v2, v3 and v4 manuscripts, and the diagnostic scripts that exposed the v1 problems |
| `run_all.sh` | Re-runs everything (about 4 h on one CPU core) |

## What changed from v1 (summary)
1. **Diagnosis.** Re-scoring the v1 GWO solutions on independent share grids showed that the halftone threshold bias had no real effect: Floyd–Steinberg error diffusion preserves mean tone for any threshold, so the v1 gains (3.0% / 8.5%) were selection of evaluation noise. NPCR/UACI computed between a binary share and the secret are fixed by construction (UACI = 50%, NPCR ≈ 100%) and were removed.
2. **Redesign (Iteration 2).** Per-channel tone pre-compensation (γ) before halftoning, counteracting the (1+d)/2 density compression of OR-stacked random grids.
3. **Method fixes.** Full-resolution search (264×264) via a bit-exact C/MEX Floyd–Steinberg; common random numbers (K = 4) in the fitness; 30 independent evaluation grids never seen by any optimizer; standard SSIM (Gaussian 11×11); border-normalized viewing filter; one viewing window for search and report; security metrics on the displayed shares; corrected BHHO (continuous positions, kept evaluated candidates, exact 400-evaluation budget); random-search comparator.

## Changes in v8 (second line-by-line proofreading)
- Section 6.4: Iteration 3 outperforms the closed form on 23 of 24 Kodak images in Q (was "every image").
- Literal "Q_p" in Tables 2-3 and Section 5.7 rendered as Qp with subscript; "ΔE00" written as ΔE₀₀ throughout; true minus signs in tables and text.
- Table 1: closed-form "gain vs. closed form" shown as a dash; caption explains why Iteration 4 has no search score; Figure 3 caption names Iterations 1-3.
- Lesson 3 of Section 6.1 says "relaxed" (consistent with Iteration 4); missing comma in the data availability statement restored.

## Changes in v7 (final line-by-line proofreading)
- Logic: XOR decoding is no longer presented as a remedy for cheating (with XOR an adversary can force any pattern); Section 5.5 and conclusion say "relaxed" (not "no") range guard; Sprint 1 no longer claims every decision cleared the rule "by wide margins" (Iteration 4: 0.85%, p = 0.52).
- Notation: perceived ink map renamed V_c (it clashed with the shares R1, R2); X defined in the UACI derivation; fitness/evaluation sentences cover Q_p and the 10 Kodak grids.
- Citations: duplicated [42] removed; Section 2.2 now points to Sections 5.5 and 5.7 for the perceptual checks.
- Wording: "gate was applied four times"; "17.7% on average"; CVC defined before use (now "color VC"); trade-off sentence of Section 3 updated; Figure 4 caption labels (a); p-values in scientific notation (× 10^n); duplicated "therefore", double parentheses and "S1, S2, …." fixed; Section 5.8 statement on the four-image perceptual results made exact.

## Changes in v6 (final expert reading)
- Accuracy: "relaxed range guard" (abstract); kappa "nearly triples" (0.078 -> 0.210) instead of "five-fold"; Iteration-1 score range "about 0.4%"; timing of the perceptual objective; Algorithm 1 line 13 cites Eq. (10); Eq. (4) written in terms of the secret density x.
- Disclosure: Kodak suite cited as a reference, mirror and the six pre-cropped images named in Section 5.1 and in the data availability statement; Holm correction stated for Table 3.
- Supplement: stale "future work" sentence removed; four-image perceptual statement restricted and linked to the Kodak result; sections A-G aligned with the main-text sections.
- Style: US spelling throughout; IEEE citation ranges; references renumbered in order of first citation (60 references; supplement citations updated); [56]/[CRP2-VCS] completed with DOI; intro repetition removed.

## Changes in v5.1 (expert reading and author revision of Sections 5.4-5.7 and 6.1)
- Fixed a counting error in Section 5.7: the closed form is better than Iteration 3 in mean CIEDE2000 on 18 (not 6) of the 24 Kodak images (p = 0.011).
- Removed a stale sentence in 5.4 that called a perceptual objective "future work" (it is Iteration 4); 5.4 now leads directly into 5.5.
- 5.5 reports that Iteration 4 is also 4.2% below Iteration 3 in Q, and names the colour-difference vs. structure trade-off.
- 5.7 and 6.1 state that choosing between Iteration 3 and the closed form is a requirement (Sprint 1), not a measurement.
- Corrected the PSNR statement in 5.8 (3.3 dB closed form, 1.9 dB Iteration 3); Table 4 now lists four iterations; 4.3 says "four designs" and qualifies the closed-form containment by 8-bit quantization; Algorithm 1 lists the knee-perceptual variable; limitation on the untuned normalization of Eq. (10).

## Changes in v5 (final round)
- Iteration 4 (exp12, exp12b): knee-plus-power curve searched with a perceptual objective Qp = 0.5(1 - dE00/50) + 0.5 SSIM(L*) and the gamma guard relaxed to [0.1, 3]. Qp +0.85% over Iteration 3 (p = 0.52), unchanged with a doubled budget -> rejected; Iteration 3 remains the accepted design and the guard is shown not to limit it.
- Kodak benchmark (exp13, 24 images, one search per image): Iteration 3 beats the baseline in Q on 24/24 images (mean +29.2%) and the closed form on 23/24 (p = 2e-5); better than the closed form in SSIM(L*) (19/24, p = 3e-4) and vivid chroma (17/24, p = 0.011); the closed form is slightly better in mean dE00 (by 0.63 units, 18/24 images); the two are tied in Qp (p = 0.053).
- Manuscript shortened to 22 pages of body text (26 with references); sensitivity, posterization, per-channel, four-image, optimizer and per-image Kodak results moved to a separate Supplementary Material document (8 tables, 7 figures).
- CIELAB conversion uses 65536-entry lookup tables (max error < 0.05) for speed; dE00 re-verified against Sharma et al.
- Housekeeping: files from an interrupted session were moved out of the code tree; load_secret now center-crops to a square (no effect on the square test images).

## Changes in v4 (third design iteration)
- Sprint-3 closed-form check: the inverse of the (1+d)/2 OR-stacking compression, d* = max(0, 2d-1), needs no optimizer and beats the optimized power law of Iteration 2 (+20.6% vs +10.4%) -> Iteration 2 superseded.
- Iteration 3: knee-plus-power tone curve (theta_c, gamma_c per channel, 48-bit chromosome) containing the closed form; +29.4% over baseline, +7.4% over the closed form on Baboon (all 12 seeds above, p = 0.0005); +2.7% to +6.4% over the closed form on the other three images (all 20 runs above).
- Posterization check (exp10): as gamma -> 0, Q rises through the contrast term while CIEDE2000 worsens -> gamma >= 0.5 bound, disclosed as a limitation (17/36 Baboon exponents on the bound).
- Perceptual table for all designs (exp11): Iteration 3 matches the closed form in CIEDE2000 and beats it in lightness SSIM and vivid-colour chroma on all four images.
- Accepted design, figures, per-channel metrics and security analysis now use Iteration 3.
- Text corrections: contrast index described as adapted from Shyu (denominator differs); "pre-stated" removed with disclosure of when the rule was fixed; notation (h, epsilon, M, R1/R2, offset); several wording and accuracy fixes.

## Changes in v3 (expert-review round)
- Perceptual colour assessment (exp7): CIEDE2000, lightness error, chroma retention in vivid/dull regions, SSIM on L*.
- Viewing-window (2×2–8×8) and resolution (264 vs 512) sensitivity (exp8).
- Proper numbered Word equations (1)–(8); notation cleaned (offset b_c, contrast κ_c, GWO P/W/Δ).
- Pre-stated acceptance rule (gain ≥ 1%, Wilcoxon p < 0.05), honest framing of the gate as hold-out validation with a human redesign step.
- New Figure 1 with the evaluation gate; Figure 3(a) as per-seed gains.
- Positioning vs. (2,2) random-grid constructions, AbS halftoning and printing tone compensation; six new references [54]–[59] (2014–2025).
- Fixes: "one third" (was "one tenth"), removed speculative magenta explanation, contrast-scale explanation, CPU stated, softened NPCR/UACI wording, AI-use statement placeholder.

## Key results (independent scores)
- Accepted design (Iteration 3, Baboon, 12 seeds): 0.2577 vs baseline 0.1991 (+29.4%) and closed form 0.2401 (+7.4%).
- Baboon, 12 seeds: baseline 0.19912; Iteration 1 (bias) 0.19943 (+0.15%); Iteration 2 (tone) 0.21977 (+10.37%, every seed).
- Four images, 5 seeds: Iteration 1 −0.04% to +0.17%; Iteration 2 +4.8% to +17.6%.
- Optimizers on Iteration 2: GWO ≈ BDA ≈ random search, HHO marginally lower; spread < 0.4% of baseline.
- Perceptual (4 images): CIEDE2000 −15% to −22%, lightness error −37% to −58%, SSIM on L* up slightly; vivid-colour chroma down on Baboon (60%→56%), up on Coffee/Chelsea.
- Viewing/resolution: offset has no effect at any window or resolution; tone gain +5.2% to +15.9%.
- Shares: entropy 1.0000 bit, |adjacent corr| ≤ 0.007, |CC vs secret| ≤ 0.007, MI vs halftone ≤ 1.1e-5 bits (all G-test p ≥ 0.31).

## Reproducing
```
./run_all.sh
```
Requires GNU Octave 8.4 + octave-image, `mkoctfile` (Debian/Ubuntu package `octave-dev`), and Python 3 with numpy, pandas, scipy, matplotlib, pillow. In MATLAB, compile the halftoner with `mex fs_halftone_mex.c`; without it, `halftone.m` falls back to the reference `floyd_steinberg.m` (identical output, much slower). Every experiment script is resumable.

## Code map
- Scheme: `rgb2cmy`, `tone_precompensate`, `halftone` → `fs_halftone_mex.c` / `floyd_steinberg`, `random_grid_encrypt`, `random_grid_decrypt`, `view_filter`, `build_cvc_channel`
- Metrics: `eval_metrics` (PSNR, `ssim_gauss`, Shyu contrast), `quality_score`, `security_metrics`, `binary_mi`, `srgb2lab`, `deltaE2000` (verified on Sharma et al. test pairs), `reconstruct_rgb`
- Search: `cvc_fitness`, `evaluate_design`, `make_R1set`, `decode_params`/`encode_params`, `design_from_params`, `run_design_search`; optimizers `BGWO1D`, `BDA1D`, `BHHO1D`, `BRS1D`
- Experiments: `exp1`…`exp13` (run order in `run_all.sh`; exp5, exp11 and exp12 need exp9) (settings in `setup_cfg.m`); figures and statistics: `make_figures.py`, `make_fig_framework.py`, `make_fig_kodak.py`; perceptual objective: `perceptual_score`, `evaluate_design_perceptual`

## Licenses and data
`BDA1D.m` and `Levy.m` derive from S. Mirjalili's BDA demo and are redistributed under the BSD license in `code/license.txt`. All other code was written for this project. Astronaut, Coffee and Chelsea are from scikit-image (see its data license); Baboon is the standard USC-SIPI test image.
