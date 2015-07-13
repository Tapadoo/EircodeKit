//
//  EircodeAPI.swift
//  EircodeKit
//
//  Created by Dermot Daly on 13/07/2015.
//  Copyright © 2015 Tapadoo. All rights reserved.
//
/*
The MIT License (MIT)

Copyright (c) 2015 Tapadoo Limited.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import Foundation
/**
 API Class for calling the Autoaddress Eircode database lookup functions published at [Autoaddress Developer Support page](https://www.autoaddress.ie/support/developer-centre/api)
*/
public class EircodeAPI {
    /**
    A type alias to use for your callback completion handlers
    */
    public typealias EircodeCompletionHandler = (error:NSError?, retData:AnyObject?) -> Void
    /**
    Keys used for various parameters used to the API calls
    */
    static let key_key = "key"
    static let key_postcode = "postcode"
    static let key_address = "address"
    static let key_addressId = "addressId"
    static let key_limmit = "limit"
    static let key_language = "language"
    static let key_country = "country"
    static let key_vanityMode = "vanityMode"
    static let key_addressProfileName = "addressProfileName"
    static let key_ecadId = "ecadId"
    
    /**
    The curernt autoaddress API endpoint
    */
    private static let address = "https://api.autoaddress.ie/2.0"
    /**
    Error domain to use in NSErrors
    */
    static let MY_ERROR_DOMAIN = "EircodeAPI"
    /**
    Developer key, must be supplied by Autoaddress
    */
    private let developerKey : String
    
    /**
    Languages supported by the API
    */
    public enum SupportedLanguages:String {
        case English = "en"
        case Irish = "ga"
    }
    
    /**
    Countries supported by the API
    */
    public enum SupportedCountries:String {
        case GreatBritain = "gb"
        case Ireland = "ie"
    }
    /**
    Initialiser 
    - parameter developerKey: The developer key supplied to you by AutoAddress
    */
    public init(developerKey:String) {
        self.developerKey = developerKey
    }
    
    /**
    Private helper method to extract an error from a returned response from the API
    - parameter respDict: The response dictionary supplied
    - returns: An NSError object representing the error, if there is an error in the response, or nil if there isn't
    */
    private static func extractError(respDict:NSDictionary) -> NSError? {
        if let errorArr = respDict["errors"] {
            let message = errorArr[0]["message"] as! String
            if let internalType = errorArr[0]["type"] as! NSDictionary? {
                let retErr = NSError(domain: EircodeAPI.MY_ERROR_DOMAIN, code: internalType["code"] as! Int, userInfo: [NSLocalizedDescriptionKey: message])
                return retErr
            }
        }
        // No errorObj, return no error
        return nil
    }
    
    /**
    Private convenience method to send a request to the API
    - parameter URL: The URL to make the request to.
    - parameter parameters: An array of NSURLQueryItems storing the parameters to the request
    - parameter completionHandler: The completion handler to call once the asychronous request returns
    - returns: Nothing. The completion handler does the hard work
    */
    private func sendRequestToURL(URL:String, parameters:Array<NSURLQueryItem>, completionHandler:EircodeCompletionHandler)->Void {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration)
        let components = NSURLComponents(string: URL)
        components?.queryItems = parameters
        
        
        let request = NSURLRequest(URL:(components?.URL)!)
        let task = session.dataTaskWithRequest(request) { data, response, error  in
            if let recData = data {
                do {
                    // Better deserialize it. Assume JSON, Right
                    let retObj = try NSJSONSerialization.JSONObjectWithData(recData, options: NSJSONReadingOptions.AllowFragments)
                    // retObj should be a dictionary
                    if retObj is NSDictionary {
                        let optionalError = EircodeAPI.extractError(retObj as! NSDictionary)
                        completionHandler(error:optionalError, retData:retObj)
                    }
                } catch {
                    completionHandler(error:NSError(domain: EircodeAPI.MY_ERROR_DOMAIN, code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"]), retData: nil)
                }
            } else {
                // No data - complete with error if there is one
                completionHandler(error:error, retData:nil)
            }
        }
        task?.resume()
    }

    // MARK: API Calls
    
    /**
    find an address.  See [Find Address API](https://www.autoaddress.ie/support/developer-centre/api/find-address)
    - parameter address: Address or postcode to search
    - parameter addressId: Optional id of the address to look up (these are returned in ecad lookups)
    - parameter limit: Optional upper limit on the number of results to return. This will default to 20 if not supplied
    - parameter language: Optional Language you want the results in. This will default to English if not supplied
    - parameter country: Optional country the address should be searched in. Defaults to Ireland if not supplied
    - parameter vanityMode: Set to true to return vanity address if it exists
    - parameter addressProfileName: Address to reformat.  If this is supplied, the API will reformat this nicely. (I think)
    - returns: Nothing, you do the hard work in the completion handler
    */
    public func findAddress(address:String, addressId:String?, limit:Int?, language:SupportedLanguages?, country:SupportedCountries?, includeVanity:Bool, addressProfileName:String?, completionHandler:EircodeCompletionHandler) {
        var queryItems = [NSURLQueryItem]()
        queryItems.append(NSURLQueryItem(name:EircodeAPI.key_key, value:self.developerKey))
        queryItems.append(NSURLQueryItem(name:EircodeAPI.key_address, value:address))
        if let hasAddressId = addressId {
            queryItems.append(NSURLQueryItem(name:EircodeAPI.key_addressId, value:hasAddressId))
        }
        if let hasLimit = limit {
            queryItems.append(NSURLQueryItem(name:EircodeAPI.key_limmit, value: String(hasLimit)))
        }
        if let hasLanguage = language {
            queryItems.append(NSURLQueryItem(name:EircodeAPI.key_language, value:hasLanguage.rawValue))
        }
        if let hasCountry = country {
            queryItems.append(NSURLQueryItem(name:EircodeAPI.key_country, value:hasCountry.rawValue))
        }
        if includeVanity {
            // Defaults to false, so only put it on if it passed in
            queryItems.append(NSURLQueryItem(name:EircodeAPI.key_vanityMode, value:"true"))
        }
        if let hasAddressProfileName = addressProfileName {
            queryItems.append(NSURLQueryItem(name: EircodeAPI.key_addressProfileName, value:hasAddressProfileName))
        }
        let queryURL = "\(EircodeAPI.address)/FindAddress"
        self.sendRequestToURL(queryURL, parameters: queryItems, completionHandler: completionHandler)
    }

    /**
    post code lookup. See [Postcode lookup API] (https://www.autoaddress.ie/support/developer-centre/api/postcode-lookup for details on response)
    - parameter postcode: The post code to look up
    - parameter completionHandler: The handler which will be called when the async task completes
    - returns: Nothing, you do the hard work in the completion handler
    */
    public func postcodeLookup(postcode:String, completionHandler:EircodeCompletionHandler) {
        var queryItems = [NSURLQueryItem]()
        queryItems.append(NSURLQueryItem(name:EircodeAPI.key_key, value:self.developerKey))
        queryItems.append(NSURLQueryItem(name:EircodeAPI.key_postcode, value:postcode))
        let queryURL = "\(EircodeAPI.address)/postcodelookup"
        self.sendRequestToURL(queryURL, parameters: queryItems, completionHandler: completionHandler)
    }

    /**
    Verify an address against the Eircode system. See [Verify Address API](https://www.autoaddress.ie/support/developer-centre/api/verify-address)
    - parameter postcode: Post code to check
    - parameter address: Address to check, separated by commas
    - parameter language: Optional language to return address in. If not supplied, defaults to English
    - parameter completionHandler: The handler which will be called when the async task completes
    - returns: Nothing, you do the hard work in the completion handler
    */
    public func verifyAddress(postcode:String, address:String, language:EircodeAPI.SupportedLanguages?, completionHandler:EircodeCompletionHandler) {
        var queryItems = [NSURLQueryItem]()
        queryItems.append(NSURLQueryItem(name:EircodeAPI.key_key, value:self.developerKey))
        queryItems.append(NSURLQueryItem(name:EircodeAPI.key_postcode, value:postcode))
        queryItems.append(NSURLQueryItem(name:EircodeAPI.key_address, value:address))
        if let hasLanguage = language {
            queryItems.append(NSURLQueryItem(name:EircodeAPI.key_language, value:hasLanguage.rawValue))
        }
        let queryURL = "\(EircodeAPI.address)/VerifyAddress"
        self.sendRequestToURL(queryURL, parameters: queryItems, completionHandler: completionHandler)
    }
    
    /**
    Get ecad data. Get the available data from the Eircode Address Database for a given ecadId. See [Get ECAD Data API](https://www.autoaddress.ie/support/developer-centre/api/get-ecad-data)
    - parameter ecadId: The ecad id to query
    - parameter completionHandler: The handler which will be called when the async task completes
    - returns: Nothing, you do the hard work in the completion handler
    */
    public func getEcadData(ecadId:String, completionHandler:EircodeCompletionHandler) {
        var queryItems = [NSURLQueryItem]()
        queryItems.append(NSURLQueryItem(name:EircodeAPI.key_key, value:self.developerKey))
        queryItems.append(NSURLQueryItem(name:EircodeAPI.key_ecadId, value:ecadId))
        let queryURL = "\(EircodeAPI.address)/getEcadData"
        self.sendRequestToURL(queryURL, parameters: queryItems, completionHandler: completionHandler)
    }
}