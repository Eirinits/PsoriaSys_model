# PsoriaSys_model

Files and scripts to reproduce the analysis presented in XX.

For questions or issues regarding the code or the model, please contact: [Eirini Tsirvouli](eirini.tsirvouli@ntnu.no)

## Notebook & scripts description

### 1. Sensitivity Analysis

- `1.1_sensitivity_up_rates_all.py`: Increase and decrease by 50% the activation rates of all nodes.
- `1.1_sensitivity_down_rates_all.py`: Increase and decrease by 50% the inactivation rates of all nodes.

### 2. Perturbation Analysis

- `2.1_single_node_perturbation.ipynb`: Run wild-type model and perturbation of all single nodes.
- `2.2.1_identify_FVS_subsets.ipynb`: Identify and evaluate the Feedback Vertex Set (FVS) Subsets.
- `2.2.2_translate_top_fvs.R`: Translate node IDs from the output of the FVS analysis to node names.
- `2.2.3_run_FVS.ipynb`: Run the combinatorial perturbations identified in the *2.2.1_identify_FVS_subsets.ipynb* notebook.
- `2.3_calculate_prob_difference.R`: Calculate the difference (increase or decrease) of activation probability after perturbation (single & combinatorial) compared to the WT model.

### 3. Visualization & Figure Preparation

- `3.1_visualize_sensitivity_analysis.ipynb`: Visualize the results of the sensitivity analysis.
- `3.2_plot_node_trajectory.R`: Plot trajectories of selected nodes in WT or perturbed conditions.

