const cds = require('@sap/cds')
//const jwt_decode = require('jwt-decode');
//const { status } = require('express/lib/response');
const { createAttachmentBody, createItemsBody, deleteOpportunityInstances, createAttachments, deleteAttachments, deleteItems } = require('./libs/utils');
const { sendRequestToC4C } = require('./libs/ManageAPICalls');
const { loadProductsAndPricesListsFromC4C } = require('./libs/dataLoading');

class OpportunityService extends cds.ApplicationService {
    async init() {

        const { Customer } = cds.entities('customer')
        const { Opportunity, Attachement, Item, ItemProduct, SalesPriceList, RemoteOpportunity } = this.entities;
        
        const remoteOpptAPI = await cds.connect.to('opportunity');

        async function _createOpportunityInstances(opportunities) {
            opportunities.forEach(async item => {
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
                    MainContactID: item.PrimaryContactPartyID,
                    CustomerComment : item.CustomerComment_SDK,
                    NotStandartRequest : item.NotStandartRequest_SDK
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
                // link to Customer
                const customerInst = await SELECT.one.from(Customer).where({InternalID : item.ProspectPartyID});
                if (customerInst){
                    opportunity.Customer_ID = customerInst.ID;
                }
                const insertResult = await INSERT(opportunity).into(Opportunity);
                if (insertResult.affectedRows > 0) {
                    const opportunityID = insertResult.results[0].values[14];
                    if (attachment){
                        attachment.Opportunity_ID = opportunityID; // link attachment and SR values[14]-id
                        await INSERT(attachment).into(Attachement);
                    }
                    // add items
                    if (item.OpportunityItem.length > 0) {
                        const items = await createItemsBody(item.OpportunityItem, ItemProduct, opportunityID);
                        await INSERT(items).into(Item);
                    }
                }
            });
        }

        this.after(['READ','NEW'], Item, async req=>{
            // calculate item sales price Amount 
            if (req.length != 0){
                let data = req;
                if (!Array.isArray(req)){
                    data = [req];
                }
                for(let item of data) {
                    
                    if (item.toItemProduct){
                        //item.Quantity = 2;
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

        this.on('LoadProducts', async (req) => {
            await loadProductsAndPricesListsFromC4C(ItemProduct, SalesPriceList, req);
        })

        this.before('PATCH', Opportunity, async req=>{
            if (req.data.ProspectPartyID){ // if Prospect Party was changed
                const customer = await SELECT.one.from(Customer).columns(root=>root('ResponsibleManager')).where({InternalID : req.data.ProspectPartyID});
                if (customer){
                    req.data.MainEmployeeResponsiblePartyName = customer.ResponsibleManager;
                }
            }
            if (req.data.ProspectPartyID == '') {
                req.data.ProspectPartyName =  req.data.MainEmployeeResponsiblePartyName = '';
            }
        })

        this.before('READ', 'Opportunity', async req => {
            const path = req._path;
            const editing = path.includes('IsActiveEntity=false'); // fetch from remote only for reading page not editing
            if (path == 'Opportunity' && !editing && req._.event == 'READ' && req._._queryOptions && req._._queryOptions.$top && req._._queryOptions.$top == '30') { // read only for general list
                var email = req._.user.id;
                var partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: email });
                if (partner){
                    req.query.where({ 'MainContactID': partner.CODE });
                    const existingOpportunities = await SELECT.from(Opportunity).where({MainContactID : partner.CODE});
                    const path = `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection?$filter=PrimaryContactPartyID eq '${partner.CODE}'&$expand=OpportunityAttachmentFolder,OpportunityItem`;
                    try {
                        const createRequestParameters = {
                            method: 'get',
                            url: path,
                            headers: {
                                'content-type': 'application/json'
                            }
                        }
                        const c4cResponse = await sendRequestToC4C(createRequestParameters);
                        const remoteOpportunitites = c4cResponse.data.d.results;
                        // exclude existing rows to create only new
                        const newOpptsToCreate = remoteOpportunitites.filter(newItem => !existingOpportunities.some(existingItem => existingItem.ObjectID == newItem.ObjectID));
                        await _createOpportunityInstances(newOpptsToCreate);
                        await deleteOpportunityInstances(c4cResponse.data.d.results, existingOpportunities, Opportunity);
                    }
                    catch (error) {
                        req.reject({
                            message: error.message
                        });
                    }
                }
            }
            else if(path.startsWith('Opportunity') && path.endsWith(')') && req.event == 'READ'){
                //update status from remote when 
                //const opptPath = path.substring(path.indexOf('ToOpportunities'));
                const opptEditing = path.includes('IsActiveEntity=false');
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
        });

        // this.before('NEW', 'Item', async (req) => {
        //     req.data.OpportunityID = req.data.toOpportunity_ID;
        // })

        this.before('NEW', 'Opportunity', async (req) => {
            req.data.LifeCycleStatusCode_code = '1';
            req.data.LifeCycleStatusText = 'Open';
            var email = req._.user.id;
            const partner = await SELECT.one.from("Partner_PartnerProfile").where({ Email: email });
            if(partner){
                req.data.MainContactID = partner.CODE;
            }
        })

        this.before('DELETE', 'Opportunity', async (req) => {
            const id = req.data.ID;
            const opportunity = await SELECT.one.from(Opportunity, id);
            if(opportunity.ObjectID){
                await remoteOpptAPI.run(DELETE.from(RemoteOpportunity).where({ObjectID:opportunity.ObjectID}));
            }
        });

        this.after('SAVE', 'Opportunity', async req => {
            // create new Opportunities in remote
            const opportunity = req;
            if (opportunity.UUID === null) {
                
                let requestBody = {
                    Name: opportunity.Subject,
                    LifeCycleStatusCode: opportunity.LifeCycleStatusCode_code,
                    CustomerComment_SDK : opportunity.CustomerComment,
                    NotStandartRequest_SDK : opportunity.NotStandartRequest,
                    PrimaryContactPartyID : opportunity.MainContactID,
                }
                if (req.Customer_ID){
                    const customer = await SELECT.one.from(Customer).where({ID : req.Customer_ID}).columns('ResponsibleManagerID');
                    if (customer && customer.ResponsibleManagerID){
                        requestBody.MainEmployeeResponsiblePartyID = customer.ResponsibleManagerID;
                    }

                }
                if (opportunity.ProspectPartyID)
                    requestBody.ProspectPartyID = opportunity.ProspectPartyID;
                // add products
                const products = [];
                const items = opportunity.Items;
                for (let itemRow of items) {
                    const itemProductID = itemRow.ItemProductID;
                    const itemProduct = await SELECT.one.from(ItemProduct).where({ ID: itemProductID });
                    if (itemProduct) {
                        products.push({ ProductID: itemProduct.InternalID, Quantity: String(itemRow.Quantity) })
                    }
                }
                if (products.length > 0) {
                    requestBody.OpportunityItem = { results: products };
                }

                if (opportunity.Attachment && opportunity.Attachment.length !== 0) {
                    const results = [];
                    createAttachmentBody(opportunity, results);
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
                        const result = await UPDATE(Opportunity)
                            .where({ ID: opportunity.ID })
                            .with({
                                UUID: createdData.UUID,
                                ObjectID: createdData.ObjectID,
                                //MainEmployeeResponsiblePartyName: createdData.MainEmployeeResponsiblePartyName,
                                InternalID: createdData.ID,
                            });

                        if (opportunity.Attachment && opportunity.Attachment.length !== 0) {
                            createRequestParameters = {
                                method: 'GET',
                                url: createdData.OpportunityAttachmentFolder.__deferred.uri,
                                headers: { 'content-type': 'application/json' }
                            }
                            // save ObjectID for the first time
                            const attachmentResponse = await sendRequestToC4C(createRequestParameters);
                            const attachmentsInResponse = attachmentResponse.data.d.results;
                            for (let i = 0; i < attachmentsInResponse.length; i++) {
                                const attachmentInDB = opportunity.Attachment[i];
                                const ObjectID = attachmentsInResponse[i].ObjectID;
                                await UPDATE(Attachement, attachmentInDB.ID).set({ ObjectID: ObjectID });
                            }
                        }
                    }
                } catch (e) {
                    console.log(e)
                }
            }
        });


        this.on('updateFromRemote', async (req) => {
            const pathStart = "Opportunity(ID=";
            let opportunityID = req._path.substring(pathStart.length, pathStart.length + 36);

            const obj = await SELECT.one.from(Opportunity, opportunityID);
            if (obj.ObjectID) {
            const path = `/sap/c4c/odata/v1/c4codataapi/OpportunityCollection('${obj.ObjectID}')?$expand=OpportunityAttachmentFolder,OpportunityItem`;
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

                let opportunity = {
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
                    CustomerComment : opportunityResponse.CustomerComment_SDK,
                    NotStandartRequest : opportunityResponse.NotStandartRequest_SDK
                }
                // link to new Customer if it was changed
                if (opportunityResponse.ProspectPartyID){
                    const customerInst = await SELECT.one.from(Customer).where({InternalID : opportunityResponse.ProspectPartyID});
                    if (customerInst){
                        opportunity.Customer_ID = customerInst.ID;
                    }
                }
                await UPDATE(Opportunity).with(opportunity).where({ ObjectID: opportunityResponse.ObjectID });
              
                const attachmentsFromRemote = opportunityResponse.OpportunityAttachmentFolder;
                const existingAttachmentsFromDB = await SELECT.from(Attachement).where({Opportunity_ID:opportunityID});
                
                createAttachments(attachmentsFromRemote, existingAttachmentsFromDB, Attachement, opportunityID, "Opportunity");
                deleteAttachments(attachmentsFromRemote, existingAttachmentsFromDB, Attachement);

                //update Items
                // const itemsFromRemote = opportunityResponse.OpportunityItem;
                // const existingItems = await SELECT.from(Item).where({toOpportunity_ID : opportunityID});

                // deleteItems(itemsFromRemote, existingItems, Item);

                // const itemsToCreate = itemsFromRemote.filter(obj1 => !existingItems.some(obj2 => obj2.ObjectID === obj1.ObjectID) /*&& obj1.ObjectID != null*/);
                // const itemBodies = await createItemsBody(itemsToCreate, ItemProduct, opportunityID)

                //await INSERT(itemBodies).into(Item)
                
                return SELECT(Opportunity, opportunityID);
            }
            catch (error) {
                req.reject({
                    message: error.message
                });
            }
        }
        });

        return super.init();
    }
}
module.exports = { OpportunityService };
