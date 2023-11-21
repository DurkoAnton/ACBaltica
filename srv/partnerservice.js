const { executeHttpRequest, getDestination } = require('@sap-cloud-sdk/core');
const { getObjectsWithDifferentPropertyValue, createAttachmentBody, linkSelectedOpportunity, createNewCustomerInRemote, deleteCustomerInstances } = require('./libs/utils');
const { sendRequestToC4C } = require('./libs/ManageAPICalls');
const { loadProductsAndPricesListsFromC4C } = require('./libs/dataLoading');

const destinationName = 'C4C_DEMO';

class PartnerService extends cds.ApplicationService {
    async init() {

        cds.env.features.fetch_csrf = true;

        const { PartnerProfile, Attachement, ItemProduct, RemoteContact,RemoteCustomer } = this.entities;
        const { Customer, Opportunity, ServiceRequest, SalesPriceList } = cds.entities('customer');

        const remoteC4CAPI = await cds.connect.to('api');
        
        function _getPath(currentUserEmail) {
            return `/sap/c4c/odata/v1/c4codataapi/ContactCollection?$filter=Email eq '${currentUserEmail}'`
        }

        async function _createCustomerInstances(corporateAccounts, customersFromDB) {

            let customer;
            corporateAccounts.forEach(async item => {
                if (customersFromDB.filter(n => n.UUID == item.CorporateAccount.UUID).length == 0) {
                    const account = item.CorporateAccount;
                    const owner = account.OwnerEmployeeBasicData;
                    const note = account.CorporateAccountTextCollection.results;
                    if (account != undefined) {
                        customer = {
                            CustomerFormattedName: account.BusinessPartnerFormattedName,
                            InternalID: account.AccountID,
                            Status_code: account.LifeCycleStatusCode,
                            UUID: account.UUID,
                            ObjectID: account.ObjectID,
                            MainContactID: item.ContactID,//added

                            JuridicalAddress_City: account.City,
                            JuridicalCountry_code: account.CountryCode,
                            JuridicalAddress_Street: account.Street,
                            JuridicalAddress_HomeID: account.HouseNumber,
                            JuridicalAddress_RoomID: account.Room,

                            POBox : account.POBox,
                            POBoxCountry_code : account.POBoxDeviatingCountryCode,
                            POBoxState : account.POBoxDeviatingRegionCodeText,
                            POBoxCity : account.POBoxDeviatingCity
                        }
                        if (owner != undefined) {
                            customer.ResponsibleManager = owner.FormattedName;
                            customer.ResponsibleManagerID = owner.EmployeeID;
                            customer.ResponsibleManagerEmail = owner.Email;
                        }
                        if (note != undefined) {
                            customer.Note = note.Text;
                        }
                        await INSERT(customer).into(Customer);
                    }
                }
            });
        }

        async function _getDataFromAPI(request, dest, currentUserEmail) {

            try {

                let path = _getPath(currentUserEmail);

                let c4cResponse = await executeHttpRequest(dest, {
                    method: 'GET',
                    url: path
                });

                let c4cData = c4cResponse.data.d.results;
                return c4cData;

            } catch (e) {
                const tenant = e.response.config.baseURL;
                const url = e.response.request.path;
                let message = '';
                if (e.response.data.error) {
                    message = e.response.data.error.message.value;
                } else {
                    message = e.message;
                }
                const statusCode = e.response.status;
                const statusDescription = e.response.statusText;
                let finalMessage = `${statusCode} - ${statusDescription}\n\n Tenant url: ${tenant} \n\n Request path: ${url} \n\n Message: ${message}`

                request.error({
                    code: statusDescription,
                    message: finalMessage,
                    status: statusCode
                })
            }
        }

        async function _mapRecordInServiceInst(partnerProfileObjs) {

            try {
                for (let index = 0; index < partnerProfileObjs.length; index++) {
                    const partnerProfileObj = partnerProfileObjs[index];
                    const obj = {
                        ObjectID: partnerProfileObj.ObjectID,
                        Code: partnerProfileObj.ContactID,
                        FirstName: partnerProfileObj.FirstName,
                        LastName: partnerProfileObj.LastName,
                        MobilePhone: partnerProfileObj.NormalisedMobile,
                        Phone: partnerProfileObj.NormalisedPhone,
                        Email: partnerProfileObj.Email,
                        AccountID: partnerProfileObj.AccountID,
                        AccountUUID: partnerProfileObj.AccountUUID,
                        AccountFormattedName: partnerProfileObj.AccountFormattedName,
                        Country_code: partnerProfileObj.BusinessAddressCountryCode,
                        City: partnerProfileObj.BusinessAddressCity,
                        Status_code: partnerProfileObj.StatusCode,
                        Region: partnerProfileObj.BusinessAddressStateCodeText,
                        HouseNumber: partnerProfileObj.BusinessAddressHouseNumber,
                        Street: partnerProfileObj.BusinessAddressStreet,
                        PostalCode: partnerProfileObj.BusinessAddressStreetPostalCode
                    };

                    await INSERT(obj).into(PartnerProfile);

                };

            } catch (error) {
                console.log(error);
            }
        }

        this.before('READ', 'Customer', async (req) => {
            if (req._path.endsWith('ToCustomers')) {
                const currentEmail = req._.user.id;
                const currentPartner = await SELECT.one.from(PartnerProfile).where({ Email: currentEmail }).columns('Code',);
                const customersFromDB = await SELECT.from(Customer).where({MainContactID : currentPartner.Code});

                const path = `/sap/c4c/odata/v1/c4codataapi/ContactCollection?$filter=Email eq '${currentEmail}'&$expand=ContactIsContactPersonFor,ContactIsContactPersonFor/CorporateAccount,ContactIsContactPersonFor/CorporateAccount/OwnerEmployeeBasicData,ContactIsContactPersonFor/CorporateAccount/CorporateAccountTextCollection`;
                try {
                    const createRequestParameters = {
                        method: 'GET',
                        url: path,
                        headers: { 'content-type': 'application/json' }
                    }

                    const customers = await remoteC4CAPI.run(SELECT.from(RemoteContact).columns(root=>{
                        root('ContactID'),
                        root.ContactIsContactPersonFor(person=>{
                            person('ContactID'),
                            person.CorporateAccount(account => {
                                account('BusinessPartnerFormattedName'),
                                account('AccountID')
                                account('LifeCycleStatusCode'),
                                account('UUID')
                                account('ObjectID')
                                account('City'),account('CountryCode'),account('Street'),account('HouseNumber'),account('Room'),
                                account('POBox'),account('POBoxDeviatingCountryCode'),account('POBoxDeviatingRegionCodeText'),account('POBoxDeviatingCity'),
                                account.OwnerEmployeeBasicData(owner=>{owner('FormattedName'),owner('Email'),owner('EmployeeID')}),
                                account.CorporateAccountTextCollection(text=>text('Text'))
                            })
                        })
                    }).where({Email: currentEmail}));
    
                    await _createCustomerInstances(customers[0].ContactIsContactPersonFor, customersFromDB);
                    await deleteCustomerInstances(customers[0].ContactID, customers[0].ContactIsContactPersonFor, customersFromDB, Customer);
                
                    /*
                    const c4cResponse = await sendRequestToC4C(createRequestParameters);
                    const result = c4cResponse.data.d.results[0];
                    await _createCustomerInstances(c4cResponse, customersFromDB, currentPartner.Code); // 
                    await deleteCustomerInstances(result.ContactID,result.ContactIsContactPersonFor, customersFromDB, Customer);
                    */
                }
                catch (error) {
                    req.reject({
                        message: error.message
                    });
                }
            }
            else if (req._path != 'Customer' && req._path.endsWith(')') && req._.event != 'draftPrepare'){
                const customerID = req.data.ID;
                const customerPage = await SELECT.one.from(Customer,customerID).columns(root=>{root('ObjectID'),root('ID')});
                if (customerPage){
                     const customerInstance = await remoteC4CAPI.run(SELECT.one.from(RemoteCustomer).columns(root=>{
                         root('*'),
                         root.OwnerEmployeeBasicData(owner=>{owner('FormattedName'),owner('Email')}),
                         root.CorporateAccountTextCollection(text=>text('Text'))
                     }).where({ObjectID: customerPage.ObjectID}));
                     const owner = customerInstance.OwnerEmployeeBasicData;
                     const note = customerInstance.CorporateAccountTextCollection[0];
                     let customer = {
                         CustomerFormattedName: customerInstance.Name,
                         Status_code: customerInstance.LifeCycleStatusCode,
 
                         JuridicalAddress_City: customerInstance.City,
                         JuridicalCountry_code: customerInstance.CountryCode,
                         JuridicalAddress_Street: customerInstance.Street,
                         JuridicalAddress_HomeID: customerInstance.HouseNumber,
                         JuridicalAddress_RoomID: customerInstance.Room,
 
                         POBox : customerInstance.POBox,
                         POBoxCountry_code : customerInstance.POBoxDeviatingCountryCode,
                         POBoxState : customerInstance.POBoxDeviatingRegionCodeText,
                         POBoxCity : customerInstance.POBoxDeviatingCity
                         
                     }
                     if (owner != undefined) {
                         customer.ResponsiblemanagerID = customerInstance.OwnerID;
                         customer.ResponsibleManager = owner.FormattedName;
                         customer.ResponsibleManagerEmail = owner.Email;
                     }
                     if (note != undefined) {
                         customer.Note = note.Text;
                     }
                     await UPDATE(Customer, customerPage.ID).with(customer);
                 }
             }
        });

        this.before('NEW', 'Customer', async req =>{
            req.data.Status_code = "1";
           // connect to new Customer, created from Partner Page
           const currentEmail = req._.user.id;
            const currentPartner = await SELECT.one.from(PartnerProfile).where({Email:currentEmail});
            if (currentPartner){
                req.data.MainContactID = currentPartner.Code;
            }
        })
    
        this.on('READ', PartnerProfile, async (req, next) => {
            //open one record for object page 
            if (req._path == 'PartnerProfile') {
                const currentEmail = req._.user.id;
                const currentRecord = await SELECT.one.from(PartnerProfile).where({ Email: currentEmail });
                //delete excees created draft
                if (req._.data.ID){
                    await DELETE.from(PartnerProfile.drafts).where({ID : req._.data.ID})
                }
                if (currentRecord){
                    return req.reply(currentRecord);
                }
            }
            else return next();
        })

        this.before('READ', PartnerProfile, async (req) => {

            // check for one current Partner
            if (req._path == 'PartnerProfile'){
                const currentEmail = req._.user.id;
                const partner = await SELECT.one.from(PartnerProfile).where({ Email: currentEmail });
                if (!partner) {
                    const destination = await getDestination(destinationName);
                    try {
                        const partnerProfileObj = await _getDataFromAPI(req, destination, currentEmail);
                        await _mapRecordInServiceInst(partnerProfileObj);
                    }
                    catch (error) {
                        req.reject({
                            message: error.message
                        });
                    }
                }
            }
        })

        this.before('NEW', 'Opportunity', async (req) => {
            const parentId = this._getParentIdFromPath(req);
            const customerDB = await SELECT.from(Customer).where({ ID: parentId });
            if (customerDB.length > 0) {
                req.data.ProspectPartyID = customerDB[0].InternalID;
                req.data.ProspectPartyName = customerDB[0].CustomerFormattedName;
                //req.data.MainEmployeeResponsiblePartyID = customerDB[0].ResponsibleManager;//id
                req.data.MainEmployeeResponsiblePartyName = customerDB[0].ResponsibleManager;
            }
            req.data.LifeCycleStatusCode_code = '1';
            req.data.LifeCycleStatusText = 'Open';
            const currentEmail = req._.user.id;
            const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: currentEmail });
            if(partner){
                req.data.MainContactID = partner.CODE;
            }
        });

        this.before('NEW', 'ServiceRequest', async (req) => {
            const parentId = this._getParentIdFromPath(req);
            const customerDB = await SELECT.one.from(Customer).where({ ID: parentId });
            const currentEmail = req._.user.id;
            if (customerDB) {
                req.data.CustomerID = customerDB.InternalID;
                req.data.CustomerFormattedName = customerDB.CustomerFormattedName;
                req.data.Customer_ID = customerDB.ID;
            }
            const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: currentEmail });
            if(partner){
                req.data.MainContactID = partner.CODE;
            }
       });

        this.before('SAVE', PartnerProfile, async (req) => {

            const path = `/sap/c4c/odata/v1/c4codataapi/ContactCollection('${req.data.ObjectID}')`;
            const body = {
                BusinessAddressCountryCode: req.data.Country_code,
                BusinessAddressCity: req.data.City,
                FirstName: req.data.FirstName,
                LastName: req.data.LastName,
                Mobile: req.data.MobilePhone,
                Phone: req.data.Phone,
                Email: req.data.Email,
                StatusCode : req.data.Status_code,
                // Region
                BusinessAddressHouseNumber: req.data.HouseNumber,
                BusinessAddressStreet: req.data.Street,
                BusinessAddressStreetPostalCode: req.data.PostalCode
            }
            try {
                const createRequestParameters = {
                    method: 'PATCH',
                    url: path,
                    data: body,
                    headers: { 'content-type': 'application/json' }
                }
                await sendRequestToC4C(createRequestParameters);
            }
            catch (error) {
                req.reject({
                    message: error.message
                });
            }

            // create new Customers in remote
            req.data.ToCustomers.filter(customer=>customer.UUID == null).forEach(async customerData => {
                await createNewCustomerInRemote(customerData, Customer, req);
            });

            // create new Opportunities in remote
            const newOpports = [];
            req.data.ToCustomers.forEach(element => {
                const result = element.ToOpportunities.filter(opportunity => opportunity.UUID === null);
                newOpports.push(...result);
            });
            newOpports.forEach(async item => {
                let requestBody = {
                    Name: item.Subject,
                    ProspectPartyID: item.ProspectPartyID,
                    LifeCycleStatusCode: item.LifeCycleStatusCode_code,
                }
                // add products
                const products = [];
                const items = item.Items;
                for (let itemRow of items) {
                    const itemProductID = itemRow.ItemProductID;
                    const itemProduct = await SELECT.one.from(ItemProduct).where({ ID: itemProductID });
                    if (itemProduct) {
                        products.push({ ProductID: itemProduct.InternalID })
                    }
                }
                if (products.length > 0) {
                    requestBody.OpportunityItem = { results: products };
                }
                // add attachments
                if (item.Attachment && item.Attachment.length !== 0) {
                    const results = [];
                    createAttachmentBody(item, results);
                    requestBody.OpportunityAttachmentFolder = { results };
                }

                try {
                    let createRequestParameters = {
                        method: 'POST',
                        url: `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection`,
                        data: requestBody,
                        headers: {
                            'content-type': 'application/json'
                        }
                    }
                    const createdOppt = await sendRequestToC4C(createRequestParameters);
                    if (createdOppt && createdOppt.data && createdOppt.data.d && createdOppt.data.d.results) {
                        const createdData = createdOppt.data.d.results;
                        await UPDATE(Opportunity)
                            .where({ ID: item.ID })
                            .with({
                                UUID: createdData.UUID,
                                ObjectID: createdData.ObjectID,
                                MainEmployeeResponsiblePartyName: createdData.MainEmployeeResponsiblePartyName,
                                InternalID: createdData.ID

                            });

                        if (item.Attachment && item.Attachment.length !== 0) {
                            createRequestParameters = {
                                method: 'GET',
                                url: createdData.OpportunityAttachmentFolder.__deferred.uri,
                                headers: { 'content-type': 'application/json' }
                            }
                            // save ObjectID for the first time
                            const attachmentResponse = await sendRequestToC4C(createRequestParameters);
                            const attachmentsInResponse = attachmentResponse.data.d.results;
                            for (let i = 0; i < attachmentsInResponse.length; i++) {
                                const attachmentInDB = item.Attachment[i];
                                const ObjectID = attachmentsInResponse[i].ObjectID;
                                await UPDATE(Attachement, attachmentInDB.ID).set({ ObjectID: ObjectID });
                            }
                        }
                    }
                } catch (e) {
                    console.log(e)
                }
            })
            // create new Service Requests in remote
            const newTickets = [];
            req.data.ToCustomers.forEach(element => {
                const result = element.ToServiceRequests.filter(serviceRequest => serviceRequest.UUID === null);
                newTickets.push(...result);
            });
            newTickets.forEach(async item => {
                let customer;
                const customerID = item.Customer_ID;
                let internalBuyerID;
                if (customerID) {
                    customer = await SELECT.from(Customer).where({ ID: customerID });
                    if (customer[0]) {
                        internalBuyerID = customer[0].InternalID;
                    }
                }

                let body = {
                    Name: item.ProblemDescription,
                    BuyerPartyID: internalBuyerID,
                    ServiceRequestUserLifeCycleStatusCode: item.Status_code,
                    //oppt - document reference?
                    //category - codes are not matches
                    //processor - ovs of Employees from Remote
                }
                // add problem item
                let products = [];
                // if (item.ProblemItem != null) {
                //     const itemInstance = await SELECT.one.from(Item).where({ ID: item.ProblemItem });
                //     products.push({ ProductID: itemInstance.ProductInternalID });
                //     body.ServiceRequestItem = { results: products };
                // }
                // add attachments
                if (item.Attachment && item.Attachment.length !== 0) {
                    const results = [];
                    createAttachmentBody(item, results);
                    body.ServiceRequestAttachmentFolder = { results };
                }

                await linkSelectedOpportunity(item, Opportunity, body);

                let createRequestParameters = {
                    method: 'POST',
                    url: `/sap/c4c/odata/v1/c4codataapi/ServiceRequestCollection`,
                    data: body,
                    headers: { 'content-type': 'application/json' }
                }
                const c4cResponse = await sendRequestToC4C(createRequestParameters);
                // Update UUID
                if (c4cResponse.status == '201' && c4cResponse.data.d.results != undefined) {
                    const data = c4cResponse.data.d.results;
                    const objectID = data.ObjectID;
                    const UUID = data.UUID;
                    if (objectID && UUID) {
                        await UPDATE(ServiceRequest, item.ID).with({
                            UUID: UUID,
                            ObjectID: objectID,
                            InternalID: data.ID,
                            Processor: data.ProcessorPartyName
                        });
                    }
                    if (item.Attachment && item.Attachment.length !== 0) {
                        createRequestParameters = {
                            method: 'GET',
                            url: data.ServiceRequestAttachmentFolder.__deferred.uri,
                            headers: { 'content-type': 'application/json' }
                        }
                        // save ObjectID for the first time
                        const attachmentResponse = await sendRequestToC4C(createRequestParameters);
                        const attachmentsInResponse = attachmentResponse.data.d.results;
                        for (let i = 0; i < attachmentsInResponse.length; i++) {
                            const attachmentInDB = item.Attachment[i];
                            const ObjectID = attachmentsInResponse[i].ObjectID;
                            await UPDATE(Attachement, attachmentInDB.ID).set({ ObjectID: ObjectID });
                        }

                    }
                }
            });
        });
        
        this.on('updateAllFieldsFromRemote', async (req) => {
            const email = req._.user.id;
            const path = `/sap/c4c/odata/v1/c4codataapi/ContactCollection?$filter=Email eq '${email}'&$expand=ContactIsContactPersonFor,ContactIsContactPersonFor/CorporateAccount,ContactIsContactPersonFor/CorporateAccount/OwnerEmployeeBasicData,ContactIsContactPersonFor/CorporateAccount/CorporateAccountTextCollection`;

            try {
                const createRequestParameters = {
                    method: 'GET',
                    url: path,
                    headers: { 'content-type': 'application/json' }
                }
                const c4cResponse = await sendRequestToC4C(createRequestParameters);

                if (!c4cResponse.data.d.results[0]) { return; }
                const partnerProfileObj = c4cResponse.data.d.results[0];

                const partnerObj = {
                    FirstName: partnerProfileObj.FirstName,
                    LastName: partnerProfileObj.LastName,
                    Phone: partnerProfileObj.NormalisedPhone,
                    MobilePhone: partnerProfileObj.NormalisedMobile,
                    Email: partnerProfileObj.Email,
                   // AccountID: partnerProfileObj.AccountID,
                   // AccountUUID: partnerProfileObj.AccountUUID,
                    AccountFormattedName: partnerProfileObj.AccountFormattedName,
                    Country_code: partnerProfileObj.BusinessAddressCountryCode,
                    CountryDescription: partnerProfileObj.BusinessAddressCountryCodeText,
                    City: partnerProfileObj.BusinessAddressCity,
                    Status_code: partnerProfileObj.StatusCode,
                    Region: partnerProfileObj.BusinessAddressStateCodeText,
                    HouseNumber: partnerProfileObj.BusinessAddressHouseNumber,
                    Street: partnerProfileObj.BusinessAddressStreet,
                    PostalCode: partnerProfileObj.BusinessAddressStreetPostalCode
                };

                await UPDATE(PartnerProfile).with(partnerObj).where({ ObjectID: partnerProfileObj.ObjectID });

                const contacts = partnerProfileObj.ContactIsContactPersonFor;
                for (let i = 0; i < contacts.length; i++) {
                    const contact = contacts[i];
                    const account = contact.CorporateAccount;
                    const owner = account.OwnerEmployeeBasicData;
                    const note = account.CorporateAccountTextCollection.results;
                    let customer;
                    if (account != undefined) {
                        customer = {
                            CustomerFormattedName: account.BusinessPartnerFormattedName,
                            InternalID: account.AccountID,
                            Status_code: account.LifeCycleStatusCode,

                            JuridicalAddress_City: account.City,
                            JuridicalCountry_code: account.CountryCode,
                            JuridicalAddress_Street: account.Street,
                            JuridicalAddress_HomeID: account.HouseNumber,
                            JuridicalAddress_RoomID: account.Room,

                            IndividualAddress_City: account.City,
                            IndividualCountry_code: account.CountryCode,
                            IndividualAddress_Street: account.Street,
                            IndividualAddress_HomeID: account.HouseNumber,
                            IndividualAddress_RoomID: account.Room,
                            MainContactID : partnerProfileObj.ContactID // added
                        }
                        if (owner != undefined) {
                            customer.ResponsibleManager = owner.FormattedName;
                        }
                        if (note != undefined) {
                            customer.Note = note.Text;
                        }

                        const cust = await SELECT.one.from(Customer).where({ ObjectID: account.ObjectID });

                        if (cust)
                            await UPDATE(Customer).with(customer).where({ ObjectID: account.ObjectID })
                        else
                            await INSERT(customer).into(Customer);
                    }
                }
                return this.read(PartnerProfile).where({Email : email});
            }
            catch (error) {
                req.reject({
                    message: error.message
                });
            }

        });

        this.on('updateFromRemote', async (req) => { // update serviceRequests or Opportunities from remote
            const pathString = req._path;
            const toServiceRequestsString = "ToServiceRequests(ID=";
            const serviceRequestsStart = pathString.indexOf(toServiceRequestsString);
            const toOpportunitiesString = "ToOpportunities(ID=";
            const opportunitiesStart = pathString.indexOf(toOpportunitiesString);


            if (serviceRequestsStart !== -1) {
            const startIndex = serviceRequestsStart + toServiceRequestsString.length
                const serviceRequestID = pathString.substring(startIndex, startIndex + 36);

                const obj = await SELECT.one.from(ServiceRequest, serviceRequestID);

                let path = `/sap/c4c/odata/v1/c4codataapi/ServiceRequestCollection('${obj.ObjectID}')?$expand=ServiceRequestAttachmentFolder`;
                try {
                    let createRequestParameters = {
                        method: 'GET',
                        url: path,
                        headers: { 'content-type': 'application/json' }
                    }
                    const c4cResponse = await sendRequestToC4C(createRequestParameters);
                    const serviceRequestResponse = c4cResponse.data.d.results;

                    const LastChangeDateTime = serviceRequestResponse.LastChangeDateTime;
                    const timestamp = serviceRequestResponse.LastChangeDateTime.substring(LastChangeDateTime.indexOf('(') + 1, LastChangeDateTime.indexOf(')'));
                    const date = new Date(Number(timestamp));
                    const year = date.getFullYear();
                    const month = String(date.getMonth() + 1).padStart(2, '0'); // Month is 0-indexed, so add 1 and pad with '0' if necessary
                    const day = String(date.getDate()).padStart(2, '0'); // Pad day with '0' if necessary
                    const formattedDate = `${year}-${month}-${day}`;

                    const serviceRequest = {
                        CustomerID: serviceRequestResponse.BuyerPartyID,
                        Status_code: serviceRequestResponse.ServiceRequestLifeCycleStatusCode,
                        LastChangingDate: formattedDate,
                        Processor: serviceRequestResponse.ProcessorPartyName,
                        RequestProcessingTime: serviceRequestResponse.RequestInProcessdatetimeContent,
                        OrderID: serviceRequestResponse.SalesOrderID,
                        ProblemDescription: serviceRequestResponse.Name,
                        MainContactID: serviceRequestResponse.BuyerMainContactPartyID,
                    }

                    await UPDATE(ServiceRequest).with(serviceRequest).where({ ObjectID: serviceRequestResponse.ObjectID });

                    if (serviceRequestResponse.ServiceRequestAttachmentFolder.length) {
                        serviceRequestResponse.ServiceRequestAttachmentFolder.forEach(async attachmentResponse => {
                            if (attachmentResponse) {
                                const str = attachmentResponse.Binary;
                                const content = Buffer.from(str, 'base64').toString();
                                const buffer = Buffer.from(content, 'utf-8');
                                const attachment = {
                                    content: buffer,
                                    fileName: attachmentResponse.Name,
                                    url: attachmentResponse.DocumentLink,
                                    mediaType: attachmentResponse.MimeType
                                }
                                const attachmentInDB = await SELECT.one.from(Attachement).where({ ObjectID: attachmentResponse.ObjectID });
                                if (attachmentInDB)
                                    await UPDATE(Attachement, attachmentInDB.ID).with(attachment);
                                else {
                                    attachment.ObjectID = attachmentResponse.ObjectID;
                                    attachment.ServiceRequest_ID = serviceRequestID;
                                    await INSERT.into(Attachement).entries(attachment);
                                }
                            }
                        });
                    }
                    // if no ObjectID is in remote attachments, need to delete
                    const attachmentsInDB = await SELECT(Attachement).where({ ServiceRequest_ID: serviceRequestID });

                    // if (attachmentsInDB.length) {
                    //     const attachmentsToBeDeleted = getObjectsWithDifferentPropertyValue(attachmentsInDB,
                    //         serviceRequestResponse.ServiceRequestAttachmentFolder, "ObjectID", "ObjectID");
                    //     const attachmentObjectIDsToBeDeleted = attachmentsToBeDeleted.map(item => item.ObjectID);
                    //     if (attachmentObjectIDsToBeDeleted.length)
                    //         await DELETE.from(Attachement).where({ ObjectID: attachmentObjectIDsToBeDeleted });
                    // }

                    return SELECT(ServiceRequest, serviceRequestID);
                }
                catch (error) {
                    req.reject({
                        message: error.message
                    });
                }

            }
            if (opportunitiesStart !== -1) {
                const startIndex = opportunitiesStart + toOpportunitiesString.length;
                const opportunityID = pathString.substring(startIndex, startIndex + 36);

                const obj = await SELECT.one.from(Opportunity, opportunityID);

                let path = `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection('${obj.ObjectID}')?$expand=OpportunityAttachmentFolder`;
                try {
                    let createRequestParameters = {
                        method: 'GET',
                        url: path,
                        headers: { 'content-type': 'application/json' }
                    }
                    const c4cResponse = await sendRequestToC4C(createRequestParameters);
                    const opportunityResponse = c4cResponse.data.d.results;

                    const LastChangeDateTime = opportunityResponse.LastChangeDateTime;
                    const timestamp = opportunityResponse.LastChangeDateTime.substring(LastChangeDateTime.indexOf('(') + 1, LastChangeDateTime.indexOf(')'));
                    const date = new Date(Number(timestamp));
                    const year = date.getFullYear();
                    const month = String(date.getMonth() + 1).padStart(2, '0'); // Month is 0-indexed, so add 1 and pad with '0' if necessary
                    const day = String(date.getDate()).padStart(2, '0'); // Pad day with '0' if necessary
                    const formattedDate = `${year}-${month}-${day}`;

                    const opportunity = {
                        InternalID: opportunityResponse.ID,
                        ProspectPartyID: opportunityResponse.ProspectPartyID,
                        ProspectPartyName: opportunityResponse.ProspectPartyName,
                        Subject: opportunityResponse.Name,
                        LifeCycleStatusCode_code: opportunityResponse.LifeCycleStatusCode,
                        MainEmployeeResponsiblePartyID: opportunityResponse.MainEmployeeResponsiblePartyID,
                        MainEmployeeResponsiblePartyName: opportunityResponse.MainEmployeeResponsiblePartyName,
                        CreatedBy: opportunityResponse.CreatedBy,
                        LastChangeDateTime: formattedDate,
                        LastChangedBy: opportunityResponse.LastChangedBy,
                        MainContactID: opportunityResponse.PrimaryContactPartyID,
                    }

                    await UPDATE(Opportunity).with(opportunity).where({ ObjectID: opportunityResponse.ObjectID });

                    if (opportunityResponse.OpportunityAttachmentFolder.length) {
                        opportunityResponse.OpportunityAttachmentFolder.forEach(async attachmentResponse => {
                            if (attachmentResponse) {
                                const str = attachmentResponse.Binary;
                                const content = Buffer.from(str, 'base64').toString();
                                const buffer = Buffer.from(content, 'utf-8');
                                const attachment = {
                                    content: buffer,
                                    fileName: attachmentResponse.Name,
                                    url: attachmentResponse.DocumentLink,
                                    mediaType: attachmentResponse.MimeType
                                }
                                const attachmentInDB = await SELECT.one.from(Attachement).where({ ObjectID: attachmentResponse.ObjectID });
                                if (attachmentInDB)
                                    await UPDATE(Attachement, attachmentInDB.ID).with(attachment);
                                else {
                                    attachment.ObjectID = attachmentResponse.ObjectID;
                                    attachment.Opportunity_ID = opportunityID;
                                    await INSERT.into(Attachement).entries(attachment);
                                }
                            }
                        });
                    }
                    // if no ObjectID is in remote attachments, need to delete
                    const attachmentsInDB = await SELECT(Attachement).where({ Opportunity_ID: opportunityID });

                    if (attachmentsInDB.length) {
                        const attachmentsToBeDeleted = getObjectsWithDifferentPropertyValue(attachmentsInDB,
                            opportunityResponse.OpportunityAttachmentFolder, "ObjectID", "ObjectID");
                        const attachmentObjectIDsToBeDeleted = attachmentsToBeDeleted.map(item => item.ObjectID);
                        if (attachmentObjectIDsToBeDeleted.length)
                            await DELETE.from(Attachement).where({ ObjectID: attachmentObjectIDsToBeDeleted });
                    }

                    return SELECT(Opportunity, opportunityID);
                }
                catch (error) {
                    req.reject({
                        message: error.message
                    });
                }
            }
        });

        this.on('LoadProducts', async (req) => {
            await loadProductsAndPricesListsFromC4C(ItemProduct, SalesPriceList, req);
        })

        return super.init();
    }

    _getParentIdFromPath(req) {
        const path = req._path;
        const toCustomersString = "ToCustomers(ID=";
        const customersStart = path.indexOf(toCustomersString);
        const startIndex = customersStart + toCustomersString.length;
        const parentId = path.substring(startIndex, startIndex + 36);
        return parentId;
    }
}

module.exports = { PartnerService };