"""Kodak benchmark figure (exp13): per-image gains and colour differences."""
import os, numpy as np, pandas as pd, matplotlib
matplotlib.use("Agg"); import matplotlib.pyplot as plt
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "results")
k = pd.read_csv(f"{R}/exp13_kodak.csv")
q = k.pivot(index="image", columns="design", values="q"); de = k.pivot(index="image", columns="design", values="dE00")
order = (q.iter3 / q.baseline).sort_values().index; x = np.arange(len(order)); lab = [s.replace("kodim", "") for s in order]
plt.rcParams.update({"font.size": 8.5, "axes.spines.top": False, "axes.spines.right": False})
fig, ax = plt.subplots(2, 1, figsize=(7.2, 4.8), sharex=True)
ax[0].bar(x - 0.2, 100 * (q.analytic / q.baseline - 1)[order], 0.4, color="#444444", label="Closed-form inverse")
ax[0].bar(x + 0.2, 100 * (q.iter3 / q.baseline - 1)[order], 0.4, color="#7570b3", label="Iteration 3")
ax[0].set(ylabel="Gain in Q over baseline (%)"); ax[0].legend(frameon=False, ncol=2)
for d, c, m in [("baseline", "#7f7f7f", "o"), ("analytic", "#444444", "s"), ("iter3", "#7570b3", "^")]:
    ax[1].plot(x, de[d][order], m, color=c, ms=4, label={"baseline": "Baseline", "analytic": "Closed-form inverse", "iter3": "Iteration 3"}[d])
ax[1].set(ylabel="Mean CIEDE2000", xlabel="Kodak image (sorted by Iteration-3 gain)"); ax[1].set_xticks(x, lab); ax[1].legend(frameon=False, ncol=3)
fig.tight_layout(); fig.savefig(f"{R}/figures/fig_kodak.png", dpi=300, bbox_inches="tight"); print("ok")
