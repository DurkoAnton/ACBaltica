using CustomerService as service from '../../srv/CustomerService';

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
            Label: 'Region',
            Value: JuridicalAddress_Street
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

                {
                    $Type : 'UI.ReferenceFacet',
                    Label : '{i18n>IndividualAddress}',
                    ID    : 'AddressInformationIndividual',
                    Target: '@UI.FieldGroup#AddressInformationIndividual',
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

        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Bank Information',
            Target: 'BankData/@UI.LineItem#Banks'
        },
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
    TypeName      : 'Customers',
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
            Value: CustomerFormattedName
        },
        {
            $Type: 'UI.DataField',
            Label: 'Internal ID',
            Value: InternalID,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Status}',
            Value: Status_code,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>ResponsibleManager}',
            Value: ResponsibleManager,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Note}',
            Value: Note,
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
    {
        $Type: 'UI.DataField',
        Label: 'Customer',
        Value: ProspectPartyID,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Status',
        Value: LifeCycleStatusCode.name,
    },
    {
        $Type: 'UI.DataField',
        Value: MainEmployeeResponsiblePartyName,
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
        // {
        //     $Type: 'UI.DataField',
        //     Label: 'oppt 1',
        //     Value: OpportunityID,
        // },
        //  {
        //     $Type: 'UI.DataField',
        //     Label: 'oppt 2',
        //     Value: toOpportunity_ID,
        // },
        // {
        //     $Type: 'UI.DataField',
        //     Label: 'Internal ID',
        //     Value: toItemProduct.InternalID,
        // },
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

annotate service.Item with @(UI.HeaderInfo: {
    TypeName      : 'Sales Price List',
    TypeNamePlural: '',
    Title         : {
        $Type: 'UI.DataField',
        Value: ProductInternalID,
    },
});

annotate service.Item with {
    ProductInternalID @(Common: {
        Text           : ProductCategory,
        TextArrangement: #TextFirst,
    })
};

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
    // {
    //     $Type : 'UI.DataField',
    //     Value : AmountCurrencyCode_code,
    //     Label : 'Amount',
    // },
    {
        $Type: 'UI.DataField',
        Value: PriceUnitContent,
        Label: 'Price Unit',
    },
//  {
//         $Type : 'UI.DataField',
//     Value : PriceUnitCode,
//     Label : 'Price Unit',
// }
]);

annotate service.Customer with @(UI.FieldGroup #AddressInformationIndividual: {
    $Type: 'UI.FieldGroupType',
    Data : [
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Country}',
            Value: IndividualCountry_code,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>City}',
            Value: IndividualAddress_City,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Street}',
            Value: IndividualAddress_Street,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>HomeID}',
            Value: IndividualAddress_HomeID,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>RoomID}',
            Value: IndividualAddress_RoomID,
        }
    ]
});

annotate service.Customer with @(UI.FieldGroup #AddressInformationJuridical: {
    $Type: 'UI.FieldGroupType',
    Data : [
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Country}',
            Value: JuridicalCountry_code,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>City}',
            Value: JuridicalAddress_City,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>Street}',
            Value: JuridicalAddress_Street,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>HomeID}',
            Value: JuridicalAddress_HomeID,
        },
        {
            $Type: 'UI.DataField',
            Label: '{i18n>RoomID}',
            Value: JuridicalAddress_RoomID,
        },
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
    UI.FieldGroup #Parties      : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Customer',
                Value: CustomerID,
            },
            // {
            //     $Type: 'UI.DataField',
            //     Label: 'Customer name',
            //     Value: CustomerFormattedName,
            // },
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
                Label: 'Problem Items',
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
        Value: fileName,
        Label: 'File name',
    },
    {
        $Type: 'UI.DataField',
        Value: mediaType,
        Label: 'Media type',
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
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                },
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
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                },
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
                    $Type            : 'Common.ValueListParameterIn',// filter by Completed Oppt
                    LocalDataProperty: LifeCycleStatusCodeCompletedDefault,
                    ValueListProperty: 'LifeCycleStatusCode_code'
                },
                {
                    $Type            : 'Common.ValueListParameterIn',// filter by selected Customer
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
                // {
                //     $Type            : 'Common.ValueListParameterDisplayOnly',
                //     ValueListProperty: 'ProspectPartyID'
                // },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ProspectPartyName'
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
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ProductCategory',
                    LocalDataProperty: ProblemItemDescription
                },
                {
                    $Type            : 'Common.ValueListParameterIn',
                    ValueListProperty: 'toOpportunity_ID',
                    LocalDataProperty: OrderID // filter by selected Order
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ProductInternalID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ProductCategory'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ProductStatus'
                },
            ]
        }
    });
};

annotate service.Customer with @(UI.SelectionFields: [
    InternalID,
    CustomerFormattedName,
    Status_code,
    ResponsibleManager,
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
    IndividualCountry @Common      : {
        Text           : IndividualCountry.name,
        TextArrangement: #TextLast
    };
};

annotate service.Customer with {
    Status @Common.Label: '{i18n>Status}'
};

annotate service.Customer with {
    ResponsibleManager @Common.Label: '{i18n>ResponsibleManager}'
};

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

annotate service.Customer with @(UI.Identification: [{
    $Type : 'UI.DataFieldForAction',
    Action: 'CustomerService.updateAllFieldsFromRemote',
    Label : 'Refresh'
}]);

annotate service.Opportunity with @(UI.Identification: [
                                                        // {
                                                        //     $Type : 'UI.DataFieldForAction',
                                                        //     Action: 'CustomerService.LoadProducts',
                                                        //     Label : 'Load Products'
                                                        // },
                                                       {
    $Type : 'UI.DataFieldForAction',
    Action: 'CustomerService.updateFromRemote',
    Label : 'Refresh'
}]);

annotate service.Item with {
    ItemProductID @(Common: {
        ValueListWithFixedValues: false,
        Text                    : toItemProduct.InternalID,
        TextArrangement         : #TextOnly,
        ValueList               : {
            CollectionPath: 'ItemProduct',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: ItemProductID
                },
                // filter rows by ProductStatus, display records with ProductStatus=2
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


annotate service.Opportunity with {
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
    MainEmployeeResponsiblePartyName @(Common: {
        Text           : MainEmployeeResponsiblePartyID,
        TextArrangement: #TextLast
    });
};


annotate service.Item @(Common: {SideEffects #toItemProductChanged: {
    SourceProperties: ['ItemProductID'],
    TargetEntities  : [
        toItemProduct,
        toItemProduct.SalesPriceLists
    ]
}});

annotate service.Customer @(Common: {SideEffects #StatusChanged: {
    SourceProperties: ['Status_code'],
    TargetEntities  : [Status]
}});

annotate service.ServiceRequest @(Common: {SideEffects #StatusChanged: {
    SourceProperties: ['Status_code'],
    TargetEntities  : [Status]
}});

annotate service.Opportunity @(Common: {SideEffects #LifeCycleStatusCodeChanged: {
    SourceProperties: ['LifeCycleStatusCode_code'],
    TargetEntities  : [LifeCycleStatusCode]
}});

annotate service.ServiceRequest with @(UI.Identification: [{
    $Type : 'UI.DataFieldForAction',
    Action: 'CustomerService.updateFromRemote',
    Label : 'Refresh'
}]);

annotate service.Customer with {
    ResponsibleManager @Common:{
        Text:ResponsibleManagerID,
        TextArrangement : #TextLast,
    };
    ResponsibleManagerID @UI.Hidden: true;
};

annotate service.Opportunity with {
    ID @Common:{
        Text: InternalID,
        TextArrangement : #TextOnly,
    };
    LifeCycleStatusText @Common.Label : 'Status';
    ProspectPartyName @Common:{
        Label: 'Customer',
        Text: ProspectPartyID,
        TextArrangement : #TextLast,
    };
    MainEmployeeResponsiblePartyName @Common:{
        Label: 'Responsible Employee'
    };
};