param name string
param cosdbaLocation string = resourceGroup().location

@allowed([
    'Standard'
])
param cosdbaAccountOfferType string = 'Standard'
param cosdbaAutomaticFailover bool = true

@allowed([
    'Strong'
    'BoundedStaleness'
    'Session'
    'ConsistentPrefix'
    'Eventual'
])
param cosdbaConsistencyLevel string = 'Session'

param cosdbaPrimaryRegion string = resourceGroup().location
param cosdbaEnableServerless bool = true

@allowed([
    'Local'
    'Zone'
    'Geo'
])
param cosdbaBackupStorageRedundancy string = 'Local'

param cosdbaDatabaseName string = 'ACS'
param cosdbaContainerName string = 'users'
param cosdbaPartitionKeyPaths array = [
    '/id'
]

var capabilities = cosdbaEnableServerless ? [
    {
        name: 'EnableServerless'
    }
] : []

var cosmosDb = {
    name: 'cosdba-${name}'
    location: cosdbaLocation
    databaseAccountOfferType: cosdbaAccountOfferType
    enableAutomaticFailover: cosdbaAutomaticFailover
    defaultConsistencyLevel: cosdbaConsistencyLevel
    primaryRegion: cosdbaPrimaryRegion
    capabilities: capabilities
    backupStorageRedundancy: cosdbaBackupStorageRedundancy
    databaseName: cosdbaDatabaseName
    containerName: cosdbaContainerName
    partitionKeyPaths: cosdbaPartitionKeyPaths
}

resource cosdba 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' = {
    name: cosmosDb.name
    location: cosmosDb.location
    kind: 'GlobalDocumentDB'
    properties: {
        databaseAccountOfferType: cosmosDb.databaseAccountOfferType
        enableAutomaticFailover: cosmosDb.enableAutomaticFailover
        consistencyPolicy: {
            defaultConsistencyLevel: cosmosDb.defaultConsistencyLevel
            maxIntervalInSeconds: 5
            maxStalenessPrefix: 100
        }
        locations: [
            {
                locationName: cosmosDb.primaryRegion
                failoverPriority: 0
                isZoneRedundant: false
            }
        ]
        capabilities: cosmosDb.capabilities
        backupPolicy: {
            type: 'Periodic'
            periodicModeProperties: {
                backupIntervalInMinutes: 240
                backupRetentionIntervalInHours: 8
                backupStorageRedundancy: cosmosDb.backupStorageRedundancy
            }
        }
    }
}

resource cosdbasql 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-10-15' = {
    name: '${cosdba.name}/${cosmosDb.databaseName}'
    properties: {
        resource: {
            id: cosmosDb.databaseName
        }
    }
}

resource cosdbasqlcontainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-10-15' = {
    name: '${cosdbasql.name}/${cosmosDb.containerName}'
    properties: {
        resource: {
            id: cosmosDb.containerName
            partitionKey: {
                paths: cosmosDb.partitionKeyPaths
            }
        }
    }
}

output id string = cosdba.id
output name string = cosdba.name
output connectionString string = 'AccountEndpoint=https://${cosdba.name}.documents.azure.com:443/;AccountKey=${cosdba.listKeys().primaryMasterKey};'
