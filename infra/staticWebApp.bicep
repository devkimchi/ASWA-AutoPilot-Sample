param name string

@allowed([
    'Central US'
    'East Asia'
    'East US 2'
    'West Europe'
    'West US 2'
])
param sttappLocation string = 'East Asia'

@allowed([
    'Free'
    'Standard'
])
param sttappSkuName string = 'Free'

param sttappAllowConfigFileUpdates bool = true

@allowed([
    'Disabled'
    'Enabled'
])
param sttappStagingEnvironmentPolicy string = 'Enabled'

@secure()
param cosdbaConnectionString string

var staticApp = {
    name: 'sttapp-${name}'
    location: sttappLocation
    skuName: sttappSkuName
    allowConfigFileUpdates: sttappAllowConfigFileUpdates
    stagingEnvironmentPolicy: sttappStagingEnvironmentPolicy
    connectionStrings: {
        cosmosDb: cosdbaConnectionString
    }
}

resource sttapp 'Microsoft.Web/staticSites@2021-03-01' = {
    name: staticApp.name
    location: staticApp.location
    sku: {
        name: staticApp.skuName
    }
    properties: {
        allowConfigFileUpdates: staticApp.allowConfigFileUpdates
        stagingEnvironmentPolicy: staticApp.stagingEnvironmentPolicy
    }
}

resource sttappconfig 'Microsoft.Web/staticSites/config@2021-03-01' = {
    name: '${sttapp.name}/appsettings'
    properties: {
        ConnectionStrings_CosmosDB: staticApp.connectionStrings.cosmosDb
    }
}

output id string = sttapp.id
output name string = sttapp.name
output deploymentKey string = sttapp.listSecrets().properties.apiKey
