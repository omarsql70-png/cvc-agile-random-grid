"""Figure 1: four-sprint framework with the independent evaluation gate."""
import os, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "results", "figures", "fig_framework.png")
fig, ax = plt.subplots(figsize=(10, 5.4)); ax.set_xlim(0, 100); ax.set_ylim(0, 62); ax.axis("off")
edge, face, red, green, gold = "#1f3864", "#dce6f2", "#c00000", "#1b7a4b", "#7f6000"
def box(x, y, w, h, title, body, fc=face, ec=edge, tc=edge):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.5,rounding_size=1.5", fc=fc, ec=ec, lw=1.8))
    ax.text(x + w/2, y + h - 2.2, title, ha="center", va="top", fontsize=10, weight="bold", color=tc)
    if body: ax.text(x + w/2, y + h - 6.6, body, ha="center", va="top", fontsize=8.0, color=tc, linespacing=1.35)
def arrow(p, q, color=red, ls="-", rad=0.0):
    ax.add_patch(FancyArrowPatch(p, q, arrowstyle="-|>", mutation_scale=16, color=color, lw=2.0, ls=ls, connectionstyle=f"arc3,rad={rad}"))
box(2, 38, 29, 21, "Sprint 1 — Requirements", "(2,2) access structure, colour\nsecrets, zero pixel expansion;\nfresh share grid per secret;\nacceptance rule:\ngain ≥ 1% and p < 0.05")
box(36, 38, 29, 21, "Sprint 2 — Prototype", "CMY separation, tone curve,\nerror-diffusion halftone,\nrandom-grid shares,\nOR stacking;\nexposes one design variable")
box(70, 38, 28, 21, "Sprint 4 — Refinement", "BGWO searches the design\nvariable on K = 4 fixed\nsearch grids (common\nrandom numbers)")
box(70, 3, 28, 24, "Sprint 3 — Evaluation", "re-score the returned design\non 30 unseen share grids:\nPSNR, SSIM, contrast, ΔE00;\nshare-level security tests;\ndiagnose failures")
box(38, 8, 25, 13, "Gate", "does the iteration meet\nthe acceptance rule?", fc="#fff2cc", ec=gold, tc=gold)
box(2, 6, 29, 17, "Accepted design", "final shares built with a\nfresh grid; parameters\nrecorded with the evidence", fc="#e2f0d9", ec=green, tc=green)
arrow((31.6, 48.5), (35.4, 48.5)); arrow((65.6, 48.5), (69.4, 48.5))
arrow((84, 37.4), (84, 27.6))
arrow((69.4, 14.5), (63.6, 14.5))
arrow((37.4, 14.5), (31.6, 14.5), color=green)
ax.text(34.5, 16.5, "yes", color=green, fontsize=9, ha="center", weight="bold")
arrow((50.5, 21.6), (50.5, 37.4), color=red, ls="--")
ax.text(52, 31.5, "no: redesign the Sprint-2 variable\nfrom the Sprint-3 diagnosis\n(Iteration 1 → Iteration 2)", color=red, fontsize=8.2, style="italic", va="center")
fig.savefig(OUT, dpi=250, bbox_inches="tight"); print(OUT)
