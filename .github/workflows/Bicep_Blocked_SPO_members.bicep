param workflows_Blocked_SPO_members_name string = 'Bicep_Blocked_SPO_members'
param connections_keyvault_4_externalid string = '/subscriptions/d6abefe9-d8b8-4f4c-880b-1c7f6992b04d/resourceGroups/NVMT-ISID-EK1-RGP-Recovery-Vault/providers/Microsoft.Web/connections/keyvault-4'
param userAssignedIdentities_PSR_UAMI_externalid string = '/subscriptions/d6abefe9-d8b8-4f4c-880b-1c7f6992b04d/resourceGroups/NVMT-ISID-EK1-RGP-Recovery-Vault/providers/Microsoft.ManagedIdentity/userAssignedIdentities/PSR-UAMI'

resource workflows_Blocked_SPO_members_name_resource 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflows_Blocked_SPO_members_name
  location: 'westindia'
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/d6abefe9-d8b8-4f4c-880b-1c7f6992b04d/resourceGroups/NVMT-ISID-EK1-RGP-Recovery-Vault/providers/Microsoft.ManagedIdentity/userAssignedIdentities/PSR-UAMI': {}
    }
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        Recurrence: {
          recurrence: {
            interval: 1
            frequency: 'Day'
            timeZone: 'India Standard Time'
            schedule: {
              hours: [
                5
              ]
            }
          }
          evaluatedRecurrence: {
            interval: 1
            frequency: 'Day'
            timeZone: 'India Standard Time'
            schedule: {
              hours: [
                5
              ]
            }
          }
          type: 'Recurrence'
        }
      }
      actions: {
        Tenant_ID: {
          runAfter: {
            Get_secret: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Tenant ID'
                type: 'string'
                value: 'dcac7e0b-5007-4b90-8f3b-39d5d2289aa1'
              }
            ]
          }
        }
        Client_ID: {
          runAfter: {
            Tenant_ID: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Client ID'
                type: 'string'
                value: '86e111ff-fa41-4401-9f9b-509efdbe87e0'
              }
            ]
          }
        }
        Group_Pairs: {
          runAfter: {}
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Group pairs'
                type: 'array'
                value: [
                  {
                    GroupID: 'a15253f2-d279-430e-8e8d-2deb8067dc3b'
                    GroupName: 'SG-SITI-O365-DENY-SPO_Members'
                  }
                  {
                    GroupID: '2a5c2fcd-6153-444a-bff0-1ec3c346246b'
                    GroupName: 'SG-SITI-O365-DENY-SPO_CDT_Members'
                  }
                ]
              }
            ]
          }
        }
        Get_secret: {
          runAfter: {
            Group_Pairs: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'keyvault-1\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/secrets/@{encodeURIComponent(\'KeyVaultpfx\')}/value'
          }
        }
        For_each: {
          foreach: '@variables(\'Group pairs\')'
          actions: {
            'Compose-Current_Group': {
              type: 'Compose'
              inputs: '@items(\'For_each\')'
            }
            'HTTP-Get_group_members_count': {
              runAfter: {
                'Set-Current_Group_Name': [
                  'Succeeded'
                ]
              }
              type: 'Http'
              inputs: {
                uri: 'https://graph.microsoft.com/v1.0/groups/@{outputs(\'Compose-Current_Group\')?[\'GroupID\']}/members?$count=true'
                method: 'GET'
                headers: {
                  ConsistencyLevel: 'eventual'
                }
                authentication: {
                  type: 'ActiveDirectoryOAuth'
                  tenant: '@{variables(\'Tenant ID\')}'
                  audience: 'https://graph.microsoft.com/'
                  clientId: '@{variables(\'Client ID\')}'
                  pfx: '@{body(\'Get_secret\')?[\'value\']}'
                  password: '@{null}'
                }
              }
              runtimeConfiguration: {
                contentTransfer: {
                  transferMode: 'Chunked'
                }
              }
            }
            'Parse_JSON-_Get_Group_members_count': {
              runAfter: {
                'HTTP-Get_group_members_count': [
                  'Succeeded'
                ]
              }
              type: 'ParseJson'
              inputs: {
                content: '@body(\'HTTP-Get_group_members_count\')'
                schema: {
                  type: 'object'
                  properties: {
                    statusCode: {
                      type: 'integer'
                    }
                    headers: {
                      type: 'object'
                      properties: {
                        'Cache-Control': {
                          type: 'string'
                        }
                        'Transfer-Encoding': {
                          type: 'string'
                        }
                        Vary: {
                          type: 'string'
                        }
                        'Strict-Transport-Security': {
                          type: 'string'
                        }
                        'request-id': {
                          type: 'string'
                        }
                        'client-request-id': {
                          type: 'string'
                        }
                        'x-ms-ags-diagnostic': {
                          type: 'string'
                        }
                        'x-ms-resource-unit': {
                          type: 'string'
                        }
                        'OData-Version': {
                          type: 'string'
                        }
                        Date: {
                          type: 'string'
                        }
                        'Content-Type': {
                          type: 'string'
                        }
                        'Content-Length': {
                          type: 'string'
                        }
                      }
                    }
                    body: {
                      type: 'object'
                      properties: {
                        '@@odata.context': {
                          type: 'string'
                        }
                        '@@odata.count': {
                          type: 'integer'
                        }
                        value: {
                          type: 'array'
                          items: {
                            type: 'object'
                            properties: {
                              '@@odata.type': {
                                type: 'string'
                              }
                              id: {
                                type: 'string'
                              }
                              businessPhones: {
                                type: 'array'
                              }
                              displayName: {
                                type: 'string'
                              }
                              givenName: {
                                type: 'string'
                              }
                              jobTitle: {}
                              mail: {
                                type: 'string'
                              }
                              mobilePhone: {}
                              officeLocation: {}
                              preferredLanguage: {}
                              surname: {
                                type: 'string'
                              }
                              userPrincipalName: {
                                type: 'string'
                              }
                            }
                            required: [
                              '@@odata.type'
                              'id'
                              'businessPhones'
                              'displayName'
                              'givenName'
                              'jobTitle'
                              'mail'
                              'mobilePhone'
                              'officeLocation'
                              'preferredLanguage'
                              'surname'
                              'userPrincipalName'
                            ]
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            Condition: {
              actions: {}
              runAfter: {
                'Parse_JSON-_Get_Group_members_count': [
                  'Succeeded'
                ]
              }
              else: {
                actions: {
                  'HTTP_-_Get_group_properties': {
                    type: 'Http'
                    inputs: {
                      uri: 'https://graph.microsoft.com/v1.0/groups/@{outputs(\'Compose-Current_Group\')?[\'GroupID\']}/members?&$select=id,userPrincipalName,displayName,mail,userType,accountEnabled,assignedLicenses,assignedPlans,licenseAssignmentStates,createdDateTime,showInAddressList,onPremisesLastSyncDateTime,onPremisesSyncEnabled,showInAddressList'
                      method: 'GET'
                      authentication: {
                        type: 'ActiveDirectoryOAuth'
                        tenant: '@{variables(\'Tenant ID\')}'
                        audience: 'https://graph.microsoft.com/'
                        clientId: '@{variables(\'Client ID\')}'
                        pfx: '@{body(\'Get_secret\')?[\'value\']}'
                        password: '@{null}'
                      }
                    }
                    runtimeConfiguration: {
                      contentTransfer: {
                        transferMode: 'Chunked'
                      }
                    }
                  }
                  Parse_JSON: {
                    runAfter: {
                      'HTTP_-_Get_group_properties': [
                        'Succeeded'
                      ]
                    }
                    type: 'ParseJson'
                    inputs: {
                      content: '@body(\'HTTP_-_Get_group_properties\')'
                      schema: {
                        type: 'object'
                        properties: {
                          '@@odata.context': {
                            type: 'string'
                          }
                          value: {
                            type: 'array'
                            items: {
                              type: 'object'
                              properties: {
                                '@@odata.type': {
                                  type: 'string'
                                }
                                id: {
                                  type: 'string'
                                }
                                userPrincipalName: {
                                  type: 'string'
                                }
                                displayName: {
                                  type: 'string'
                                }
                                mail: {}
                                userType: {
                                  type: 'string'
                                }
                                accountEnabled: {
                                  type: 'boolean'
                                }
                                createdDateTime: {
                                  type: 'string'
                                }
                                showInAddressList: {}
                                onPremisesLastSyncDateTime: {}
                                onPremisesSyncEnabled: {}
                                assignedLicenses: {
                                  type: 'array'
                                }
                                assignedPlans: {
                                  type: 'array'
                                }
                                licenseAssignmentStates: {
                                  type: 'array'
                                }
                              }
                              required: [
                                '@@odata.type'
                                'id'
                                'userPrincipalName'
                                'displayName'
                                'mail'
                                'userType'
                                'accountEnabled'
                                'createdDateTime'
                                'showInAddressList'
                                'onPremisesLastSyncDateTime'
                                'onPremisesSyncEnabled'
                                'assignedLicenses'
                                'assignedPlans'
                                'licenseAssignmentStates'
                              ]
                            }
                          }
                        }
                      }
                    }
                  }
                  Create_CSV_table: {
                    runAfter: {
                      'Select-Members_information': [
                        'Succeeded'
                      ]
                    }
                    type: 'Table'
                    inputs: {
                      from: '@body(\'Select-Members_information\')'
                      format: 'CSV'
                    }
                  }
                  'HTTP-Upload_CSV_files_to_SharePoint_site': {
                    runAfter: {
                      'Set-fileName': [
                        'Succeeded'
                      ]
                    }
                    type: 'Http'
                    inputs: {
                      uri: 'https://graph.microsoft.com/v1.0/sites/@{variables(\'site id\')}/drives/@{variables(\'drive id\')}/root:/Blocked_SPO_Members/@{variables(\'file Name\')}:/content'
                      method: 'PUT'
                      headers: {
                        'Content-Type': 'binary/octet-stream'
                      }
                      body: '@string(body(\'Create_CSV_table\'))'
                      authentication: {
                        type: 'ActiveDirectoryOAuth'
                        tenant: '@{variables(\'Tenant ID\')}'
                        audience: 'https://graph.microsoft.com/'
                        clientId: '@{variables(\'Client ID\')}'
                        pfx: '@{body(\'Get_secret\')?[\'value\']}'
                        password: '@{null}'
                      }
                    }
                    runtimeConfiguration: {
                      contentTransfer: {
                        transferMode: 'Chunked'
                      }
                    }
                  }
                  'Set-fileName': {
                    runAfter: {
                      Create_CSV_table: [
                        'Succeeded'
                      ]
                    }
                    type: 'SetVariable'
                    inputs: {
                      name: 'file Name'
                      value: '@{outputs(\'Compose-Current_Group\')?[\'GroupName\']}_@{utcNow(\'yyyy-MMM-dd\')}.csv'
                    }
                  }
                  'Select-Members_information': {
                    runAfter: {
                      Parse_JSON: [
                        'Succeeded'
                      ]
                    }
                    type: 'Select'
                    inputs: {
                      from: '@body(\'Parse_JSON\')?[\'value\']'
                      select: {
                        UserPrincipalName: '@{item()?[\'userPrincipalName\']}'
                        ID: '@{item()?[\'id\']}'
                        displayName: '@{item()?[\'displayName\']}'
                        mail: '@{item()?[\'mail\']}'
                        userType: '@{item()?[\'userType\']}'
                        accountEnabled: '@{item()?[\'accountEnabled\']}'
                        createdDateTime: '@{item()?[\'createdDateTime\']}'
                        showInAddressList: '@{item()?[\'showInAddressList\']}'
                        onPremisesLastSyncDateTime: '@{item()?[\'onPremisesLastSyncDateTime\']}'
                        onPremisesSyncEnabled: '@{item()?[\'onPremisesSyncEnabled\']}'
                        assignedLicenses: '@{item()?[\'assignedLicenses\']}'
                        assignedPlans: '@{item()?[\'assignedPlans\']}'
                        licenseAssignmentStates: '@{item()?[\'licenseAssignmentStates\']}'
                      }
                    }
                  }
                  'Set-fileName-copy': {
                    runAfter: {
                      'HTTP-Upload_CSV_files_to_SharePoint_site': [
                        'Succeeded'
                      ]
                    }
                    type: 'SetVariable'
                    inputs: {
                      name: 'file Name'
                      value: ' '
                    }
                  }
                }
              }
              expression: {
                and: [
                  {
                    equals: [
                      '@body(\'Parse_JSON-_Get_Group_members_count\')?[\'body\']?[\'@@odata.count\']'
                      0
                    ]
                  }
                ]
              }
              type: 'If'
            }
            'Set-Current_Group_ID': {
              runAfter: {
                'Compose-Current_Group': [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'Current GroupID'
                value: '@outputs(\'Compose-Current_Group\')?[\'GroupID\']'
              }
            }
            'Set-Current_Group_Name': {
              runAfter: {
                'Set-Current_Group_ID': [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'Current Group Name'
                value: '@outputs(\'Compose-Current_Group\')?[\'GroupName\']'
              }
            }
          }
          runAfter: {
            variable_string: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        site_id: {
          runAfter: {
            Client_ID: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'site id'
                type: 'string'
                value: 'a5c5ca51-ab90-49f3-b122-e63419bc8a55'
              }
            ]
          }
        }
        drive_id: {
          runAfter: {
            site_id: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'drive id'
                type: 'string'
                value: 'b!UcrFpZCr80mxIuY0GbyKVbALHkHU2nRGl_Q457XgiwLc-iVLIH7fRJpar6BeROgX'
              }
            ]
          }
        }
        'variable-Current_Group_Name': {
          runAfter: {
            drive_id: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Current Group Name'
                type: 'string'
              }
            ]
          }
        }
        'Variable-Current_GroupID': {
          runAfter: {
            'variable-Current_Group_Name': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Current GroupID'
                type: 'string'
              }
            ]
          }
        }
        'variable-file_Name': {
          runAfter: {
            'Variable-Current_GroupID': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'file Name'
                type: 'string'
              }
            ]
          }
        }
        variable_csvContent: {
          runAfter: {
            'variable-file_Name': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'csvContent'
                type: 'string'
                value: '@body(\'Get_secret\')?[\'value\']'
              }
            ]
          }
        }
        variable_string: {
          runAfter: {
            variable_csvContent: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'varstring'
                type: 'string'
              }
            ]
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          'keyvault-1': {
            id: '/subscriptions/d6abefe9-d8b8-4f4c-880b-1c7f6992b04d/providers/Microsoft.Web/locations/westindia/managedApis/keyvault'
            connectionId: connections_keyvault_4_externalid
            connectionName: 'keyvault-4'
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
                identity: userAssignedIdentities_PSR_UAMI_externalid
              }
            }
          }
        }
      }
    }
  }
}
