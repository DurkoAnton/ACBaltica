using RequestApprovalService as service from '../../srv/RequestApprovalService';

annotate service.RequestApproval with @(UI.LineItem: [
    {
        $Type: 'UI.DataField',
        Label: 'Customer ID',
        Value: Customer.InternalID,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Customer',
        Value: currentData_CustomerFormattedName,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Status',
        Value: Status_code,
    },
     {
        $Type: 'UI.DataField',
        Label: 'Responsible manager',
        Value: currentData_ResponsibleManager,
    },
     {
        $Type: 'UI.DataField',
        Label: 'Created At',
        Value: CreationDateTime,
    },
]);

annotate service.RequestApproval with @(
    UI.Facets                       : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'GeneratedFacet1',
            Label : 'Customer Information',
            Target: '@UI.FieldGroup#GeneratedGroup1',
        },
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'CompareData',
            Label : 'General Information',
            Facets: [

                {
                    $Type                   : 'UI.ReferenceFacet',
                    Label                   : 'Current Data',
                    ID                      : 'OldData',
                    Target                  : '@UI.FieldGroup#OldData',
                    ![@Common.FieldControl] : #ReadOnly,
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'New Data',
                    ID    : 'NewData',
                    Target: '@UI.FieldGroup#NewData',
                },

            ],
            ![@UI.Hidden] : {$edmJson : {$Eq : [{$Path : 'CustomerID'},'']}}
        },
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'CompareJurAddressData',
            Label : 'Juridical Address Information',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Current Address Data',
                    ID    : 'OldJurAddressData',
                    Target: '@UI.FieldGroup#OldJurAddressData',

                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'New Address Data',
                    ID    : 'NewJurAddressData',
                    Target: '@UI.FieldGroup#NewJurAddressData',
                },
            ],
            ![@UI.Hidden] : {$edmJson : {$Eq : [{$Path : 'CustomerID'},'']}}
        },
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'ComparePostalAddressData',
            Label : 'Postal Address Information',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Current Postal Address Data',
                    ID    : 'OldPostalAddressData',
                    Target: '@UI.FieldGroup#OldPostalAddressData',
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'New Postal Address Data',
                    ID    : 'NewPostalAddressData',
                    Target: '@UI.FieldGroup#NewPostalAddressData',
                },
            ],
            ![@UI.Hidden] : {$edmJson : {$Eq : [{$Path : 'CustomerID'},'']}}
        },


    ],
    UI.FieldGroup #OldData          : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type                   : 'UI.DataField',
                Label                   : 'Customer Name',
                Value                   : currentData_CustomerFormattedName,
                ![@Common.FieldControl] : #ReadOnly,
            },
            // {
            //     $Type                   : 'UI.DataField',
            //     Label                   : 'Responsible Manager',
            //     Value                   : currentData_ResponsibleManager,
            //     ![@Common.FieldControl] : #ReadOnly,
            // },
            {
                $Type                   : 'UI.DataField',
                Label                   : 'Status',
                Value                   : currentStatusCode_code,
                ![@Common.FieldControl] : #ReadOnly,
            },
            {
                $Type                   : 'UI.DataField',
                Label                   : 'Note',
                Value                   : currentData_Note,
                ![@Common.FieldControl] : #ReadOnly,
            },
        ]
    },
    UI.FieldGroup #OldJurAddressData: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type                   : 'UI.DataField',
                Label                   : 'Country',
                Value                   : currentCountry_code,
                ![@Common.FieldControl] : #ReadOnly,
            },
            {
                $Type                   : 'UI.DataField',
                Label                   : 'City',
                Value                   : currentData_JuridicalCity,
                ![@Common.FieldControl] : #ReadOnly,
            },
            {
                $Type                   : 'UI.DataField',
                Label                   : 'Street',
                Value                   : currentData_JuridicalStreet,
                ![@Common.FieldControl] : #ReadOnly,
            },
            {
                $Type                   : 'UI.DataField',
                Label                   : 'House',
                Value                   : currentData_JuridicalHomeID,
                ![@Common.FieldControl] : #ReadOnly,
            },
            {
                $Type                   : 'UI.DataField',
                Label                   : 'Room',
                Value                   : currentData_JuridicalRoomID,
                ![@Common.FieldControl] : #ReadOnly,
            },
        ]
    },
    UI.FieldGroup #OldPostalAddressData: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Postal Box',
                Value: currentData_POBox,
                ![@Common.FieldControl] : #ReadOnly,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Postal Country',
                Value: currentPOBoxCountry_code,
                ![@Common.FieldControl] : #ReadOnly,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Postal Code',
                Value: currentData_POBoxPostalCode,
                ![@Common.FieldControl] : #ReadOnly,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Postal City',
                Value: currentData_POBoxCity,
                ![@Common.FieldControl] : #ReadOnly,
            },
        ]
    },
    UI.FieldGroup #NewJurAddressData: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Country',
                Value: newCountry_code,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'City',
                Value: newData_JuridicalCity,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Street',
                Value: newData_JuridicalStreet,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'House',
                Value: newData_JuridicalHomeID,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Room',
                Value: newData_JuridicalRoomID,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
        ]
    },
    UI.FieldGroup #NewPostalAddressData: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Postal Box',
                Value: newData_POBox,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Postal Country',
                Value: newPOBoxCountry_code,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Postal Code',
                Value: newData_POBoxPostalCode,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Postal City',
                Value: newData_POBoxCity,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
        ]
    },
    UI.FieldGroup #NewData          : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Customer Name',
                Value: newData_CustomerFormattedName,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
            // {
            //     $Type: 'UI.DataField',
            //     Label: 'Responsible Manager',
            //     Value: newData_ResponsibleManager,
            //     ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            // },
            {
                $Type: 'UI.DataField',
                Label: 'Status',
                Value: newStatusCode_code,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
            {
                $Type                   : 'UI.DataField',
                Label                   : 'Note',
                Value                   : newData_Note,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
        ]
    },

    UI.FieldGroup #GeneratedGroup1  : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Customer',
                Value: CustomerID,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'Status_code'}, '1' ]}, 3, 1 ]}},
            },
            {
                $Type                   : 'UI.DataField',
                Label                   : 'Customer ID',
                Value                   : Customer.InternalID,
                ![@Common.FieldControl] : #ReadOnly,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Responsible manager',
                Value: currentData_ResponsibleManager,
                ![@Common.FieldControl] : #ReadOnly,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Status',
                Value: Status_code,
            },
            {
                $Type: 'UI.DataField',
                Value: CreationDateTime,
            },
            
        ],
    },
);

annotate service.RequestApproval with {
    CustomerID        @(Common: {
        Text           : Customer.CustomerFormattedName,
        TextArrangement: #TextOnly,
        ValueList      : {
            CollectionPath: 'Customer',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: 'CustomerID',
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'CustomerFormattedName',
                    LocalDataProperty: currentData_CustomerFormattedName,![@UI.Hidden]:true,
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ResponsibleManager',
                    LocalDataProperty: currentData_ResponsibleManager
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'Note',
                    LocalDataProperty: currentData_Note
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'Status_code',
                    LocalDataProperty: currentStatusCode_code
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalCountry_code',
                    LocalDataProperty: currentCountry_code
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalAddress_City',
                    LocalDataProperty: currentData_JuridicalCity
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalAddress_Street',
                    LocalDataProperty: currentData_JuridicalStreet
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalAddress_HomeID',
                    LocalDataProperty: currentData_JuridicalHomeID
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalAddress_RoomID',
                    LocalDataProperty: currentData_JuridicalRoomID
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'POBox',
                    LocalDataProperty: currentData_POBox
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'POBoxCity',
                    LocalDataProperty: currentData_POBoxCity
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'POBoxPostalCode',
                    LocalDataProperty: currentData_POBoxPostalCode
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'POBoxCountry_code',
                    LocalDataProperty: currentPOBoxCountry_code
                },
                
                //copy to new values
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'CustomerFormattedName',
                    LocalDataProperty: newData_CustomerFormattedName
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ResponsibleManager',
                    LocalDataProperty: newData_ResponsibleManager
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'Note',
                    LocalDataProperty: newData_Note
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'Status_code',
                    LocalDataProperty: newStatusCode_code
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalCountry_code',
                    LocalDataProperty: newCountry_code
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalAddress_City',
                    LocalDataProperty: newData_JuridicalCity
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalAddress_Street',
                    LocalDataProperty: newData_JuridicalStreet,
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalAddress_HomeID',
                    LocalDataProperty: newData_JuridicalHomeID
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalAddress_RoomID',
                    LocalDataProperty: newData_JuridicalRoomID
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ObjectID',
                    LocalDataProperty: CustomerObjectID
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'POBox',
                    LocalDataProperty: newData_POBox
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'POBoxCity',
                    LocalDataProperty: newData_POBoxCity
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'POBoxPostalCode',
                    LocalDataProperty: newData_POBoxPostalCode
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'POBoxCountry_code',
                    LocalDataProperty: newPOBoxCountry_code
                },
            ]
        }
    });
    currentCountry    @(Common: {
        Text           : currentCountry.name,
        TextArrangement: #TextLast,
    });
    newCountry        @(Common: {
        Text           : newCountry.name,
        TextArrangement: #TextLast,
        ValueListWithFixedValues : true,
        ValueList      : {
            CollectionPath: 'Countries',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: newCountry_code
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                },
            ]
        }
    });
    currentStatusCode @(Common: {
        Text           : currentStatusCode.name,
        TextArrangement: #TextLast,
    });
    newStatusCode     @(Common: {
        Text                    : newStatusCode.name,
        TextArrangement         : #TextLast,
        ValueListWithFixedValues: true,
        ValueList               : {
            CollectionPath: 'StatusCodes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: newStatusCode_code
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                },
            ]
        }
    });
    Status            @(Common: {
        Text                    : Status.name,
        TextArrangement         : #TextLast,
        ValueListWithFixedValues: true,
        ValueList               : {
            CollectionPath: 'RequestApprovalStatusCodes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: Status_code
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                },
            ]
        }
    });
    currentPOBoxCountry@(Common: {
        Text                    : currentPOBoxCountry.name,
        TextArrangement         : #TextLast,
        ValueListWithFixedValues: true,
    }); 
    newPOBoxCountry@(Common: {
        Text                    : newPOBoxCountry.name,
        TextArrangement         : #TextLast,
        ValueListWithFixedValues: true,
    }); 
};
annotate service.Customer with {
    ID @UI.Hidden;
    ObjectID @UI.Hidden;
    JuridicalCountry @(Common: {
        Text                    : JuridicalCountry.name,
        TextArrangement         : #TextFirst,
    }); 
    Status @(Common: {
        Text                    : Status.name,
        TextArrangement         : #TextFirst,
    }); 
  POBox @UI.Hidden;
    POBoxPostalCode @UI.Hidden;
    POBoxCity @UI.Hidden;
    POBoxCountry @UI.Hidden;
};

// annotate service.RequestApproval with {
//     CustomerID @UI.Hidden;
// };


// annotate service.ServiceRequest @(Common: {SideEffects #CustomerChanged: {
//     SourceProperties: ['CustomerID'],
//     TargetEntities  : [Customer]
// }});
// annotate service.RequestApproval @(Common: {SideEffects #StatusChanged: {
//     SourceProperties: ['Customer/Status_code'],
//     TargetEntities  : [Customer.Status]
// }});
annotate service.RequestApproval with @(UI.Identification: [
    {
        $Type : 'UI.DataFieldForAction',
        Action: 'RequestApprovalService.sendRequestForApproval',
        Label : 'Send Approval Request',
        ![@UI.Hidden] : {$edmJson : {$Ne : [{$Path : 'Status_code'},'1']}}
    },
]);

annotate service.RequestApproval with @(UI.HeaderInfo: {
    TypeName      : 'Request for Approval',
    TypeNamePlural: 'Request for Approvals',
    Title         : {
        $Type: 'UI.DataField',
        Value: Customer.CustomerFormattedName,
    }
});

annotate service.RequestApproval with @(UI.SelectionFields: [CustomerID, ]);
annotate service.Customer with @(UI.SelectionFields: [ID, ]);
annotate service.RequestApproval with {
    CustomerID @Common.Label: '{i18n>CustomerID}';
    newData { 
        Note @mandatory;
    }; 
};

annotate service.RequestApproval with {
    CustomerID @Common:{
        SemanticObject : 'Customer',
         SemanticObjectMapping : [
            {
                $Type : 'Common.SemanticObjectMappingType',
                LocalProperty : 'ID',
                SemanticObjectProperty : 'none',
            },
           {
                $Type : 'Common.SemanticObjectMappingType',
                LocalProperty : 'Status_code',
                SemanticObjectProperty : 'none',
            },
            //  {
            //     $Type : 'Common.SemanticObjectMappingType',
            //     LocalProperty : 'Customer/CustomerFormattedName',
            //     SemanticObjectProperty : 'none',
            // },
        ], 
    }
};
