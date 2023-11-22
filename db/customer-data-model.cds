using sap from '@sap/cds/common';
using { Country, Currency, cuid } from '@sap/cds/common';
using {api as external} from '../srv/external/api';

namespace customer;

entity Customer  : cuid {
	UUID : UUID;
	ObjectID : String;
	CustomerFormattedName : String @Common.Label : '{i18n>Customerformattedname}';
	Status : StatusCode;
	ResponsibleManager : String @Common.Label : '{i18n>ResponsibleManager}';
	ResponsibleManagerID : String;
	ResponsibleManagerEmail : String; // for approval process
	JuridicalAddress : Address;
	JuridicalCountry : Country;
	IndividualCountry : Country;
	IndividualAddress : Address;
	BankData : Composition of many Bank on BankData.Customer = $self;
	Note : String;
	InternalID: String @readonly;
	ToOpportunities: Composition of many Opportunity on ToOpportunities.Customer = $self;
	ToServiceRequests : Composition of many ServiceRequest on ToServiceRequests.Customer = $self;
	MainContactID : String;

	// Postal Address
	POBox : String;
	POBoxCountry : Country;
	POBoxState : String;
	POBoxCity : String;
}

entity Bank : cuid {
	BankCode : String;
	BankAccount : String;
	IBAN : String;
	SWIFT: String;
    Customer : Association to Customer;
}

type Address {
	Country : Country;
	Region : Region;
	City : String;
	Street : String;
	HomeID : String;
	RoomID : String;
}
type Region : sap.common.CodeList{}

type StatusCode :  Association to StatusCodes;
entity StatusCodes : sap.common.CodeList{
	key code : String(2);
}

// test
entity ValueHelpTable {
 	key code : String(10);
 	descr: String;
}

entity Opportunity : cuid{
	UUID : UUID;
	ObjectID : String;
	InternalID : String @readonly default '';
	ProspectPartyID: String;
	@Common:{
		SemanticObject : 'Customer',
		// SemanticObjectMapping: [
        //      {
        //          LocalProperty : ProspectPartyID,
        //          SemanticObjectProperty : 'InternalID',
        //      },
		// 	//  {
        //     //      LocalProperty : Customer_ID,
        //     //      SemanticObjectProperty : 'ID',
        //     //  }
        //  ]
	}
		
	ProspectPartyName: String;
	Subject: String;
	LifeCycleStatusCode: Association to OpportunityStatus;
	LifeCycleStatusText: String;
	MainEmployeeResponsiblePartyID: String @readonly;
	MainEmployeeResponsiblePartyName: String @readonly;
	CreationDateTime: Date @cds.on.insert : $now;
	CreatedBy: String;
	LastChangeDateTime: Date @cds.on.insert : $now  @cds.on.update : $now;
	LastChangedBy: String;
	Customer : Association to one Customer /*@Common.SemanticObject : 'Customer'*/;
	Items : Composition of many Item on Items.toOpportunity = $self;
	Attachment : Composition of many Attachment on Attachment.Opportunity = $self;
	NotStandartRequest : Boolean default false;
	MainContactID : String;
	CustomerComment : String default '';
}
entity Item : cuid {
	OpportunityID : String;
	toOpportunity : Association to Opportunity;
	ItemProductID : String; // id cap
	Quantity : Integer default 1;
	NetPriceAmount : Decimal @Measures.ISOCurrency : NetPriceCurrency_code @readonly;
	NetPriceCurrency : Currency @readonly;
	ObjectID : String;
	toItemProduct : Association to ItemProduct on toItemProduct.ID = $self.ItemProductID;
	virtual ProductStatusActiveDefault: Integer default 2;
}
entity ItemProduct : cuid {
	InternalID : String @readonly @Common.Label : '{i18n>InternalID}';
	ProductCategory : String @readonly @Common.Label : '{i18n>ProductCategory}';
	ProductStatus : String @readonly @Common.Label : '{i18n>ProductStatus}';
	ProductStatusDescription : String @readonly @Common.Label : '{i18n>ProductStatus}';
	UnitMeasure : String @readonly @Common.Label : '{i18n>UnitMeasure}'; // measure list?
	OpportunityID : String @readonly;
	toItem : Association to Item;
	SalesPriceLists : Composition of many SalesPriceList on SalesPriceLists.ItemProductID = $self.InternalID;
}
entity SalesPriceList : cuid {
	PriceListID : String @readonly;
	ProductInternalID : String @readonly;
	ItemProductID : String @readonly;
	ItemID : String @readonly;
	Amount : Decimal @Measures.ISOCurrency : AmountCurrencyCode.code @readonly;
	AmountCurrencyCode : Currency @readonly;
	PriceUnitContent : String @Measures.Unit : PriceUnitCode @readonly;
	PriceUnitCode : String @readonly; //unit code list
	IsBasePriceList : Boolean;
	ReleaseStatusCode : String(1);
}
entity OpportunityStatus : sap.common.CodeList { 
    key code : String(2);
}

entity ServiceRequest : cuid {
	UUID : UUID @readonly;
	ObjectID : String;
	CustomerID : String;
	InternalID : String  @readonly;
	Status : ServiceRequestStatusCode;
	StatusDescription : String default 'Open';
	CreationDate : Date @cds.on.insert : $now;
	LastChangingDate : Date @cds.on.insert : $now  @cds.on.update : $now;
	Processor : String;
	ProcessorID : String @readonly;
	RequestProcessingTime : String;
	OrderID : String;
	OrderDescription : String;
	ProblemDescription : String;
	Attachment : Composition of many Attachment on Attachment.ServiceRequest = $self;
	Customer : Association to Customer;
	Category : Association to CategoryCodes; 
	CategoryDescription : String;
	ProblemItem : String;
	ProblemItemDescription : String;
	virtual LifeCycleStatusCodeCompletedDefault: Integer default 4;
	CustomerFormattedName : String @Common.Label : '{i18n>Customerformattedname}';
	MainContactID : String;

	// Time intervals
	RequestInitialDateTime : DateTime;//RequestInitialReceiptdatetimecontent
	RequestEndDateTime : DateTime;	  //RequestedFulfillmentPeriodEndDateTime
	ResolutionDateTime : DateTime; 	  //ResolvedOnDateTime

}

type ServiceRequestStatusCode :  Association to ServiceRequestStatusCodes;
entity ServiceRequestStatusCodes : sap.common.CodeList{
	key code : String(2) default '1';
}

entity CategoryCodes : sap.common.CodeList{
	key code : String(2) default '1';
}

entity Attachment : cuid {
	ObjectID : String;
	@Core.MediaType   : mediaType content : LargeBinary @Core.ContentDisposition.Filename: fileName;
	@Core.IsMediaType : true mediaType : String;
	fileName  : String;
	url       : String;
	ServiceRequest : Association to ServiceRequest;
	Opportunity : Association to Opportunity;
	CreationDateTime: Timestamp @cds.on.insert : $now @Common.Label : '{i18n>CreationDateTime}';
}

//entity RemoteCustomer as select from external.CorporateAccountCollection;