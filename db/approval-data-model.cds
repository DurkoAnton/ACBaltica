using { managed, cuid, Country } from '@sap/cds/common';
using  customer from './customer-data-model';

namespace approval;

entity RequestApproval : cuid {
    CustomerID : UUID;
    Customer : Association to one customer.Customer on Customer.ID = $self.CustomerID;

    //copies of fields from current object state
    //OldCustomer {
        // CustomerFormattedNameOld : String ;
        // ResponsibleManagerOld : String ;
        // StatusCodeOld : Association to customer.StatusCodes ;
        // StatusDescriptionOld : String(20) ;
        // NoteOld : String @UI.MultiLineText ;

        // JuridicalCountryOld : Country ;
        // //Region : Region;
        // JuridicalCityOld : String ;
        // JuridicalStreetOld : String ;
        // JuridicalHomeIDOld : String ;
        // JuridicalRoomIDOld : String ;
    //}

    currentData : CustomerDataSet;
    newData : CustomerDataSet;
}

type CustomerDataSet {
        CustomerFormattedName : String ;
        ResponsibleManager : String;
        ResponsibleManagerID : String;
        StatusCode : Association to customer.StatusCodes;
        StatusDescription : String(20);
        Note : String @UI.MultiLineText ;

        JuridicalCountry : Country;
        //Region : Region;
        JuridicalCity : String ;
        JuridicalStreet : String ;
        JuridicalHomeID : String ;
        JuridicalRoomID : String ;
}