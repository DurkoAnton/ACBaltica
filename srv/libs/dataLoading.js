const { sendRequestToC4C } = require('./ManageAPICalls');

async function loadProductsAndPricesListsFromC4C(ItemProduct, SalesPriceList, req) {
    try {
        await DELETE.from(ItemProduct);
        // load products from C4C to HANA 
        let path = `sap/c4c/odata/v1/c4codataapi/ProductCollection?$filter=ProductCategoryID eq 'GLYCOLS' or ProductCategoryID eq 'RESINS' or ProductCategoryID eq 'PLASTICS' or ProductCategoryID eq 'CAOUTCHOUCS' or ProductCategoryID eq 'POLYESTERS'`;
        let createRequestParameters = {
            method: 'GET',
            url: path,
            headers: {
                'content-type': 'application/json'
            }
        };
        let c4cResponse = await sendRequestToC4C(createRequestParameters);
        if (c4cResponse.status == '200' && c4cResponse.data.d.results != undefined) {
            const data = c4cResponse.data.d.results;
            for(let item of data){
                let product = {
                    InternalID: item.ProductID,
                    ProductCategory: item.ProductCategoryID,
                    ProductStatus: item.Status,
                    ProductStatusDescription: item.StatusText,
                    UnitMeasure: item.BaseUOMText,
                    Description : item.Description
                };
                await INSERT(product).into(ItemProduct);
            };
        }

        // load price lists and connect them to material
        await DELETE.from(SalesPriceList);
        path = `sap/c4c/odata/v1/salespricelist/InternalPriceDiscountListCollection?$expand=InternalPriceDiscountListItems`;
        createRequestParameters = {
            method: 'GET',
            url: path,
            headers: {
                'content-type': 'application/json'
            }
        };
        c4cResponse = await sendRequestToC4C(createRequestParameters);
        if (c4cResponse.status == '200' && c4cResponse.data.d.results != undefined) {
            const data = c4cResponse.data.d.results;
            for (let priceList of data){
                for (let priceListItem of priceList.InternalPriceDiscountListItems) {
                    let product = {
                        PriceListID: priceListItem.PriceDiscountListID,
                        Amount: priceListItem.Amount,
                        AmountCurrencyCode_code: priceListItem.AmountCurrencyCode,
                        ItemProductID: priceListItem.ProductID,
                        IsBasePriceList : priceList.IsBasePriceList,
                        ReleaseStatusCode : priceList.ReleaseStatusCode,
                        ValidFrom : new Date(Number(priceList.ValidityStartDate.substring(priceList.ValidityStartDate.indexOf('(')+1,priceList.ValidityStartDate.indexOf(')')))),
                        ValidTo : new Date(Number(priceList.ValidityEndDate.substring(priceList.ValidityEndDate.indexOf('(')+1,priceList.ValidityEndDate.indexOf(')')))),
                    };
                    if (priceListItem.PriceUnitContent && priceListItem.PriceUnitContent != ''){
                        let priceUnit = priceListItem.PriceUnitContent.substring(0,priceListItem.PriceUnitContent.indexOf('.')+2)
                        product.PriceUnitContent = priceUnit;
                    } 
                    await INSERT(product).into(SalesPriceList);
                }
            }
        }
    }
    catch (error) {
        req.reject({
            message: error.message
        });
    }

}

module.exports = { loadProductsAndPricesListsFromC4C }