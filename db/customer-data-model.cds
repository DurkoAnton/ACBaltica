using sap from '@sap/cds/common';
using { Country, Currency, cuid } from '@sap/cds/common';
using {api as external} from '../srv/external/api';
using {interaction as externalSR} from '../srv/external/interaction';


namespace customer;

entity Customer  : cuid {
	UUID : UUID;
	ObjectID : String;
	CustomerFormattedName : String @Common.Label : '{i18n>Customerformattedname}';
	Status : StatusCode @Common.Label : '{i18n>Status}';
	ResponsibleManager : String @Common.Label : '{i18n>ResponsibleManager}';
	ResponsibleManagerID : String;
	ResponsibleManagerEmail : String; // for approval process
	JuridicalAddress : Address;
	JuridicalCountry : Country @Common.Label : '{i18n>Country}';
	//IndividualCountry : Country;
	//IndividualAddress : Address;
	BankData : Composition of many Bank on BankData.Customer = $self;
	Note : String;
	InternalID: String @readonly default '';
	ToOpportunities: Composition of many Opportunity on ToOpportunities.Customer = $self;
	ToServiceRequests : Composition of many ServiceRequest on ToServiceRequests.Customer = $self;
	MainContactID : String;
	SalesOrganisation : String @readonly; 

	// Postal Address
	POBox : String @Common.Label : '{i18n>POBox}';
	POBoxCountry : Country @Common.Label : '{i18n>POBoxCountry}';
	POBoxState : Association to RegionCode @Common.Label : '{i18n>POBoxState}';
	POBoxPostalCode : String @Common.Label : '{i18n>POBoxPostalCode}';
	POBoxCity : String @Common.Label : '{i18n>POBoxCity}';
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
	Region : Association to RegionCode;
	City : String @Common.Label : '{i18n>City}';
	Street : String @Common.Label : '{i18n>Street}';
	HomeID : String @Common.Label : '{i18n>HomeID}';
	RoomID : String @Common.Label : '{i18n>RoomID}';
}
type Region : sap.common.CodeList{
	country: String(2);
}
entity RegionCode : sap.common.CodeList {
	key code : String(3);
	country: String(2);
}
    
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
	ProspectPartyName: String;
	Subject: String;
	LifeCycleStatusCode: Association to OpportunityStatus;
	LifeCycleStatusText: String;
	MainEmployeeResponsiblePartyID: String @readonly;
	MainEmployeeResponsiblePartyName: String @readonly default '';
	CreationDateTime: DateTime @cds.on.insert : $now;
	CreatedBy: String;
	LastChangeDateTime: DateTime @cds.on.insert : $now  @cds.on.update : $now;
	LastChangedBy: String;
	Customer : Association to one Customer /*@Common.SemanticObject : 'Customer'*/;
	Items : Composition of many Item on Items.toOpportunity = $self;
	Attachment : Composition of many Attachment on Attachment.Opportunity = $self;
	NotStandartRequest : Boolean default false;
	MainContactID : String;
	CustomerComment : String default '' @UI.MultiLineText;

	//Owner communication
	ResponsibleEmail : String @readonly;
	ResponsiblePhone : String @readonly;
	ResponsibleMobilePhone : String @readonly;
}
entity Item : cuid {
	OpportunityID : String;
	toOpportunity : Association to Opportunity;
	ItemProductID : String default ''; // id cap
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
	Description : String @readonly @Common.Label : 'Description';
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
	ValidFrom : DateTime @readonly;
	ValidTo : DateTime @readonly;
}
entity OpportunityStatus : sap.common.CodeList { 
    key code : String(2);
}
 
entity ServiceRequest : cuid {
	UUID : UUID @readonly;
	ObjectID : String;
	Subject : String;
	CustomerID : String default '';
	InternalID : String  @readonly default '';
	Status : ServiceRequestStatusCode;
	StatusDescription : String default 'Open';
	CreationDate : DateTime @cds.on.insert : $now @readonly;
	LastChangingDate : DateTime @cds.on.insert : $now  @cds.on.update : $now @readonly;
	Processor : String @readonly;
	ProcessorID : String @readonly;
	RequestProcessingTime : String;
	OrderID : String default '';
	OrderDescription : String;
	ProblemDescription : String  @UI.MultiLineText;
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

	Interactions : Composition of many ServiceRequestInteraction on Interactions.ServiceRequest = $self;
}

entity ServiceRequestInteraction : cuid{
	InternalID : String @readonly;
	Sender : String @readonly;
	Recepients : String @readonly;
	Text : String @readonly;
	CreationDateTime : DateTime @readonly;
	Subject : String @readonly;
	ServiceRequest : Association to ServiceRequest @readonly;
};

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
	@Core.IsMediaType : true mediaType : String @readonly;
	fileName  : String;
	url       : String;
	ServiceRequest : Association to ServiceRequest;
	Opportunity : Association to Opportunity;
	CreationDateTime: Timestamp @cds.on.insert : $now @Common.Label : '{i18n>CreationDateTime}';
}