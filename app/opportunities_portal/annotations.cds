using OpportunityService as service from '../../srv/OpportunityService';

annotate service.Opportunity with @(UI.LineItem: [
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
        Label: 'Responsible Employee',
        Value: MainEmployeeResponsiblePartyName,
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
    // {
    //     $Type: 'UI.DataField',
    //     Label: 'Changed By',
    //     Value: LastChangedBy,
    // },
    {
        $Type: 'UI.DataField',
        Label: 'Created At',
        Value: CreationDateTime,
    },
    // {
    //     $Type: 'UI.DataField',
    //     Label: 'Created By',
    //     Value: CreatedBy,
    // },
], );

annotate service.Opportunity with @(
    UI.Facets                 : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'General Info',
            ID    : 'GeneralInfo',
            Target: '@UI.FieldGroup#GeneralInfo',
        },
       {
            $Type : 'UI.CollectionFacet',
            Label : 'Parties',
            ID    : 'PartiesNew',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Parties',
                    ID    : 'Parties',
                    Target: '@UI.FieldGroup#Parties',
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Owners Communication',
                    ID    : 'Owners',
                    Target: '@UI.FieldGroup#Owners',
                    ![@UI.Hidden] : {$edmJson: {$Eq: [{$Path: 'InternalID'}, '']}}
                }
            ]
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Items',
            Target: 'Items/@UI.LineItem#Items'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Attachments',
            ID    : 'Attachments',
            Target: 'Attachment/@UI.LineItem#Attachments',
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
                ![@UI.Hidden] : {$edmJson: {$Eq: [{$Path: 'InternalID'}, '']}}
            },
            {
                $Type: 'UI.DataField',
                Value: Subject,
                Label: 'Subject',
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Value: LifeCycleStatusCode_code,
                Label: 'Status',
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Not Standart Request',
                Value: NotStandartRequest,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Customer Comment',
                Value: CustomerComment,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
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
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Value: MainEmployeeResponsiblePartyName,
                Label: 'Employee Responsible',
            },
        ]
    },
    UI.FieldGroup #Owners    : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: ResponsibleEmail,
                Label: 'Email',
                //![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
             {
                $Type: 'UI.DataField',
                Value: ResponsiblePhone,
                Label: 'Phone',
                //![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
             {
                $Type: 'UI.DataField',
                Value: ResponsibleMobilePhone,
                Label: 'Mobile',
                //![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
        ]
    }
);

// annotate service.Opportunity with {
//     Customer @(
//         Common.SemanticObject : 'Customer',
//         Common.SemanticObjectMapping: [
//             {
//                 LocalProperty : ID,
//                 SemanticObjectProperty : 'ID',
//             }
//         ]
//     )
// };

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
                // {
                //     $Type            : 'Common.ValueListParameterOut',
                //     ValueListProperty: 'ResponsibleManager',
                //     LocalDataProperty: MainEmployeeResponsiblePartyName
                // },
                // {
                //     $Type            : 'Common.ValueListParameterOut',
                //     ValueListProperty: 'ResponsibleManagerID',
                //     LocalDataProperty: MainEmployeeResponsiblePartyID
                // },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: Customer_ID
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Status_code',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ResponsibleManager'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Note'
                },
                
            ]
        }
    });
    MainEmployeeResponsiblePartyName @(Common: {
        Text           : MainEmployeeResponsiblePartyID,
        TextArrangement: #TextLast
    });
};

annotate service.Attachement with @(UI.LineItem #Attachments: [
    {
        $Type: 'UI.DataField',
        Value: content,
        Label: 'Content',
        ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
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

annotate service.Item with {
    ItemProductID @(Common: {
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
                    ValueListProperty: 'Description',
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
        ProductStatus                  @(Common: {
        Text           : ProductStatusDescription,
        TextArrangement: #TextFirst,
    });
    ID @UI.Hidden;
};
annotate service.SalesPriceList with @(UI.HeaderInfo: {
    TypeName      : 'Sales Price List',
    TypeNamePlural: 'Sales Price Lists',
    Title         : {
        $Type: 'UI.DataField',
        Value: ProductInternalID,
    },
});
annotate service.Item with @(
    UI.LineItem #Items: [
        {
            $Type: 'UI.DataField',
            Label: 'Product',
            Value: ItemProductID,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        },
        
        {
            $Type: 'UI.DataField',
            Label: 'Description',
            Value: toItemProduct.Description,
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
            Label: 'Price',
            Value: NetPriceAmount,
        },
         {
            $Type: 'UI.DataField',
            Label: 'Quantity',
            Value: Quantity,
            ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
        },
        {
            $Type: 'UI.DataField',
            Label: 'Total Price',
            Value: TotalPrice,
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
    }],
);

annotate service.Item with @(UI.HeaderInfo: {
    TypeName      : 'Item',
    TypeNamePlural: 'Items',
    Title : {
        $Type : 'UI.DataField',
        Value : ' ',
    } 
});

// annotate service.SalesPriceList with @(UI.HeaderInfo: {
//     TypeName      : 'Sales Price List',
//     TypeNamePlural: 'Sales Price List',
//     Title         : {
//         $Type: 'UI.DataField',
//         Value: 'new',
//     },
// });


annotate service.Item with {
    ProductInternalID @(Common: {
        Text                    : ProductCategory,
        TextArrangement         : #TextFirst,
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
    {
        $Type: 'UI.DataField',
        Value: ValidFrom,
        Label: 'Valid From',
    },
    {
        $Type: 'UI.DataField',
        Value: ValidTo,
        Label: 'Valid To',
    },
], );

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
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                },
            ]
        }
    });

};

annotate service.Opportunity with @(UI.HeaderInfo: {
    TypeName      : 'Opportunity',
    TypeNamePlural: 'Opportunities',
    Title         : {
        $Type: 'UI.DataField',
        Label: '{i18n>Subject}}',
        Value: Subject,
    }
}, );

annotate service.Opportunity with @(UI.Identification: [
    {
        $Type : 'UI.DataFieldForAction',
        Action: 'OpportunityService.updateFromRemote',
        Label : 'Refresh'
    },
   
]);

annotate service.Item @(Common: {SideEffects #toItemProductChanged: {
    SourceProperties: ['ItemProductID','toItemProduct/InternalID'],
    TargetEntities  : [
        toItemProduct,
        toItemProduct.SalesPriceLists
    ]
}});
annotate service.Item @(Common: {SideEffects #ItemProductChanged: {
    SourceProperties: ['ItemProductID'],
    TargetProperties  : ['NetPriceAmount', 'NetPriceCurrency_code', 'TotalPrice'],
    TargetEntities :[toItemProduct, toItemProduct.SalesPriceLists]
}});
annotate service.Attachement @(Common: {SideEffects #content: {
    SourceProperties: ['content'],
    TargetProperties  : ['mediaType']
}});
annotate service.Opportunity with @(
    UI.SelectionFields : [
        InternalID,
        Subject,
        LifeCycleStatusCode_code,
        CreationDateTime,
    ]
);
annotate service.Opportunity with {
    InternalID @Common.Label : '{i18n>InternalID}'
};
annotate service.Opportunity with {
    InternalID @(Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Opportunity',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : InternalID,
                    ValueListProperty : 'InternalID',
                },
            ],
        },
)};

annotate service.Opportunity @(Common: {SideEffects #LifeCycleStatusCodeChanged: {
    SourceProperties: ['LifeCycleStatusCode_code'],
    TargetEntities  : [LifeCycleStatusCode]
}}); 
annotate service.Opportunity @(Common: {SideEffects #ProspectPartyIDChanged: {
    SourceProperties: ['ProspectPartyID'],
    TargetProperties  : ['ProspectPartyName','MainEmployeeResponsiblePartyName']
}}); 

annotate service.Opportunity with {
    Subject @Common.Label : 'Subject'
};
annotate service.Opportunity with {
    LifeCycleStatusCode @Common.Label : 'Status'
};
annotate service.Opportunity with {
    CreationDateTime @Common.Label : 'Creation Date'
};

annotate service.Customer with {
    InternalID @Common.Label:'Internal ID';
    ResponsibleManager @Common:{
        Label:'Responsible manager',
        Text:ResponsibleManagerID,
        TextArrangement : #TextLast,
    };
    ID @UI.Hidden:true;
    Status            @(Common: {
    Text                    : Status.name,
    TextArrangement         : #TextFirst,
    });
};
annotate service.Opportunity with {
    ProspectPartyID @Common:{
        SemanticObject : 'Customer',
        SemanticObjectMapping : [
            {
                $Type : 'Common.SemanticObjectMappingType',
                LocalProperty : 'ProspectPartyID',
                SemanticObjectProperty : 'InternalID',
            },
            {
                $Type : 'Common.SemanticObjectMappingType',
                LocalProperty : 'ID',
                SemanticObjectProperty : 'none',
            },
            //  {
            //     $Type : 'Common.SemanticObjectMappingType',
            //     LocalProperty : 'ProspectPartyName',
            //     SemanticObjectProperty : 'CustomerFormattedName',
            // },
        ],
        }
};
// annotate service.Opportunity with {
//     Customer @Common:{SemanticObject : 'Customer',
//        SemanticObjectMapping : [
//             {
//                 $Type : 'Common.SemanticObjectMappingType',
//                 LocalProperty : 'Customer_ID',
//                 SemanticObjectProperty : 'ID',
//             },
//         ],
//     }
// };

annotate service.Opportunity with @( UI.UpdateHidden: true);