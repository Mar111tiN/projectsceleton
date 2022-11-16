import os
import sys
from datetime import datetime as dt
from yaml import CLoader as Loader, load


ansii_colors = {
    "magenta": "[1;35;2m",
    "green": "[1;9;2m",
    "red": "[1;31;1m",
    "cyan": "[1;36;1m",
    "gray": "[1;30;1m",
    "black": "[0m",
}

colors = {
    "process": ansii_colors["green"],
    "time": ansii_colors["magenta"],
    "normal": ansii_colors["gray"],
    "warning": ansii_colors["red"],
    "success": ansii_colors["cyan"],
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


def load_config_file(config_file):
    '''
    loads a yaml_config
    '''

    with open(config_file, "r") as stream:
        return load(stream, Loader=Loader)


def load_config(config_file="", *, config_path="", **kwargs):
    '''
    passes configs to inner functions
    directly passed arguments overwrite config
    '''

    # build the config_file path from config_file and config_path arguments
    if config_path and not config_file.startswith("/"):
        config_file = os.path.join(config_path, config_file)
    if not os.path.splitext(config_file)[-1] in [".yml", "yaml"]:
        config_file = config_file + ".yml"
    # savely load the config file into config dict
    try:
        config = load_config_file(config_file)
    except:
        show_output(f"config file {config_file} could not be loaded", color="warning")
        return {}

    # build base_path relative to HOME path
    path_config = config['paths']
    if not path_config['base_path'].startswith("/"):
        path_config['base_path'] = os.path.join(os.environ['HOME'], path_config['base_path'])
    
    # build other paths relative to base_path
    for path in ['data', 'output', 'info', 'img', 'tables']:
        key = f"{path}_path"
        if key in path_config:
            if not path_config[key].startswith("/"):
                path_config[key] = os.path.join(path_config['base_path'], path_config[key])

    # load in the kwargs to overwrite config
    config.update(kwargs)
    show_output(f"config file {config_file} successfully loaded", color="success")
    # build the output paths
    pc = config['paths']
    for folder in ['output_path', 'img_path', 'tables_path']:
        if folder in pc:
            if not os.path.isdir(pc[folder]):
                show_output(f"Creating folder {pc[folder].replace(pc['base_path'], '')} in base folder")
                os.makedirs(pc[folder])

    if (code_base := pc['code_core']):
        sys.path.append(code_base)
        show_output(f"Added {code_base} to python path for imports")

    return config


def get_path(path, file_type="file", config={}):
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
    if not (file_path := pc[path]).startswith("/"):
        file_path = os.path.join(os.environ['HOME'], pc[path])
        
    if os.path.isfile(file_path):
        return file_path
    else:
        show_output(f"{file_type} {file_path} cannot be found!", color="warning")
        return