# For local only
setwd("~/ADSWork/zipkinlab/azrunr/inst/VM_and_Extension")

login = "az login"
system(command = login)

# May not be needed for everyone, add some error handling to offer a subscription switch if the resource group cannot be found
switchsubscription = "az account set --subscription \"ADS Unstructured Storage\""
system(command = switchsubscription)

vmdeploy =  "az deployment group create --resource-group scriptvmcreation --template-file VMtemplate.json --parameters VMtemplate.parameters.json"
system(command = vmdeploy)

# Will not need this after revision to the VM template
#extensiondeploy = "az vm extension set --resource-group scriptvmcreation --vm-name scriptvm --name customScript --publisher Microsoft.Azure.Extensions --protected-settings ./extensionscript.json"
#system(command = extensiondeploy)

# Function will probably do two things: update the parameters json (Unsure what we will leave up to the users discretion)
# Then it needs the resource group and
