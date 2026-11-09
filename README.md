# Mini-ALI and Optopatch Electrophysiology Analysis

MATLAB-based analysis workflows for high-throughput, wide-field, all-optical electrophysiology recordings of human iPSC-derived neurons.

The workflow consists of three connected modules:

1. **Mini-ALI** — activity-guided localization of neurons and extraction of fluorescence traces from voltage-imaging movies.
2. **Single-Trace Analysis** — signal preprocessing, spike detection, quality control, and extraction of action-potential and firing features.
3. **Population Analysis** — aggregation, visualization, and comparison of electrophysiological phenotypes across cells, recordings, and perturbations.

The software was developed for recordings acquired with an Optopatch system combining the genetically encoded voltage indicator **Voltron2** and the optogenetic actuator **CheRiff**, including experiments in human iPSC-derived NGN2 excitatory neurons and CRISPRi-mediated gene perturbations.

## Overview

The platform supports wide-field neuronal voltage imaging and optical stimulation, enabling simultaneous measurement of large neuronal populations. A representative acquisition configuration is **800 frames/s** at **1400 × 1400 pixels**; actual acquisition parameters vary by experiment.

```text
Raw voltage-imaging movies + acquisition metadata
                       |
                       v
                  [Mini-ALI]
       motion correction / activity localization
             ROI identification / traces
                       |
                       v
             [Single-Trace Analysis]
      baseline correction / signal normalization
        quality control / spike identification
        firing and waveform feature extraction
                       |
                       v
               [Population Analysis]
        combine cells / conditions / batches
     distributions / trajectories / comparisons
                       |
                       v
         Summary tables and statistics
```

## 1. Mini-ALI: Activity Localization and Trace Extraction

**Purpose:** Identify optically active neurons from time-series fluorescence movies and extract their corresponding fluorescence traces.

### Inputs

- Raw fluorescence voltage-imaging movies (for example, camera `.bin` files, with their required frame dimensions and data-type metadata).
- Acquisition parameters: frame rate, frame count, image dimensions, and pixel encoding.
- Optical stimulation timing or traces, when used for downstream analysis.
- Optional reference images and previously computed ROI/footprint information.

### Main steps

1. Load a movie and validate its dimensions and acquisition metadata.
2. Correct rigid sample motion where necessary.
3. Identify spatially localized activity and generate candidate neuronal footprints or ROIs.
4. Extract a fluorescence time series for each accepted ROI.
5. Save extracted traces, ROI footprints, spatial coordinates, and metadata for downstream processing.

**Expected output:** Per-cell traces linked to their spatial footprint and original movie/FOV. Verify alignment of footprints with representative images before proceeding.

## 2. Single-Trace Analysis: Electrophysiological Feature Extraction

**Purpose:** Convert individual optical voltage traces into quality-controlled measurements of excitability and action-potential shape.

### Main steps

1. **Baseline correction:** Correct slow fluorescence changes, including photobleaching or baseline drift (the current workflow includes a two-component exponential correction).
2. **Normalization:** Convert corrected fluorescence to a normalized signal, preserving the established Optopatch voltage-polarity convention.
3. **Quality control:** Evaluate signal quality using spike-related and stimulation-step-related SNR metrics, together with other recording checks.
4. **Spike detection:** Identify candidate action potentials and reject events that fail detection or quality criteria.
5. **Spike-triggered averaging (STA):** Estimate representative spike waveforms using valid events.
6. **Feature extraction:** Quantify firing behavior and action-potential kinetics.
7. **Export:** Save cell-level features and, when enabled, spike-level events, waveforms, and processed traces.

### Example features

| Category | Measurements |
|---|---|
| Excitability | Spike count, firing rate, stimulus-response relationship, optical rheobase where applicable |
| Spike amplitude | Action-potential height / normalized optical spike amplitude |
| Spike duration | Width at 20%, 50%, and 80% of spike height |
| Spike kinetics | Rise and decay characteristics; maximum upstroke and downstroke slopes |
| Repolarization | Afterhyperpolarization (AHP), waveform area under the curve |
| Adaptation | Changes in spike amplitude, width, and firing across a stimulus or spike train |
| Quality control | Spike SNR, step SNR, valid-spike counts, inclusion flags |

Features may be calculated from multiple defined spike subsets, such as the first spike during a selected step, the first spike in a ramp, or spikes near the end of a ramp. The precise subset definitions should be taken from the analysis configuration.

### Example outputs

Depending on the code version and export settings:

- `processed_signals.h5` — processed voltage traces.
- `cells_analysis.parquet` — cell-level metadata and analysis results.
- `features.parquet` — electrophysiological features.
- `spike_events.parquet` — spike-level event information, if exported by the selected version.
- `spike_waveforms.h5` — extracted waveforms, if exported.
- MATLAB `.mat` files — supporting analysis data, parameters, and metadata.

**Important:** The actual output schema and file names depend on the checked-out pipeline version. In particular, do not assume that all optional files are present in every analysis run.

## 3. Population Analysis: Cross-Cell and Cross-Condition Comparisons

**Purpose:** Combine per-cell analysis results to quantify electrophysiological phenotypes across experimental groups.

### Inputs

- Cell-level analysis and feature tables.
- Condition or perturbation labels (for example, non-targeting control and CRISPRi gene targets).
- Recording, plate, well, FOV, and batch identifiers as available.
- Optional spike-level data for waveform and adaptation analyses.

### Main steps

1. Load and harmonize feature tables from all selected recordings.
2. Associate each cell with its recording identifiers and perturbation or experimental condition.
3. Apply pre-specified cell quality-control and inclusion rules.
4. Aggregate measurements at the cell, FOV, well, plate, or biological-replicate level as appropriate.
5. Plot distributions, stimulus-response curves, spike waveforms, and adaptation trends.
6. Compare experimental conditions with controls using statistical methods suited to the experimental design.
7. Export summary tables, figures, and analysis settings.

### Example applications

- Compare neuronal excitability between non-targeting controls and ion-channel CRISPRi conditions, including **KCNQ2, KCNT2, SCN2A, SCN8A, and SCN9A**.
- Assess how perturbations modify firing frequency, spike amplitude, width, afterhyperpolarization, or adaptation.
- Compare electrophysiological properties across differentiation time points or experimental batches.

**Statistical note:** Cells from the same well, plate, or differentiation batch are not necessarily independent biological replicates. Report the number of cells **and** the number of independent biological replicates, and choose statistical tests or hierarchical models accordingly.

## Installation and Requirements

- **MATLAB:** Use a release compatible with the functions and toolboxes required by your checked-out code.
- **Storage and RAM:** Large raw movies may require substantial disk bandwidth and memory. Consider chunked reading, local scratch storage, and per-FOV or per-well processing for large datasets.
- **File readers:** Confirm support for your camera's binary format and for the Parquet/HDF5 outputs in the installed MATLAB release.
- **Optional tools:** Additional MATLAB toolboxes or custom functions may be required by specific scripts.

> **Setup before first run:** Add the repository's required code folders to the MATLAB path, inspect the main analysis scripts for dependencies, and update their input/output paths. The exact script names and launch commands should be documented after verification against the repository.

