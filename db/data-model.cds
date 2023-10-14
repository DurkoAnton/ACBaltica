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
        Status      : Association to PartnerProfileStatus;
        Region      : String;
        HouseNumber : String;
        Street      : String;
        PostalCode  : String;
        ToCustomers : Composition of many customer.Customer on ToCustomers.MainContactID = $self.Code;
}

entity PartnerProfileStatus : sap.common.CodeList{
	key code : String(2);
}

