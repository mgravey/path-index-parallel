# path-index-parallel

This repository provides a **theoretical analysis** of the potential speedup achievable through **path-level parallelization** of **sequential geostatistical simulation** methods (SGS, SIS, MPS). It focuses on quantifying performance limits using simplified models and controlled dependency tracking — **not** on implementing the parallel simulation itself.

The analysis is based on the use of a **Path Index grid**, a known technique for enabling asynchronous, lock-free parallelism during simulation. This code evaluates how much concurrency can be exploited in ideal conditions and visualizes the impact of simulation parameters on achievable speedup.

---

## 🔍 Purpose

This project supports the findings from:

> **Quasi-Optimal Path-Level Parallelization for Sequential Geostatistical Simulation**    
> *[DOI/link TBD]*

---

## 🧠 What This Code Does

- Computes **dependency maps** from random simulation paths and neighborhood templates.
- Simulates idealized **threaded execution** using spin-wait logic (no actual simulation).
- Compares speedup with **random** and **optimal** simulation paths.
- Generates plots for:
  - Speedup ratios across different simulation sizes, kernel sizes, and number of neighbors.
  - Maximum theoretical speedup and corresponding optimal number of threads.

---

## 📂 File Overview

| File | Purpose |
|------|---------|
| `RunSpeedupMeasure.m` | Runs the full sweep across parameter combinations and stores results in a 4D tensor. |
| `speedup.m` | Core function to compute theoretical speedup for a single configuration. |
| `getDependancy.m` | Computes the dependency rank for each pixel in the simulation path. |
| `Simulation.m` | Single-run script to compare random vs optimal path impact for a given setup. |
| `displaySpeedup.m` | Visualization of speedup results (`.mat` output from `RunSpeedupMeasure.m`). |
| `getProxyDependancy.m` | Simpler alternative dependency estimator (not used in final evaluation). |

---

## 🧪 Dependencies

- MATLAB R2021a or later (recommended)
- Image Processing Toolbox (`bwdist`, `padarray`)
- `export_fig` (optional, for figure export)

---

## 🧭 How to Use

1. **Run simulations across parameter grid:**

```matlab
RunSpeedupMeasure
````

This generates `speedup_data_grid.mat`, containing all computed speedup ratios.

2. **Visualize results:**

```matlab
displaySpeedup
```

This produces figures similar to those in the paper, showing:

* Speedup slices for fixed thread count.
* Max achievable speedup and corresponding optimal number of threads.

3. **Test individual configurations:**

Use `Simulation.m` to test the impact of optimized path vs random ordering on a single run.

---

## 📊 Output

* `speedup_data_grid.mat`: Contains 4D array `speedupData(simSize, ks, n, threads)`
* `speedup_slices_fixed_thread.png`: Speedup vs parameters at fixed thread count.
* `max_speedup_optimal_threads.png`: Heatmaps of max speedup and best thread count.

---

## 📌 Notes

* This is **not** a simulation engine. No spatial values are simulated — only dependency resolution is modeled.
* The "waiting" cost per thread is used as a proxy for spin-wait behavior in parallel execution.
* The model assumes uniform per-node cost and no memory or scheduling overhead.

---

## 📜 License

This repository is released under the MIT License.

---

## 📣 Citation

If you use this code or analysis, please cite the associated paper (once published):

> *Quasi-Optimal Path-Level Parallelization for Sequential Geostatistical Simulation*
> *\[DOI TBD]*
