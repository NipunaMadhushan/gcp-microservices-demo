// Copyright (c) 2022 WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

type JsonProduct record {|
    string id;
    string name;
    string description;
    string picture;
    record {|
        string currencyCode;
        int units;
        int nanos;
    |} priceUsd;
    string[] categories;
|};

isolated function parseProductJson(json jsonContents) returns Product[]|error {
    json productsJson = check jsonContents.products;
    if productsJson !is json[] {
        return error("product array is not found");
    }

    JsonProduct[] jsonProducts = check productsJson.fromJsonWithType();
    return from var {id, name, description, picture, priceUsd, categories} in jsonProducts
        let Product product = {
            id,
            name,
            description,
            picture,
            price_usd: check parseUsdPrice(priceUsd),
            categories
        }
        select product;
}

isolated function parseUsdPrice(json usdPrice) returns Money|error {
    return {
        currency_code: check usdPrice.currencyCode,
        units: check usdPrice.units,
        nanos: check usdPrice.nanos
    };
}

isolated function isProductRelated(Product product, string query) returns boolean {
    string queryLowercase = query.toLowerAscii();
    return product.name.toLowerAscii().includes(queryLowercase) ||
        product.description.toLowerAscii().includes(queryLowercase);
}
