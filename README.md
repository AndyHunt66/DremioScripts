# DremioScripts
A collection of Dremio Scripts to ease admin

## To Download 
To download just the scripts, grab DremioScripts.zip or the individual required script from `/target`

## To run in the context of the project, 
clone the project and run from the `/scripts` directory



The scripts in `/target` are the same as the ones from `/source` but with the imported `source` scripts inlined so they can be run without any context. 
### utils/login.sh
As the vast majority of the scripts need to log in first, `utils/login.sh` is just a helper script to get the Dremio Auth Token as an environment variable for subsequent scripts to use.
Call it before accessing other API calls that need authentication