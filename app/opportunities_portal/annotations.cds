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
            $Type : 'UI.ReferenceFacet',
            Label : 'Attachments',
            ID    : 'Attachments',
            Target: 'Attachment/@UI.LineItem#Attachments',
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
                $Type: 'UI.DataFieldWithIntentBasedNavigation',
                SemanticObject : 'Customer',
                Label: 'Customer ID',
                Action : 'display',
                Value : Customer_ID,
                Mapping   : [{
                    $Type                 : 'Common.SemanticObjectMappingType',
                    LocalProperty         : Customer_ID,
                    SemanticObjectProperty: 'ID',
                } 
            ],
           },
            {
                $Type: 'UI.DataFieldWithIntentBasedNavigation',
                SemanticObject : 'Customer',
                Label: 'Customer ID2',
                Action : 'display',
                Value : ProspectPartyID,
                Mapping   : [
                    {
                    $Type                 : 'Common.SemanticObjectMappingType',
                    LocalProperty         : 'ProspectPartyID',
                    SemanticObjectProperty: 'InternalID',
                } ,
                {
                    $Type                 : 'Common.SemanticObjectMappingType',
                    LocalProperty         : 'ID',
                    SemanticObjectProperty: 'Customer_ID',
                } 
            ],
           },
        //  {
        //         $Type: 'UI.DataField',
        //         Value: ProspectPartyID,
        //         Label: 'ProspectPartyID',
        //     },
        //     {
        //         $Type: 'UI.DataField',
        //         Value: Customer_ID,
        //         Label: 'Customer',
        //     },
             {
                $Type: 'UI.DataField',
                Value: MainEmployeeResponsiblePartyName,
                Label: 'Employee Responsible',
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
        ProductStatus                  @(Common: {
        Text           : ProductStatusDescription,
        TextArrangement: #TextFirst,
    });
};

annotate service.Item with @(
    UI.LineItem #Items: [
        {
            $Type: 'UI.DataField',
            Label: 'Product',
            Value: ItemProductID,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Quantity',
            Value: Quantity,
        },
         {
            $Type: 'UI.DataField',
            Label: 'Price',
            Value: NetPriceAmount,
        },
        //  {
        //     $Type: 'UI.DataField',
        //     Label: 'oppt',
        //     Value: toOpportunity_ID,
        // },
        {
            $Type: 'UI.DataField',
            Label: 'Internal ID',
            Value: toItemProduct.InternalID,
        },
        // {
        //     $Type: 'UI.DataField',
        //     Label: 'Product Category',
        //     Value: toItemProduct.ProductCategory,
        // },
        // {
        //     $Type: 'UI.DataField',
        //     Label: 'Product Status',
        //     Value: toItemProduct.ProductStatus,
        // },
        
        
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

annotate service.Item with @(
    UI.HeaderInfo : {
        TypeName : 'Sales Price List',
        TypeNamePlural : '',
        Title : {
            $Type : 'UI.DataField',
            Value : ProductInternalID,
        },
    }
);

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
    {
        $Type : 'UI.DataFieldForAction',
        Action: 'OpportunityService.LoadProducts',
        Label : 'Load Products'
    },
]);

annotate service.Item @(Common: {SideEffects #ItemProductChanged: {
    SourceProperties: ['ItemProductID'],
    TargetProperties  : ['NetPriceAmount', 'NetPriceCurrency_code'],
    TargetEntities :[toItemProduct, toItemProduct.SalesPriceLists]
}});

annotate service.Item @(Common: {SideEffects #ItemProduct1Changed: {
    SourceEntities: [toItemProduct],
    TargetEntities :[toItemProduct.SalesPriceLists]
}});

annotate service.Opportunity @(Common: {SideEffects #ItemChanged: {
    SourceProperties: ['Items/ItemProductID'],
    TargetProperties  : ['Items/NetPriceCurrency/code'],
    TargetEntities :[Items.toItemProduct,Items.toItemProduct.SalesPriceLists] 
}});

annotate service.Item @(Common: {SideEffects #ItemProductIDChanged: {
    SourceProperties: ['ItemProductID'],
    TargetEntities  : [
        toItemProduct,
        toItemProduct.SalesPriceLists
    ]
}});
// annotate service.ItemProduct @(Common: {SideEffects #InternalIDChanged: {
//     SourceProperties: ['InternalID'],
//     TargetEntities  : [
//         SalesPriceLists
//     ]
// }});
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
};
