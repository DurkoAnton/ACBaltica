using RequestApprovalService as service from '../../srv/RequestApprovalService';

annotate service.RequestApproval with @(
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'CustomerID',
            Value : Customer.InternalID,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Customer',
            Value : currentData_CustomerFormattedName,
        },
    ]
);
annotate service.RequestApproval with @(
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'Customer Information',
            Target : '@UI.FieldGroup#GeneratedGroup1',
        },
        {
            $Type : 'UI.CollectionFacet',
            ID : 'CompareData',
            Label : 'Old/New General Information',
            Facets: [

                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Old Data',
                    ID    : 'OldData',
                    Target: '@UI.FieldGroup#OldData',
                    ![@Common.FieldControl]: #ReadOnly,
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'New Data',
                    ID    : 'NewData',
                    Target: '@UI.FieldGroup#NewData',
                },
                
            ],
        },
            {
                $Type : 'UI.CollectionFacet',
                ID : 'CompareJurAddressData',
                Label : 'Old/New Address Information',
                Facets: [
                    {
                        $Type : 'UI.ReferenceFacet',
                        Label : 'Old Address Data',
                        ID    : 'OldJurAddressData',
                        Target: '@UI.FieldGroup#OldJurAddressData',
                       
                    },
                    {
                        $Type : 'UI.ReferenceFacet',
                        Label : 'New Address Data',
                        ID    : 'NewJurAddressData',
                        Target: '@UI.FieldGroup#NewJurAddressData',
                    },
                ]
            },
            
            
    ],
    UI.FieldGroup #OldData :{
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'Customer Name',
                Value : currentData_CustomerFormattedName,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Responsible Manager',
                Value : currentData_ResponsibleManager,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Status',
                Value : currentStatusCode_code,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Note',
                Value : currentData_Note,
                 ![@Common.FieldControl]: #ReadOnly,
            },
        ]
    },
    UI.FieldGroup #OldJurAddressData :{
        $Type : 'UI.FieldGroupType',
        Data : [
   { 
                $Type : 'UI.DataField',
                Label : 'Country',
                Value : currentCountry_code,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'City',
                Value : currentData_JuridicalCity,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Street',
                Value : currentData_JuridicalStreet,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'House',
                Value : currentData_JuridicalHomeID,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Room',
                Value : currentData_JuridicalRoomID,
                 ![@Common.FieldControl]: #ReadOnly,
            },
        ]},
         UI.FieldGroup #NewJurAddressData :{
        $Type : 'UI.FieldGroupType',
        Data : [
   { 
                $Type : 'UI.DataField',
                Label : 'Country',
                Value : newCountry_code,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'City',
                Value : newData_JuridicalCity,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Street',
                Value : newData_JuridicalStreet,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'House',
                Value : newData_JuridicalHomeID,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Room',
                Value : newData_JuridicalRoomID,
            },
        ]},

    UI.FieldGroup #NewData :{
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'Customer Name',
                Value : newData_CustomerFormattedName,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Responsible Manager',
                Value : newData_ResponsibleManager,
            },
             { 
                $Type : 'UI.DataField',
                Label : 'Status',
                Value : newStatusCode_code,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Note',
                Value : newData_Note,
                ![@Common.FieldControl]: #Mandatory,
            },
        ]
    },
    
    UI.FieldGroup #GeneratedGroup1 : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'Customer',
                Value : CustomerID,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Customer ID',
                Value : Customer.InternalID,
                ![@Common.FieldControl]: #ReadOnly,
            }
        ],
    },
);

annotate service.RequestApproval with {
    CustomerID  @(Common: {
        Text           : Customer.CustomerFormattedName,
        TextArrangement: #TextOnly,
        ValueList      : {
            CollectionPath: 'Customer',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: CustomerID
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'CustomerFormattedName',
                    LocalDataProperty: currentData_CustomerFormattedName
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
                // {
                //     $Type            : 'Common.ValueListParameterOut',
                //     ValueListProperty: 'Status/name',
                //     LocalDataProperty: currentStatusDescription
                // },
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
                //  {
                //     $Type            : 'Common.ValueListParameterOut',
                //     ValueListProperty: 'JuridicalCountry/name',
                //     LocalDataProperty: currentCountryDescription
                // },
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
                // {
                //     $Type            : 'Common.ValueListParameterOut',
                //     ValueListProperty: 'Status/name',
                //     LocalDataProperty: newStatusDescription
                // },
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
                    LocalDataProperty: newData_JuridicalStreet
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
            ]
        }
    });
    currentCountry @(Common:{
        Text : currentCountry.name,
        TextArrangement : #TextLast,
    });
     newCountry @(Common:{
        Text : newCountry.name,
        TextArrangement : #TextLast,
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
    currentStatusCode @(Common:{
        Text : currentStatusCode.name,
        TextArrangement : #TextLast,
    });
    newStatusCode @(Common:{
        Text : newStatusCode.name,
        TextArrangement : #TextLast,
        ValueListWithFixedValues:true,
         ValueList      : {
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
  
};

// annotate service.ServiceRequest @(Common: {SideEffects #CustomerChanged: {
//     SourceProperties: ['CustomerID'],
//     TargetEntities  : [Customer]
// }});
// annotate service.RequestApproval @(Common: {SideEffects #StatusChanged: {
//     SourceProperties: ['Customer/Status_code'],
//     TargetEntities  : [Customer.Status]
// }});
annotate service.RequestApproval with @(UI.Identification: [{
    $Type : 'UI.DataFieldForAction',
    Action: 'RequestApprovalService.sendRequestForApproval',
    Label : 'Send Approval Request'
}]);
annotate service.RequestApproval with @(UI.HeaderInfo: {
    TypeName      : 'Request for Approval',
    TypeNamePlural: 'Request for Approvals',
    Title         : {
        $Type: 'UI.DataField',
        Value: Customer.CustomerFormattedName,
    }
});

