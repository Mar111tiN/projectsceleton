import os
import sys
import pandas as pd
import numpy as np
from datetime import datetime as dt
from yaml import CLoader as Loader, load
from subprocess import PIPE, run
from io import StringIO


ansii_colors = {
    "magenta": "[1;35;2m",
    "green": "[1;9;2m",
    "red": "[5;31;5m",
    "cyan": "[1;36;1m",
    "gray": "[1;30;1m",
    "black": "[0m",
    "blue": "[34;1m",
    "orange": "[38;5;202m",
    "orange2": "[48;2;255;165;0m",
    "green2": "[32m;1m"
}

colors = {
    "info": ansii_colors["blue"],
    "process": ansii_colors["green"],
    "time": ansii_colors["magenta"],
    "normal": ansii_colors["gray"],
    "warning": ansii_colors["orange2"],
    "error": ansii_colors["red"],
    "success": ansii_colors["cyan"]
}



def show_output(text, color="normal", multi=False, time=False, **kwargs):
    """
    get colored output to the terminal
    """
    time = (
        f"\033{colors['time']}{dt.now().strftime('%H:%M:%S')}\033[0m : " if time else ""
    )
    proc = f"\033{colors['process']}Process {os.getpid()}\033[0m : " if multi else ""
    text = f"\033{colors[color]}{text}\033[0m"
    print(time + proc + text, **kwargs)

def show_command(command, list=False, multi=True, **kwargs):
    """
    prints the command line if debugging is active
    """

    proc = f"\033[92mProcess {os.getpid()}\033[0m : " if multi else ""
    if list:
        command = f"\033[1m$ {' '.join(command)}\033[0m"
    else:
        command = f"\033[1m$ {command}\033[0m"
    print(proc + command, **kwargs)
    return


def run_cmd(cmd, show=False, **kwargs):
    if show:
        show_command(cmd, **kwargs)
    exit = run(cmd, shell=True, check=True)
    return exit == 0


def cmd2df(cmd, show=False, **kwargs):
    """
    wrapper for running shell commands directly into a dataframe
    optional output with show argument that passes kwargs to show_command
    """

    if show:
        show_command(cmd, **kwargs)
    cmd_df = pd.read_csv(
        StringIO(run(cmd, stdout=PIPE, check=True, shell=True).stdout.decode("utf-8")),
        sep="\t",
    )
    return cmd_df


############ PATH HELPER #######################################################

def full_path(path, base_folder=os.environ['PROJECT_DIR']):
    '''
    extends any path with the base_folder if it is not a full path or starts with "."
    '''
    if path[0] in ["/", "."]:
        return path
    return os.path.join(base_folder,path)


def get_path(path, file_type="file", config={}, base_folder=os.environ['PROJECT_DIR']):
    '''
    retrieves a path value from the given key in the config and does some checks
    '''
    pc = config['paths']
    if not path in pc:
        show_output(f"Please provide a path for the {file_type} in the configs @{path}!", color="warning")
        return
    if not (file_path := pc[path]):
        show_output("Please provide a {file_type} in the configs", color="warning")
        return
    file_path = full_path(pc[path], base_folder=base_folder)
        
    if os.path.isfile(file_path):
        return file_path
    else:
        show_output(f"{file_type} {file_path} cannot be found!", color="warning")
        return


############ CONFIG LOADER #######################################################
def get_nested_path(path_dict, root="", pc={}):
    '''
    helper for recursive path building
    '''
    
    path_names = list(path_dict.keys())
    for name in path_names:
        # already done
        if name in ['base', 'static', 'root']:
            continue
        # check whether this is a path or a folder (substructure)
        if isinstance(path_dict[name], str):
            # if it is a path, set it in path config
            if path_dict[name]:
                pc[name] = full_path(path_dict[name], root)
        else:
            # a folder (substructure)
            # look ahead for root entry
            if 'root' in path_dict[name]:
                subroot = full_path(path_dict[name]['root'], base_folder=root)
            else:
                subroot = os.path.join(root, name) 
            get_nested_path(path_dict[name], root=subroot, pc=pc)
            pc[name] = subroot
            

def load_config_file(config_file, config_path="", base_path="", main_config=False):
    '''
    loads a yaml_config
    '''

    # build the config_file path from config_file and config_path arguments
    if config_path and not config_file.startswith("/"):
        config_file = full_path(os.path.join(config_path, config_file))
    # add the extension if needed
    if not os.path.splitext(config_file)[-1] in [".yml", "yaml"]:
        config_file = config_file + ".yml"
    with open(config_file, "r") as stream:
        config = load(stream, Loader=Loader)

        ######### EXTERNAL PATHS ###################
    # build base and other external paths relative to PROJECT_DIR path
    if "paths" in config:
        path_config = config['paths']
        # extend the base and static paths
        for path_key in ['base', 'static']:
            if path_key in path_config:
                path_config[path_key] = full_path(path_config[path_key], base_folder=os.environ['HOME'])
        if main_config and not 'base' in path_config:
            show_output(f"base path set to env variable $PROJECT_DIR {os.environ['PROJECT_DIR']}")
            path_config['base'] = os.environ['PROJECT_DIR']
        # overwrite the base path as config if not set
        #     it might be set for external configs
        path_config['base'] = base_path if base_path else full_path(path_config['base'])
            
        # build other paths nested relative to base path
        get_nested_path(path_config, root=path_config['base'], pc=path_config)
        config['paths'] = path_config
    return config


def setup_config(config_file="", *, config_path="", **kwargs):
    '''
    passes configs to inner functions
    directly passed arguments overwrite config
    '''

    ######## LOAD THE CONFIG ####################
    # savely load the config file into config dict
    try:
        config = load_config_file(config_file, config_path, main_config=True)
    except:
        show_output(f"config file {config_file} could not be loaded", color="warning")
        return {}

    show_output(f"config file {config_file} successfully loaded", color="success")
    # load in the kwargs to overwrite config
    config.update(kwargs)
    
    
    # build the output paths
    pc = config['paths']
    for folder in ['output', 'img', 'tables', 'html', 'reports', 'src', 'Rmd', 'datacols']:
        if folder in pc:
            if not os.path.isdir(pc[folder]):
                show_output(f"Creating folder {pc[folder].replace(pc['base'], '')} in base folder")
                os.makedirs(pc[folder])

    # add external code base
    cc = config['code']
    if (code_base_list := cc.get('py_core', "")):
        # convert code_base to list if only one string is given
        if isinstance(code_base_list, str):
            code_base_list = [code_base_list]
        for code_base in code_base_list:
            if code_base.endswith('/R'):
                continue
            code_base = full_path(code_base, os.environ['REPODIR'])
            sys.path.append(code_base)
            show_output(f"Added {code_base} to python path for imports")
        del cc['py_core']

    # add additional configs
    for config_name in config.get('configs',""):
        # no loop if there is no configs entry
        if not config_name:
            break
        # try:
        show_output(f"Loading additional config {config_name} from {config_name}")
        config2add = load_config_file(config['configs'][config_name], config_path=config['paths']['config'], base_path=config['paths']['base'])
        config.update({config_name:config2add})
        # except:
        #     show_output(f"Additional config file {os.path.basename(config_file_added)} could not be loaded", color="warning")
    config.pop("configs", None)

    # add hook to mawk/shell tools
    if (mawk_path := cc.get('shell_core', "")):
        if isinstance(mawk_path, list):
            mawk_path = mawk_path[0]
        if mawk_path.endswith('/R') or mawk_path.endswith('/py'):
                return config
        cc['shell'] = full_path(mawk_path, base_folder=os.environ['REPODIR'])
        show_output(f"Added shell path {mawk_path} to configs")
        del cc['shell_core']
    return config


############## EXCEL OUTPUT ######################################
def writeExcel(df_dict={}, excel_out="", dt_format="YYYY-MM-DD", fit_cols=True, max_colwidth=50, extra_space=2):
    '''
    convenience function to write excel file with nicer formating
    either pass a df or a dict with {sheetname:df}-format
    '''
    with pd.ExcelWriter(excel_out, datetime_format=dt_format, date_format=dt_format) as writer:
        # check data type
        if isinstance(df_dict, pd.DataFrame):
            df_dict = {"Sheet1": df_dict}

        if isinstance(df_dict, dict):
            for sheetname, df in df_dict.items():
                df.to_excel(writer, sheet_name=sheetname, index=isinstance(df.columns, pd.MultiIndex))
        else:
            show_output("df_dict (first arg) must be either dict or pd.DataFrame!", color="error")
            return None
        if fit_cols:
            for sheetname, sheet in writer.sheets.items():
                df = df_dict[sheetname]
                if isinstance(df.columns, pd.MultiIndex):
                    continue
                for idx, col in enumerate(df):  # loop through all columns
                    series = df[col]
                    max_len = min(max((
                        series.astype(str).map(len).max(),  # len of largest item
                        len(str(series.name))  # len of column name/header
                        )) + extra_space, max_colwidth)  # adding a little extra space
                    _ = sheet.set_column(idx, idx, max_len)  # set column width


########### IO ###################################################
def convert2time(df, date_cols=[], f="", **kwargs):
    '''
    convert strings in date_cols of df to time format
    '''
    for col in date_cols:
        df.loc[:, col] = pd.to_datetime(df[col], errors='coerce').dt.date
    return df


def convert2int(df, int_cols=[], int_default=-1, **kwargs):
    '''
    convert strings in cols of df to time format
    '''
    for col in int_cols:
        df.loc[:, col] = df[col].fillna(int_default).astype(float).astype(int)
    return df


def convert2str(df, str_cols=[], str_default="", **kwargs):
    '''
    convert strings in cols of df to time format
    '''
    for col in str_cols:
        df.loc[:, col] = df[col].fillna(str_default).astype(str)
    return df


def convert2categorical(df, cat_cols={}, **kwargs):
    '''
    convert the cols to categorical columns with given order
    '''
    for col in cat_cols:
        miss_cols = [c for c in df[col].unique() if not c in cat_cols[col]]
        if len(miss_cols):
            show_output(f"<convert2categorical> Found {col} value(s) {'|'.join(miss_cols)} missing in data --> please adjust factors in meta config!", color="warning")
        df[col] = pd.Categorical(df[col], cat_cols[col], ordered=True)
    return df


def convert2float(df, float_cols={}, round2=2, **kwargs):
    '''
    convert the cols to categorical columns with given order
    '''
    if float_cols == "all":
        float_cols = [col for col, _dt in df.dtypes.items() if _dt == "float64"]

    for col in float_cols:
        df[col] = np.round(df[col].astype(float), round2)
    return df


def edit_cols(df, **kwargs):
    '''
    format the columns in a dataframe
    '''

    # convert date_cols
    df = convert2time(df, **kwargs)
    df = convert2int(df, **kwargs)
    df = convert2categorical(df, **kwargs)
    df = convert2str(df, **kwargs)
    df = convert2float(df, **kwargs)
    return df