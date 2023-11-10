using { managed, cuid, Country } from '@sap/cds/common';
using  customer from './customer-data-model';

namespace approval;

entity RequestApproval : cuid {
    CustomerID : UUID;
    Customer : Association to one customer.Customer on Customer.ID = $self.CustomerID;

    currentData : CustomerDataSet;
    currentStatusCode : Association to customer.StatusCodes;
    currentCountry : Country;
    newData : CustomerDataSet;
    newStatusCode : Association to customer.StatusCodes;
    newCountry : Country;
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