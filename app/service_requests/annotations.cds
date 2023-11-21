using ServiceRequestService as service from '../../srv/ServiceRequestService';

annotate service.ServiceRequest with @(UI.LineItem: [
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
    {
        $Type: 'UI.DataField',
        Value: OrderID,
        Label: 'Order',
    },
    {
        $Type: 'UI.DataField',
        Value: ProblemItem,
        Label: 'Problem Item',
    },
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
            // {
            //     $Type: 'UI.DataField',
            //     Label: 'Request Processing Time',
            //     Value: RequestProcessingTime,
            // },
            {
                $Type: 'UI.DataField',
                Label: 'Creation Date',
                Value: CreationDate,
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
                Value: CustomerID,
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

annotate service.ServiceRequest with @(UI.HeaderInfo: {
    TypeName      : '{i18n>ServiceRequest}',
    TypeNamePlural: '{i18n>ServiceRequests}',
    Title         : {
        $Type: 'UI.DataField',
        Label: '{i18n>ProblemDescription}',
        Value: ProblemDescription,
    }
}, );

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
    }, )
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
                    ValueListProperty: 'ProductCategory',
                    LocalDataProperty: ProblemItemDescription
                },
                {
                    $Type            : 'Common.ValueListParameterIn',
                    ValueListProperty: 'toOpportunity_ID',
                    LocalDataProperty: OrderID // filter by selected Order
                },
                // {
                //     $Type            : 'Common.ValueListParameterIn',
                //     ValueListProperty: 'toOpportunity/ProspectPartyID',
                //     LocalDataProperty: Customer_ID // filter by selected Customer
                // },
                // {
                //     $Type            : 'Common.ValueListParameterDisplayOnly',
                //     ValueListProperty: 'ProductInternalID'
                // },
                // {
                //     $Type            : 'Common.ValueListParameterDisplayOnly',
                //     ValueListProperty: 'ProductCategory'
                // },
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
            ]
        }
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
        Value: mediaType,
        Label: 'Media type',
    },
    {
        $Type: 'UI.DataField',
        Value: CreationDateTime,
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
    }
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
    };
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