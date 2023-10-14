// using PartnerService as service from '../../srv/partnerservice';

// annotate service.PartnerProfile with @(
//     UI.Facets : [
//         {
//             $Type : 'UI.ReferenceFacet',
//             Label : 'General Info',
//             ID : 'GeneralInfo',
//             Target : '@UI.FieldGroup#GeneralInfo',
//         },
//         {
//             $Type : 'UI.ReferenceFacet',
//             Label : 'Address Info',
//             ID : 'AddressInfo',
//             Target : '@UI.FieldGroup#AddressInfo',
//         },
//         {
//             $Type : 'UI.ReferenceFacet',
//             Label : 'Communication Info',
//             ID : 'CommunicationInfo',
//             Target : '@UI.FieldGroup#CommunicationInfo',
//         },
//          {
//             $Type: 'UI.ReferenceFacet', 
//             Label: 'Customers', 
//             Target: 'ToCustomers/@UI.LineItem#Customers' 
//         }
//     ],
//    UI.HeaderInfo : {
//         TypeName : 'Contact',
//         TypeNamePlural : 'Contacts',
//         Title : {
//             $Type : 'UI.DataField',
//             Value : `{FirstName} {LastName}`,
//         },
//     },
//     UI.FieldGroup #GeneralInfo : {
//         $Type : 'UI.FieldGroupType',
//         Data : [
            
//             {
//                 $Type : 'UI.DataField',
//                 Value : FirstName,
//                 Label : 'First Name',
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Value : LastName,
//                 Label : 'Last Name',
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Value : Status_code,
//                 Label : 'Status',
//                 ![@Common.FieldControl]: #ReadOnly,
//             },
//              {
//                 $Type : 'UI.DataField',
//                 Value : Code,
//                 Label : 'Internal ID',
//             },
//             /*{
//                 $Type : 'UI.DataField',
//                 Value : AccountID,
//                 Label : 'Main Customer ID',
//             },*/
//             {
//                 $Type : 'UI.DataField',
//                 Value : createdAt,
//                 Label : 'Created At',
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Value : modifiedAt,
//                 Label : 'Modified At',
//             },
//             // {
//             //     $Type : 'UI.DataField',
//             //     Value : modifiedBy,
//             //     Label : 'Modified By',
//             // }
            
//             ],
//     },
//       UI.FieldGroup #AddressInfo : {
//          $Type : 'UI.FieldGroupType',
//         Data : [
//             {
//                 $Type : 'UI.DataField',
//                 Value : Country_code,
//                 Label : 'Country',
//             },
//              {
//                 $Type : 'UI.DataField',
//                 Value : Region,
//                 Label : 'Region',
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Value : City,
//                 Label : 'City',
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Value : Street,
//                 Label : 'Street',
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Value : HouseNumber,
//                 Label : 'House Number',
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Value : PostalCode,
//                 Label : 'Postal Code',
//             },
//         ]
//       },
//        UI.FieldGroup #CommunicationInfo : {
//         $Type : 'UI.FieldGroupType',
//         Data : [
//             {
//                 $Type : 'UI.DataField',
//                 Value : MobilePhone,
//                 Label : 'MobilePhone',
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Value : Phone,
//                 Label : 'Phone',
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Value : Email,
//                 Label : 'Email',
//             },
//         ]
//       }
// );

// annotate service.Customer with @(
//       UI.LineItem #Customers  : [
//             {
//                 $Type : 'UI.DataField',
//                 Label : 'ID',
//                 Value : InternalID,
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Label : '{i18n>Customerformattedname}',
//                 Value : CustomerFormattedName
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Label : '{i18n>Status}',
//                 Value : Status_code
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Label : '{i18n>ResponsibleManager}',
//                 Value : ResponsibleManager
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Label : '{i18n>Country}',
//                 Value : JuridicalCountry.name
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Label : 'City',
//                 Value : JuridicalAddress_City
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Label : 'Region',
//                 Value : JuridicalAddress_Street
//             },
//              {
//                 $Type : 'UI.DataField',
//                 Label : 'Street',
//                 Value : JuridicalAddress_Street
//             },
//              {
//                 $Type : 'UI.DataField',
//                 Label : 'House ID',
//                 Value : JuridicalAddress_HomeID
//             },
//              {
//                 $Type : 'UI.DataField',
//                 Label : 'Room ID',
//                 Value : JuridicalAddress_RoomID
//             },
//             {
//                 $Type : 'UI.DataField',
//                 Label : 'Note',
//                 Value : Note
//             },
//     ] 
// );

// annotate service.PartnerProfile with @(
//     UI.LineItem:[
//          {
//                 $Type : 'UI.DataField',
//                 Value : AccountID,
//                 Label : 'AccountID',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : AccountFormattedName,
//                 Label : 'AccountFormattedName',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : City,
//                 Label : 'City',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : Code,
//                 Label : 'Code',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : Country.code,
//                 Label : 'Country',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : Email,
//                 Label : 'Email',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : FirstName,
//                 Label : 'FirstName',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : ID,
//                 Label : 'ID',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : LastName,
//                 Label : 'LastName',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : MobilePhone,
//                 Label : 'MobilePhone',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : Phone,
//                 Label : 'Phone',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : AccountUUID,
//                 Label : 'AccountUUID',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : createdBy,
//                 Label : 'createdBy',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : createdAt,
//                 Label : 'createdAt',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : modifiedAt,
//                 Label : 'modifiedAt',
//             },{
//                 $Type : 'UI.DataField',
//                 Value : modifiedBy,
//                 Label : 'modifiedBy',
//             }],
// );
// annotate service.PartnerProfile with {
//  Country @(Common:{
//          Text: CountryDescription,
// 		 TextArrangement : #TextLast,
//         ValueListWithFixedValues: true,
//         ValueList       : {
//             CollectionPath : 'Countries',
//             Parameters     : [
//                 {
//                     $Type               : 'Common.ValueListParameterInOut',
//                     ValueListProperty   : 'code',
//                     LocalDataProperty   : Country_code
//                 },
//                 {
//                     $Type               : 'Common.ValueListParameterOut',
//                     ValueListProperty   : 'name',
//                     LocalDataProperty   : CountryDescription
//                 }, 
//             ]
//         }
//     })
// };

// annotate service.PartnerProfile with {
//  Status @(Common:{
//         Text: Status.name,
//         TextArrangement : #TextOnly,
//         ValueListWithFixedValues: true,
//         ValueList       : {
//             CollectionPath : 'PartnerProfileStatus',
//             Parameters     : [
//                 {
//                     $Type               : 'Common.ValueListParameterInOut',
//                     ValueListProperty   : 'code',
//                     LocalDataProperty   : Status_code
//                 },
//                 {
//                     $Type               : 'Common.ValueListParameterDisplayOnly',
//                     ValueListProperty   : 'name'
//                 }, 
//             ]
//         }
//     })
// };

// annotate service.PartnerProfile with @(UI.Identification : [
//     { 
//                 $Type: 'UI.DataFieldForAction', 
//                 Action: 'PartnerService.updateAllFieldsFromRemote',
//                 Label: 'Update All Fields From Remote'
//     }
// ]);