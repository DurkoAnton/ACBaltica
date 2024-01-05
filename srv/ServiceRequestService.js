const cds = require('@sap/cds')
const { createAttachmentBody, linkSelectedOpportunity, 
    deleteServiceRequestInstances, createAttachments} = require('./libs/utils');
const { sendRequestToC4C } = require('./libs/ManageAPICalls');
//const { startsWith, contains } = require('@sap-cloud-sdk/core');

class ServiceRequestService extends cds.ApplicationService {
    async init() {

        const { Customer, ServiceRequest, Attachement, Opportunity, Item, RemoteInteraction, ServiceRequestInteraction, RemoteServiceRequest } = this.entities;

        const remoteAPI = await cds.connect.to('interaction');
        const remoteTicketAPI = await cds.connect.to('ticket');

        async function _createServiceRequestInstances(serviceRequests) {
            //const items = c4cResponse.data.d.results;
            for (let item of serviceRequests) {
                const attachmentFolder = item.ServiceRequestAttachmentFolder;
                let serviceRequest = {
                    UUID: item.UUID,
                    ObjectID: item.ObjectID,
                    CustomerID: item.BuyerPartyID,
                    CustomerFormattedName : item.BuyerPartyName,
                    InternalID: item.ID,
                    Status_code: item.ServiceRequestLifeCycleStatusCode,
                    Processor: item.ProcessorPartyName,
                    OrderID: item.SalesOrderID,
                    Subject: item.Name,
                    MainContactID: item.BuyerMainContactPartyID,
                    RequestInitialDateTime : item.RequestInitialReceiptdatetimecontent,
                    RequestEndDateTime : item.RequestedFulfillmentPeriodEndDateTime,
                    CreationDate : new Date(Number(item.CreationDateTime.substring(item.CreationDateTime.indexOf('(')+1,item.CreationDateTime.indexOf(')')))),
                    LastChangingDate : new Date(Number(item.LastChangeDateTime.substring(item.LastChangeDateTime.indexOf('(')+1,item.LastChangeDateTime.indexOf(')')))),
                    Attachment :[]
                }
 
                if (item.ResolvedOnDateTime != ''){ // check for valid date time value
                    serviceRequest.ResolutionDateTime = item.ResolvedOnDateTime;
                }
                if (item.ServiceIssueCategoryID != ''){
                    serviceRequest.Category_code = item.ServiceIssueCategoryID.replace('ZA_','');
                }
                const docReference = item.ServiceRequestBusinessTransactionDocumentReference;
                if (docReference.length > 0) {
                    const opptReference = docReference.filter(i=>i.TypeCode == "72" && i.RoleCode == "1");
                    if (opptReference[0]){
                        const refOppot =  await SELECT.one.from(Opportunity).where({InternalID : opptReference[0].ID}).columns('ID', 'Subject');
                        if (refOppot) {
                            serviceRequest.OrderID = refOppot.ID;
                            serviceRequest.OrderDescription = refOppot.Subject;
                            serviceRequest.ProblemItemDescription = item.ProductDescription;
                        }
                    }
                }
                const text = item.ServiceRequestTextCollection[0];
                if (text){
                    serviceRequest.ProblemDescription = text.Text;
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
                        mediaType: 'text/plain',
                        ObjectID : attachmentInst.ObjectID
                    }
                    serviceRequest.Attachment.push(attachment)
                });
              
                 const customerInst = await SELECT.one.from(Customer).where({InternalID : item.BuyerPartyID});
                 if (customerInst){
                    serviceRequest.Customer_ID = customerInst.ID;
                 }
                await INSERT(serviceRequest).into(ServiceRequest);
                
            };
        }

        this.before('PATCH', ServiceRequest, async req=>{
            if (req.data.CustomerID){ // if Customer was changed
                const customer = await SELECT.one.from(Customer).columns(root=>{root('ResponsibleManager'),root('ResponsibleManagerID')}).where({InternalID : req.data.CustomerID});
                if (customer){
                    req.data.Processor = customer.ResponsibleManager;
                    req.data.ProcessorID = customer.ResponsibleManagerID;
                    req.data.OrderID = req.data.OrderDescription = req.data.ProblemItem = req.data.ProblemItemDescription = '';
                }
            }
            if (req.data.CustomerID == '') { // if Customer was cleared
                req.data.CustomerFormattedName = req.data.Processor = req.data.ProcessorID = req.data.OrderID = req.data.OrderDescription = req.data.ProblemItem = req.data.ProblemItemDescription = '';
            }
        })

        this.before('READ', 'ServiceRequest', async req => {
            const path = req._path;
            const editing = path.includes('IsActiveEntity=false'); // fetch from remote only for reading page not editing
            if (req._path == 'ServiceRequest' && !editing && req._.event == 'READ') { // read only for general list
                    
                var email = req._.user.id;
                var partner = await SELECT.one.from('Partner_PartnerProfile').where({ Email: email });
                if (partner) {
                    req.query.where({ 'MainContactID': partner.CODE });
                }
            
                if (partner) {
                    const existingRequests = await SELECT.from(ServiceRequest).where({MainContactID : partner.CODE});
                    const path = `/sap/c4c/odata/v1/c4codataapi/ServiceRequestCollection?$filter=BuyerMainContactPartyID eq '${partner.CODE}'&$expand=ServiceRequestAttachmentFolder,ServiceRequestBusinessTransactionDocumentReference,ServiceRequestTextCollection`;
                    try {
                        const createRequestParameters = {
                            method: 'get',
                            url: path,
                            headers: {
                                'content-type': 'application/json'
                            }
                        }
                        const c4cResponse = await sendRequestToC4C(createRequestParameters);
                        const remoteRequests = c4cResponse.data.d.results;
                        // exclude existing rows to create only new
                        const newRequestsToCreate = remoteRequests.filter(newItem => !existingRequests.some(existingItem => existingItem.ObjectID == newItem.ObjectID));
                        await _createServiceRequestInstances(newRequestsToCreate);
                        await deleteServiceRequestInstances(remoteRequests, existingRequests, ServiceRequest);
                    }
                    catch (error) {
                        req.reject({
                            message: error.message
                        });
                    }
                }
            }  
            else if (req._path != 'ServiceRequest'  && req._.event == 'READ') { 
                const servicePath = path.substring(path.indexOf('ServiceRequest'));
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
                            await UPDATE(ServiceRequest, req.data.ID).with(refreshBody)                        }
                    }
                } 
            }       
        });

        this.before('NEW', 'ServiceRequest', async req => {
            var email = 'andrei_matys@atlantconsult.com';
            const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: email });
            if (partner) {
                req.data.MainContactID = partner.CODE;
                req.data.Category_code = '2'; //default
                req.data.RequestInitialDateTime = new Date().toString();
                const today = new Date();
                today.setDate(today.getDate()+1);
                req.data.RequestEndDateTime = today.toString()
            }
        });

        this.on('updateFromRemote', async (req) => {
            const pathStart = "ServiceRequest(ID=";
            let serviceRequestID = req._path.substring(pathStart.length, pathStart.length + 36);

            const obj = await SELECT.one.from(ServiceRequest, serviceRequestID);

            let path = `/sap/c4c/odata/v1/c4codataapi/ServiceRequestCollection('${obj.ObjectID}')?$expand=ServiceRequestAttachmentFolder,ServiceRequestTextCollection`;
            try {
                let createRequestParameters = {
                    method: 'GET',
                    url: path,
                    headers: { 'content-type': 'application/json' }
                }
                const c4cResponse = await sendRequestToC4C(createRequestParameters);
                const serviceRequestResponse = c4cResponse.data.d.results;
                
                let serviceRequest = {
                    CustomerID: serviceRequestResponse.BuyerPartyID,
                    Status_code: serviceRequestResponse.ServiceRequestLifeCycleStatusCode,
                    LastChangingDate: new Date(Number(
                        serviceRequestResponse.LastChangeDateTime.substring(serviceRequestResponse.LastChangeDateTime.indexOf('(')+1,serviceRequestResponse.LastChangeDateTime.indexOf(')')))),
                    Processor: serviceRequestResponse.ProcessorPartyName,
                    ProcessorID : serviceRequestResponse.ProcessorPartyID,
                    Subject: serviceRequestResponse.Name,
                    MainContactID: serviceRequestResponse.BuyerMainContactPartyID,
                    RequestInitialDateTime : serviceRequestResponse.RequestInitialReceiptdatetimecontent,
                    RequestEndDateTime : serviceRequestResponse.RequestedFulfillmentPeriodEndDateTime,
                    ProblemItemDescription : serviceRequestResponse.ProductDescription
                }
                if (serviceRequestResponse.ResolvedOnDateTime != ''){ // check for valid date time value
                    serviceRequest.ResolutionDateTime = serviceRequestResponse.ResolvedOnDateTime;
                }
                if (serviceRequestResponse.ServiceRequestTextCollection[0]){
                    serviceRequest.ProblemDescription = serviceRequestResponse.ServiceRequestTextCollection[0].Text;
                }
                if (serviceRequestResponse.ServiceIssueCategoryID != ''){
                    serviceRequest.Category_code = serviceRequestResponse.ServiceIssueCategoryID.replace('ZA_','');
                    const docReference = serviceRequestResponse.ServiceRequestBusinessTransactionDocumentReference;
                    if (serviceRequest.Category_code == '1' && docReference.length > 0) {
                        const opptReference = docReference.filter(i=>i.TypeCode == "72" && i.RoleCode == "1");
                        if (opptReference[0]){
                            const refOppot =  await SELECT.one.from(Opportunity).where({InternalID : opptReference[0].ID}).columns('ID', 'Subject');
                            if (refOppot) {
                                serviceRequest.OrderID = refOppot.ID;
                                serviceRequest.OrderDescription = refOppot.Subject;
                            }
                        }
                    }
                }

                await UPDATE(ServiceRequest).with(serviceRequest).where({ ObjectID: serviceRequestResponse.ObjectID });

                const attachmentsFromRemote = serviceRequestResponse.ServiceRequestAttachmentFolder;

                await DELETE.from(Attachement).where({ServiceRequest_ID: serviceRequestID});
                
                await createAttachments(attachmentsFromRemote, Attachement, serviceRequestID, "ServiceRequest");

                await DELETE(ServiceRequestInteraction).where({ServiceRequest_ID : serviceRequestID});

                //fetch interactions
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
                        Sender : item.FromPartyName,
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
                //return SELECT(ServiceRequest, serviceRequestID);
            }
            catch (error) {
                req.reject({
                    message: error.message
                });
            }
        });

        this.before('DELETE', 'ServiceRequest', async (req) => {
            const id = req.data.ID;
            const serviceRequest = await SELECT.one.from(ServiceRequest, id);
            if(serviceRequest.ObjectID){
                await remoteTicketAPI.run(DELETE.from(RemoteServiceRequest).where({ObjectID:serviceRequest.ObjectID}));
            }
        });

        this.after('SAVE', 'ServiceRequest', async (req) => {
            // create new Service Request in remote
            const ticket = req;
            if (ticket.UUID === null) { // if UUID is null, then it was not yet saved
                let customer;
                const customerID = ticket.Customer_ID;
                let internalBuyerID = null;
                if (customerID) {
                    customer = await SELECT.from(Customer).where({ ID: customerID });
                    if (customer[0]) {
                        internalBuyerID = customer[0].InternalID;
                    }
                }

                let body = {
                    Name: ticket.Subject,
                    ServiceRequestUserLifeCycleStatusCode: ticket.Status_code,
                    RequestInitialReceiptdatetimecontent : ticket.RequestInitialDateTime,
                    RequestedFulfillmentPeriodEndDateTime : ticket.RequestEndDateTime,
                }
                if (ticket.Category_code && ticket.Category_code != ''){
                    body.ServiceIssueCategoryID = 'ZA_' + ticket.Category_code;
                }
                if (ticket.ProcessorID){
                    body.ProcessorPartyID = ticket.ProcessorID;
                }
                if (internalBuyerID)
                    body.BuyerPartyID = internalBuyerID;
                let products = [];
                if (ticket.ProblemItem != null && ticket.ProblemItem != '') {
                    const itemInstance = await SELECT.one.from(Item).where({ ID: ticket.ProblemItem });
                    products.push({ ProductID: itemInstance.ProductInternalID });
                    body.ServiceRequestItem = { results: products };
                    body.ProductID = itemInstance.ProductInternalID;
                }

                if (ticket.Attachment && ticket.Attachment.length !== 0) {
                    const results = [];
                    createAttachmentBody(ticket, results);
                    body.ServiceRequestAttachmentFolder = { results };
                }
                // Problem desctiption in Text Collection
                if (ticket.ProblemDescription && ticket.ProblemDescription != ''){
                    const results = [];
                    results.push({Text : ticket.ProblemDescription})
                    body.ServiceRequestTextCollection = results;
                }
                await linkSelectedOpportunity(ticket, Opportunity, body);

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
                        await UPDATE(ServiceRequest, ticket.ID).with({
                            UUID: UUID,
                            ObjectID: objectID,
                            InternalID: data.ID,
                        });
                    }
                }
            }
        })
        return super.init();
    }
}
module.exports = { ServiceRequestService };
