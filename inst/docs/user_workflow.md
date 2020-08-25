goal: make it easier for researchers to run analysis on the cloud

I found this quote about RMarkdown, which is a front-end for Pandoc: 

The RMarkdown package's aim is simply to [provide reasonably good defaults and an R-friendly interface to customize Pandoc options..](https://blog.rstudio.org/2014/06/18/r-markdown-v2/)

We endeavor for the same thing here: 

The Azrunr package's ami is simply to provide reasonably good defaults and an R-friendly interface to the AzureRMR package and those Azure services needed to  run R processes when local resources (laptop, workstation) are insufficient. 

problem: cloud is complex, arcane and hard to manage and especially to budget

solution : create functions or a scienceOnCloud api to help make this easier

specifically, for a lab that's using R on their laptops, how can they more easily provision, use and monitor Azure to run those analsysi when their laptops are not enough.  e.g an alternative to your local HPC


Links
---

current effort : https://gitlab.msu.edu/adsdatascience/azrunr

**AzureRMR** R package that can make stuff based on Azure Resource Manager 

**Containers** interesting approach to R in a container: 

https://github.com/ThinkR-open/devindocker


Azure User Stories
===

**R code to run** without data and save results
---

I have : 
  * a git hub repo, possibly with a branch for Azure
  * an R script that is the entry point/start
  * code that saves results to file(s)
  * an Azure Sub and Resource group
  * $
 
I want : 
  * to run code on an larger machine than mine or for a long time
  * save the output to a place where I can get it
  * to specify that place

I know: 
  * approx size of machine to run
  * where my R code saves results (which folder?)
  
I need : 
  * a machine to run it on
  * to copy my code to the machine and tell it to run
  * all of the libs I need installed on that machine
  * a place to store the output files, and how to retrieve them
  * maybe to tell my R code where to store results (in a )

  
R code interative development
---

sames *R code to run* above, except

I need : 
  * To be able to check the results 
  * to adjust R code after running and discovering code (has errors/is incorrect)\
  * to replace broken code on VM
  * re-start the script
  * to re-run without to much trouble or wait time (e.g. perhaps without having to re-provision a new VM)
 
 I have : 
  * fixes pushed to my git repo
  * possibly additional branches
  * a command to start my analysis
  * possibly saved the commands I used to provision the VM/cloud resources and run my code
 

R code to run with data and save results
---

sames *R code to run* above, and additionally 

I have : 

  * code that reads data in from a path OR using azure 
  * Data files, local or available on the internet

I want : 
  * to run code on an larger machine than mine, or for a long time, or to be able to access lots of data
  * save the output to a place where I can get it
  * to specify that place


R code to run as many tasks with data and save results
---

*Same as code with data except*

I need: 
  * to create multiple VMs
  * in each VM upload and Run R code
  * each Run to save results in a folder 


R code to run in parallel (using a standard paralle lib) as many tasks with data and save results
---
  * save as 


Methods/ideas for each step in user story
===

Getting code into a VM
---
when a VM is created one option is the github repository where the code is located.  The provisioning code for the VM will automatically clone the code directly into the HOME directory (or as a preset folder in homedir like "~/code").

**Requirements :**
  - readable option for github repo (env var?)
  - git installed
  - scripts in VM deploy that pull repo at start-up



Playbooks for User Stories
===

Uploading to Storage
---

Reading from Storage
----

Code could have a preset folder that it expect read from. 

Auzre File Storage is mounted when the VM is provisioned, given the optional path parameter

The R code mounts the storage account at a path from inside the  VM after it's provisioned
   
Code could use the AzureStor lib to access storage, both in local dev/test and in cloud VM.    One option is to have a branch with the only difference being the storage access, 
or different functions for reading data `mydata <- read_data_cloud() and mydata <- read_data_local()`  or something.  


Reading from AzureBlob storage
---
Blob storage is way cheaper, so it's more desirable for research.  File storage allowsx you to 'mount' so that you don't have to change your code at all other than the path where the data is, but that's more expensive and takes more setup during deployment. 

"The universal solution is to write to a temp file, and read that. Even if there's a wrapper, that's still what is happening underneath.""
 MEANS YUO HAVE TO PROVISION THE SAME AMOUNT OF VM DISK SPACE AS Your files.  Phooey!   No wonder everyone uses spark/HDFS solution. 
 
One solution is to mount the storage with SMB, using Azure files.  More expensive but more convenient.  Writing to fstab or autofs at VM creation ensures this persists across reboots.   Use a SAS type authentication to give the VM access to only what it needs (keys allow access to entire files)

https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux#create-a-persistent-mount-point-for-the-azure-file-share-with-etcfstab

If we don't use Azure "File Storage" and and mounting the container, then files need to be  'staged' on the VM disk in a folder as part of provisioning. This is time consuming for large files, and expensive becuase VM disks are not cheap and the VM disk must be 


Since files must be downloaded from a blob container to the local VM disk, that means that ANY disk system available from the internet would be a viable solution.  Given the MSU HPCC offers large storage capacity that can be downloaded using 'scp', if a user can work with ssh keys, then one could download from the HPC and not incur cloud storage costs.  The downside is that a public key and user id must be stored on the VM, whereas for Azure storage, one could create an "SAS" token ahead of time, and also limit permissions that this SAS has available.  



Running R code on VM
---
user logs in or runs azsetup() 
user sets options for VM:
    github repository (how to download)
    

