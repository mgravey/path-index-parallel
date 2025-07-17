# path-index-parallel

This repository contains code to compute and analyze the **theoretical performance limits** of path-level parallelization in **sequential geostatistical simulation**.

It does **not** implement the parallel simulation algorithm itself — instead, it evaluates how much parallelism is achievable under ideal conditions using a precomputed **Path Index grid**. The goal is to quantify waiting times, dependency delays, and potential speedups using simplified models and simulated scheduling.

This analysis supports the findings in the publication:

> *Quasi-Optimal Path-Level Parallelization for Sequential Geostatistical Simulation*  
> [DOI / Link TBD]
