# Sceleton project folder as a template to start work from
### useful for 
+ quickly setting up a new project for data analysis
+ enforce an organized workflow
+ working with jupyter notebooks and R files in conjunction

### setup
* clone the repository into \<your basefolder\>, rename to <projectfolder> and move to into the folder:
   + `cd <basefolder> && git clone git@github.com:Mar111tiN/projectsceleton.git && mv sceleton <projectfolder> && cd <projectfolder>`

* create conda environment to run the notebooks:
   + `conda env create -n your-env -f code/env/py-env_Intel64.yml`
* for AppleSilicon you have to use the Intel64-build via Rosetta:
   + `CONDA_SUBDIR=osx-64 conda env create -n your-env -f code/env/py-env_M1.yml`
   + then you can fix the CONDA_SUBDIR env: `conda activate your-env && conda env config vars set CONDA_SUBDIR=osx-64`
* delete the git folder and init a new git in your code folder (to keep data and code separated!)
   + `rm -rf .git && cd code && git init``
* start the environment and run the jupyter notebook and run the test function
   + `conda activate your-env && cd code && jupyter notebook`
