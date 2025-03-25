param workflows_Shell175SCHADOBEGroupMemberReplication_name string = 'Bicep_Shell175SCHADOBEGroupMemberReplication'
param connections_keyvault_3_externalid string = '/subscriptions/d6abefe9-d8b8-4f4c-880b-1c7f6992b04d/resourceGroups/NVMT-ISID-EK1-RGP-Recovery-Vault/providers/Microsoft.Web/connections/keyvault-3'
param userAssignedIdentities_PSR_UAMI_externalid string = '/subscriptions/d6abefe9-d8b8-4f4c-880b-1c7f6992b04d/resourceGroups/NVMT-ISID-EK1-RGP-Recovery-Vault/providers/Microsoft.ManagedIdentity/userAssignedIdentities/PSR-UAMI'

resource workflows_Shell175SCHADOBEGroupMemberReplication_name_resource 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflows_Shell175SCHADOBEGroupMemberReplication_name
  location: 'westeurope'
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
            frequency: 'Week'
            interval: 1
            schedule: {
              weekDays: [
                'Monday'
              ]
            }
            timeZone: 'India Standard Time'
          }
          evaluatedRecurrence: {
            frequency: 'Week'
            interval: 1
            schedule: {
              weekDays: [
                'Monday'
              ]
            }
            timeZone: 'India Standard Time'
          }
          type: 'Recurrence'
        }
      }
      actions: {
        'Array_-_Destination_Group_members_Id_and_UPN': {
          runAfter: {
            'Array_-_Source_Group_members_Id_and_UPN': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Destination Group members Id and UPN'
                type: 'array'
                value: [
                  {
                    destinationGroup: ''
                    id: ''
                  }
                ]
              }
            ]
          }
        }
        'Array_-_Source_Group_members_Id_and_UPN': {
          runAfter: {
            Group_ID_pairs: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Source Group members Id and UPN'
                type: 'array'
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
        Current_Destination_Group_ID: {
          runAfter: {
            Current_Source_Group_ID: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Current Destination Group ID'
                type: 'string'
              }
            ]
          }
        }
        Current_Source_Group_ID: {
          runAfter: {
            Destination_Group_ID_pairs: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Current Source Group ID'
                type: 'string'
              }
            ]
          }
        }
        Destination_Group_ID_pairs: {
          runAfter: {
            Group_Source_ID_Pairs: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Destination Group ID pairs'
                type: 'string'
                value: '7d116558-3c78-4e40-b088-25a5f20f92b4'
              }
            ]
          }
        }
        For_each: {
          foreach: '@variables(\'Group ID pairs\')'
          actions: {
            Append_capture_logs_count_destination_group_members: {
              runAfter: {
                Set_variable_destination_group_count: [
                  'Succeeded'
                ]
              }
              type: 'AppendToStringVariable'
              inputs: {
                name: 'capture logs'
                value: '\nThe intial count of members in Destination Group [ID - @{items(\'For_each\')?[\'destinationGroup\']}] is @{variables(\'Destination Group count\')}\n\n'
              }
            }
            Append_capture_logs_count_source_group_members: {
              runAfter: {
                Set_variable_source_group_count: [
                  'Succeeded'
                ]
              }
              type: 'AppendToStringVariable'
              inputs: {
                name: 'capture logs'
                value: '\nThe intial count of members in source Group [ID - @{items(\'For_each\')?[\'sourceGroup\']}] is @{variables(\'source Group count\')}\n\n'
              }
            }
            'Compose-Select_-_Destination_Group_Members_ID': {
              runAfter: {
                'Compose-Select_-_Source_Group_Members_IDs': [
                  'Succeeded'
                ]
              }
              type: 'Compose'
              inputs: '@body(\'Select_-_Destination_Group_Members_ID\')'
            }
            'Compose-Select_-_Source_Group_Members_IDs': {
              runAfter: {
                'Select_-_Destination_Group_Members_ID': [
                  'Succeeded'
                ]
              }
              type: 'Compose'
              inputs: '@body(\'Select_-_Destination_Group_Members_ID\')'
            }
            Current_Pair: {
              type: 'Compose'
              inputs: '@items(\'For_each\')'
            }
            'For_each_2-copy-copy': {
              foreach: '@body(\'Select_-_Destination_Group_Members_ID\')'
              actions: {
                Compose_4: {
                  type: 'Compose'
                  inputs: '@not(contains(body(\'Select_-_Source_Group_Members_IDs\'),item()))'
                }
                Condition_2: {
                  actions: {
                    HTTP: {
                      type: 'Http'
                      inputs: {
                        uri: 'https://graph.microsoft.com/v1.0/groups/@{outputs(\'Current_Pair\')[\'destinationGroup\']}/members/@{item()?[\'id\']}/$ref'
                        method: 'DELETE'
                        headers: {
                          'Content-Type': 'application/json'
                        }
                        authentication: {
                          type: 'ActiveDirectoryOAuth'
                          tenant: '@{variables(\'Tenant ID\')}'
                          audience: 'https://graph.microsoft.com'
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
                    Remove_users_from_destination_group: {
                      runAfter: {
                        HTTP: [
                          'Succeeded'
                        ]
                      }
                      type: 'AppendToArrayVariable'
                      inputs: {
                        name: 'Destination Group members Id and UPN'
                        value: {
                          destinationGroup: '@{ outputs(\'Current_Pair\')[\'destinationGroup\']}'
                          id: '@{item()?[\'id\']}'
                        }
                      }
                    }
                    Append_capture_logs_members_DELETED_from_Destination_Group: {
                      runAfter: {
                        Remove_users_from_destination_group: [
                          'Succeeded'
                        ]
                      }
                      type: 'AppendToStringVariable'
                      inputs: {
                        name: 'capture logs'
                        value: '\nMember with UserID @{item()?[\'id\']} is DELETED FROM Destination group with ID \n@{items(\'For_each\')?[\'destinationGroup\']}\n'
                      }
                    }
                  }
                  runAfter: {
                    Compose_4: [
                      'Succeeded'
                    ]
                  }
                  else: {
                    actions: {}
                  }
                  expression: {
                    and: [
                      {
                        equals: [
                          '@outputs(\'Compose_4\')'
                          true
                        ]
                      }
                    ]
                  }
                  type: 'If'
                }
              }
              runAfter: {
                'For_each_2-copy_1': [
                  'Succeeded'
                ]
              }
              type: 'Foreach'
            }
            'For_each_2-copy_1': {
              foreach: '@body(\'Select_-_Source_Group_Members_IDs\')'
              actions: {
                Compose_3: {
                  type: 'Compose'
                  inputs: '@not(contains(body(\'Select_-_Destination_Group_Members_ID\'),item()))'
                }
                Condition_1: {
                  actions: {
                    Add_Users_to_Destination_Group: {
                      runAfter: {
                        Append_capture_logs_members_added_in_Destination_Group: [
                          'Succeeded'
                        ]
                      }
                      type: 'AppendToArrayVariable'
                      inputs: {
                        name: 'Source Group members Id and UPN'
                        value: '@outputs(\'Compose\')'
                      }
                    }
                    Compose: {
                      runAfter: {
                        HTTP_1: [
                          'Succeeded'
                        ]
                      }
                      type: 'Compose'
                      inputs: {
                        destinationGroup: '@{outputs(\'Current_Pair\')[\'destinationGroup\']}'
                        id: '@{item()?[\'id\']}'
                      }
                    }
                    HTTP_1: {
                      type: 'Http'
                      inputs: {
                        uri: 'https://graph.microsoft.com/v1.0/groups/@{ outputs(\'Current_Pair\')[\'destinationGroup\']}/members/$ref'
                        method: 'POST'
                        headers: {
                          'Content-Type': 'application/json'
                        }
                        body: {
                          '@@odata.id': 'https://graph.microsoft.com/v1.0/directoryObjects/@{item()?[\'id\']}'
                        }
                        authentication: {
                          type: 'ActiveDirectoryOAuth'
                          tenant: '@{variables(\'Tenant ID\')}'
                          audience: 'https://graph.microsoft.com'
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
                    Append_capture_logs_members_added_in_Destination_Group: {
                      runAfter: {
                        Compose: [
                          'Succeeded'
                        ]
                      }
                      type: 'AppendToStringVariable'
                      inputs: {
                        name: 'capture logs'
                        value: '\nMember with user id @{item()?[\'id\']} is ADDED in Destination group with group ID @{items(\'For_each\')?[\'destinationGroup\']}\n'
                      }
                    }
                  }
                  runAfter: {
                    Compose_3: [
                      'Succeeded'
                    ]
                  }
                  else: {
                    actions: {}
                  }
                  expression: {
                    and: [
                      {
                        equals: [
                          '@outputs(\'Compose_3\')'
                          true
                        ]
                      }
                    ]
                  }
                  type: 'If'
                }
              }
              runAfter: {
                compose_capture_logs: [
                  'Succeeded'
                ]
              }
              type: 'Foreach'
            }
            Get_HTTP_Destination_Group_Members: {
              runAfter: {
                Append_capture_logs_count_source_group_members: [
                  'Succeeded'
                ]
              }
              type: 'Http'
              inputs: {
                uri: 'https://graph.microsoft.com/v1.0/groups/@{ outputs(\'Current_Pair\')[\'destinationGroup\']}/members?$count=true&$select=id,displayName,userPrincipalName'
                method: 'GET'
                headers: {
                  ConsistencyLevel: 'eventual'
                }
                authentication: {
                  type: 'ActiveDirectoryOAuth'
                  tenant: '@{variables(\'Tenant ID\')}'
                  audience: 'https://graph.microsoft.com'
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
            Get_HTTP_Source_Group_Members: {
              runAfter: {
                'Append-capture_logs': [
                  'Succeeded'
                ]
              }
              type: 'Http'
              inputs: {
                uri: 'https://graph.microsoft.com/v1.0/groups/@{ outputs(\'Current_Pair\')[\'sourceGroup\']}/members?$count=true&$select=id,displayName,userPrincipalName'
                method: 'GET'
                headers: {
                  ConsistencyLevel: 'eventual'
                }
                authentication: {
                  type: 'ActiveDirectoryOAuth'
                  tenant: '@{variables(\'Tenant ID\')}'
                  audience: 'https://graph.microsoft.com'
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
            Parse_JSON_Destination_Group_Members: {
              runAfter: {
                Get_HTTP_Destination_Group_Members: [
                  'Succeeded'
                ]
              }
              type: 'ParseJson'
              inputs: {
                content: '@body(\'Get_HTTP_Destination_Group_Members\')'
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
                              displayName: {
                                type: 'string'
                              }
                              userPrincipalName: {
                                type: 'string'
                              }
                            }
                            required: [
                              '@@odata.type'
                              'id'
                              'displayName'
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
            Parse_JSON_Source_Group_Members: {
              runAfter: {
                Get_HTTP_Source_Group_Members: [
                  'Succeeded'
                ]
              }
              type: 'ParseJson'
              inputs: {
                content: '@body(\'Get_HTTP_Source_Group_Members\')'
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
                              displayName: {
                                type: 'string'
                              }
                              userPrincipalName: {
                                type: 'string'
                              }
                            }
                            required: [
                              '@@odata.type'
                              'id'
                              'displayName'
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
            'Select_-_Destination_Group_Members_ID': {
              runAfter: {
                'Select_-_Source_Group_Members_IDs': [
                  'Succeeded'
                ]
              }
              type: 'Select'
              inputs: {
                from: '@body(\'Parse_JSON_Destination_Group_Members\')?[\'value\']'
                select: {
                  id: '@{item()[\'id\']}'
                }
              }
            }
            'Select_-_Source_Group_Members_IDs': {
              runAfter: {
                Append_capture_logs_count_destination_group_members: [
                  'Succeeded'
                ]
              }
              type: 'Select'
              inputs: {
                from: '@body(\'Parse_JSON_Source_Group_Members\')?[\'value\']'
                select: {
                  id: '@{item()[\'id\']}'
                }
              }
            }
            'Set_-_Current_Source_Group_ID': {
              runAfter: {
                Current_Pair: [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'Current Source Group ID'
                value: '@ outputs(\'Current_Pair\')[\'sourceGroup\']'
              }
            }
            'Set__-_Current_Destination_Group_ID': {
              runAfter: {
                'Set_-_Current_Source_Group_ID': [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'Current Destination Group ID'
                value: '@ outputs(\'Current_Pair\')[\'destinationGroup\']'
              }
            }
            compose_capture_logs: {
              runAfter: {
                'Compose-Select_-_Destination_Group_Members_ID': [
                  'Succeeded'
                ]
              }
              type: 'Compose'
              inputs: '@variables(\'capture logs\')'
            }
            'Append-capture_logs': {
              runAfter: {
                'Set__-_Current_Destination_Group_ID': [
                  'Succeeded'
                ]
              }
              type: 'AppendToStringVariable'
              inputs: {
                name: 'capture logs'
                value: '\nThe pair of Groups are as follows:\n\n    Source Group - @{items(\'For_each\')?[\'sourceGroup\']}\n\n    Destination Group - @{items(\'For_each\')?[\'destinationGroup\']}\n\n'
              }
            }
            Get_HTTP_Source_Group_Members_final_count: {
              runAfter: {
                'For_each_2-copy-copy': [
                  'Succeeded'
                ]
              }
              type: 'Http'
              inputs: {
                uri: 'https://graph.microsoft.com/v1.0/groups/@{ outputs(\'Current_Pair\')[\'sourceGroup\']}/members?$count=true&$select=id,displayName,userPrincipalName'
                method: 'GET'
                headers: {
                  ConsistencyLevel: 'eventual'
                }
                authentication: {
                  type: 'ActiveDirectoryOAuth'
                  tenant: '@{variables(\'Tenant ID\')}'
                  audience: 'https://graph.microsoft.com'
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
            Parse_JSON_Source_Group_Members_final_count: {
              runAfter: {
                Get_HTTP_Source_Group_Members_final_count: [
                  'Succeeded'
                ]
              }
              type: 'ParseJson'
              inputs: {
                content: '@body(\'Get_HTTP_Source_Group_Members_final_count\')'
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
                              displayName: {
                                type: 'string'
                              }
                              userPrincipalName: {
                                type: 'string'
                              }
                            }
                            required: [
                              '@@odata.type'
                              'id'
                              'displayName'
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
            'Append-_Get_final_count_of_source_group': {
              runAfter: {
                Parse_JSON_Source_Group_Members_final_count: [
                  'Succeeded'
                ]
              }
              type: 'AppendToStringVariable'
              inputs: {
                name: 'capture logs'
                value: '\nThe final count of members in  source group [ID - @{items(\'For_each\')?[\'sourceGroup\']}]  is @{body(\'Parse_JSON_Source_Group_Members_final_count\')?[\'@odata.count\']}\n'
              }
            }
            Get_HTTP_Destination_Group_Members_final_count: {
              runAfter: {
                'Append-_Get_final_count_of_source_group': [
                  'Succeeded'
                ]
              }
              type: 'Http'
              inputs: {
                uri: 'https://graph.microsoft.com/v1.0/groups/@{ outputs(\'Current_Pair\')[\'destinationGroup\']}/members?$count=true&$select=id,displayName,userPrincipalName'
                method: 'GET'
                headers: {
                  ConsistencyLevel: 'eventual'
                }
                authentication: {
                  type: 'ActiveDirectoryOAuth'
                  tenant: '@{variables(\'Tenant ID\')}'
                  audience: 'https://graph.microsoft.com'
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
            Parse_JSON_Destination_Group_Members_final_count: {
              runAfter: {
                Get_HTTP_Destination_Group_Members_final_count: [
                  'Succeeded'
                ]
              }
              type: 'ParseJson'
              inputs: {
                content: '@body(\'Get_HTTP_Destination_Group_Members_final_count\')'
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
                              displayName: {
                                type: 'string'
                              }
                              userPrincipalName: {
                                type: 'string'
                              }
                            }
                            required: [
                              '@@odata.type'
                              'id'
                              'displayName'
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
            Append_final_count_of_destination_group: {
              runAfter: {
                Parse_JSON_Destination_Group_Members_final_count: [
                  'Succeeded'
                ]
              }
              type: 'AppendToStringVariable'
              inputs: {
                name: 'capture logs'
                value: '\nThe final count of members in destination group [ID - @{items(\'For_each\')?[\'destinationGroup\']}]  is @{body(\'Parse_JSON_Destination_Group_Members_final_count\')?[\'@odata.count\']}\n\n'
              }
            }
            Set_variable_source_group_count: {
              runAfter: {
                Parse_JSON_Source_Group_Members: [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'source Group count'
                value: '@body(\'Parse_JSON_Source_Group_Members\')?[\'@odata.count\']'
              }
            }
            Set_variable_destination_group_count: {
              runAfter: {
                Parse_JSON_Destination_Group_Members: [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'Destination Group count'
                value: '@body(\'Parse_JSON_Destination_Group_Members\')?[\'@odata.count\']'
              }
            }
          }
          runAfter: {
            variable_Destination_Group_count: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        Get_secret: {
          runAfter: {}
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
        Group_ID_pairs: {
          runAfter: {
            Current_Destination_Group_ID: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Group ID pairs'
                type: 'array'
                value: [
                  {
                    destinationGroup: '7d116558-3c78-4e40-b088-25a5f20f92b4'
                    sourceGroup: 'f035ba56-87f3-45cc-a9fb-1485d9f287ed'
                  }
                  {
                    destinationGroup: 'ac1ed2a0-ef5e-46cd-aef5-26829a1bf9cf'
                    sourceGroup: '11dbfed6-b323-422b-b93f-c73a37e05dbb'
                  }
                ]
              }
            ]
          }
        }
        Group_Source_ID_Pairs: {
          runAfter: {
            variable_file_name_for_sharepoint: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Group Source ID Pairs'
                type: 'string'
                value: 'f035ba56-87f3-45cc-a9fb-1485d9f287ed'
              }
            ]
          }
        }
        Tenant_ID: {
          runAfter: {
            variable_capture_logs: [
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
        'variable-DestinationGroupMembers': {
          runAfter: {
            'variable-SourceGroupMembers': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'DestinationGroupMembers'
                type: 'array'
                value: []
              }
            ]
          }
        }
        'variable-SourceGroupMembers': {
          runAfter: {
            'Array_-_Destination_Group_members_Id_and_UPN': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'SourceGroupMembers'
                type: 'array'
                value: []
              }
            ]
          }
        }
        variable_capture_logs: {
          runAfter: {
            Get_secret: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'capture logs'
                type: 'string'
                value: '                                Azure Logic app : ${workflows_Shell175SCHADOBEGroupMemberReplication_name}\n                                Tenant name:  IAM COE SHELL NOV MOT TENANT\n                                \n\nThe App started at @{utcNow(\'dd/MM/yyyy hh:mm tt\')}\n\n'
              }
            ]
          }
        }
        Compose_Final_logs: {
          runAfter: {
            For_each: [
              'Succeeded'
            ]
          }
          type: 'Compose'
          inputs: '\n@{variables(\'capture logs\')}\n\nEND__________________\n \nOperation of the Logic app completed at @{utcNow(\'dd/MM/yyyy hh:mm tt\')}'
        }
        variable_site_id_sharepoint: {
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
        variable_drive_id_of_SharePoint: {
          runAfter: {
            variable_site_id_sharepoint: [
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
        variable_file_name_for_sharepoint: {
          runAfter: {
            variable_drive_id_of_SharePoint: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'file name'
                type: 'string'
                value: '@{utcNow(\'yyyyMMMdd-hh-mmtt\')}_SCH-ADOBE_Group_Member_Replication_logs.txt'
              }
            ]
          }
        }
        variable_source_Group_count: {
          runAfter: {
            'variable-DestinationGroupMembers': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'source Group count'
                type: 'integer'
              }
            ]
          }
        }
        variable_Destination_Group_count: {
          runAfter: {
            variable_source_Group_count: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Destination Group count'
                type: 'integer'
              }
            ]
          }
        }
        HTTP_upload_logs_to_sharepoint_app: {
          runAfter: {
            Compose_Final_logs: [
              'Succeeded'
            ]
          }
          type: 'Http'
          inputs: {
            uri: 'https://graph.microsoft.com/v1.0/sites/@{variables(\'site id\')}/drives/@{variables(\'drive id\')}/root:/Shell-175-SCH-ADOBE_Group_Member_Replication/@{variables(\'file name\')}:/content'
            method: 'PUT'
            headers: {
              'Content-Type': 'text/plain'
            }
            body: '@outputs(\'Compose_Final_logs\')'
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
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          'keyvault-1': {
            id: '/subscriptions/d6abefe9-d8b8-4f4c-880b-1c7f6992b04d/providers/Microsoft.Web/locations/westeurope/managedApis/keyvault'
            connectionId: connections_keyvault_3_externalid
            connectionName: 'keyvault-3'
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
