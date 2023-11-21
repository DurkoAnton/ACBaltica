const cds = require('@sap/cds')
const jwtDecode = require('jwt-decode');
const { getObjectsWithDifferentPropertyValue, createAttachmentBody, linkSelectedOpportunity, 
    deleteServiceRequestInstances, createAttachments, deleteAttachments } = require('./libs/utils');
const { sendRequestToC4C } = require('./libs/ManageAPICalls');

class ServiceRequestService extends cds.ApplicationService {
    async init() {

        const { Customer, ServiceRequest, Attachement, Opportunity, Item } = this.entities;

        async function _createServiceRequestInstances(serviceRequests) {
            //const items = c4cResponse.data.d.results;
            for (let item of serviceRequests) {
                const attachmentFolder = item.ServiceRequestAttachmentFolder[0];
                let serviceRequest = {
                    UUID: item.UUID,
                    ObjectID: item.ObjectID,
                    CustomerID: item.BuyerPartyID,
                    CustomerFormattedName : item.BuyerPartyName,
                    InternalID: item.ID,
                    Status_code: item.ServiceRequestLifeCycleStatusCode,
                    Processor: item.ProcessorPartyName,
                    OrderID: item.SalesOrderID,
                    ProblemDescription: item.Name,
                    MainContactID: item.BuyerMainContactPartyID,
                    RequestInitialDateTime : item.RequestInitialReceiptdatetimecontent,
                    RequestEndDateTime : item.RequestedFulfillmentPeriodEndDateTime,
                }
                if (item.ResolvedOchnDateTime != ''){ // check for valid date time value
                    serviceRequest.ResolutionDateTime = item.ResolvedOnDateTime;
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
                 // link to Customer
                 const customerInst = await SELECT.one.from(Customer).where({InternalID : item.BuyerPartyID});
                 if (customerInst){
                    serviceRequest.Customer_ID = customerInst.ID;
                 }
                const requestResult = await INSERT(serviceRequest).into(ServiceRequest);
                if (attachment && requestResult.affectedRows > 0) {
                    attachment.ServiceRequest_ID = requestResult.results[0].values[14]; // link attachment and SR values[13]-id
                    await INSERT(attachment).into(Attachement);
                }
            };
        }

        this.before('PATCH', ServiceRequest, async req=>{
            if (req.data.CustomerID){ // if Customer was changed
                const customer = await SELECT.one.from(Customer).columns(root=>root('ResponsibleManager')).where({InternalID : req.data.CustomerID});
                if (customer){
                    req.data.Processor = customer.ResponsibleManager;
                    req.data.ProcessorID = req.data.OrderID = req.data.OrderDescription = req.data.ProblemItem = req.data.ProblemItemDescription = '';
                }
            }
            if (req.data.CustomerID == '') { // if Customer was clered
                req.data.CustomerFormattedName = req.data.Processor = req.data.ProcessorID = req.data.OrderID = req.data.OrderDescription = req.data.ProblemItem = req.data.ProblemItemDescription = '';
            }
        })

        this.before('READ', 'ServiceRequest', async req => {
            if (req._path == 'ServiceRequest' && req._.event == 'READ') { // read only for general list
                    
                var email = req._.user.id;
                var partner = await SELECT.one.from('Partner_PartnerProfile').where({ Email: email });
                if (partner) {
                    req.query.where({ 'MainContactID': partner.CODE });
                }
            
                if (partner) {
                    const existingRequests = await SELECT.from(ServiceRequest).where({MainContactID : partner.CODE});
                    const path = `/sap/c4c/odata/v1/c4codataapi/ServiceRequestCollection?$filter=BuyerMainContactPartyID eq '${partner.CODE}'&$expand=ServiceRequestAttachmentFolder`;
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
                        await deleteServiceRequestInstances(c4cResponse, existingRequests, ServiceRequest);
                    }
                    catch (error) {
                        req.reject({
                            message: error.message
                        });
                    }
                }
            }            
        });

        this.before('NEW', 'ServiceRequest', async req => {
            var email = 'andrei_matys@atlantconsult.com';
            const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: email });
            if (partner) {
                req.data.MainContactID = partner.CODE;
                req.data.Category_code = '1'; //default
            }
        });

        this.on('updateFromRemote', async (req) => {
            const pathStart = "ServiceRequest(ID=";
            let serviceRequestID = req._path.substring(pathStart.length, pathStart.length + 36);

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

                let serviceRequest = {
                    CustomerID: serviceRequestResponse.BuyerPartyID,
                    Status_code: serviceRequestResponse.ServiceRequestLifeCycleStatusCode,
                    LastChangingDate: formattedDate,
                    Processor: serviceRequestResponse.ProcessorPartyName,
                    RequestProcessingTime: serviceRequestResponse.RequestInProcessdatetimeContent,
                    OrderID: serviceRequestResponse.SalesOrderID,
                    ProblemDescription: serviceRequestResponse.Name,
                    MainContactID: serviceRequestResponse.BuyerMainContactPartyID,
                    RequestInitialDateTime : serviceRequestResponse.RequestInitialReceiptdatetimecontent,
                    RequestEndDateTime : serviceRequestResponse.RequestedFulfillmentPeriodEndDateTime,
                }
                if (serviceRequestResponse.ResolvedOchnDateTime != ''){ // check for valid date time value
                    serviceRequest.ResolutionDateTime = serviceRequestResponse.ResolvedOnDateTime;
                }

                await UPDATE(ServiceRequest).with(serviceRequest).where({ ObjectID: serviceRequestResponse.ObjectID });

                const attachmentsFromRemote = serviceRequestResponse.ServiceRequestAttachmentFolder;
                const existingAttachmentsFromDB = await SELECT.from(Attachement).where({ServiceRequest_ID:serviceRequestID});
                
                createAttachments(attachmentsFromRemote, existingAttachmentsFromDB, Attachement, serviceRequestID, "ServiceRequest");
                deleteAttachments(attachmentsFromRemote, existingAttachmentsFromDB, Attachement);

                return SELECT(ServiceRequest, serviceRequestID);
            }
            catch (error) {
                req.reject({
                    message: error.message
                });
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
                    Name: ticket.ProblemDescription,
                    ServiceRequestUserLifeCycleStatusCode: ticket.Status_code,
                    ServiceIssueCategoryID : 'ZA_' + ticket.Category_code
                    // dates?
                }
                if (internalBuyerID)
                    body.BuyerPartyID = internalBuyerID;
                let products = [];
                if (ticket.ProblemItem != null) {
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
                            Processor: data.ProcessorPartyName
                        });
                    }
                    if (ticket.Attachment && ticket.Attachment.length !== 0) {
                        createRequestParameters = {
                            method: 'GET',
                            url: data.ServiceRequestAttachmentFolder.__deferred.uri,
                            headers: { 'content-type': 'application/json' }
                        }
                        // save ObjectID for the first time
                        const attachmentResponse = await sendRequestToC4C(createRequestParameters);
                        const attachmentsInResponse = attachmentResponse.data.d.results;
                        for (let i = 0; i < attachmentsInResponse.length; i++) {
                            const attachmentInDB = ticket.Attachment[i];
                            const ObjectID = attachmentsInResponse[i].ObjectID;
                            await UPDATE(Attachement, attachmentInDB.ID).set({ ObjectID: ObjectID });
                        }

                    }
                }
            }
        })

        return super.init();
    }
}
module.exports = { ServiceRequestService };
