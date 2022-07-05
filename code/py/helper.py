import pandas as pd

from script_utils import show_output, load_config

def load_file_and_store(file, output_excel="", verbose=True, read_lines = -1, **kwargs):
    '''
    testing that all paths are working
    '''

    if read_lines == -1:
        if verbose:
            show_output(f"Loading file {file}", color="normal")
        df = pd.read_excel(file, sheet_name="Data")
    else:
        if verbose:
            show_output(f"Reading {read_lines} lines of file {file}", color="normal")
            df = pd.read_excel(file, sheet_name="Data", nrows=read_lines)
    for i, col in enumerate(df.columns):
        show_output(f"Detected column{i}: {col}", color="time")
    if verbose:
        show_output(f"Detected{len(df.index)} data entries", color="warning")
    if output_excel:
        df.to_csv(output_excel, sep=",", index=False)
        if verbose:
            show_output(f"Converted  to csv and saved as csv to {output_excel}", color="success")
    return df


def tool(run=True, data=[], message="Good Bye", **kwargs):
    '''
    showing passing of additional configs
    '''
    if run:
        show_output("I am running!", color="success")
        show_output(message)
        for i, d in enumerate(data):
            show_output(f"row{i}: {d}")
        

def config_wrapper(*args, config_file="", **kwargs):
    '''
    passes configs to inner functions
    directly passed arguments overwrite config
    '''

    if config_file:
        config = load_config(config_file)

    helper_config = config['helper_config']

    # load in the kwargs to overwrite config
    helper_config.update(kwargs)
    load_file_and_store(*args, **helper_config)

    tool_config = config['tool_config']
    tool_config.update(kwargs)

    tool(**tool_config)

