using ServiceRequestService as service from '../../srv/ServiceRequestService';

annotate service.ServiceRequest with @(UI.LineItem: [
    {
        $Type: 'UI.DataField',
        Value: InternalID,
        Label: '{i18n>InternalID}',
    },
    {
        $Type: 'UI.DataField',
        Value: Subject,
        Label: 'Subject',
    },
    {
        $Type: 'UI.DataField',
        Value: Status_code,
        Label: '{i18n>Status}',
    },
    {
        $Type: 'UI.DataField',
        Label: 'Customer',
        Value: CustomerID,
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
    // {
    //     $Type: 'UI.DataField',
    //     Value: OrderID,
    //     Label: 'Order',
    // },
    // {
    //     $Type: 'UI.DataField',
    //     Value: ProblemItem,
    //     Label: 'Problem Item',
    // },
    {
        $Type: 'UI.DataField',
        Label: 'Request Date',
        Value: RequestInitialDateTime,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Request End Date',
        Value: RequestEndDateTime,
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
]);

annotate service.ServiceRequest with @(
    UI.FieldGroup #GeneralInfoSR: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Internal ID',
                Value: InternalID,
                ![@UI.Hidden] : {$edmJson : {$Eq : [{$Path : 'InternalID'}, '']}}
            },
             {
                $Type: 'UI.DataField',
                Label: 'Subject',
                Value: Subject,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Category',
                Value: Category_code,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Problem Description',
                Value: ProblemDescription,
                //![@UI.Hidden] : {$edmJson: {$Eq: [ {$Path: 'Category_code'}, '1' ] } },
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Status',
                Value: Status_code,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
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
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Request End Date',
                Value: RequestEndDateTime,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
            },
            {
                $Type: 'UI.DataField',
                Label: 'Resolution Date',
                Value: ResolutionDateTime,
                ![@UI.Hidden] : {$edmJson: {$Ne: [
                {$Path: 'Status_code'},
                '3'
             ]}}
            },
              {
                $Type: 'UI.DataField',
                Label: 'Last Changing Date',
                Value: LastChangingDate,
            },
             {
                $Type: 'UI.DataField',
                Label: 'Creation Date',
                Value: CreationDate,
            },
        ]
    },
    UI.FieldGroup #Parties      : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Customer',
                Value: CustomerID,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
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
                ![@Common.FieldControl] : { $edmJson : {$If : [ { 
                    $And : [
                        { $Ne : [ { $Path : 'CustomerID'}, '']},
                        { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}
                        ]
                        }, 3, 1 ] } },
            },
            {
                $Type: 'UI.DataField', 
                Label: 'Problem Item',
                Value: ProblemItem,
                ![@Common.FieldControl] : { $edmJson : {$If : [ { 
                    $And : [
                        { $Ne : [ { $Path : 'OrderID'}, '']},
                        { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}
                        ]
                        }, 3, 1 ] } },
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
             ![@UI.Hidden] : {$edmJson: {$Eq: [
                {$Path: 'Category_code'},
                '2'
             ]}}
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Attachments',
            ID    : 'Attachments',
            Target: 'Attachment/@UI.LineItem#Attachments',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Interactions',
            ID    : 'Interactions',
            Target: 'Interactions/@UI.LineItem#Interactions',
            //![@UI.Hidden] : {$edmJson: {$Ne: [{$Path: 'Status_code'},'3']}}
        },
        
    ]
);
annotate service.ServiceRequestInteraction with @(UI.HeaderInfo: {
    TypeName      : 'Interaction',
    TypeNamePlural: 'Interactions' 
});
annotate service.ServiceRequest with @(UI.HeaderInfo: {
    TypeName      : '{i18n>ServiceRequest}',
    TypeNamePlural: '{i18n>ServiceRequests}',
    Title         : {
        $Type: 'UI.DataField',
        Label: 'Subject',
        Value: Subject,
    }
}, );
annotate service.Attachement with @(UI.HeaderInfo: {
    TypeName      : 'Attachment',
    TypeNamePlural: 'Attachments',
});

annotate service.ServiceRequest with @(UI.SelectionFields: [
    InternalID,
    Status_code,
    Category_code,
    ProblemDescription,
    CreationDate,
]);

annotate service.ServiceRequest with {
    InternalID @(Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'ServiceRequest',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: InternalID,
                ValueListProperty: 'InternalID',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'ProblemDescription',
            },
        ],
    }, );
    Processor @readonly;
    ProcessorID @readonly;
};

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
                    ValueListProperty: 'name'
                },
            ]
        }
    });
    Category    @(Common: {
        Text                    : Category.name,
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
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
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
                    ValueListProperty: 'LifeCycleStatusCode/name',
                },
                // {
                //     $Type            : 'Common.ValueListParameterDisplayOnly',
                //     ValueListProperty: 'ProspectPartyID'
                // },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ProspectPartyName'
                },
                // {
                //     $Type            : 'Common.ValueListParameterDisplayOnly',
                //     ValueListProperty: 'MainEmployeeResponsiblePartyID'
                // },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'MainEmployeeResponsiblePartyName'
                },
            ],
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
                    ValueListProperty: 'ProductDescription',
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
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Status_code',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'ResponsibleManager',
                },
                // {
                //     $Type            : 'Common.ValueListParameterOut',
                //     ValueListProperty: 'ResponsibleManagerID',
                //     LocalDataProperty: ProcessorID
                // },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    ValueListProperty: 'ID',
                    LocalDataProperty: Customer_ID
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Note'
                },
            ]
        }
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

annotate service.ServiceRequestInteraction with @(UI.LineItem #Interactions: [
    {
        $Type: 'UI.DataField',
        Value: InternalID,
        Label: 'InternalID',
    },
     {
        $Type: 'UI.DataField',
        Value: Subject,
        Label: 'Subject',
        ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
    },
    {
        $Type: 'UI.DataField',
        Value: Text,
        Label: 'Text',
        ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
    },
    {
        $Type: 'UI.DataField',
        Value: Sender,
        Label: 'Sender',
        ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
    },
    {
        $Type: 'UI.DataField',
        Value: Recepients,
        Label: 'Recepient',
        ![@Common.FieldControl] : { $edmJson : {$If : [ { $Eq : [ { $Path : 'HasActiveEntity'}, false ]}, 3, 1 ]}},
    },
   {
        $Type: 'UI.DataField',
        Value: CreationDateTime,
        Label: 'CreatedAt',
    },
]);

annotate service.ServiceRequest with @(UI.Identification: [{
    $Type : 'UI.DataFieldForAction',
    Action: 'ServiceRequestService.updateFromRemote',
    Label : 'Refresh'
}]);

annotate service.ServiceRequest @(Common: {SideEffects #CategoryChanged: {
    SourceProperties: ['Category_code'],
    TargetEntities  : [Category]
}});
annotate service.Attachement @(Common: {SideEffects #content: {
    SourceProperties: ['content'],
    TargetProperties  : ['mediaType']
}});

annotate service.ServiceRequest with {
    InternalID @Common.Label: '{i18n>InternalID}';
    ProblemDescription @Common.Label: '{i18n>ProblemDescription}';
    CreationDate @Common.Label : '{i18n>CreationDate}';
    Status @Common.Label : 'Status';
    Category @Common.Label : 'Category';
    Processor @Common:{
        Text : ProcessorID,
        TextArrangement : #TextLast
    };
    ResolutionDateTime @readonly;
    Subject @mandatory;
};

annotate service.OpportunityStatus with {
    name @Common.Label : 'Status';
};

annotate service.Opportunity with {
    ID @Common:{
        Text: InternalID,
        TextArrangement : #TextOnly,
    }; 
    //LifeCycleStatusCode_name @Common.Label : 'Status';
    LifeCycleStatusText @Common.Label : 'Status';
    ProspectPartyName @Common:{
        Label: 'Customer',
        Text: ProspectPartyID,
        TextArrangement : #TextLast,
    };
    MainEmployeeResponsiblePartyName @Common:{
        Label: 'Responsible Employee',
        Text: MainEmployeeResponsiblePartyID,
        TextArrangement : #TextLast
    };
};
annotate service.Item with {
    ID @Common:{
        Text: ProductInternalID,
        TextArrangement : #TextOnly,
    };
    ProductStatus @Common.Label : 'Status';
    ProductCategory @Common:{
        Label: 'Category',
    };
};
annotate service.Customer with {
    InternalID @Common.Label : 'Internal ID'; 
    ResponsibleManager @Common:{
        Label: 'Responsible manager',
        Text: ResponsibleManagerID,
        TextArrangement : #TextLast,
    } @readonly;
    ID @UI.Hidden:true;
    Status @Common : { 
        Label : 'Status',
        Text : Status.name,
        TextArrangement : #TextFirst,
    };

    // ResponsibleManager @Common :{
    //     Label : 'Res',
    //     Text : Status.name,
    //     TextArrangement : #TextFirst,
    // }
};

annotate service.ServiceRequest @(Common: {SideEffects #CustomerIDChanged: {
    SourceProperties: ['CustomerID'],
    TargetProperties  : ['CustomerFormattedName','Processor','OrderID','OrderDescription','ProblemItem']
}}); 
annotate service.ServiceRequest @(Common: {SideEffects #Statushanged: {
    SourceProperties: ['Status_code'],
    TargetEntities  : [Status]
}}); 
annotate service.ServiceRequest with {
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
                LocalProperty : 'InternalID',
                SemanticObjectProperty : 'none',
            },
             {
                $Type : 'Common.SemanticObjectMappingType',
                LocalProperty : 'Status_code',
                SemanticObjectProperty : 'none',
            },
        ],
        }
};

annotate service.ServiceRequestInteraction with @(
    UI.PresentationVariant #Interactions : {
        $Type : 'UI.PresentationVariantType',
        Visualizations : [
            '@UI.LineItem#Interactions',
        ],
    }
);

annotate service.ServiceRequest with @( UI.UpdateHidden: true);