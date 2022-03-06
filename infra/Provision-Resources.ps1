# Provisions resources
Param(
    [string]
    [Parameter(Mandatory=$false)]
    $ResourceGroupName = "",

    [string]
    [Parameter(Mandatory=$false)]
    $ResourceName = "",

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Australia Central", "Australia East", "Australia Southeast", "Brazil South", "Canada Central", "Canada East", "Central India", "Central US", "East Asia", "East US", "East US 2", "France Central", "Germany West Central", "Japan East", "Japan West", "Jio India West", "Korea Central", "Korea South", "North Central US", "North Europe", "Norway East", "South Africa North", "South Central US", "South India", "Southeast Asia", "Sweden Central", "Switzerland North", "UAE North", "UK South", "UK West", "West Central US", "West Europe", "West India", "West US", "West US 2", "West US 3")]
    $Location = "Korea Central",

    ### Cosmos DB ###
    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Standard")]
    $CosmosDbAccountOfferType = "Standard",

    [bool]
    [Parameter(Mandatory=$false)]
    $CosmosDbAutomaticFailover = $true,

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Strong", "BoundedStaleness", "Session", "ConsistentPrefix", "Eventual")]
    $CosmosDbConsistencyLevel = "Session",

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Australia Central", "Australia East", "Australia Southeast", "Brazil South", "Canada Central", "Canada East", "Central India", "Central US", "East Asia", "East US", "East US 2", "France Central", "Germany West Central", "Japan East", "Japan West", "Jio India West", "Korea Central", "Korea South", "North Central US", "North Europe", "Norway East", "South Africa North", "South Central US", "South India", "Southeast Asia", "Sweden Central", "Switzerland North", "UAE North", "UK South", "UK West", "West Central US", "West Europe", "West India", "West US", "West US 2", "West US 3")]
    $CosmosDbPrimaryRegion = "Korea Central",

    [bool]
    [Parameter(Mandatory=$false)]
    $CosmosDbEnableServerless = $true,

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Local", "Zone", "Geo")]
    $CosmosDbBackupStorageRedundancy = "Local",
    ### Cosmos DB ###

    ### Static Web App ###
    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Central US", "East Asia", "East US 2", "West Europe", "West US 2")]
    $StaticWebAppLocation = "East Asia",

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Free", "Standard")]
    $StaticWebAppSkuName = "Free",

    [bool]
    [Parameter(Mandatory=$false)]
    $StaticWebAppAllowConfigFileUpdates = $true,

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Disabled", "Enabled")]
    $StaticWebAppStagingEnvironmentPolicy = "Enabled",
    ### Static Web App ###

    ### Target Scope ###
    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("ResourceGroup", "Subscription")]
    $TargetScope = "Subscription",
    ### Target Scope ###

    [switch]
    [Parameter(Mandatory=$false)]
    $WhatIf,

    [switch]
    [Parameter(Mandatory=$false)]
    $Help
)

function Show-Usage {
    Write-Output "    This provisions resources to Azure

    Usage: $(Split-Path $MyInvocation.ScriptName -Leaf) ``
            -ResourceGroupName <resource group name> ``
            -ResourceName <resource name> ``
            [-Location <location>] ``

            [-CosmosDbAccountOfferType <Cosmos DB account type>] ``
            [-CosmosDbAutomaticFailover <`$true|`$false>] ``
            [-CosmosDbConsistencyLevel <Cosmos DB consistency level>] ``
            [-CosmosDbPrimaryRegion <Cosmos DB primary region>] ``
            [-CosmosDbEnableServerless <`$true|`$false>] ``
            [-CosmosDbBackupStorageRedundancy <Cosmos DB backup storage redundancy>] ``

            [-StaticWebAppLocation <Static Web App location>] ``
            [-StaticWebAppSkuName <Static Web App SKU name>] ``
            [-StaticWebAppAllowConfigFileUpdates <`$true|`$false>] ``
            [-StaticWebAppStagingEnvironmentPolicy <Static Web App staging envronment policy>] ``

            [-TargetScope <Target scope>] ``

            [-WhatIf] ``
            [-Help]

    Options:
        -ResourceGroupName                Resource group name.
                                          Default is empty string.
                                          But if -TargetScope is ResourceGroup,
                                          it must be specified.
        -ResourceName                     Resource name.
        -Location                         Resource location.
                                          Default is 'koreacentral'.

        -CosmosDbAccountOfferType         Cosmos DB account type.
                                          Default is 'Standard'.
        -CosmosDbAutomaticFailover        To enable failover or not.
                                          Default is `$true.
        -CosmosDbConsistencyLevel         Cosmos DB consistency level.
                                          Default is 'Session'.
        -CosmosDbPrimaryRegion            Cosmos DB primary region.
                                          Default is 'Korea Central'.
        -CosmosDbEnableServerless         To enable serverless or not.
                                          Default is `$true.
        -CosmosDbBackupStorageRedundancy  Cosmos DB backup storage redundancy.
                                          Default is 'Local'.

        -StaticWebAppLocation             Static Web App location.
                                          Default is 'eastasia'.
        -StaticWebAppSkuName              Static Web App SKU name.
                                          Default is 'Free'.
        -StaticWebAppAllowConfigFileUpdates
                                          To allow config file update or not.
                                          Default is `$true.
        -StaticWebAppStagingEnvironmentPolicy
                                          Staging environment policy.
                                          Default is 'Enabled'.

        -WhatIf:                          Show what would happen without
                                          actually provisioning resources.
        -Help:                            Show this message.
"

    Exit 0
}

# Show usage
$needHelp = ($ResourceName -eq "") -or ($Help -eq $true)
if ($needHelp -eq $true) {
    Show-Usage
    Exit 0
}

$needHelp = ($TargetScope -eq "ResourceGroup") -and ($ResourceGroupName -eq "")
if ($needHelp -eq $true) {
    Show-Usage
    Exit 0
}

# Build parameters
$params = @{
    name = @{ value = $ResourceName };

    cosdbaAccountOfferType = @{ value = $CosmosDbAccountOfferType };
    cosdbaAutomaticFailover = @{ value = $CosmosDbAutomaticFailover };
    cosdbaConsistencyLevel = @{ value = $CosmosDbConsistencyLevel };
    cosdbaPrimaryRegion = @{ value = $CosmosDbPrimaryRegion };
    cosdbaEnableServerless = @{ value = $CosmosDbEnableServerless };
    cosdbaBackupStorageRedundancy = @{ value = $CosmosDbBackupStorageRedundancy };

    sttappLocation = @{ value = $StaticWebAppLocation };
    sttappSkuName = @{ value = $StaticWebAppSkuName };
    sttappAllowConfigFileUpdates = @{ value = $StaticWebAppAllowConfigFileUpdates };
    sttappStagingEnvironmentPolicy = @{ value = $StaticWebAppStagingEnvironmentPolicy };
}

if ($TargetScope -eq "ResourceGroup") {
    $params.cosdbaLocation = @{ value = $Location };
} else {
    $params.location = @{ value = $Location };
}

# Uncomment to debug
# $params | ConvertTo-Json
# $params | ConvertTo-Json -Compress
# $params | ConvertTo-Json -Compress | ConvertTo-Json

$stringified = $params | ConvertTo-Json -Compress | ConvertTo-Json

# Provision the resources
if ($WhatIf -eq $true) {
    if ($TargetScope -eq "ResourceGroup") {
        $result = az deployment group create -g $ResourceGroupName -n $TargetScope `
            -f ./main.bicep `
            -p $stringified `
            -w
    } else {
        $result = az deployment sub create -l $Location -n $TargetScope `
            -f ./azuredeploy.bicep `
            -p $stringified `
            -w
    }

} else {
    if ($TargetScope -eq "ResourceGroup") {
        $result = az deployment group create -g $ResourceGroupName -n $TargetScope `
            -f ./main.bicep `
            -p $stringified `
            --verbose
    } else {
        $result = az deployment sub create -l $Location -n $TargetScope `
            -f ./azuredeploy.bicep `
            -p $stringified `
            --verbose
    }
}

$result
