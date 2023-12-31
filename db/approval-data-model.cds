using sap from '@sap/cds/common';
using { managed, cuid, Country } from '@sap/cds/common';
using  customer from './customer-data-model';

namespace approval;

entity RequestApproval : cuid {
    CustomerID : String default '' @mandatory;
    CustomerObjectID : String default '';
    Customer : Association to one customer.Customer on Customer.ID = $self.CustomerID;
    MainContactID : String;
	CreationDateTime: Timestamp @cds.on.insert : $now @Common.Label : '{i18n>CreationDateTime}';
    Status : RequestApprovalStatusCode;
    
    currentData : CustomerDataSet;
    currentPOBoxCountry : Country;
    currentStatusCode : Association to customer.StatusCodes;
    currentCountry : Country;
    newData : CustomerDataSet;
    newPOBoxCountry : Country;
    newStatusCode : Association to customer.StatusCodes;
    newCountry : Country;
    
    bodyToRemote : {};
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
        // Postal Address
        POBox : String;
        POBoxState : String;
        POBoxPostalCode : String;
        POBoxCity : String;
}