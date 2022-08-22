import pandas as pd

from script_utils import show_output, load_config

def load_and_save(file, output="", verbose=False, read_lines = -1, **kwargs):
    '''
    testing that all paths are working
    '''

    if read_lines == -1:
        show_output(f"Loading file {file}", color="normal")
        df = pd.read_excel(file, sheet_name="Data")
    else:
        show_output(f"Reading {read_lines} lines of file {file}", color="normal")
        df = pd.read_excel(file, sheet_name="Data", nrows=read_lines)
    if verbose:
        for i, col in enumerate(df.columns):
            show_output(f"Detected column{i}: {col}", color="time")
    show_output(f"Detected {len(df.index)} data entries", color="warning")
    if output:
        df.to_csv(output, sep=",", index=False)
        show_output(f"Converted  to csv and saved as csv to {output}", color="success")
    return df


def simple_message(run=True, data=[], message="Good Bye", **kwargs):
    '''
    showing passing of additional configs
    '''
    if run:
        show_output("I am running!", color="success")
        show_output(message)
        for i, d in enumerate(data):
            show_output(f"row{i}: {d}")
    else:
        show_output("I shall not run", color="warning")
        

def config_wrapper(*args, config_file="", **kwargs):
    '''
    passes configs to inner functions
    directly passed arguments overwrite config
    '''

    if config_file:
        config = load_config(config_file)

    LaS_config = config['load_and_save']

    show_output("\n <<<Wrapper running \"load_and_save\">>>\n")
    # load in the kwargs to overwrite config
    LaS_config.update(kwargs)

    # 
    df = load_and_save(*args, **LaS_config)

    show_output("\n <<<Wrapper running \"simple_message\">>>\n")
    sm_config = config['simple_message']
    sm_config.update(kwargs)
    simple_message(**sm_config)
    return df
