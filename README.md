# cDSP-based-Bayesian-Optimization-for-ICME-MATLAB-Implementation
cDSP-based Bayesian Optimization for ICME — MATLAB Implementation
Author: H M Dilshad Alam Digonta, Ph.D. Candidate, Systems Realization Laboratory at Florida Institute of Technology

This repository contains the MATLAB implementation of a Bayesian Optimization (BO) integrated with the compromise Decision Support Problem (cDSP) construcy for robust, uncertainty-aware design in Integrated Computational Materials Engineering (ICME).

The proposed framework integrates the compromise Decision Support Problem (cDSP) construct with Bayesian Optimization (BO) for design decision support in ICME. Using the framework, we carry out data-driven inverse robust design exploration of ICME design problems under uncertainty. Within this framework, Gaussian Process (GP) surrogate models are utilized to establish Processing–microStructure–Property–Performance (PSPP) linkages and to quantify predictive uncertainty. While BO is used to adaptively guide data acquisition to mitigate model uncertainty in an information-efficient manner, robust design constructs are used within the cDSP formulation to manage parametric, interpolation, and experimental uncertainties by identifying robust satisficing solutions that are relatively insensitive to variability.

This MATLAB implementation is intended to support reproducibility, further development, and extension of the framework for ICME, multidisciplinary design, robust design, and decision-based design applications.

This MATLAB repository includes two main examples:

1. an analytical test problem based on a nonlinear eighth-order polynomial function, and  
2. an industry-inspired hot rod rolling case study.

---

## Associated Paper

This repository accompanies the work:

> H M Dilshad Alam Digonta, Maryam Ghasemzadeh, Anton van Beek, and Anand Balu Nellippallil**  
> Design for ICME — A Data-Driven Decision Support Framework for Quantifying and Managing Uncertainty**

If you use this code, please cite the associated paper and this repository.

---

## Repository Structure

The repository is organized as follows:

```text
cDSP-BO-ICME-MATLAB/
│
├── README.md
│
├── analytical-test-problem/
│   ├── 8th-order-polynomial-test-problem.md
│   ├── BOwithcDSPtestproblem.m
│   ├── d_min.p
│   ├── EMI_Min.p
│   ├── CorrMat.p
│   ├── N2LogL.p
│   ├── FitGPModel.p
│   └── PredictGPModel.p
│
└── industry-test-problem/

```

---

## Folder Descriptions

| Folder | Description |
|---|---|
| `analytical-test-problem/` | Contains the MATLAB implementation of the eighth-order polynomial benchmark problem used to evaluate the behavior of the proposed cDSP-based BO framework |
| `industry-test-problem/` | Contains the MATLAB implementation of the industry-inspired hot rod rolling case study used to demonstrate the framework in an ICME design context |

---

## Analytical Test Problem

The analytical test problem uses an eighth-order polynomial function as the system response function. 

The purpose of this example is to demonstrate how the proposed cDSP-based BO framework identifies robust satisficing regions rather than converging only to a single-point optimum.

This folder includes:

```text
analytical-test-problem/
│
├── 8th-order-polynomial-test-problem.md
├── BOwithcDSPtestproblem.m
├── d_min.p
├── EMI_Min.p
├── CorrMat.p
├── N2LogL.p
├── FitGPModel.p
└── PredictGPModel.p
```

The file `8th-order-polynomial-test-problem.md` provides the detailed problem description, code explanation, required files, and instructions for running the analytical benchmark.

---

## Industry Test Problem

The industry-inspired hot rod rolling case study demonstrates the application of the proposed cDSP-based BO framework to an ICME-related engineering design problem.

This example demonstrates how the framework can support robust, uncertainty-aware design exploration in a multidisciplinary setting involving process-structure-property-performance relationships.


---

## Methodology Overview

The proposed framework integrates four main constructs: robust design metrics, the compromise Decision Support Problem, Gaussian Process surrogate modeling, and Bayesian Optimization.

### 1. Robust Design Metrics: DCI and EMI

Robust design metrics are used to evaluate system performance under uncertainty. Robust design metrics are used to evaluate system performance in the presence of uncertainty.

For a maximization-type response, where a larger value is preferred, EMI is defined as:

$$
EMI(x) = \frac{\mu(x)-LRL}{\sigma(x)}
$$

where:

| Term | Description |
|---|---|
| $x$ | Design or process variable |
| $\mu(x)$ | Predicted mean response |
| $\sigma(x)$ | Predicted standard deviation |
| $LRL$ | Lower Requirement Limit |

A design is considered robust when:

$$
EMI(x) \geq 1
$$

### 2. Compromise Decision Support Problem

The compromise Decision Support Problem (cDSP) construct is used for balancing design tradeoffs among multiple objectives. It allows multiple and potentially conflicting goals to be considered together through deviation functions. The objective of the design problem is to minimize the deviation function.

For a maximization-type goal, the deviation is calculated as:
$$
\frac{y(x)}{y_{\text{target}}} + d_m(x) = 1
$$

where:

| Term | Description |
|---|---|
| $y(x)$ | System response |
| $y_{\text{target}}$ | Desired target value |
| $d_m(x)$ | Deviation from the $m$-th target |

For a single discipline, the deviation function is calculated as:

$$
Z(x) = \sum_m w_m \left| d_m(x) \right|
$$

where $w_m$ is the weight assigned to the $m$-th goal.

---

### 3. Gaussian Process Surrogate Modeling

Gaussian Process (GP) models are used to approximate system or discipline-level responses from available data. The GP model provides both a predicted mean response and an associated uncertainty estimate.

A zero-mean GP with a squared-exponential kernel

$$
k(x_i,x_j) = \exp\left(-10^{\omega_0}\left\|x_i-x_j\right\|^2\right)
$$


parameterised by `omega = [log10 roughness, log10 nugget]`.


### 4. Bayesian Optimization with cDSP-Based Acquisition

Bayesian Optimization is used to adaptively select new sample points and improve the surrogate model. In the proposed framework, the acquisition function is modified to operate on the cDSP-based deviation measure rather than only on the raw objective value.

The next sample for the BO iteration is selected by maximizing the deviation-based Expected Improvement:

$$
x_{\text{next}} = \arg\max_x EI_d(x)
$$

where $EI_d(x)$ represents the Expected Improvement calculated using the cDSP-based deviation measure.

This integration enables the BO process to search for robust satisficing regions while still using the GP model's predictive uncertainty to guide adaptive sampling.

---

## External Dependencies

This repository uses MATLAB and may require additional toolboxes depending on the example.

Recommended software:

```text
MATLAB R2022a or later
Statistics and Machine Learning Toolbox
Optimization Toolbox
Global Optimization Toolbox
```

The test problems also use the **SURROGATES Toolbox** developed by Dr. Felipe A. C. Viana.


Make sure the SURROGATES Toolbox is added to the MATLAB path before running the analytical test problem.

---

## Gaussian Process Model Files

The analytical test problem uses the following protected MATLAB executable files for Gaussian Process modeling:

```text
CorrMat.p
N2LogL.p
FitGPModel.p
PredictGPModel.p
```

These files were developed by Bostanabad and co-authors for their work on efficient Gaussian Process modeling. Since these files are the property of the original authors, they are included as protected executable `.p` files.

Please cite the following work when using these GP model files:

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

## Citation

If you use this repository or adapt the code for your research, please cite the associated paper:

```bibtex
@article{digonta_cdsp_bo_icme,
  title   = {Design for ICME - A Data-Driven Decision Support Framework for Quantifying and Managing Uncertainty},
  author  = {Digonta, H. M. Dilshad Alam and Ghasemzadeh, Maryam and van Beek, Anton and Nellippallil, Anand Balu},
  journal = {Integrating Materials and Manufacturing Innovation},
  year    = {2026}
}
```
A `CITATION.cff` file is included so GitHub will surface a "Cite this repository" button automatically.

---

## License

This repository is released under the license specified in the `LICENSE` file.

Please note that the protected MATLAB files:

```text
CorrMat.p
N2LogL.p
FitGPModel.p
PredictGPModel.p
```

are not the original source code developed by the repository author. They are included as executable protected files for Gaussian Process modeling and should be cited according to the referenced publication.

---

## Contact

For questions, suggestions, or collaboration inquiries, please contact:

**H M Dilshad Alam Digonta**  
Systems Realization Laboratory @ Florida Institute of Technology  
Email: hdigonta2023@my.fit.edu

**Maryam Ghasemzadeh**  
University College Dublin (UCD)

---
