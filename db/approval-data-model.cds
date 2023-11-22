using sap from '@sap/cds/common';
using { managed, cuid, Country } from '@sap/cds/common';
using  customer from './customer-data-model';

namespace approval;

entity RequestApproval : cuid {
    CustomerID : UUID;
    Customer : Association to one customer.Customer on Customer.ID = $self.CustomerID;
    MainContactID : String;
	CreationDateTime: Timestamp @cds.on.insert : $now @Common.Label : '{i18n>CreationDateTime}';
    Status : RequestApprovalStatusCode;
    
    currentData : CustomerDataSet;
    currentStatusCode : Association to customer.StatusCodes;
    currentCountry : Country;
    newData : CustomerDataSet;
    newStatusCode : Association to customer.StatusCodes;
    newCountry : Country;
    
}

type RequestApprovalStatusCode :  Association to RequestApprovalStatusCodes;
entity RequestApprovalStatusCodes : sap.common.CodeList{
	key code : String(2) default '1';
}

type CustomerDataSet {
        CustomerFormattedName : String ;
        ResponsibleManager : String;
        ResponsibleManagerID : String;
        Note : String @UI.MultiLineText;
        //Region : Region;
        JuridicalCity : String ;
        JuridicalStreet : String ;
        JuridicalHomeID : String ;
        JuridicalRoomID : String ;
}