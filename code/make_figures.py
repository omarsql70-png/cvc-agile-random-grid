"""make_figures.py - figures and statistics for the revised CVC paper.
Reads the CSV outputs of exp1-exp6 in ../results and writes PNG figures
to ../results/figures and a plain-text statistics report.
Requires: numpy, pandas, scipy, matplotlib, pillow."""
import os, numpy as np, pandas as pd, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from scipy import stats
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "results"); FIG = os.path.join(RES, "figures"); IMG = os.path.join(RES, "images")
os.makedirs(FIG, exist_ok=True)
plt.rcParams.update({"font.size": 9, "font.family": "DejaVu Sans", "axes.spines.top": False,
                     "axes.spines.right": False, "savefig.dpi": 300, "savefig.bbox": "tight"})
CH = {"C": "#00a3c4", "M": "#c4007a", "Y": "#c9a800"}
COL = {"baseline": "#7f7f7f", "bias": "#d95f02", "gamma": "#1b9e77"}
out = []
def say(s=""): out.append(s); print(s)
def cohen_dz(a, b): d = np.asarray(a) - np.asarray(b); return d.mean() / d.std(ddof=1)

# ---------- Figure: Sprint-3 evidence ------------------------------------
d1 = pd.read_csv(f"{RES}/exp1a_density_vs_bias.csv"); qb = pd.read_csv(f"{RES}/exp1b_quality_vs_bias.csv")
qg = pd.read_csv(f"{RES}/exp1c_quality_vs_gamma.csv")
fig, ax = plt.subplots(1, 3, figsize=(10.5, 3.0))
for c in "CMY":
    s = d1[d1.channel == c]
    ax[0].plot(s.bias, 100 * s.black_fraction, "o-", ms=3, color=CH[c], label=f"{c} halftone")
    ax[0].axhline(100 * s.mean_ink.iloc[0], color=CH[c], ls=":", lw=1)
ax[0].set(xlabel="Threshold bias b", ylabel="Black-dot density (%)", title="(a) Error diffusion preserves tone",
          ylim=(40, 62)); ax[0].legend(frameon=False, fontsize=7)
ax[1].errorbar(qb.bias, qb.q_mean, yerr=qb.q_sd, fmt="o-", ms=3, color=COL["bias"], capsize=2)
ax[1].set(xlabel="Common threshold bias b", ylabel="Quality score Q (30 independent grids)",
          title="(b) Iteration-1 variable: no effect", ylim=(0.16, 0.225))
ax[2].errorbar(qg.gamma, qg.q_mean, yerr=qg.q_sd, fmt="o-", ms=3, color=COL["gamma"], capsize=2)
ax[2].axvline(1.0, color="k", ls=":", lw=1)
ax[2].set(xlabel=r"Common tone exponent $\gamma$", title=r"(c) Iteration-2 variable: real effect", ylim=(0.16, 0.225))
fig.tight_layout(); fig.savefig(f"{FIG}/fig_sprint3_evidence.png"); plt.close(fig)
say("== Sprint-3 diagnostics (Baboon, 264x264, 30 independent grids)")
rng = d1.groupby("channel").black_fraction.agg(lambda s: 100 * (s.max() - s.min()))
say("black-dot density range over b in [-80,80] (percentage points): " + ", ".join(f"{k}={v:.2f}" for k, v in rng.items()))
say(f"Q over bias sweep: min {qb.q_mean.min():.5f}, max {qb.q_mean.max():.5f}; per-draw SD ~{qb.q_sd.mean():.5f}")
gi = qg.q_mean.idxmax()
say(f"Q over gamma sweep: gamma=1 -> {qg.q_mean[qg.gamma==1].iloc[0]:.5f}; best gamma={qg.gamma[gi]:.2f} -> {qg.q_mean[gi]:.5f}")

# ---------- Iterations (exp2) -------------------------------------------
r2 = pd.read_csv(f"{RES}/exp2_runs.csv"); base = np.loadtxt(f"{RES}/exp2_baseline_indep_scores.txt").ravel()
it1 = r2[r2["mode"] == "bias"].sort_values("seed"); it2 = r2[r2["mode"] == "gamma"].sort_values("seed")
bmean = base.mean()
say("\n== Design iterations, Baboon, GWO (independent re-scoring)")
say(f"baseline (b=0, gamma=1): Q = {bmean:.5f} (SD over 30 grids {base.std(ddof=1):.5f})")
for lab, s in [("Iteration 1 (bias)", it1), ("Iteration 2 (gamma)", it2)]:
    if len(s) == 0: continue
    gap = s.search_score - s.indep_mean
    t = stats.ttest_1samp(s.indep_mean, bmean)
    w = stats.wilcoxon(s.indep_mean - bmean) if len(s) > 5 else None
    say(f"{lab}: n={len(s)} search Q {s.search_score.mean():.5f}+-{s.search_score.std():.5f} | "
        f"independent Q {s.indep_mean.mean():.5f}+-{s.indep_mean.std():.5f} | gain vs baseline "
        f"{100*(s.indep_mean.mean()/bmean-1):+.2f}% | t={t.statistic:.2f} p={t.pvalue:.2e}"
        + (f" | Wilcoxon p={w.pvalue:.2e}" if w else "") + f" | search-minus-independent gap {gap.mean():.5f}")
    say("  params per seed: " + "; ".join(f"[{a:.2f},{b:.2f},{c:.2f}]" for a, b, c in zip(s.p_C, s.p_M, s.p_Y)))
if len(it1) and len(it2):
    m = min(len(it1), len(it2))
    t = stats.ttest_rel(it2.indep_mean.values[:m], it1.indep_mean.values[:m])
    say(f"Iteration 2 vs Iteration 1 (paired by seed): t={t.statistic:.2f}, p={t.pvalue:.2e}, d_z={cohen_dz(it2.indep_mean.values[:m], it1.indep_mean.values[:m]):.2f}")
    r9 = pd.read_csv(f"{RES}/exp9_runs.csv"); i3 = r9[r9.image == "baboon"].sort_values("seed")
    an = pd.read_csv(f"{RES}/exp9_analytic.csv").set_index("image").loc["baboon", "analytic_q"]
    COL["iter3"] = "#7570b3"
    fig, ax = plt.subplots(1, 2, figsize=(8.5, 3.3))
    g1 = 100 * (it1.indep_mean.values[:m] / bmean - 1); g2 = 100 * (it2.indep_mean.values[:m] / bmean - 1); g3 = 100 * (i3.indep_mean.values / bmean - 1)
    rng_ = np.random.default_rng(3)
    for k, (g, c) in enumerate([(g1, COL["bias"]), (g2, COL["gamma"]), (g3, COL["iter3"])]):
        ax[0].scatter(k + rng_.uniform(-.08, .08, len(g)), g, s=16, color=c, zorder=3)
        ax[0].hlines(g.mean(), k - .25, k + .25, color="k", lw=1.5, zorder=4)
        ax[0].text(k + .28, g.mean(), f"{g.mean():+.1f}%", va="center", fontsize=8)
    ax[0].axhline(0, color=COL["baseline"], ls="--", lw=1)
    ax[0].axhline(100 * (an / bmean - 1), color="k", ls=":", lw=1.2)
    ax[0].text(-0.45, 100 * (an / bmean - 1) + 0.8, "closed-form inverse", fontsize=7.5)
    ax[0].set_xticks([0, 1, 2], ["Iteration 1\n(offset)", "Iteration 2\n(power law)", "Iteration 3\n(knee + power)"]); ax[0].set_xlim(-.5, 2.75)
    ax[0].set(ylabel="Independent gain over baseline (%)", title="(a) Per-seed outcome (12 seeds)")
    for lab, s_, c in [("Iteration 1", it1, COL["bias"]), ("Iteration 2", it2, COL["gamma"]), ("Iteration 3", i3, COL["iter3"])]:
        ax[1].scatter(s_.search_score, s_.indep_mean, s=16, color=c, label=lab)
    allv = np.r_[r2.indep_mean, r2.search_score, i3.indep_mean, i3.search_score]
    lo, hi = allv.min() - 0.003, allv.max() + 0.003
    ax[1].plot([lo, hi], [lo, hi], "k:", lw=1); ax[1].axhline(bmean, color=COL["baseline"], ls="--", lw=1, label="baseline")
    ax[1].axhline(an, color="k", ls=":", lw=1.2, label="closed-form inverse")
    ax[1].set(xlabel="Score on the K=4 search grids", ylabel="Score on 30 unseen grids", title="(b) Search vs. independent score")
    ax[1].legend(frameon=False, fontsize=7); fig.tight_layout(); fig.savefig(f"{FIG}/fig_iterations.png"); plt.close(fig)
    c2 = pd.read_csv(f"{RES}/exp2_curves.csv")
    fig, ax = plt.subplots(figsize=(4.6, 3.0))
    for mode, lab in [("bias", "Iteration 1 (bias)"), ("gamma", "Iteration 2 (tone)")]:
        cv = np.array([[float(v) for v in s.strip(";").split(";")] for s in c2[c2["mode"] == mode].curve])
        it = np.arange(1, cv.shape[1] + 1); mu = cv.mean(0); sd = cv.std(0)
        ax.plot(it, mu, color=COL[mode], label=lab); ax.fill_between(it, mu - sd, mu + sd, color=COL[mode], alpha=0.2)
    c9 = pd.read_csv(f"{RES}/exp9_curves.csv"); c9 = c9[c9.image == "baboon"]
    cv = np.array([[float(v) for v in s_.strip(";").split(";")] for s_ in c9.curve]); it_ = np.arange(1, cv.shape[1] + 1)
    ax.plot(it_, cv.mean(0), color=COL["iter3"], label="Iteration 3 (knee + power)"); ax.fill_between(it_, cv.mean(0) - cv.std(0), cv.mean(0) + cv.std(0), color=COL["iter3"], alpha=0.2)
    ax.axhline(an, color="k", ls=":", lw=1.2, label="closed-form inverse (independent)")
    ax.axhline(bmean, color=COL["baseline"], ls="--", lw=1, label="baseline (independent)")
    ax.set(xlabel="GWO iteration", ylabel="Best search score (mean ± SD, 12 seeds)"); ax.legend(frameon=False, fontsize=7)
    fig.tight_layout(); fig.savefig(f"{FIG}/fig_convergence.png"); plt.close(fig)

# ---------- Optimizers (exp3) -------------------------------------------
if os.path.exists(f"{RES}/exp3_runs.csv"):
    r3 = pd.read_csv(f"{RES}/exp3_runs.csv")
    allr = pd.concat([it2.assign(optimizer="GWO"), r3])
    order = [o for o in ["GWO", "BDA", "HHO", "RS"] if o in set(allr.optimizer)]
    say("\n== Optimizer comparison (Iteration-2 task, independent Q, equal 400-evaluation budget)")
    for o in order:
        s = allr[allr.optimizer == o]
        say(f"{o}: n={len(s)} Q {s.indep_mean.mean():.5f}+-{s.indep_mean.std():.5f} evals {s.evals.min()}-{s.evals.max()} "
            f"gamma mean [{s.p_C.mean():.2f},{s.p_M.mean():.2f},{s.p_Y.mean():.2f}]")
    piv = allr.pivot_table(index="seed", columns="optimizer", values="indep_mean")[order].dropna()
    if len(order) > 2 and len(piv) > 2:
        fr = stats.friedmanchisquare(*[piv[o] for o in order]); say(f"Friedman (n={len(piv)} seeds): chi2={fr.statistic:.2f}, p={fr.pvalue:.3f}")
        for i in range(len(order)):
            for j in range(i + 1, len(order)):
                a, b = piv[order[i]], piv[order[j]]
                say(f"  {order[i]} vs {order[j]}: Wilcoxon p={stats.wilcoxon(a, b).pvalue:.3f}, mean diff {a.mean()-b.mean():+.5f}")
    fig, ax = plt.subplots(figsize=(4.6, 3.0))
    data = [allr[allr.optimizer == o].indep_mean.values for o in order]
    ax.boxplot(data, widths=0.5, showfliers=False)
    for i, dd in enumerate(data): ax.scatter(np.full(len(dd), i + 1) + np.random.default_rng(i).uniform(-.12, .12, len(dd)), dd, s=10, color=COL["gamma"], zorder=3)
    ax.axhline(bmean, color=COL["baseline"], ls="--", lw=1, label="baseline")
    ax.set_xticks(range(1, len(order) + 1), order); ax.set(ylabel="Independent quality score Q"); ax.legend(frameon=False, fontsize=7)
    fig.tight_layout(); fig.savefig(f"{FIG}/fig_optimizers.png"); plt.close(fig)

# ---------- Images (exp4 + Baboon seeds 1-5 from exp2) -------------------
if os.path.exists(f"{RES}/exp4_runs.csv"):
    r4 = pd.read_csv(f"{RES}/exp4_runs.csv")
    bb = r2[r2.seed <= 5]
    r4 = pd.concat([bb, r4]); imgs = ["baboon", "astronaut", "coffee", "chelsea"]; imgs = [i for i in imgs if i in set(r4.image)]
    say("\n== Generalization across images (GWO, 5 seeds, independent Q)")
    rows = []
    for im in imgs:
        s = r4[r4.image == im]; b = s.baseline_indep_mean.iloc[0]
        q1 = s[s["mode"] == "bias"].indep_mean; q2 = s[s["mode"] == "gamma"].indep_mean
        rows.append((im, b, q1.mean(), q1.std(), q2.mean(), q2.std()))
        g = s[s["mode"] == "gamma"]
        say(f"{im}: baseline {b:.5f} | iter1 {q1.mean():.5f}+-{q1.std():.5f} ({100*(q1.mean()/b-1):+.2f}%) | "
            f"iter2 {q2.mean():.5f}+-{q2.std():.5f} ({100*(q2.mean()/b-1):+.2f}%) | gamma mean [{g.p_C.mean():.2f},{g.p_M.mean():.2f},{g.p_Y.mean():.2f}]")
    r9 = pd.read_csv(f"{RES}/exp9_runs.csv"); an9 = pd.read_csv(f"{RES}/exp9_analytic.csv").set_index("image")
    fig, ax = plt.subplots(figsize=(6.6, 3.0)); x = np.arange(len(rows)); w = 0.17
    q3 = [r9[(r9.image == r[0]) & (r9.seed <= 5)].indep_mean for r in rows]
    ax.bar(x - 2*w, [r[1] for r in rows], w, color=COL["baseline"], label="Baseline")
    ax.bar(x - w, [r[2] for r in rows], w, yerr=[r[3] for r in rows], color=COL["bias"], label="Iteration 1", capsize=2)
    ax.bar(x, [r[4] for r in rows], w, yerr=[r[5] for r in rows], color=COL["gamma"], label="Iteration 2", capsize=2)
    ax.bar(x + w, [an9.loc[r[0], "analytic_q"] for r in rows], w, color="#444444", label="Closed-form inverse")
    ax.bar(x + 2*w, [q.mean() for q in q3], w, yerr=[q.std() for q in q3], color="#7570b3", label="Iteration 3", capsize=2)
    ax.set_xticks(x, [r[0].capitalize() for r in rows]); ax.set(ylabel="Independent quality score Q")
    ax.set_ylim(min(r[1] for r in rows) * 0.9, max(q.mean() for q in q3) * 1.12); ax.legend(frameon=False, fontsize=7, ncol=3, loc="upper left")
    fig.tight_layout(); fig.savefig(f"{FIG}/fig_images.png"); plt.close(fig)

# ---------- Visual panels (exp5) ----------------------------------------
if os.path.exists(f"{IMG}/reconstructed_iter2.png"):
    def show(a, p, t): a.imshow(Image.open(p), cmap="gray", interpolation="nearest"); a.set_title(t, fontsize=8); a.axis("off")
    fig, ax = plt.subplots(1, 5, figsize=(12, 2.9))
    show(ax[0], f"{IMG}/secret_original.png", "(a) Secret")
    show(ax[1], f"{IMG}/reconstructed_baseline.png", "(b) Baseline")
    show(ax[2], f"{IMG}/reconstructed_iter2.png", "(c) Iteration 2")
    show(ax[3], f"{IMG}/reconstructed_analytic.png", "(d) Closed-form inverse")
    show(ax[4], f"{IMG}/reconstructed_iter3.png", "(e) Iteration 3")
    fig.tight_layout(); fig.savefig(f"{FIG}/fig_visual_comparison.png"); plt.close(fig)
    fig, ax = plt.subplots(1, 2, figsize=(6, 3.2))
    show(ax[0], f"{IMG}/share1_color.png", "Share 1"); show(ax[1], f"{IMG}/share2_color.png", "Share 2")
    fig.tight_layout(); fig.savefig(f"{FIG}/fig_shares.png"); plt.close(fig)
    fig, ax = plt.subplots(2, 3, figsize=(7.5, 5.2))
    for j, c in enumerate("CMY"):
        show(ax[0, j], f"{IMG}/halftone_baseline_{c}.png", f"{c} halftone, γ=1")
        show(ax[1, j], f"{IMG}/halftone_iter3_{c}.png", f"{c} halftone, Iteration 3")
    for a in ax.ravel(): a.images[0].set_cmap("gray")
    fig.tight_layout(); fig.savefig(f"{FIG}/fig_halftones.png"); plt.close(fig)
    fig, ax = plt.subplots(1, 2, figsize=(6, 3.2))
    show(ax[0], f"{IMG}/r1_reuse_leak.png", "S2(Baboon) ⊕ S2(Astronaut), reused R1")
    show(ax[1], f"{IMG}/r1_fresh_noleak.png", "Same, fresh R1")
    fig.tight_layout(); fig.savefig(f"{FIG}/fig_r1_reuse.png"); plt.close(fig)
    say("\n== Final build (Baboon, seed-1 designs)")
    say(pd.read_csv(f"{RES}/exp5_overall.csv").to_string(index=False))
    say(pd.read_csv(f"{RES}/exp5_metrics.csv").to_string(index=False))
    say("\n== Security (displayed Iteration-2 shares)")
    say(pd.read_csv(f"{RES}/exp5_security.csv").to_string(index=False))
    say(pd.read_csv(f"{RES}/exp5_r1_reuse.csv").to_string(index=False))
    say(pd.read_csv(f"{RES}/exp5_cheating.csv").to_string(index=False))
if os.path.exists(f"{RES}/exp6_weights.csv"):
    say("\n== Weight sensitivity (common gamma grid)")
    say(pd.read_csv(f"{RES}/exp6_weights.csv").to_string(index=False))
    comp = pd.read_csv(f"{RES}/exp6_components.csv")
    fig, ax = plt.subplots(figsize=(4.6, 3.0))
    ax.plot(comp.gamma, comp.psnr_norm, label="PSNR/40"); ax.plot(comp.gamma, comp.ssim, label="SSIM")
    ax.plot(comp.gamma, comp.contrast_norm, label="contrast/0.5"); ax.axvline(1, color="k", ls=":", lw=1)
    ax.set(xlabel=r"Common tone exponent $\gamma$", ylabel="Objective component"); ax.legend(frameon=False, fontsize=7)
    fig.tight_layout(); fig.savefig(f"{FIG}/fig_components.png"); plt.close(fig)
open(f"{RES}/stats_summary.txt", "w").write("\n".join(out) + "\n")
