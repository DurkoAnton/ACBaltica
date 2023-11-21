const { sendRequestToC4C } = require('./ManageAPICalls');

async function loadProductsAndPricesListsFromC4C(ItemProduct, SalesPriceList, req) {
    try {
        await DELETE.from(ItemProduct);
        // load products from C4C to HANA 
        let path = `sap/c4c/odata/v1/c4codataapi/ProductCollection`;
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
            data.forEach(async (item) => {
                let product = {
                    InternalID: item.ProductID,
                    ProductCategory: item.ProductCategoryID,
                    ProductStatus: item.Status,
                    ProductStatusDescription: item.StatusText,
                    UnitMeasure: item.BaseUOMText
                };
                await INSERT(product).into(ItemProduct);
            });
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
            data.forEach(async (priceList) => {
                priceList.InternalPriceDiscountListItems.forEach(async (priceListItem) => {
                    const product = {
                        PriceListID: priceListItem.PriceDiscountListID,
                        Amount: priceListItem.Amount,
                        AmountCurrencyCode_code: priceListItem.AmountCurrencyCode,
                        PriceUnitContent: priceListItem.PriceUnitContent,
                        PriceUnitCode: priceListItem.PriceUnitCode,
                        ItemProductID: priceListItem.ProductID,
                        IsBasePriceList : priceList.IsBasePriceList,
                        ReleaseStatusCode : priceList.ReleaseStatusCode
                    };
                    await INSERT(product).into(SalesPriceList);
                });
            });
        }
    }
    catch (error) {
        req.reject({
            message: error.message
        });
    }

}

module.exports = { loadProductsAndPricesListsFromC4C }