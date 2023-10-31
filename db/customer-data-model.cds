using sap from '@sap/cds/common';
using { Country, Currency, cuid } from '@sap/cds/common';

namespace customer;

entity Customer  : cuid {
	UUID : UUID;
	ObjectID : String;
	CustomerFormattedName : String;
	Status : StatusCode;
	ResponsibleManager : String;
	ResponsibleManagerID : String;
	JuridicalAddress : Address;
	JuridicalCountry : Country;
	IndividualCountry : Country;
	IndividualAddress : Address;
	BankData : Composition of many Bank on BankData.Customer = $self;
	Note : String;
	InternalID: String;
	ToOpportunities: Composition of many Opportunity on ToOpportunities.Customer = $self;
	ToServiceRequests : Composition of many ServiceRequest on ToServiceRequests.Customer = $self;
	MainContactID : String;
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
	InternalID : String @readonly;
	ProspectPartyID: String;
	ProspectPartyName: String;
	Subject: String;
	LifeCycleStatusCode: Association to OpportunityStatus;
	LifeCycleStatusText: String;
	MainEmployeeResponsiblePartyID: String @readonly;
	MainEmployeeResponsiblePartyName: String;
	CreationDateTime: Date @cds.on.insert : $now;
	CreatedBy: String;
	LastChangeDateTime: Date @cds.on.insert : $now  @cds.on.update : $now;
	LastChangedBy: String;
	Customer : Association to one Customer;
	Items : Composition of many Item on Items.toOpportunity = $self;
	Attachment : Composition of many Attachment on Attachment.Opportunity = $self;
	NotStandartRequest : Boolean;
	MainContactID : String;
}
entity Item : cuid {
	OpportunityID : String;
	toOpportunity : Association to Opportunity;
	ItemProductID : String;
	toItemProduct : Association to ItemProduct on toItemProduct.ID = $self.ItemProductID;
}
entity ItemProduct : cuid {
	InternalID : String;
	ProductCategory : String;
	ProductStatus : String;
	ProductStatusDescription : String;
	UnitMeasure : String; // measure list?
	OpportunityID : String;
	toItem : Association to Item;
	SalesPriceLists : Composition of many SalesPriceList on SalesPriceLists.ItemProductID = $self.InternalID;
}
entity SalesPriceList : cuid {
	PriceListID : String;
	ProductInternalID : String;
	ItemProductID : String;
	ItemID : String;
	Amount : Decimal @Measures.ISOCurrency : AmountCurrencyCode.code;
	AmountCurrencyCode : Currency;
	PriceUnitContent : String @Measures.Unit : PriceUnitCode;
	PriceUnitCode : String; //unit code list
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
	CustomerFormattedName : String;
	MainContactID : String;
	//toProblemsItem : Association to many Item on toProblemsItem.OpportunityID = $self.OrderID;
}

type ServiceRequestStatusCode :  Association to ServiceRequestStatusCodes;
entity ServiceRequestStatusCodes : sap.common.CodeList{
	key code : String(2) default '1';
}

entity CategoryCodes : sap.common.CodeList{
	key code : String(2);
}

entity Attachment : cuid {
	ObjectID : String;
	@Core.MediaType   : mediaType content : LargeBinary @Core.ContentDisposition.Filename: fileName;
	@Core.IsMediaType : true mediaType : String;
	fileName  : String;
	url       : String;
	ServiceRequest : Association to ServiceRequest;
	Opportunity : Association to Opportunity;
}