using PartnerService as service from '../../srv/partnerservice';

annotate service.Customer with @(
    UI.LineItem: [
        {
            $Type: 'UI.DataField',
            Label: '{i18n>InternalID}',
            Value: InternalID,
        },
        {
            $Type: 'UI.DataField',
            Value: CustomerFormattedName
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Status}',
            Value: Status_code
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>ResponsibleManager}',
            Value: ResponsibleManager
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Country}',
            Value: JuridicalCountry.name
        },
        {
            $Type: 'UI.DataField',
            Label: 'City',
            Value: JuridicalAddress_City
        },
        {
            $Type: 'UI.DataField',
            Label: 'Street',
            Value: JuridicalAddress_Street
        },
        {
            $Type: 'UI.DataField',
            Label: 'House ID',
            Value: JuridicalAddress_HomeID
        },
        {
            $Type: 'UI.DataField',
            Label: 'Room ID',
            Value: JuridicalAddress_RoomID
        },
        {
            $Type: 'UI.DataField',
            Label: 'Note',
            Value: Note
        },

    ],
    UI.Facets  : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'GeneratedFacet1',
            Label : '{i18n>GeneralInformation}',
            Target: '@UI.FieldGroup#GeneratedGroup1',
        },
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>AddressInformation}',
            ID    : 'AddressInformation',
            Facets: [

                // {
                //     $Type : 'UI.ReferenceFacet',
                //     Label : '{i18n>IndividualAddress}',
                //     ID    : 'AddressInformationIndividual',
                //     Target: '@UI.FieldGroup#AddressInformationIndividual',
                // },
                { 
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Postal Address',
                    ID    : 'AddressInformationPostal',
                    Target: '@UI.FieldGroup#AddressInformationPostal',
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : '{i18n>JuridicalAddress}',
                    ID    : 'AddressInformationJuridical',
                    Target: '@UI.FieldGroup#AddressInformationJuridical',
                }
            ]
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Opportunities',
            ID    : 'Opportunities',
            Target: 'ToOpportunities/@UI.LineItem#Opportunities',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Service Requests',
            ID    : 'ServiceRequests',
            Target: 'ToServiceRequests/@UI.LineItem#ServiceRequests',
        },
        // {
        //     $Type : 'UI.ReferenceFacet',
        //     Label : 'Bank Information',
        //     Target: 'BankData/@UI.LineItem#Banks'
        // }
    ],

);

annotate service.Bank with @(UI.LineItem #Banks: [
    {
        $Type                 : 'UI.DataField',
        Label                 : '{i18n>BankCode}',
        Value                 : BankCode,
        ![@HTML5.CssDefaults] : {width: '25%'}

    },
    {
        $Type                 : 'UI.DataField',
        Label                 : '{i18n>BankAccount}',
        Value                 : BankAccount,
        ![@HTML5.CssDefaults] : {width: '25%'}

    },
    {
        $Type                 : 'UI.DataField',
        Label                 : '{i18n>SWIFT}',
        Value                 : SWIFT,
        ![@HTML5.CssDefaults] : {width: '25%'}

    },
    {
        $Type                 : 'UI.DataField',
        Label                 : '{i18n>IBAN}',
        Value                 : IBAN,
        ![@HTML5.CssDefaults] : {width: '25%'}

    },
]);

annotate service.Bank with @(UI.HeaderInfo: {
    TypeName      : '{i18n>BankRecord}',
    TypeNamePlural: '{i18n>BankRecords}',
    Title         : {
        $Type: 'UI.DataField',
        Value: BankAccount,
    },
});

annotate service.Customer with @(UI.HeaderInfo: {
    TypeName      : 'Customer',
    TypeNamePlural: 'Customers',
    Title         : {
        $Type: 'UI.DataField',
        Value: CustomerFormattedName,
    },
});

annotate service.Customer with @(UI.FieldGroup #GeneratedGroup1: {
    $Type: 'UI.FieldGroupType',
    Data : [
        {
            $Type: 'UI.DataField',
            Value: CustomerFormattedName,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 
        },
        {
            $Type: 'UI.DataField',
            Label: 'Internal ID',
            Value: InternalID,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Status}',
            Value: Status_code,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>ResponsibleManager}',
            Value: ResponsibleManager,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Note}',
            Value: Note,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        },
    ]
}, );

annotate service.Opportunity with @(UI.LineItem #Opportunities: [
    {
        $Type: 'UI.DataField',
        Label: 'Internal ID',
        Value: InternalID,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Subject',
        Value: Subject,
    },
    // {
    //     $Type: 'UI.DataField',
    //     Label: 'Customer',
    //     Value: ProspectPartyID,
    // },
    {
        $Type: 'UI.DataField',
        Label: 'Status',
        Value: LifeCycleStatusCode.name,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Responsible Employee',
        Value: MainEmployeeResponsiblePartyName,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Not Stadard Request',
        Value: NotStandartRequest,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Customer Comment',
        Value: CustomerComment,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Changed At',
        Value: LastChangeDateTime,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Changed By',
        Value: LastChangedBy,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Created At',
        Value: CreationDateTime,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Created By',
        Value: CreatedBy,
    },
], );

annotate service.Opportunity with @(UI.HeaderInfo: {
    TypeName      : 'Opportunity',
    TypeNamePlural: 'Opportunities',
    Title         : {
        $Type: 'UI.DataField',
        Value: Subject,
    }
});

annotate service.Opportunity with @(
    UI.Facets                 : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'General Info',
            ID    : 'GeneralInfo',
            Target: '@UI.FieldGroup#GeneralInfo',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Parties',
            ID    : 'Parties',
            Target: '@UI.FieldGroup#Parties',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Items',
            Target: 'Items/@UI.LineItem#Items'
        },
        {
            $Type         : 'UI.ReferenceFacet',
            Label         : 'Attachments',
            ID            : 'Attachments',
            Target        : 'Attachment/@UI.LineItem#Attachments',
            ![@UI.Hidden] : {$edmJson: {$Eq: [
                {$Path: 'NotStandartRequest'},
                false
            ]}}
        },
    ],
    UI.FieldGroup #GeneralInfo: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: InternalID,
                Label: 'Internal ID',
            },
            {
                $Type: 'UI.DataField',
                Value: Subject,
                Label: 'Subject',
            },
            {
                $Type: 'UI.DataField',
                Value: LifeCycleStatusCode_code,
                Label: 'Status',
            },
            {
                $Type: 'UI.DataField',
                Label: 'Not Standart Request',
                Value: NotStandartRequest,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Customer Comment',
                Value: CustomerComment,
            },
            {
                $Type: 'UI.DataField',
                Value: CreationDateTime,
                Label: 'Created At',
            },
            {
                $Type: 'UI.DataField',
                Value: LastChangeDateTime,
                Label: 'Changed At',
            },

        ],
    },
    UI.FieldGroup #Parties    : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: ProspectPartyID,
                Label: 'Customer',
            },
            {
                $Type: 'UI.DataField',
                Value: MainEmployeeResponsiblePartyName,
                Label: 'Employee Responsible',
            },
        ]
    }
);


annotate service.Item with @(
    UI.LineItem #Items: [
        {
            $Type: 'UI.DataField',
            Label: 'Product',
            Value: ItemProductID,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Internal ID',
            Value: toItemProduct.InternalID,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Product Category',
            Value: toItemProduct.ProductCategory,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Product Status',
            Value: toItemProduct.ProductStatus,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Unit Measure',
            Value: toItemProduct.UnitMeasure,
        },
    ],
    UI.Facets         : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Sales Price Lists',
        Target: 'toItemProduct/SalesPriceLists/@UI.LineItem#SalesPriceLists'
    }, ],
);

annotate service.SalesPriceList with @(UI.LineItem #SalesPriceLists: [
    {
        $Type: 'UI.DataField',
        Value: PriceListID,
        Label: 'Price List ID',
    },
    {
        $Type: 'UI.DataField',
        Value: Amount,
        Label: 'Amount',
    },
    {
        $Type: 'UI.DataField',
        Value: AmountCurrencyCode_code,
        Label: 'Amount',
    },
    {
        $Type: 'UI.DataField',
        Value: PriceUnitContent,
        Label: 'Price Unit',
    },
    {
        $Type: 'UI.DataField',
        Value: PriceUnitCode,
        Label: 'Price Unit',
    }
]);

// annotate service.Customer with @(UI.FieldGroup #AddressInformationIndividual: {
//     $Type: 'UI.FieldGroupType',
//     Data : [
//         {
//             $Type: 'UI.DataField',
//             Label: '{i18n>Country}',
//             Value: IndividualCountry_code,
//             ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
//         },
//         {
//             $Type: 'UI.DataField',
//             Label: '{i18n>City}',
//             Value: IndividualAddress_City,
//             ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
//         },
//         {
//             $Type: 'UI.DataField',
//             Label: '{i18n>Street}',
//             Value: IndividualAddress_Street,
//             ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
//         },
//         {
//             $Type: 'UI.DataField',
//             Label: '{i18n>HomeID}',
//             Value: IndividualAddress_HomeID,
//             ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
//         },
//         {
//             $Type: 'UI.DataField',
//             Label: '{i18n>RoomID}',
//             Value: IndividualAddress_RoomID,
//             ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
//         }
//     ]
// });

annotate service.Customer with @(UI.FieldGroup #AddressInformationJuridical: {
    $Type: 'UI.FieldGroupType',
    Data : [
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Country}',
            Value: JuridicalCountry_code,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>City}',
            Value: JuridicalAddress_City,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Street}', 
            Value: JuridicalAddress_Street,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>HomeID}',
            Value: JuridicalAddress_HomeID,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>RoomID}',
            Value: JuridicalAddress_RoomID,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        },
    ]
});
annotate service.Customer with @(UI.FieldGroup #AddressInformationPostal: {
    $Type: 'UI.FieldGroupType',
    Data : [
         {
            $Type: 'UI.DataField',
            Label: 'Postal Box',
            Value: POBox,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},

        },
        {
            $Type: 'UI.DataField',
            Label: 'Postal Country',
            Value: POBoxCountry_code,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},

        },
         {
            $Type: 'UI.DataField',
            Label: 'Postal Region',
            Value: POBoxState_code,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},

        },
        {
            $Type: 'UI.DataField',
            Label: 'Postal City',
            Value: POBoxCity,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        }
    ]
});

annotate service.Customer with @(
                                 // UI.HeaderFacets : [
                                 //     {
                                 //         $Type : 'UI.ReferenceFacet',
                                 //         Label : '{i18n>CustomerHeaderInfo}',
                                 //         ID : 'ImportantInfo',
                                 //         Target : '@UI.FieldGroup#ImportantInfo',
                                 //     },

                                 // ],
                               UI.FieldGroup #ImportantInfo: {
    $Type: 'UI.FieldGroupType',
    Data : [
        {
            $Type: 'UI.DataField',
            Value: InternalID,
            Label: '{i18n>InternalID}'
        },
        {
            $Type: 'UI.DataField',
            Value: CustomerFormattedName
        }
    ],
});

annotate service.ServiceRequest with @(UI.LineItem #ServiceRequests: [
    {
        $Type: 'UI.DataField',
        Value: InternalID,
        Label: '{i18n>InternalID}',
    },
    {
        $Type: 'UI.DataField',
        Value: Status_code,
        Label: '{i18n>Status}',
    },
    {
        $Type: 'UI.DataField',
        Value: Category_code,
        Label: 'Category',
    },
    {
        $Type: 'UI.DataField',
        Value: ProblemDescription,
        Label: '{i18n>ProblemDescription}',
    },
    {
        $Type: 'UI.DataField',
        Value: Processor,
        Label: '{i18n>Processor}',
    },
    {
        $Type: 'UI.DataField',
        Value: RequestProcessingTime,
        Label: '{i18n>RequestProcessingTime}',
    },
    {
        $Type: 'UI.DataField',
        Value: OrderID,
        Label: '{i18n>OrderID}',
    },
    {
        $Type: 'UI.DataField',
        Value: CreationDate,
        Label: 'Created At',
    },
    {
        $Type: 'UI.DataField',
        Value: LastChangingDate,
        Label: 'Changed At',
    },
], );

annotate service.ServiceRequest with @(UI.HeaderInfo: {
    TypeName      : '{i18n>ServiceRequest}',
    TypeNamePlural: '{i18n>ServiceRequests}',
    Title         : {
        $Type: 'UI.DataField',
        Label: '{i18n>ProblemDescription}',
        Value: ProblemDescription,
    }
}, );

annotate service.Bank with @(
    UI.Facets                     : [{
        $Type : 'UI.ReferenceFacet',
        Label : '{i18n>GeneralInfo}',
        ID    : 'GeneralInfo',
        Target: '@UI.FieldGroup#GeneralInfoBank',
    }],
    UI.FieldGroup #GeneralInfoBank: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: ID,
                Label: '{i18n>ID}',
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>BankCode}',
                Value: BankCode,
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>BankAccount}',
                Value: BankAccount,
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>SWIFT}',
                Value: SWIFT,
            },
            {
                $Type: 'UI.DataField',
                Label: '{i18n>IBAN}',
                Value: IBAN,
            },
        ]
    },
);

annotate service.ServiceRequest with @(
    UI.FieldGroup #GeneralInfoSR: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Internal ID',
                Value: InternalID,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Status',
                Value: Status_code,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Problem Description',
                Value: ProblemDescription,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Category',
                Value: Category_code,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Request Processing Time',
                Value: RequestProcessingTime,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Creation Date',
                Value: CreationDate,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Last Changing Date',
                Value: LastChangingDate,
            },
        ],
    },
     UI.FieldGroup #TimeProcessing      : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Request Date',
                Value: RequestInitialDateTime,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Last Changing Date',
                Value: LastChangingDate,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Request End Date',
                Value: RequestEndDateTime,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Resolution Date',
                Value: ResolutionDateTime,
            },
            
        ]
    },
    UI.FieldGroup #Parties      : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Customer',
                Value: Customer.CustomerFormattedName,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Processor',
                Value: Processor,
            },
        ]
    },
    UI.FieldGroup #ProblemItem  : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Order ID',
                Value: OrderID,
            },
            {
                $Type: 'UI.DataField',
                Label: 'Problem Item',
                Value: ProblemItem,
            },
        ]
    },
    UI.Facets                   : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'GeneralInfo',
            Label : 'General Information',
            Target: '@UI.FieldGroup#GeneralInfoSR',
        },
         {
            $Type : 'UI.ReferenceFacet',
            Label : 'Time Processing',
            ID    : 'TimeProcessing',
            Target: '@UI.FieldGroup#TimeProcessing',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Parties',
            ID    : 'Parties',
            Target: '@UI.FieldGroup#Parties',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Problem Item',
            ID    : 'ProblemItem',
            Target: '@UI.FieldGroup#ProblemItem',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Attachments',
            ID    : 'Attachments',
            Target: 'Attachment/@UI.LineItem#Attachments',
        },
    ]
);

annotate service.Attachement with @(UI.LineItem #Attachments: [
    {
        $Type: 'UI.DataField',
        Value: content,
        Label: 'Content',
    },
    {
        $Type: 'UI.DataField',
        Value: mediaType,
        Label: 'Media type',
    },
    {
        $Type: 'UI.DataField',
        Value: CreationDateTime,
    },
]);

annotate service.Customer with {
    Status      @(Common: {
        Text                    : Status.name,
        TextArrangement         : #TextLast,
        ValueListWithFixedValues: true,
        ValueList               : {
            CollectionPath: 'StatusCodes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: Status_code
                },
                // {
                //     $Type            : 'Common.ValueListParameterOut',
                //     ValueListProperty: 'name',
                //     LocalDataProperty: Status.name
                // },
            ]
        }
    });
    JuridicalAddress {
        Country @(Common: {
            Text           : '',
            TextArrangement: #TextLast,
        });
    }
    Note        @UI.MultiLineText;
}

annotate service.ServiceRequest with {
    Status      @(Common: {
        Text                    : Status.name,
        TextArrangement         : #TextLast,
        ValueListWithFixedValues: true,
        ValueList               : {
            CollectionPath: 'ServiceRequestStatusCode',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: Status_code
                },
                // {
                //     $Type            : 'Common.ValueListParameterOut',
                //     ValueListProperty: 'name',
                //     LocalDataProperty: Status.name
                // },
            ]
        }
    });
    Category    @(Common: {
        Text                    : CategoryDescription,
        TextArrangement         : #TextLast,
        ValueListWithFixedValues: true,
        ValueList               : {
            CollectionPath: 'CategoryCodes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: Category_code
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'name',
                    LocalDataProperty: CategoryDescription
                },
            ]
        }
    });
    OrderID     @(Common: {
        Text           : OrderDescription,
        TextArrangement: #TextOnly,
        ValueList      : {
            CollectionPath: 'Opportunity',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: OrderID,
                    ValueListProperty: 'ID',

                },
                {
                    $Type            : 'Common.ValueListParameterIn', // filter by Completed Oppt
                    LocalDataProperty: LifeCycleStatusCodeCompletedDefault,
                    ValueListProperty: 'LifeCycleStatusCode_code'
                },
                {
                    $Type            : 'Common.ValueListParameterIn', // filter by selected Customer
                    LocalDataProperty: Customer_ID,
                    ValueListProperty: 'Customer_ID'
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'Subject',
                    LocalDataProperty: OrderDescription
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'LifeCycleStatusText'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ProspectPartyID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'MainEmployeeResponsiblePartyName'
                },
            ],
        }
    });
    CustomerID  @(Common: {
        Text           : CustomerFormattedName,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'Customer',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'InternalID',
                    LocalDataProperty: CustomerID
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'CustomerFormattedName',
                    LocalDataProperty: CustomerFormattedName
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ResponsibleManager',
                    LocalDataProperty: Processor
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ResponsibleManagerID',
                    LocalDataProperty: ProcessorID
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: Customer_ID
                },
            ]
        }
    });
    ProblemItem @(Common: {
        Text           : ProblemItemDescription,
        TextArrangement: #TextOnly,
        ValueList      : {
            CollectionPath: 'Item',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: ProblemItem
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ProductInternalID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ProductStatus'
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ProductCategory',
                    LocalDataProperty: ProblemItemDescription
                },
                {
                    $Type            : 'Common.ValueListParameterIn',
                    ValueListProperty: 'toOpportunity_ID',
                    LocalDataProperty: OrderID // filter by selected Order
                },


            ]
        }
    });
};

annotate service.Customer with @(UI.SelectionFields: [
    InternalID,
    Status_code,
    ResponsibleManager,
    //JuridicalAddress_Region_name,
    JuridicalAddress_Country_code,
]);

annotate service.Customer with {
    InternalID @(
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'Customer',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: InternalID,
                ValueListProperty: 'InternalID',
            }, ],
        },
        Common.ValueListWithFixedValues: false,
        Common.Text                    : {
            $value                 : CustomerFormattedName,
            ![@UI.TextArrangement] : #TextSeparate,
        }
    )
};

annotate service.Customer with {
    InternalID        @Common.Label: '{i18n>InternalID}';
    JuridicalCountry  @Common      : {
        Text           : JuridicalCountry.name,
        TextArrangement: #TextLast,
    };
    // IndividualCountry @Common      : {
    //     Text           : IndividualCountry.name,
    //     TextArrangement: #TextLast
    // };
};

annotate service.Customer with {
    Status @Common.Label: '{i18n>Status}'
};

annotate service.Customer with {
    ResponsibleManager @Common.Label: '{i18n>ResponsibleManager}'
};

annotate service.Customer with @(UI.FieldGroup #i18nAddministrationData: {
    $Type: 'UI.FieldGroupType',
    Data : [],
});

annotate service.Customer with @(UI.FieldGroup #i18nCreatedSection: {
    $Type: 'UI.FieldGroupType',
    Data : [],
});

annotate service.Opportunity with {
    LifeCycleStatusCode @(Common: {
        Text                    : LifeCycleStatusCode.name,
        TextArrangement         : #TextLast,
        ValueListWithFixedValues: true,
        ValueList               : {
            CollectionPath: 'OpportunityStatusCode',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: LifeCycleStatusCode_code
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'name',
                    LocalDataProperty: LifeCycleStatusText
                },
            ]
        }
    });
};

// annotate service.Customer with @(UI.Identification : [
//     {
//         $Type: 'UI.DataFieldForAction',
//         Action: 'CustomerService.updateAllFieldsFromRemote',
//         Label: 'Update All Fields From Remote'
//     }
// ]);
// annotate service.Opportunity with @(UI.Identification : [
//     {
//         $Type: 'UI.DataFieldForAction',
//         Action: 'CustomerService.LoadProducts',
//         Label: 'Load Products'
//     }
// ]);
annotate service.Item with {
    ItemProductID @(Common: {
        ValueListWithFixedValues: false,
        ValueList               : {
            CollectionPath: 'ItemProduct',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: ItemProductID
                },
                {
                    $Type            : 'Common.ValueListParameterIn',
                    ValueListProperty: 'ProductStatus',
                    LocalDataProperty: ProductStatusActiveDefault
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'InternalID',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ProductCategory',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ProductStatus',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'UnitMeasure',
                },
            ]
        }
    });
};

annotate service.ItemProduct with {
    ProductStatus @(Common: {
        Text           : ProductStatusDescription,
        TextArrangement: #TextFirst,
    });
};

// annotate service.Item @(Common: {SideEffects #toItemProductChanged: {
//     SourceProperties: ['ItemProductID'],
//     TargetEntities  : [
//         toItemProduct,
//         toItemProduct.SalesPriceLists
//     ]
// }});
// annotate service.Attachement @(Common: {SideEffects #content: {
//     SourceProperties: ['content'],
//     TargetProperties  : ['mediaType']
// }});
// annotate service.PartnerProfile @(Common: {SideEffects #code: {
//     SourceProperties: ['Region/code'],
//     TargetEntities : [Region]
// }});
// annotate service.PartnerProfile @(Common: {SideEffects #region: {
//     SourceProperties: [Region.code],
//     TargetProperties  : [Region.name]
// }});
annotate service.PartnerProfile with @(
    UI.Facets                       : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'General Information',
            ID    : 'GeneralInfo',
            Target: '@UI.FieldGroup#GeneralInfo',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Address Information',
            ID    : 'AddressInfo',
            Target: '@UI.FieldGroup#AddressInfo',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Communication Information',
            ID    : 'CommunicationInfo',
            Target: '@UI.FieldGroup#CommunicationInfo',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Customers',
            Target: 'ToCustomers/@UI.LineItem#Customers'
        }
    ],
    UI.HeaderInfo                   : {
        TypeName      : 'Contact',
        TypeNamePlural: 'Contacts',
        Title         : {
            $Type: 'UI.DataField',
            Value: `{FirstName} {LastName}`,
        },
    },
    UI.FieldGroup #GeneralInfo      : {
        $Type: 'UI.FieldGroupType',
        Data : [

            {
                $Type: 'UI.DataField',
                Value: FirstName,
                Label: 'First Name',
            },
            {
                $Type: 'UI.DataField',
                Value: LastName,
                Label: 'Last Name',
            },
            {
                $Type                   : 'UI.DataField',
                Value                   : Status_code,
                Label                   : 'Status',
                //![@Common.FieldControl] : #ReadOnly,
            },
            {
                $Type: 'UI.DataField',
                Value: Code,
                Label: 'Internal ID',
            },
            // {
            //     $Type : 'UI.DataField',
            //     Value : AccountID,
            //     Label : 'Account',
            // },
            {
                $Type: 'UI.DataField',
                Value: createdAt,
                Label: 'Created At',
            },
            {
                $Type: 'UI.DataField',
                Value: modifiedAt,
                Label: 'Modified At',
            },
        // {
        //     $Type : 'UI.DataField',
        //     Value : modifiedBy,
        //     Label : 'Modified By',
        // }

        ],
    },
    UI.FieldGroup #AddressInfo      : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: Country_code,
                Label: 'Country',
            },
            // {
            //     $Type: 'UI.DataField',
            //     Value: Region_code,
            //     Label: 'Region',
            // },
            {
                $Type: 'UI.DataField',
                Value: City,
                Label: 'City',
            },
            {
                $Type: 'UI.DataField',
                Value: Street,
                Label: 'Street',
            },
            {
                $Type: 'UI.DataField',
                Value: HouseNumber,
                Label: 'House Number',
            },
            {
                $Type: 'UI.DataField',
                Value: PostalCode,
                Label: 'Postal Code',
            },
        ]
    },
    UI.FieldGroup #CommunicationInfo: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: MobilePhone,
                Label: 'MobilePhone',
            },
            {
                $Type: 'UI.DataField',
                Value: Phone,
                Label: 'Phone',
            },
            {
                $Type: 'UI.DataField',
                Value: Email,
                Label: 'Email',
            },
        ]
    }
);

annotate service.Customer with @(UI.LineItem #Customers: [
    {
        $Type: 'UI.DataField',
        Label: 'ID',
        Value: InternalID,
                  //  ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
    {
        $Type: 'UI.DataField',
        Value: CustomerFormattedName,
                   // ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
    {
        $Type: 'UI.DataField',
        Label: '{i18n>Status}',
        Value: Status_code,
                   // ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
    {
        $Type: 'UI.DataField',
        Label: '{i18n>ResponsibleManager}',
        Value: ResponsibleManager,
                  //  ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
    {
        $Type: 'UI.DataField',
        Label: 'Sales Organisation',
        Value: SalesOrganisation,
                  //  ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
    {
        $Type: 'UI.DataField',
        Label: '{i18n>Country}',
        Value: JuridicalCountry.code,
                   // ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
    {
        $Type: 'UI.DataField',
        Label: 'City',
        Value: JuridicalAddress_City,
                  //  ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
    {
        $Type: 'UI.DataField',
        Label: 'Region',
        Value: JuridicalAddress_Street,
                   // ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
    {
        $Type: 'UI.DataField',
        Label: 'Street',
        Value: JuridicalAddress_Street,
                   // ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
    {
        $Type: 'UI.DataField',
        Label: 'House ID',
        Value: JuridicalAddress_HomeID,
                   // ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
    {
        $Type: 'UI.DataField',
        Label: 'Room ID',
        Value: JuridicalAddress_RoomID,
                    //![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
    {
        $Type: 'UI.DataField',
        Label: 'Note',
        Value: Note,
                   // ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}}, 

    },
]);

annotate service.PartnerProfile with @(UI.LineItem: [
    // {
    //     $Type: 'UI.DataField',
    //     Value: AccountID,
    //     Label: 'AccountID',
    // },
    {
        $Type: 'UI.DataField',
        Value: AccountFormattedName,
        Label: 'AccountFormattedName',
    },
    {
        $Type: 'UI.DataField',
        Value: City,
        Label: 'City',
    },
    {
        $Type: 'UI.DataField',
        Value: Code,
        Label: 'Code',
    },
    {
        $Type: 'UI.DataField',
        Value: Country.code,
        Label: 'Country',
    },
    {
        $Type: 'UI.DataField',
        Value: Email,
        Label: 'Email',
    },
    {
        $Type: 'UI.DataField',
        Value: FirstName,
        Label: 'FirstName',
    },
    {
        $Type: 'UI.DataField',
        Value: ID,
        Label: 'ID',
    },
    {
        $Type: 'UI.DataField',
        Value: LastName,
        Label: 'LastName',
    },
    {
        $Type: 'UI.DataField',
        Value: MobilePhone,
        Label: 'MobilePhone',
    },
    {
        $Type: 'UI.DataField',
        Value: Phone,
        Label: 'Phone',
    },
    {
        $Type: 'UI.DataField',
        Value: AccountUUID,
        Label: 'AccountUUID',
    },
    {
        $Type: 'UI.DataField',
        Value: createdBy,
        Label: 'createdBy',
    },
    {
        $Type: 'UI.DataField',
        Value: createdAt,
        Label: 'createdAt',
    },
    {
        $Type: 'UI.DataField',
        Value: modifiedAt,
        Label: 'modifiedAt',
    },
    {
        $Type: 'UI.DataField',
        Value: modifiedBy,
        Label: 'modifiedBy',
    }
], );

annotate service.PartnerProfile with {
    Country @(Common: {
        Text                    : Country.name,
        TextArrangement         : #TextLast,
        ValueListWithFixedValues: true,
        ValueList               : {
            CollectionPath: 'Countries',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: Country_code
                },
                // {
                //     $Type            : 'Common.ValueListParameterOut',
                //     ValueListProperty: 'name',
                //     LocalDataProperty: CountryDescription
                // },
            ]
        }
    });
    Region @(Common: {
        Text                    : RegionDescription,
        TextArrangement         : #TextLast,
        ValueListWithFixedValues: true,
        ValueList               : {
            CollectionPath: 'RegionCode',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: Region_code
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'name',
                    LocalDataProperty: RegionDescription
                },
                // {
                //     $Type            : 'Common.ValueListParameterDisplayOnly',
                //     ValueListProperty: 'name',
                // },
            ]
        }
    });
    Email @readonly;
    AccountID @(Common:{
        Text                    : AccountFormattedName,
        TextArrangement         : #TextFirst,
        ValueList               : {
            CollectionPath: 'Customer',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'InternalID',
                    LocalDataProperty: AccountID
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'CustomerFormattedName',
                    LocalDataProperty: AccountFormattedName
                },
            ]
        }
    })
};

annotate service.PartnerProfile with {
    Status @(Common: {
        Text                    : StatusDescription,
        TextArrangement         : #TextLast,
        ValueListWithFixedValues: true,
        ValueList               : {
            CollectionPath: 'StatusCodes',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'code',
                    LocalDataProperty: Status_code
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'name',
                    LocalDataProperty: StatusDescription
                },
            ]
        }
    });
    // Region @readonly;
    // PostalCode @readonly;
    // Country @readonly; 
    // City @readonly;
    // Street @readonly;
    // HouseNumber @readonly;
};

// annotate service.StatusCodes with{
//     code @UI.Hidden;
// } 

annotate service.PartnerProfile with @(UI.Identification: [{
    $Type : 'UI.DataFieldForAction',
    Action: 'PartnerService.updateAllFieldsFromRemote',
    Label : 'Refresh'
}]);

annotate service.Opportunity with @(UI.Identification: [
    {
        $Type : 'UI.DataFieldForAction',
        Action: 'PartnerService.updateFromRemote',
        Label : 'Refresh'
    },
    {
        $Type : 'UI.DataFieldForAction',
        Action: 'PartnerService.LoadProducts',
        Label : 'Load Products'
    },
]);

annotate service.ServiceRequest with @(UI.Identification: [{
    $Type : 'UI.DataFieldForAction',
    Action: 'PartnerService.updateFromRemote',
    Label : 'Refresh'
}]);

annotate service.Item with @(UI.HeaderInfo: {
    TypeName      : 'Sales Price List',
    TypeNamePlural: '',
    Title         : {
        $Type: 'UI.DataField',
        Value: ProductInternalID,
    },
});

annotate service.Item with {
    ID @(Common: {
        Text           : ProductInternalID,
        TextArrangement: #TextOnly,
    })
};

annotate service.Opportunity with {
    ID                               @Common      : {
        Text           : InternalID,
        TextArrangement: #TextOnly,
    };
    ProspectPartyID                  @(Common: {
        Text           : ProspectPartyName,
        TextArrangement: #TextFirst,
        ValueList      : {
            CollectionPath: 'Customer',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'InternalID',
                    LocalDataProperty: ProspectPartyID
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'CustomerFormattedName',
                    LocalDataProperty: ProspectPartyName
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ResponsibleManager',
                    LocalDataProperty: MainEmployeeResponsiblePartyName
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ResponsibleManagerID',
                    LocalDataProperty: MainEmployeeResponsiblePartyID
                },
            ]
        }
    });
    LifeCycleStatusText              @Common.Label: 'Status';
    MainEmployeeResponsiblePartyName @Common      : {
        Label          : 'Responsible Employee',
        Text           : MainEmployeeResponsiblePartyID,
        TextArrangement: #TextLast
    };
};
annotate service.Customer with {
    ResponsibleManager @Common:{
        Text:ResponsibleManagerID,
        TextArrangement : #TextLast,
    } @readonly;
    ResponsibleManagerID @UI.Hidden: true @readonly;
    CustomerFormattedName @readonly;
    Status @readonly;
    JuridicalCountry @readonly;
    JuridicalAddress @readonly;
    Note @readonly;
    // JuridicalAddress_City @readonly;
    // JuridicalAddress_Street @readonly;

};
annotate service.Item with {
    // ID @Common:{
    //     Text: ProductInternalID,
    //     TextArrangement : #TextOnly,
    // };
    ProductStatus   @Common.Label: 'Status';
    ProductCategory @Common      : {Label: 'Category', };
};
