using sap from '@sap/cds/common';
using {cuid, Country, managed} from '@sap/cds/common';
using customer from './customer-data-model';

namespace partner;

entity partnerProfile : cuid, managed {
        ObjectID    : String;
        Code        : String @readonly;
        FirstName   : String;
        LastName    : String;
        Phone       : String;
        MobilePhone : String;
        Email       : String;
        AccountID       : String @readonly;
        AccountUUID     : String;
        AccountFormattedName    : String @readonly;
        Country     : Country;
        CountryDescription : String;
        City        : String;
        Status      : customer.StatusCode;
        StatusDescription : String;
        Region      : Association to customer.RegionCode;
        RegionDescription : String;
        HouseNumber : String;
        Street      : String;
        PostalCode  : String;
        ToCustomers : Composition of many customer.Customer on ToCustomers.MainContactID = $self.Code;
}

