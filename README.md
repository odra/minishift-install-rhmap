# Readme minishift-install-rhmap

## About

The script does the following
- Prompts used for IP address for minishift
- Creates a inventory file (minishift-example) with the IP address in your home drive to be used with the Ansible installer
- Logs into Docker
- Logs onto Minishift with oc
- Adds a docker secret to all new projects
- Creates two projects `rhmap-core` and `rhmap-1-node-mbaas`
- Prompts user for branch or tag and git checkout
- Runs Ansible script for installing rhmap-core and mbaas
- Outputs the mbaas key and url


## Prerequisites
- Docker installed and logged into
- Ansible installed
- oc install (>=3.7)
- [Minishift installed](https://github.com/fheng/help/blob/master/new_hires/new_hire_chapter_2.2.md#install-minishift-locally)
- The following repos cloned to your home/work directory
  - [fh-core-openshift-templates](https://github.com/fheng/fh-core-openshift-templates)
  - [fh-openshift-templates](https://github.com/fheng/fh-openshift-templates)
  - [rhmap-ansible](https://github.com/fheng/rhmap-ansible)

## Usage
- Clone the repo `git clone https://github.com/austincunningham/minishift-install-rhmap.git`
- Change to directory `cd minishift-install-rhmap`
- Make the script runable `chmod 775 setup-rhmap.sh`
- Run the script `./setup-rhmap.sh`
- For Clean install run `./setup-rhmap.sh -c` this removes existing `rhmap-core` and `rhmap-1-node-mbaas` projects.

## Issues
Make sure the paths in the script match you local directory structure

## More information
For more detailed information on this process see this [guide](https://github.com/fheng/help/blob/master/new_hires/new_hire_chapter_2.2.md)
