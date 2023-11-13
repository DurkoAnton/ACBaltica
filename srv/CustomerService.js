const cds = require('@sap/cds')
//const { fetchNext } = require('hdb/lib/protocol/request');
const { getObjectsWithDifferentPropertyValue, createAttachmentBody, linkSelectedOpportunity, createNewCustomerInRemote, createItemsBody, deleteCustomerInstances, deleteOpportunityInstances, deleteServiceRequestInstances } = require('./libs/utils');
const { sendRequestToC4C } = require('./libs/ManageAPICalls');
const { loadProductsAndPricesListsFromC4C } = require('./libs/dataLoading');

class CustomerService extends cds.ApplicationService {
    async init() {

        const { Customer, Opportunity, ServiceRequest, Attachement, Item, ItemProduct, SalesPriceList/*, remoteCustomer */} = this.entities;

         //const remoteC4CAPI = await cds.connect.to('remote');

        // this.on('READ', remoteCustomer, req => {
        //     const d = remoteC4CAPI.run(req.query)
        //     return d;
        // });

        async function _createCustomerInstances(c4cResponse, customersFromDB) {
            let customer;
            if (!c4cResponse.data.d.results[0]) { return; }
            const corporateAccounts = c4cResponse.data.d.results[0].ContactIsContactPersonFor;
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

                            IndividualAddress_City: account.City,
                            IndividualCountry_code: account.CountryCode,
                            IndividualAddress_Street: account.Street,
                            IndividualAddress_HomeID: account.HouseNumber,
                            IndividualAddress_RoomID: account.Room
                        }
                        if (owner != undefined) {
                            customer.ResponsibleManager = owner.FormattedName;
                        }
                        if (note != undefined) {
                            customer.Note = note.Text;
                        }
                        await INSERT(customer).into(Customer);
                    }
                }
            });
        }

        async function _createOpportunityInstances(c4cResponse, customerUUID, opportunitiesFromDB) {
            const oppts = c4cResponse.data.d.results;
            oppts.forEach(async item => {
                if (opportunitiesFromDB.filter(n => n.UUID == item.UUID).length == 0) {
                    let opportunity = {
                        UUID: item.UUID,
                        ObjectID: item.ObjectID,
                        InternalID: item.ID,
                        ProspectPartyID: item.ProspectPartyID,
                        ProspectPartyName: item.ProspectPartyName,
                        Subject: item.Name,
                        LifeCycleStatusCode_code: item.LifeCycleStatusCode,
                        LifeCycleStatusText: item.LifeCycleStatusText,
                        MainEmployeeResponsiblePartyID: item.MainEmployeeResponsiblePartyID,
                        MainEmployeeResponsiblePartyName: item.MainEmployeeResponsiblePartyName,
                        //CreationDateTime: item.CreationDateTime,
                        CreatedBy: item.CreatedBy,
                        //LastChangeDateTime: item.LastChangeDateTime,
                        LastChangedBy: item.LastChangedBy,
                        Customer_ID: customerUUID,
                        MainContactID: item.PrimaryContactPartyID,
                    }

                    const attachmentFolder = item.OpportunityAttachmentFolder[0];
                    let attachment;
                    if (attachmentFolder) {
                        let str = attachmentFolder.Binary;
                        let content = Buffer.from(str, 'base64').toString();
                        let buffer = Buffer.from(content, 'utf-8');
                        attachment = {
                            content: buffer,
                            fileName: attachmentFolder.Name,
                            url: attachmentFolder.DocumentLink,
                            mediaType: 'text/plain'
                        }
                    }
                    const insertResult = await INSERT(opportunity).into(Opportunity);

                    if (insertResult.affectedRows > 0) {
                        const opportunityID = insertResult.results[0].values[14];
                        if (attachment) {
                            attachment.Opportunity_ID = opportunityID; // link attachment and SR   values[14]-id
                            await INSERT(attachment).into(Attachement);
                        }
                        // add items
                        if (item.OpportunityItem && item.OpportunityItem.length != 0) {
                            const items = await createItemsBody(item.OpportunityItem, ItemProduct, opportunityID);
                            await INSERT(items).into(Item);
                        }
                    }
                }
            });
        }

        async function _createServiceRequestInstances(c4cResponse, customerUUID, serviceRequestsFromDB) {
            const serviceRequests = c4cResponse.data.d.results;
            serviceRequests.forEach(async item => {
                if (serviceRequestsFromDB.filter(n => n.UUID == item.UUID).length == 0) {
                    const attachmentFolder = item.ServiceRequestAttachmentFolder[0];
                    let serviceRequest = {
                        UUID: item.UUID,
                        ObjectID: item.ObjectID,
                        CustomerID: item.BuyerPartyID,
                        CustomerFormattedName: item.BuyerPartyName,
                        InternalID: item.ID,
                        Status_code: item.ServiceRequestLifeCycleStatusCode,
                        Processor: item.ProcessorPartyName,
                        RequestProcessingTime: item.RequestInProcessdatetimeContent,
                        OrderID: item.SalesOrderID,
                        ProblemDescription: item.Name,
                        Customer_ID: customerUUID,
                        MainContactID: item.BuyerMainContactPartyID,
                    }
                    let attachment;
                    if (attachmentFolder) {
                        let str = attachmentFolder.Binary;
                        let content = Buffer.from(str, 'base64').toString();
                        let buffer = Buffer.from(content, 'utf-8');
                        attachment = {
                            content: buffer,
                            fileName: attachmentFolder.Name,
                            url: attachmentFolder.DocumentLink,
                            mediaType: 'text/plain'
                        }
                    }
                    // format date
                    var milliSeconds = item.CreationDateTime.substring(item.CreationDateTime.indexOf('(') + 1, item.CreationDateTime.indexOf(')'))
                    var date = new Date(1970, 0, 1, 0, 0, 0, Number(milliSeconds));

                    let year = date.getFullYear();
                    let month = String(date.getMonth() + 1).padStart(2, '0'); // Month is 0-indexed, so add 1 and pad with '0' if necessary
                    let day = String(date.getDate()).padStart(2, '0'); // Pad day with '0' if necessary
                    serviceRequest.CreationDate = `${year}-${month}-${day}`;

                    milliSeconds = item.LastChangeDateTime.substring(item.LastChangeDateTime.indexOf('(') + 1, item.LastChangeDateTime.indexOf(')'))
                    date = new Date(1970, 0, 1, 0, 0, 0, Number(milliSeconds));
                    year = date.getFullYear();
                    month = String(date.getMonth() + 1).padStart(2, '0');
                    day = String(date.getDate()).padStart(2, '0');

                    serviceRequest.LastChangingDate = `${year}-${month}-${day}`;
                    const requestResult = await INSERT(serviceRequest).into(ServiceRequest);
                    if (attachment && requestResult.affectedRows > 0) {
                        attachment.ServiceRequest_ID = requestResult.results[0].values[13]; // link attachment and SR   values[13]-id
                        await INSERT(attachment).into(Attachement);
                    }
                }
            });
        }

        this.before('READ', 'Customer', async (req) => {
            // OWL Read -> Get all data from C4C
            const path = req._path;
            // stop calling api when showing help value lists
            // on list req._queryOptions.$top == 30
            if (path == 'Customer' && req._queryOptions && req._queryOptions.$top && req._queryOptions.$top == '30') {
                const customersFromDB = await SELECT.from(Customer);
                if (!req.req) return; // get all Customers only for List Report
                var email = req._.user.id;
                //const pathWithSelect = `/sap/c4c/odata/v1/c4codataapi/ContactCollection?$filter=Email eq '${email}'&$expand=ContactIsContactPersonFor,ContactIsContactPersonFor/CorporateAccount,ContactIsContactPersonFor/CorporateAccount/OwnerEmployeeBasicData,ContactIsContactPersonFor/CorporateAccount/CorporateAccountTextCollection&$select=ContactID,ContactIsContactPersonFor/CorporateAccount/BusinessPartnerFormattedName,ContactIsContactPersonFor/CorporateAccount/AccountID,ContactIsContactPersonFor/CorporateAccount/LifeCycleStatusCode,ContactIsContactPersonFor/CorporateAccount/UUID,ContactIsContactPersonFor/CorporateAccount/ObjectID,ContactIsContactPersonFor/CorporateAccount/City,ContactIsContactPersonFor/CorporateAccount/CountryCode,ContactIsContactPersonFor/CorporateAccount/Street,ContactIsContactPersonFor/CorporateAccount/HouseNumber,ContactIsContactPersonFor/CorporateAccount/Room,ContactIsContactPersonFor/CorporateAccount/OwnerEmployeeBasicData/FormattedName,ContactIsContactPersonFor/CorporateAccount/CorporateAccountTextCollection/Text`;
                const path = `/sap/c4c/odata/v1/c4codataapi/ContactCollection?$filter=Email eq '${email}'&$expand=ContactIsContactPersonFor,ContactIsContactPersonFor/CorporateAccount,ContactIsContactPersonFor/CorporateAccount/OwnerEmployeeBasicData,ContactIsContactPersonFor/CorporateAccount/CorporateAccountTextCollection`;
                try {
                    const createRequestParameters = {
                        method: 'GET',
                        url: path,
                        headers: { 'content-type': 'application/json' }
                    }
                    const c4cResponse = await sendRequestToC4C(createRequestParameters);
                    await _createCustomerInstances(c4cResponse, customersFromDB);
                    await deleteCustomerInstances(c4cResponse, customersFromDB, Customer);
                }
                catch (error) {
                    req.reject({
                        message: error.message
                    });
                }
                //update object page header data
                if (req._path == 'Customer' && req._.event == 'READ') { // read only for general list
                    var email = req._.user.id;
                    const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: email });
                    if (partner) {
                        req.query.where({ 'MainContactID': partner.CODE });
                    }
                }
            }
            
        })

        this.after('READ', 'ServiceRequest', each => {
            if (each.Status_code == '') { // default value
                each.Status_code = '1';
            }
        })

        this.before('READ', 'ServiceRequest', async (req) => {

            // OWL SR Read - > get all SRs   
            if (req._path.startsWith('Customer') && req._path.endsWith('ToServiceRequests') && req.event == 'READ') {
                // const serviceRequestsFromDB = await SELECT.from(ServiceRequest);
                let customerUUID = req._path.substring(12, 48);
                var customerInternalID;
                var serviceRequestsFromDB;
                if (customerUUID) {
                    
                    customerFromDB = await SELECT.from(Customer).where({ ID: customerUUID });
                    if (customerFromDB[0] != undefined) {
                        customerInternalID = customerFromDB[0].InternalID;
                    }
                    serviceRequestsFromDB = await SELECT.from(ServiceRequest).where({ Customer_ID: customerUUID });
                }

                if (customerInternalID) {
                    var customerFromDB;

                    const path = `/sap/c4c/odata/v1/c4codataapi/ServiceRequestCollection?$filter=BuyerPartyID eq '${customerInternalID}'&$expand=ServiceRequestAttachmentFolder`;
                    try {
                        const createRequestParameters = {
                            method: 'get',
                            url: path,
                            headers: {
                                'content-type': 'application/json'
                            }
                        }

                        const c4cResponse = await sendRequestToC4C(createRequestParameters);
                        await _createServiceRequestInstances(c4cResponse, customerUUID, serviceRequestsFromDB);
                        await deleteServiceRequestInstances(c4cResponse, serviceRequestsFromDB, ServiceRequest)
                    }
                    catch (error) {
                        req.reject({
                            message: error.message
                        });
                    }
                }
            }
        });

        this.before('READ', 'Opportunity', async (req) => {

            if (req._path.startsWith('Customer') && req._path.endsWith('ToOpportunities') && req.event == 'READ') {

                let opportunitiesFromDB = [];
                const parentId = req._path.substring(12, 48);
                if (parentId) {
                    opportunitiesFromDB = await SELECT.from(Opportunity).where({ Customer_ID: parentId });
                }
                const customerDB = await SELECT.from(Customer).where({ ID: parentId });
                let customerInternalID;
                if (customerDB.length > 0) {
                    customerInternalID = customerDB[0].InternalID;
                }

                if (customerInternalID) {
                    const path = `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection?$filter=ProspectPartyID eq '${customerInternalID}'&$expand=OpportunityAttachmentFolder,OpportunityItem`;
                    try {
                        const createRequestParameters = {
                            method: 'get',
                            url: path,
                            headers: {
                                'content-type': 'application/json'
                            }
                        }

                        const c4cResponse = await sendRequestToC4C(createRequestParameters);
                        await _createOpportunityInstances(c4cResponse, parentId, opportunitiesFromDB);
                        await deleteOpportunityInstances(c4cResponse, opportunitiesFromDB);
                    }
                    catch (error) {
                        req.reject({
                            message: error.message
                        });
                    }
                }
            }
        })

        this.on('LoadProducts', async (req) => {
            await loadProductsAndPricesListsFromC4C(ItemProduct, SalesPriceList, req);
        })

        this.before('NEW', 'Opportunity', async (req) => {
            const parentId = req._path.substring(12, 48);
            const customerDB = await SELECT.from(Customer).where({ ID: parentId });
            var email = req._.user.id;;
            if (customerDB.length > 0) {
                req.data.ProspectPartyID = customerDB[0].InternalID;
                req.data.ProspectPartyName = customerDB[0].CustomerFormattedName;
                //req.data.MainEmployeeResponsiblePartyID = customerDB[0].ResponsibleManager;//id
                req.data.MainEmployeeResponsiblePartyName = customerDB[0].ResponsibleManager;
            }
            req.data.LifeCycleStatusCode_code = '1';
            req.data.LifeCycleStatusText = 'Open';
            //if (req.headers['x-username']) {
                const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: email});
                if (partner) {
                    req.data.MainContactID = partner.CODE;
                }
            //}
        })

        this.before('NEW', 'Item', async (req) => {
            req.data.OpportunityID = req.data.toOpportunity_ID;
        })

        this.before('NEW', 'ServiceRequest', async (req) => {
            const parentId = req._path.substring(12, 48);
            var email = req._.user.id;;
            const customerDB = await SELECT.one.from(Customer).where({ ID: parentId });
            if (customerDB) {
                req.data.CustomerID = customerDB.InternalID;
                req.data.CustomerFormattedName = customerDB.CustomerFormattedName;
                req.data.Customer_ID = customerDB.ID;
            }
            //if (req.headers['x-username']) {
                const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email:  email });
                if (partner) {
                    req.data.MainContactID = partner.CODE;
                }
            //}
        })

        this.before('NEW', 'Customer', async (req) => {
            req.data.Status_code = "1";
            var email = req._.user.id;;
            //if (req.headers['x-username']) {
                const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: email });
                if (partner) {
                    req.data.MainContactID = partner.CODE;
                }
            //}
        })

        this.after('SAVE', 'Customer', async (req) => {
            //create new Opportunities in remote
             const newOpports = req.ToOpportunities.filter(n => n.UUID == null)
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
            const newTickets = req.ToServiceRequests.filter(n => n.UUID == null);
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
                }
                // link selected Opportunity
                await linkSelectedOpportunity(item, Opportunity, body);

                // link selected Items
                let products = [];
                if (item.ProblemItem != null) {
                    const itemInstance = await SELECT.one.from(Item).where({ ID: item.ProblemItem });
                    products.push({ ProductID: itemInstance.ProductInternalID });
                    body.ServiceRequestItem = { results: products };
                }

                if (item.Attachment && item.Attachment.length !== 0) {
                    const results = [];
                    createAttachmentBody(item, results);
                    body.ServiceRequestAttachmentFolder = { results };
                }

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
                        //return this.read('ServiceRequest');
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

            const customerData = req;
            await createNewCustomerInRemote(customerData, Customer, req);

        });

        // this.before('PATCH', ServiceRequest, async req =>{
        //     req.data.Customer_ID = '03d6cdea-6957-42f3-99e7-9c90cf5dd220';
        //    //const r = await UPDATE(ServiceRequest).where({ID : req.data.ID}).set({Customer_ID : '03d6cdea-6957-42f3-99e7-9c90cf5dd220'})
        //     console.log('1');
        // })

        this.on('updateAllFieldsFromRemote', async (req) => {
            let customerID = req._path.substring(12, 48);

            const obj = await SELECT.one.from(Customer, customerID);
            let path = `/sap/c4c/odata/v1/c4codataapi/CorporateAccountCollection('${obj.ObjectID}')?$expand=CorporateAccountTextCollection,OwnerEmployeeBasicData`
            try {
                let createRequestParameters = {
                    method: 'GET',
                    url: path,
                    headers: { 'content-type': 'application/json' }
                }
                let c4cResponse = await sendRequestToC4C(createRequestParameters);
                // if (!c4cResponse.data.d.results[0]) { return; }

                const account = c4cResponse.data.d.results;
                const owner = account.OwnerEmployeeBasicData;
                const note = account.CorporateAccountTextCollection[0];
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
                        IndividualAddress_RoomID: account.Room
                    }
                    if (owner != undefined) {
                        customer.ResponsibleManager = owner.FormattedName;
                        customer.ResponsibleManagerID = owner.EmployeeID;
                    }
                    if (note != undefined) {
                        customer.Note = note.Text;
                    }
                    await UPDATE(Customer).with(customer).where({ ObjectID: account.ObjectID });
                }

                const customerInternalID = account.AccountID;

                path = `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection?$filter=ProspectPartyID eq '${customerInternalID}'`;

                createRequestParameters = {
                    method: 'get',
                    url: path,
                    headers: {
                        'content-type': 'application/json'
                    }
                }

                c4cResponse = await sendRequestToC4C(createRequestParameters);

                const oppts = c4cResponse.data.d.results;
                oppts.forEach(async item => {
                    let opportunity = {
                        InternalID: item.ID,
                        ProspectPartyID: item.ProspectPartyID,
                        ProspectPartyName: item.ProspectPartyName,
                        Subject: item.Name,
                        LifeCycleStatusCode_code: item.LifeCycleStatusCode,
                        MainEmployeeResponsiblePartyID: item.MainEmployeeResponsiblePartyID,
                        MainEmployeeResponsiblePartyName: item.MainEmployeeResponsiblePartyName,
                        //CreationDateTime: item.CreationDateTime,
                        CreatedBy: item.CreatedBy,
                        //LastChangeDateTime: item.LastChangeDateTime,
                        LastChangedBy: item.LastChangedBy,
                        Customer_ID: customerID, // link to Customer
                        ObjectID: item.ObjectID,
                        UUID: item.UUID
                    }

                    const opp = await SELECT.one.from(Opportunity).where({ ObjectID: item.ObjectID });
                    if (opp)
                        await UPDATE(Opportunity).with(opportunity).where({ ObjectID: opportunity.ObjectID });
                    else
                        await INSERT(opportunity).into(Opportunity);
                });

                path = `/sap/c4c/odata/v1/c4codataapi/ServiceRequestCollection?$filter=BuyerPartyID eq '${customerInternalID}'`;

                createRequestParameters = {
                    method: 'get',
                    url: path,
                    headers: {
                        'content-type': 'application/json'
                    }
                }

                c4cResponse = await sendRequestToC4C(createRequestParameters);

                const items = c4cResponse.data.d.results;
                items.forEach(async item => {
                    let serviceRequest = {
                        UUID: item.UUID,
                        ObjectID: item.ObjectID,
                        CustomerID: item.BuyerPartyID,
                        InternalID: item.ID,
                        Status_code: item.ServiceRequestLifeCycleStatusCode,
                        Processor: item.ProcessorPartyName,
                        RequestProcessingTime: item.RequestInProcessdatetimeContent,
                        OrderID: item.SalesOrderID,
                        ProblemDescription: item.Name,
                        Customer_ID: customerID // link to Customer
                    }

                    const servReq = await SELECT.one.from(ServiceRequest).where({ objectID: item.ObjectID });
                    if (servReq)
                        await UPDATE(ServiceRequest).with(serviceRequest).where({ ObjectID: item.ObjectID });
                    else
                        await INSERT(serviceRequest).into(ServiceRequest);

                });
                return SELECT(Customer, customerID);

            }
            catch (error) {
                req.reject({
                    message: error.message
                });
            }

        });

        this.on('updateFromRemote', async (req) => { // update serviceRequests or Opportunities from remote
            const inputString = req._path;
            const toServiceRequestsString = "ToServiceRequests(ID=";
            const serviceRequestsStart = inputString.indexOf(toServiceRequestsString);
            const toOpportunitiesString = "ToOpportunities(ID=";
            const opportunitiesStart = inputString.indexOf(toOpportunitiesString);


            if (serviceRequestsStart !== -1) {
                const startIndex = serviceRequestsStart + toServiceRequestsString.length
                const serviceRequestID = inputString.substring(startIndex, startIndex + 36);

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
                    //if no ObjectID is in remote attachments, need to delete
                    //const attachmentsInDB = await SELECT(Attachement).where({ ServiceRequest_ID: serviceRequestID });

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
                const opportunityID = inputString.substring(startIndex, startIndex + 36);

                const obj = await SELECT.one.from(Opportunity, opportunityID);
                if (obj.ObjectID) {
                    let path = `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection('${obj.ObjectID}')?$expand=OpportunityAttachmentFolder,OpportunityItem`;
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
                            //InternalID: opportunityResponse.ID,
                            ProspectPartyID: opportunityResponse.ProspectPartyID,
                            ProspectPartyName: opportunityResponse.ProspectPartyName,
                            Subject: opportunityResponse.Name,
                            LifeCycleStatusCode_code: opportunityResponse.LifeCycleStatusCode,
                            MainEmployeeResponsiblePartyID: opportunityResponse.MainEmployeeResponsiblePartyID,
                            MainEmployeeResponsiblePartyName: opportunityResponse.MainEmployeeResponsiblePartyName,
                            //CreatedBy: opportunityResponse.CreatedBy,
                            LastChangeDateTime: formattedDate,
                            LastChangedBy: opportunityResponse.LastChangedBy,
                            MainContactID: opportunityResponse.PrimaryContactPartyID,
                        }

                        await UPDATE(Opportunity).with(opportunity).where({ ObjectID: opportunityResponse.ObjectID });

                        // add items
                        if (opportunityResponse.OpportunityItem) {
                            //exclude existing rows
                            const existingItems = await SELECT.from(Item).where({ toOpportunity_ID: opportunityID });
                            const newRows =
                                opportunityResponse.OpportunityItem.filter(item => !existingItems.some(itemExists => itemExists.ProductInternalID == item.ProductID));
                            if (newRows) {
                                const items = await createItemsBody(newRows, ItemProduct, opportunityID);
                                if (items.length != 0) {
                                    await INSERT(items).into(Item);
                                }
                            }
                        }

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
                        // const attachmentsInDB = await SELECT(Attachement).where({ Opportunity_ID: opportunityID });

                        // if (attachmentsInDB.length) {
                        //     const attachmentsToBeDeleted = getObjectsWithDifferentPropertyValue(attachmentsInDB,
                        //         opportunityResponse.OpportunityAttachmentFolder, "ObjectID", "ObjectID");
                        //     const attachmentObjectIDsToBeDeleted = attachmentsToBeDeleted.map(item => item.ObjectID);
                        //     if (attachmentObjectIDsToBeDeleted.length)
                        //         await DELETE.from(Attachement).where({ ObjectID: attachmentObjectIDsToBeDeleted });
                        // }

                        return SELECT(Opportunity, opportunityID);
                    }
                    catch (error) {
                        req.reject({
                            message: error.message
                        });
                    }
                }
            }
        });

        return super.init();
    }
}
module.exports = { CustomerService };

