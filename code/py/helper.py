import pandas as pd

from script_utils import show_output

def load_file_and_store(file, output_excel=""):
    '''
    testing that all paths are working
    '''

    show_output(f"Loading file {file}", color="normal")
    df = pd.read_excel(file, sheet_name="Data")
    for i, col in enumerate(df.columns):
        show_output(f"Detected column{i}: {col}", color="time")
    show_output(f"Detected{len(df.index)} data entries", color="warning")
    if output_excel:
        df.to_csv(output_excel, sep=",", index=False)
        show_output(f"Converted  to csv and saved as csv to {output_excel}", color="success")
    return df