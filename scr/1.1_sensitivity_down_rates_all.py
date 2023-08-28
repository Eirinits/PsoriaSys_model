import matplotlib.pyplot as plt
from matplotlib.pyplot import figure
import pandas as pd
import numpy as np
import maboss
import time
import datetime

file = "PsoriaSys"

bnd_file = file+".bnd"
cfg_file = file+".cfg"
upp_file = file+"_200.upp"

model_Trigger = maboss.load(bnd_file,cfg_file)

def append_new_line(file_name, text_to_append):
    """Append given text as a new line at the end of file"""
    # Open the file in append & read mode ('a+')
    with open(file_name, "a+") as file_object:
        # Move read cursor to the start of file.
        file_object.seek(0)
        # If file is not empty then append '\n'
        data = file_object.read(100)
        if len(data) > 0:
            file_object.write("\n")
        # Append text at the end of file
        file_object.write(text_to_append)       
        
def convert_to_float(frac_str):
    try:
        return float(frac_str)
    except ValueError:
        num, denom = frac_str.split('/')
        try:
            leading, num = num.split(' ')
            whole = float(leading)
        except ValueError:
            whole = 0
        frac = float(num) / float(denom)
        return whole - frac if whole < 0 else whole + frac
    
down_rates = []
for key in model_Trigger.param:
    if key.startswith("$d"):
        down_rates.append(key)
        print(key, model_Trigger.param[key])
        
for par in down_rates[6:83]:
    rate_dec = convert_to_float(model_Trigger.param[par])/2
    updated_model = maboss.load(bnd_file,cfg_file)
    updated_model.param[par] = rate_dec
 #   updated_model = maboss.copy_and_update_parameters(model_Trigger, {par:rate})
    # Run UpPMaBoSS on the modified setup
    rwd = "%s_reduced_to_%s" % (par, rate_dec)
    print("Started for " + par)
    uppModel_step = maboss.UpdatePopulation(updated_model, upp_file)   
    run_par = uppModel_step.run()
    pop_ratios = run_par.get_population_ratios()
    prol_KC_state = run_par.get_nodes_stepwise_probability_distribution(['Prol_KC', 'Diff_KC', 'preDiff_KC', 'pDC', 'iDC', 'M1', 'M2', 'Neutrophil', 'Th0', 'Th1', 'Th2', 'Th17', 'Th22', 'Treg', 'Fibroblast'])
    prol_KC_state.to_csv("%s_reduced_all_cells" % (par))
    print("Finished for " + par)
    
    rate_inc = convert_to_float(model_Trigger.param[par])*1.5
    updated_model = maboss.load(bnd_file,cfg_file)
    updated_model.param[par] = rate_inc
    # Run UpPMaBoSS on the modified setup
    rwd = "%s_increased_to_%s" % (par, rate_inc)
    print("Started for " + par)
    uppModel_step = maboss.UpdatePopulation(updated_model, upp_file)   
    run_par = uppModel_step.run()
    pop_ratios = run_par.get_population_ratios()
    prol_KC_state = run_par.get_nodes_stepwise_probability_distribution(['Prol_KC', 'Diff_KC', 'preDiff_KC', 'pDC', 'iDC', 'M1', 'M2', 'Neutrophil', 'Th0', 'Th1', 'Th2', 'Th17', 'Th22', 'Treg', 'Fibroblast'])
    prol_KC_state.to_csv("%s_increased_all_cells" % (par))
    print("Finished for " + par)