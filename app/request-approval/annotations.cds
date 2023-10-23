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
                Label : 'Customer Name Old',
                Value : currentData_CustomerFormattedName,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Responsible Manager Old',
                Value : currentData_ResponsibleManager,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Status Old',
                Value : currentData_StatusCode_code,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Status Old descr',
                Value : currentData_StatusDescription,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Note Old',
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
                Label : 'Country Old',
                Value : currentData_JuridicalCountry_code,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'City Old',
                Value : currentData_JuridicalCity,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Street Old',
                Value : currentData_JuridicalStreet,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'House Old',
                Value : currentData_JuridicalHomeID,
                 ![@Common.FieldControl]: #ReadOnly,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Room Old',
                Value : currentData_JuridicalRoomID,
                 ![@Common.FieldControl]: #ReadOnly,
            },
        ]},
         UI.FieldGroup #NewJurAddressData :{
        $Type : 'UI.FieldGroupType',
        Data : [
   { 
                $Type : 'UI.DataField',
                Label : 'Country New',
                Value : newData_JuridicalCountry_code,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'City New',
                Value : newData_JuridicalCity,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Street New',
                Value : newData_JuridicalStreet,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'House New',
                Value : newData_JuridicalHomeID,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Room New',
                Value : newData_JuridicalRoomID,
            },
        ]},

    UI.FieldGroup #NewData :{
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'Customer Name New',
                Value : newData_CustomerFormattedName,
            },
            { 
                $Type : 'UI.DataField',
                Label : 'Responsible Manager New',
                Value : newData_ResponsibleManager,
            },
             { 
                $Type : 'UI.DataField',
                Label : 'Status New',
                Value : newData_StatusCode_code,
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

// annotate service.Customer with {
//     Status  @(Common: {
//         Text           : Status.name,
//         TextArrangement: #TextLast,
//     })
// };

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
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'Status/name',
                    LocalDataProperty: currentData_StatusDescription
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'Status_code',
                    LocalDataProperty: currentData_StatusCode_code
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalAddress_Country_code',
                    LocalDataProperty: currentData_JuridicalCountry_code
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
                    ValueListProperty: 'StatusDescription',
                    LocalDataProperty: newData_StatusDescription
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'Status_code',
                    LocalDataProperty: newData_StatusCode_code
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'JuridicalAddress_Country_code',
                    LocalDataProperty: newData_JuridicalCountry_code
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
    // currentData {
    //     StatusCode 
    // }

    
    // currentData_StatusCode @(Common :{
    //             Text            : StatusDescription,
    //             TextArrangement : #TextLast,
    //         });
   // };
    //  newData{
    //     StatusCode @(Common :{
    //             Text            : StatusDescription,
    //             TextArrangement : #TextLast,
    //       ValueList      : {
    //         CollectionPath: 'Customer',
    //         Parameters    : [
    //             {
    //                 $Type            : 'Common.ValueListParameterInOut',
    //                 ValueListProperty: 'ID',
    //                 LocalDataProperty: StatusCode_code
    //             },
    //             {
    //                 $Type            : 'Common.ValueListParameterOut',
    //                 ValueListProperty: 'name',
    //                 LocalDataProperty: StatusDescription
    //             },
    //         ]
    //       }
    //     });
    //     // JuridicalCountry @(Common :{
    //     //         Text            : JuridicalCountry_name,
    //     //         TextArrangement : #TextLast,
    //     //     });
    // };
  
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

