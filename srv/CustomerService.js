const cds = require('@sap/cds')
//const { fetchNext } = require('hdb/lib/protocol/request');
const { getObjectsWithDifferentPropertyValue, createAttachmentBody, linkSelectedOpportunity, 
    createNewCustomerInRemote, createItemsBody, deleteCustomerInstances, deleteOpportunityInstances, 
    deleteServiceRequestInstances, createAttachments, deleteAttachments } = require('./libs/utils');
const { sendRequestToC4C } = require('./libs/ManageAPICalls');
const { loadProductsAndPricesListsFromC4C } = require('./libs/dataLoading');

class CustomerService extends cds.ApplicationService {
    async init() {

        const { Customer, Opportunity, ServiceRequest, Attachement, Item, ItemProduct, SalesPriceList,
                RemoteCustomer, RemoteContact, RemoteOpportunity, RemoteServiceRequest, ServiceRequestInteraction,
                RemoteInteraction} = this.entities;

        const remoteC4CAPI = await cds.connect.to('api');
        const remoteOpptAPI = await cds.connect.to('opportunity');
        const remoteTicketAPI = await cds.connect.to('ticket');
        const remoteAPI = await cds.connect.to('interaction');


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

        async function _createOpportunityInstances(oppts, customerUUID, opportunitiesFromDB) {
           // const oppts = c4cResponse.data.d.results;
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

        async function _createServiceRequestInstances(serviceRequests, customerUUID, serviceRequestsFromDB) {
           // const serviceRequests = c4cResponse.data.d.results;
            serviceRequests.forEach(async item => {
                if (serviceRequestsFromDB.filter(n => n.UUID == item.UUID).length == 0) {
                    const attachmentFolder = item.ServiceRequestAttachmentFolder;
                    let serviceRequest = {
                        UUID: item.UUID,
                        ObjectID: item.ObjectID,
                        CustomerID: item.BuyerPartyID,
                        CustomerFormattedName: item.BuyerPartyName,
                        InternalID: item.ID,
                        Status_code: item.ServiceRequestLifeCycleStatusCode,
                        Processor: item.ProcessorPartyName,
                        //RequestProcessingTime: item.RequestInProcessdatetimeContent,
                        //OrderID: item.SalesOrderID,
                        Subject :  item.Name,
                        CreationDate : item.CreationDateTime,
                        LastChangingDate : item.LastChangeDateTime,
                        Customer_ID: customerUUID,
                        MainContactID: item.BuyerMainContactPartyID,
                        RequestInitialDateTime : item.RequestInitialReceiptdatetimecontent,
                        RequestEndDateTime : item.RequestedFulfillmentPeriodEndDateTime,
                        Attachment :[]
                    }
                    if (item.ResolvedOnDateTime != ''){ // check for valid date time value
                        serviceRequest.ResolutionDateTime = item.ResolvedOnDateTime;
                    }
                    if (item.ServiceIssueCategoryID != ''){
                        serviceRequest.Category_code = item.ServiceIssueCategoryID.replace('ZA_','');
                    }
                    let attachment;
                    attachmentFolder.forEach(attachmentInst => {
                        let str = attachmentInst.Binary;
                        let content = Buffer.from(str, 'base64').toString();
                        let buffer = Buffer.from(content, 'utf-8');
                        attachment = {
                            content: buffer,
                            fileName: attachmentInst.Name,
                            url: attachmentInst.DocumentLink,
                            mediaType: 'text/plain'
                        }
                        serviceRequest.Attachment.push(attachment)
                    });
                    const text = item.ServiceRequestTextCollection[0];
                    if (text){
                        serviceRequest.ProblemDescription = text.Text;
                    }
                    await INSERT(serviceRequest).into(ServiceRequest);
                }
            });
        }

        this.before('READ', 'Customer', async (req) => {
            // OWL Read -> Get all data from C4C
            const path = req._path;
            // stop calling api when showing help value lists
            // on list req._queryOptions.$top == 30
            const customersEditing = path.includes('IsActiveEntity=false'); // fetch customer from remote only for reading page not editing
            if (path == 'Customer' && !customersEditing && req._queryOptions && req._queryOptions.$top && req._queryOptions.$top == '30') {
                const customersFromDB = await SELECT.from(Customer);
                if (!req.req) return; // get all Customers only for List Report
                var email = req._.user.id;
                //the same request only based remote service
                const customers = await remoteC4CAPI.run(SELECT.from(RemoteContact).columns(root=>{
                    root('ContactID'),
                    root.ContactIsContactPersonFor(person=>{
                        person('ContactID'),
                        person.CorporateAccount(account => {
                            account('BusinessPartnerFormattedName'),
                            account('AccountID'),
                            account('LifeCycleStatusCode'),
                            account('UUID')
                            account('ObjectID')
                            account('City'),account('CountryCode'),account('Street'),account('HouseNumber'),account('Room'),
                            account('POBox'),account('POBoxDeviatingCountryCode'),account('POBoxDeviatingRegionCodeText'),account('POBoxDeviatingCity'),
                            account.OwnerEmployeeBasicData(owner=>{owner('FormattedName'),owner('Email'),owner('EmployeeID')}),
                            account.CorporateAccountTextCollection(text=>text('Text'))
                        })
                    })
                }).where({Email: email}));

                await _createCustomerInstances(customers[0].ContactIsContactPersonFor, customersFromDB);
                await deleteCustomerInstances(customers[0].ContactID, customers[0].ContactIsContactPersonFor, customersFromDB, Customer);
                
                if (req._path == 'Customer' && req._.event == 'READ') { // read only for general list
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
            const path = req._path;
            const editing = path.includes('IsActiveEntity=false'); // fetch from remote only for reading page not editing
            if (path.startsWith('Customer') && path.endsWith('ToServiceRequests') && !editing && req.event == 'READ' && req._ && req._._queryOptions && req._._queryOptions.$top) {
                // const serviceRequestsFromDB = await SELECT.from(ServiceRequest);
                let customerUUID = req._path.substring(12, 48);
                var customerInternalID;
                var serviceRequestsFromDB;
                if (customerUUID) {
                    
                    customerFromDB = await SELECT.one.from(Customer).columns('InternalID').where({ ID: customerUUID });
                    if (customerFromDB != undefined) {
                        customerInternalID = customerFromDB.InternalID;
                    }
                    serviceRequestsFromDB = await SELECT.from(ServiceRequest).where({ Customer_ID: customerUUID });
                }

                if (customerInternalID) {
                    var customerFromDB;

                    const ex = cds.parse.expr(`BuyerPartyID = '${customerInternalID}'`);
                    const serviceRequests = await remoteTicketAPI.run(SELECT.from(RemoteServiceRequest).columns(root=>{
                        root('*'),
                        root.ServiceRequestTextCollection(text=>text('*')),
                        root.ServiceRequestAttachmentFolder(attachment =>attachment('*'))
                    }).where(ex));

                    await _createServiceRequestInstances(serviceRequests, customerUUID, serviceRequestsFromDB);
                    await deleteServiceRequestInstances(serviceRequests, serviceRequestsFromDB, ServiceRequest)
                }
            } else if(path.startsWith('Customer') && path.includes('ToServiceRequests') && path.endsWith(')') && req.event == 'READ'){
                //update status from remote when 
                const servicePath = path.substring(path.indexOf('ToServiceRequests'));
                const serviceEditing = servicePath.includes('IsActiveEntity=false');
                if (!serviceEditing){ // only for viewing
                    const serviceInst = await SELECT.one.from(ServiceRequest, req.data.ID);
                    if (serviceInst && serviceInst.ObjectID){
                        const serviceRequest= await remoteTicketAPI.run(SELECT.one.from(RemoteServiceRequest).columns(root=>{
                            root('ServiceRequestLifeCycleStatusCode'),root('ResolvedOnDateTime')
                        }).where({ObjectID: serviceInst.ObjectID}));
                        if (serviceRequest){
                            let refreshBody = {
                                Status_code : serviceRequest.ServiceRequestLifeCycleStatusCode
                            }
                            if (serviceRequest.ResolvedOnDateTime != ''){
                                refreshBody.ResolutionDateTime = serviceRequest.ResolvedOnDateTime;
                            }
                            await UPDATE(ServiceRequest, req.data.ID).with(refreshBody)
                        }
                    }
                }
            }
        });

        this.before('READ', 'Opportunity', async (req) => {

            const path = req._path;
            const editing = path.includes('IsActiveEntity=false'); // fetch from remote only for reading page not editing
            if (path.startsWith('Customer') && path.endsWith('ToOpportunities') && !editing && req.event == 'READ' && req._ && req._._queryOptions && req._._queryOptions.$top) {

                let opportunitiesFromDB = [];
                const parentId = path.substring(12, 48);
                if (parentId) {
                    opportunitiesFromDB = await SELECT.from(Opportunity).where({ Customer_ID: parentId });
                }
                const customerDB = await SELECT.from(Customer).where({ ID: parentId });
                let customerInternalID;
                if (customerDB.length > 0) {
                    customerInternalID = customerDB[0].InternalID;
                }

                if (customerInternalID) {

                    const opportunities = await remoteOpptAPI.run(SELECT.from(RemoteOpportunity).columns(root=>{
                        root('UUID'),root('ObjectID'),root('ID'),root('ProspectPartyID'),root('ProspectPartyName'),
                        root('Name'),root('LifeCycleStatusCode'),root('LifeCycleStatusCodeText'),root('CreatedBy'),root('LastChangedBy'),
                        root('PrimaryContactPartyID'),root('MainEmployeeResponsiblePartyID'),root('MainEmployeeResponsiblePartyName'),
                        root.OpportunityAttachmentFolder(attachment => attachment('*')),
                        root.OpportunityItem(item=>item('*'))
                    }).where({ProspectPartyID: customerInternalID}));

                    await _createOpportunityInstances(opportunities, parentId, opportunitiesFromDB);
                    await deleteOpportunityInstances(opportunities, opportunitiesFromDB, Opportunity);

                    // const path = `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection?$filter=ProspectPartyID eq '${customerInternalID}'&$expand=OpportunityAttachmentFolder,OpportunityItem`;
                    // try {
                    //     const createRequestParameters = {
                    //         method: 'get',
                    //         url: path,
                    //         headers: {
                    //             'content-type': 'application/json'
                    //         }
                    //     }

                    //     const c4cResponse = await sendRequestToC4C(createRequestParameters);
                    //     await _createOpportunityInstances(c4cResponse, parentId, opportunitiesFromDB);
                    //     await deleteOpportunityInstances(c4cResponse, opportunitiesFromDB,Opportunity);
                    // }
                    // catch (error) {
                    //     req.reject({
                    //         message: error.message
                    //     });
                    // }
                }
            } else if(path.startsWith('Customer') && path.includes('ToOpportunities') && path.endsWith(')') && req.event == 'READ'){
                //update status from remote when 
                const opptPath = path.substring(path.indexOf('ToOpportunities'));
                const opptEditing = opptPath.includes('IsActiveEntity=false');
                if (!opptEditing){ // only for viewing
                   const opptInst = await SELECT.one.from(Opportunity, req.data.ID);
                   if (opptInst && opptInst.ObjectID){
                        const opportunity= await remoteOpptAPI.run(SELECT.one.from(RemoteOpportunity).columns(root=>{
                            root('LifeCycleStatusCode'), root('LifeCycleStatusCodeText')
                        }).where({ObjectID: opptInst.ObjectID}));
                        if (opportunity){
                            await UPDATE(Opportunity, req.data.ID).with({LifeCycleStatusCode_code : opportunity.LifeCycleStatusCode})
                        }
                   }
                }
            }
        })

        this.on('LoadProducts', async (req) => {
            await loadProductsAndPricesListsFromC4C(ItemProduct, SalesPriceList, req);
        })

        this.after(['READ','NEW'], Item, async req=>{
            // calculate item sales price Amount 
            if (req.length != 0){
                let data = req;
                if (!Array.isArray(req)){
                    data = [req];
                }
                for(let item of data) {
                    
                    if (item.toItemProduct){
                        const itemProductID = item.toItemProduct.InternalID;
                        const priceLists = await SELECT.from(SalesPriceList).where({ItemProductID : itemProductID});
                        const baseList = priceLists.filter(price => price.IsBasePriceList && price.ReleaseStatusCode == '3');
                        let netPrice = 0;
                        let netPriceCurrency;
                        baseList.forEach(price =>{
                            netPrice += price.Amount;
                            netPriceCurrency = price.AmountCurrencyCode_code;
                        })
                        item.NetPriceCurrency_code = netPriceCurrency;
                        item.NetPriceAmount = netPrice;
                    }
                 }
            }
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
            var email = req._.user.id;
            const customerDB = await SELECT.one.from(Customer).where({ ID: parentId });
            if (customerDB) {
                req.data.CustomerID = customerDB.InternalID;
                req.data.CustomerFormattedName = customerDB.CustomerFormattedName;
                req.data.Customer_ID = customerDB.ID;
                req.data.Category_code = '2';
                req.data.ProcessorID = customerDB.ResponsibleManagerID;
                req.data.Processor = customerDB.ResponsibleManager;
                req.data.RequestInitialDateTime = new Date().toString();
                req.data.RequestEndDateTime = new Date().toString();
            }
            const partner = await SELECT.one.from("Partner_PartnerProfile").columns('Code').where({ Email:  email });
            if (partner) {
                req.data.MainContactID = partner.Code;
            }
        })

        this.before('NEW', 'Customer', async (req) => {
            req.data.Status_code = "1";
            var email = req._.user.id;
            const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: email });
            if (partner) {
                req.data.MainContactID = partner.CODE;
            }
        })

        this.before('CANCEL', 'Opportunity', async (req) => {
            const id = req.data.ID;
            const opportunity = await SELECT.one.from(Opportunity, id);
            if(opportunity.ObjectID){
                await remoteOpptAPI.run(DELETE.from(RemoteOpportunity).where({ObjectID:opportunity.ObjectID}));
            }
        });

        this.before('CANCEL', 'ServiceRequest', async (req) => {
            const id = req.data.ID;
            const serviceRequest = await SELECT.one.from(ServiceRequest, id);
            if(serviceRequest.ObjectID){
                await remoteTicketAPI.run(DELETE.from(RemoteServiceRequest).where({ObjectID:serviceRequest.ObjectID}));
            }
        });
        
        this.after('SAVE', 'Customer', async (req) => {
            //create new Opportunities in remote
            const newOpports = req.ToOpportunities.filter(n => n.UUID == null)
            for(let item of newOpports) {
                let requestBody = {
                    Name: item.Subject,
                    ProspectPartyID: item.ProspectPartyID,
                    LifeCycleStatusCode: item.LifeCycleStatusCode_code,
                    CustomerComment_SDK : item.CustomerComment,
                    NotStandartRequest_SDK : item.NotStandartRequest,
                    PrimaryContactPartyID : req.MainContactID
                }
                if (req.ResponsibleManagerID){
                    requestBody.MainEmployeeResponsiblePartyID = req.ResponsibleManagerID;
                }
                // add products
                const products = [];
                const items = item.Items;
                for (let itemRow of items) {
                    const itemProductID = itemRow.ItemProductID;
                    const itemProduct = await SELECT.one.from(ItemProduct).where({ ID: itemProductID });
                    if (itemProduct) {
                        products.push({ ProductID: itemProduct.InternalID, Quantity : String(itemRow.Quantity) })
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
                        await UPDATE(Opportunity, item.ID)
                            .with({
                                UUID: createdData.UUID,
                                ObjectID: createdData.ObjectID,
                                //MainEmployeeResponsiblePartyName: createdData.MainEmployeeResponsiblePartyName,
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
            }
           // create new Service Requests in remote
            const newTickets = req.ToServiceRequests.filter(n => n.UUID == null);
           for(let item of newTickets) {
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
                    Name: item.Subject,
                    ServiceRequestUserLifeCycleStatusCode: item.Status_code,
                    ServiceIssueCategoryID : 'ZA_' + item.Category_code,
                    RequestInitialReceiptdatetimecontent : item.RequestInitialDateTime,
                    RequestedFulfillmentPeriodEndDateTime : item.RequestEndDateTime,
                    BuyerMainContactPartyID : customer[0].MainContactID
                    //ProcessorPartyID : item.ProcessorID,
                    //ServiceRequestTextCollection : [{Text:item.ProblemDescription}]
                }
                if (internalBuyerID){
                    body.BuyerPartyID = internalBuyerID;
                }
                if (item.ProcessorID){
                    body.ProcessorPartyID = item.ProcessorID;
                }
                if (item.ProblemDescription){
                    body.ServiceRequestTextCollection = [{Text:item.ProblemDescription}];
                }
                // link selected Opportunity
                await linkSelectedOpportunity(item, Opportunity, body);

                // link selected Items
                let products = [];
                if (item.ProblemItem != null) {
                    const itemInstance = await SELECT.one.from(Item).where({ ID: item.ProblemItem });
                    products.push({ ProductID: itemInstance.ProductInternalID });
                    body.ServiceRequestItem = { results: products };
                    body.ProductID = itemInstance.ProductInternalID;
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
            }

           const customerData = req;
           await createNewCustomerInRemote(customerData, Customer, req);

        });

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

                        POBox : account.POBox,
                        POBoxCountry_code : account.POBoxDeviatingCountryCode,
                        POBoxState : account.POBoxDeviatingRegionCodeText,
                        POBoxCity : account.POBoxDeviatingCity
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
                        Subject: serviceRequestResponse.Name,
                        MainContactID: serviceRequestResponse.BuyerMainContactPartyID,
                        RequestInitialDateTime : serviceRequestResponse.RequestInitialReceiptdatetimecontent,
                        RequestEndDateTime : serviceRequestResponse.RequestedFulfillmentPeriodEndDateTime,
                    }
                    if (serviceRequestResponse.ResolvedOnDateTime != ''){ // check for valid date time value
                        serviceRequest.ResolutionDateTime = serviceRequestResponse.ResolvedOnDateTime;
                    }
                    if (serviceRequestResponse.ServiceRequestTextCollection[0]){
                        serviceRequest.ProblemDescription = serviceRequestResponse.ServiceRequestTextCollection[0].Text;
                    }

                     //fetch interactions
                    await DELETE(ServiceRequestInteraction).where({ServiceRequest_ID : serviceRequestID});
                    const interactions = await remoteAPI.run(SELECT.from(RemoteInteraction).columns(root=>{
                        root('*'),
                        root.ServiceRequestInteractionInteractions(interaction => {
                            interaction('*'),
                            interaction.ServiceRequestInteractionToParty(party => party('*'))
                        })
                    }).where({ID : obj.InternalID}));

                    for(let item of interactions[0].ServiceRequestInteractionInteractions){
                        let newInteraction = {
                            InternalID : item.ID,
                            Sender : item.FromPartyName + '('+item.FromPartyID + ')',
                            Text : item.Text,
                            CreationDateTime : item.CreationDateTime,
                            Subject : item.SubjectName,
                            ServiceRequest_ID : serviceRequestID
                        }
                        const toParty = item.ServiceRequestInteractionToParty[0];
                        if (toParty){
                            newInteraction.Recepients = toParty.EmailURI;
                        }
                        // delete unexpected tags
                        let formattedText = newInteraction.Text;
                        formattedText = formattedText.replaceAll('&nbsp;',' ');
                        formattedText = formattedText.replace(/(<([^>]+)>)/gi, '');
                        newInteraction.Text = formattedText;

                        await INSERT(newInteraction).into(ServiceRequestInteraction)
                    }

                    await UPDATE(ServiceRequest).with(serviceRequest).where({ ObjectID: serviceRequestResponse.ObjectID });

                    const attachmentsFromRemote = serviceRequestResponse.ServiceRequestAttachmentFolder;
                    const existingAttachmentsFromDB = await SELECT.from(Attachement).where({ServiceRequest_ID:serviceRequestID});
                    
                    createAttachments(attachmentsFromRemote, existingAttachmentsFromDB, Attachement, serviceRequestID, "ServiceRequest");
                    deleteAttachments(attachmentsFromRemote, existingAttachmentsFromDB, Attachement);

                    //return SELECT(ServiceRequest, serviceRequestID);
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

                        const attachmentsFromRemote = opportunityResponse.OpportunityAttachmentFolder;
                        const existingAttachmentsFromDB = await SELECT.from(Attachement).where({Opportunity_ID:opportunityID});
                        
                        createAttachments(attachmentsFromRemote, existingAttachmentsFromDB, Attachement, opportunityID, "Opportunity");
                        deleteAttachments(attachmentsFromRemote, existingAttachmentsFromDB, Attachement);

                        // return SELECT(Opportunity, opportunityID);
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

