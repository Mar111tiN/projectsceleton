# Sceleton project folder as a template to start work from
### useful for 
+ quickly setting up a new project for data analysis
+ enforce an organized workflow
+ working with jupyter notebooks and R files in conjunction
+ suggests the 

## contains two separate project examples in a shared folder
+ ### The python project converts a simple excel-file into a csv-file and stores it in an output folder
+ ### just run the code/nb/template.ipynb notebook from jupyter (see setup below)
+ #### it showcases:
    * setting of global paths as anchors for data stored relative to it
    * importing externally and locally stored code and configs
    * using yaml config files to store project settings to load
        + this is useful for graphical output with lots of settings for graphical output
        + the config_wrapper
            * loads these configs (updating kwargs it finds at function call)
            * runs the two "core" functions" supplying tool-specific keyword-arguments
    * possible organisation of data and code
    * most importantly, COLORED OUTPUT!!!

+ ### The R project is a simple plot that displays two data types in a combined plot
   * expression of STAT3 on T cell subpopulations upon stimulation vs qPCR-expression of CXCR3-isoforms (if you need to know)
+ ####  just run the code/R/scripting.R and follow along..
+ ####  it showcases (mostly similar to python branch..):
    * setting of global paths as anchors for data stored relative to it
    * importing externally and locally stored code, configs and constants
    * refactoring of different code into separate files
    * using yaml config files to store project settings to load
        + this is useful for graphical output with lots of settings for graphical output
        + the config_wrapper
            * loads these configs (updating kwargs it finds at function call)
            * runs the combined plot by passing 
    * possible organisation of data and code
![R project structure](https://github.com/Mar111tiN/projectsceleton/blob/master/info/R_folder_small.png?raw=true)
## setup
* clone the repository into \<your basefolder\>, rename to <projectfolder> and move to into the folder:
   + `cd <basefolder> && git clone git@github.com:Mar111tiN/projectsceleton.git`
   + ` mv projectsceleton <projectfolder> && cd <projectfolder>`
* if you want to version-control your own code, delete the git folder and init a new git in your code folder (to keep data and code separated!)

* ### setup for python
   * create conda environment to run the notebooks:
      + `conda env create -n your-py-env-f code/env/py-env_Intel64.yml`
   * for AppleSilicon you have to use the Intel64-build via Rosetta:
      + `CONDA_SUBDIR=osx-64 conda env create -n your-py-env -f code/env/py-env_M1.yml`
      + then you can fix the CONDA_SUBDIR env: `conda activate your-py-env && conda env config vars set CONDA_SUBDIR=osx-64`
   * for Windows/Linux, create an environment from scratch:
      + `conda create -n your-py-env python=3.10 pandas jupyter pyyaml`

      + `rm -rf .git && cd code && git init`
   * start the environment and run the jupyter notebook and run the template.ipynb (code/nb/template.ipynb)
      + `conda activate your-py-env && jupyter notebook`

* ### setup for R
   * works out of the box with simple tidyverse or you could...
   * create conda environment to run rstudio from:
      + `conda env create -n your-R-env -f code/env/py-env_Intel64.yml`
   * for Windows/Linux, create an environment from scratch:
      + `conda create -n your-R-env r-tidyverse rstudio`
   * start the environment and run `scripting.R` (code/R/scripting.R) from rstudio
      + `conda activate your-R-env && rstudio`
   * most explanations are in the code comments 