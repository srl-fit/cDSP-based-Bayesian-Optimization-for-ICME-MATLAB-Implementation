# Test Problem: cDSP-Based Bayesian Optimization for an Eighth-Order Polynomial Function

This document describes the MATLAB implementation of a benchmark test problem used to evaluate the proposed compromise Decision Support Problem-based Bayesian Optimization framework, referred to as **cDSP-based BO**.

The purpose of this test problem is to demonstrate how the proposed cDSP-based BO approach identifies robust satisficing regions of the design space rather than converging only to a single-point optimum.

---

## Problem Description

To test the performance of the proposed cDSP-based BO approach, an eighth-order polynomial function is considered as the system response function. The function is defined as:

$$
f(x)=\sum_{i=1}^{9} a_i (x-900)^{i-1}
$$

where:

$$
910 \leq x \leq 976
$$


The coefficients are given as follows:

| Coefficient | Value |
|---|---:|
| $$a_1$$ |$$-659.23$$ |
| $$a_2$$ | $$190.22$$ |
| $$a_3$$ | $$-17.802$$ |
| $$a_4$$ | $$0.826910$$ |
| $$a_5$$ | $$-0.021885$$ |
| $$a_6$$ | $$0.0003463$$ |
| $$a_7$$ | $$-3.2446 × 10^{-6}$$ |
| $$a_8$$ | $$1.6606 × 10^{-8}$$ |
| $$a_9$$ | $$-3.5757 × 10^{-11}$$ |

The selected eighth-order polynomial introduces a nonlinear response landscape with multiple local variations and sensitivity regions. This makes it suitable for evaluating the behavior of the proposed cDSP-based BO framework and the updated acquisition function.

The benchmark is used to illustrate how the proposed approach supports:

- identification of robust satisficing regions,
- adaptive sampling under uncertainty,
- visualization of Gaussian Process uncertainty evolution,
- visualization of acquisition function behavior,
- and comparison of the sampling transition between traditional BO and cDSP-based BO.

---

## Folder Contents

This test problem folder contains seven MATLAB-related files:

```text
test-problem-polynomial-cdsp-bo/
│
├── 8th-order-polynomial-test-problem.md
│
├── BOwithcDSPtestproblem.m
├── d_min.p
├── EMI_Min.p
├── CorrMat.p
├── N2LogL.p
├── FitGPModel.p
└── PredictGPModel.p
```

---

## File Descriptions

| File | Description |
|---|---|
| `BOwithcDSPtestproblem.m` | Main MATLAB script used to execute the cDSP-based BO test problem |
| `d_min.p` | Function used to calculate the deviation from the target EMI value |
| `EMI_Min.p` | Function used to calculate the Error Margin Index |
| `CorrMat.p` | Protected MATLAB executable file used for Gaussian Process model construction |
| `N2LogL.p` | Protected MATLAB executable file used for Gaussian Process  model construction  |
| `FitGPModel.p` | Protected MATLAB executable file used to fit the Gaussian Process model |
| `PredictGPModel.p` | Protected MATLAB executable file used to predict the Gaussian Process mean and variance |

---

## Gaussian Process Model Files

The following four protected MATLAB executable files are used to build and evaluate the Gaussian Process surrogate model:

```text
CorrMat.p
N2LogL.p
FitGPModel.p
PredictGPModel.p
```

These files were developed by Bostanabad and co-authors for their work on efficient Gaussian Process modeling. Since these codes are the property of the original authors, they are included here as protected executable `.p` files.

Please cite the following work when using these files:

```bibtex
@article{bostanabad2018nugget,
  author  = {Bostanabad, Ramin and Kearney, Tucker and Tao, Siyu and Apley, Daniel W. and Chen, Wei},
  title   = {Leveraging the nugget parameter for efficient Gaussian process modeling},
  journal = {International Journal for Numerical Methods in Engineering},
  volume  = {114},
  number  = {5},
  pages   = {501--516},
  year    = {2018},
  doi     = {10.1002/nme.5751},
  url     = {https://onlinelibrary.wiley.com/doi/abs/10.1002/nme.5751}
}
```

---

## External Toolbox Requirement

This test problem uses the **SURROGATES Toolbox** developed by Dr. Felipe A. C. Viana.

The following SURROGATES Toolbox functions are used:

```matlab
srgtsDOEOLHS
srgtsScaleVariable
```

These functions are used to generate and scale the design of experiment samples for:

1. The initial Gaussian Process training data, and  
2. The candidate sample pool used during the Bayesian Optimization iterations.

Before running the code, make sure the SURROGATES Toolbox is added to the MATLAB path.

---

## Main Code Description

The main script is:

```text
BOwithcDSPtestproblem.m
```

This script executes the complete cDSP-based BO workflow for the polynomial test problem.

The workflow includes:

1. defining the random seed, requirement limit, and target EMI,
2. generating the initial training samples,
3. evaluating the polynomial response function,
4. generating the candidate sample pool,
5. fitting the Gaussian Process surrogate model,
6. calculating EMI and deviation values,
7. computing the cDSP-based Expected Improvement values,
8. selecting the next candidate sample,
9. updating the training data,
10. and visualizing the BO progression.

---

## Define Random Seed, Requirement Limit, and Target EMI

The following section defines the random seed, the upper requirement limit, and the target EMI value:

```matlab
rng(1)

URL = 27;
emi_target_Y = 3;
```

Here, `rng(1)` is used to ensure reproducibility. The variable `URL` defines the upper requirement limit, and `emi_target_Y` defines the target Error Margin Index.

---

## Generate Initial Training Samples

The initial training samples are generated using Latin Hypercube Sampling from the SURROGATES Toolbox:

```matlab
ndv = 1;
npoints = 5;

lb = [910];  
ub = [976];

designspace = [lb; ub];

X_lhs = srgtsDOEOLHS(npoints, ndv, 'GA');
X_train = srgtsScaleVariable(X_lhs, [zeros(1, ndv); ones(1, ndv)], designspace);
```

This section defines a one-dimensional design problem with the design variable bounded between `910` and `976`. Five initial training samples are generated and scaled to the physical design space.

---

## Define and Evaluate the Polynomial Response Function

The polynomial coefficients and response function are defined as:

```matlab
a = [-659.23, 190.22, -17.802, 0.826910, ...
     -0.021885, 0.0003463, -3.2446e-6, ...
      1.6606e-8, -3.5757e-11];

f = @(x) ((x - 900).^(0:8)) * a.';

Y_train = f(X_train);
```

---

## Generate Candidate Sample Pool

The candidate sample pool for the BO iteration is generated using the SURROGATES Toolbox:

```matlab
n_eval = 60;

lhs_eval = srgtsDOEOLHS(n_eval, 1, 'GA');

lb_eval = [920];
ub_eval = [966];

designspace_eval = [lb_eval; ub_eval];

X_test = srgtsScaleVariable(lhs_eval, [zeros(1, 1); ones(1, 1)], designspace_eval);
```

Here, 60 candidate points are generated within the interval `[920, 966]`. These candidate points are used by the BO loop to select the next sample based on the cDSP-based Expected Improvement criterion.

---

## Run the cDSP-Based BO Iteration Loop

The Bayesian Optimization loop is executed for a maximum of 15 iterations:

```matlab
max_iters = 15;

iteration = 1;

EI_progress = zeros(max_iters, 1);
best_d_history = [];
emi_best_d_history = [];
y_best_d_history = [];
```

At each iteration, the Gaussian Process model is fitted using the current training data:

```matlab
Model_test = FitGPModel(X_train, Y_train);
```

The trained GP model is then used to evaluate the current samples and candidate points under uncertainty. The functions `EMI_Min.p` and `d_min.p` are used to calculate the Error Margin Index and the corresponding deviation from the target EMI value.

The cDSP-based Expected Improvement criterion is then evaluated for each candidate point. The candidate with the maximum EI value is selected as the next sample:

```matlab
[max_EI, idx_max] = max(EI_vals);

x_new = X_test(idx_max);
```

The selected point is added to the training dataset, and the candidate pool is updated:

```matlab
X_train = [X_train; x_new];
Y_train = [Y_train; f(x_new)];

X_test(idx_max) = [];

EI_progress(iteration) = max_EI;
```

This iterative process allows the framework to progressively update the GP model and guide sampling toward regions that better satisfy the cDSP-based robustness criterion.

## Visualization

The code generates figures to visualize the BO progression.

The first figure shows the true polynomial function and the selected training points:

```matlab
figure(1);
clf;

xx = linspace(lb, ub, 200)';

plot(xx, f(xx), 'Color', [1 0.5 0], 'LineWidth', 2);
hold on;

scatter(X_train, Y_train, 50, [0.3 0.3 0.3], 'filled');

xlabel('X');
ylabel('Y');

title('Adding candidate points on true function in cDSP-based BO');

legend('True function', 'Additional training points');
```


The second figure shows the full Expected Improvement progression:

```matlab
figure(2);
clf;

plot(1:iteration, EI_progress(1:iteration), 'k-o', 'LineWidth', 1.5);

xlabel('Iteration');
ylabel('Max EI');

title('Progression of Expected Improvement');

grid on;
```

---

## How to Run

To run this test problem:

1. Open MATLAB.
2. Set the current folder to this test problem directory.
3. Add the folder and required toolbox paths:

```matlab
addpath(genpath(pwd));
```

4. Make sure the SURROGATES Toolbox is added to the MATLAB path.
5. Run:

```matlab
BOwithcDSPtestproblem
```

---

## Expected Outputs

Running the main script generates:

- selected BO sample points,
- updated training data,
- EMI values,
- deviation values,
- Expected Improvement values,
- final BO progression plots.

The main generated figures are:

| Figure | Description |
|---|---|
| Figure 1 | True polynomial function with selected training points |
| Figure 2 | Expected Improvement progression |


---

## Reproducibility

The code uses:

```matlab
rng(1)
```

to ensure reproducibility of the initial training samples, candidate sample pool, and BO sampling progression.

Changing the random seed may produce different sampling trajectories.

---

## Summary

This test problem demonstrates the application of the proposed cDSP-based BO framework to a nonlinear polynomial benchmark function. The example shows how Gaussian Process modeling, EMI-based robustness evaluation, cDSP-based deviation calculation, and Expected Improvement-based adaptive sampling can be combined to guide the search toward robust satisficing regions under uncertainty.
