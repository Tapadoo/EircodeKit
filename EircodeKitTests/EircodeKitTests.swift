//
//  EircodeKitTests.swift
//  EircodeKitTests
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

import XCTest
@testable import EircodeKit

class EircodeKitTests: XCTestCase {
    static let MY_DEVELOPER_KEY = "<YOUR DEVELOPER KEY GOES HERE>"
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // We're using codes from the published sample data
    // See https://www.autoaddress.ie/support/sample-eircode-data
    
    func testPostcodeLookup() {
        let api = EircodeAPI(developerKey: EircodeKitTests.MY_DEVELOPER_KEY)
        let asyncExpectation = self.expectationWithDescription("postcode lookup returns")
        api.postcodeLookup("X33 2KPH") { (error, retData) -> Void in
            if error  != nil {
                print(error)
                XCTAssert(false,error!.localizedDescription)
            } else {
                print(retData!)
                XCTAssert(true)
            }
            asyncExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10) { (error) -> Void in
        }
    }
    
    func testFindAddress() {
        let api = EircodeAPI(developerKey: EircodeKitTests.MY_DEVELOPER_KEY)
        let asyncExpectation = self.expectationWithDescription("find address returns")
        api.findAddress("8 Silber Birches, Dunboyne", addressId: nil, limit: nil, language: .English, country: .Ireland, includeVanity: false, addressProfileName: nil) { (error, retData) -> Void in
            if error  != nil {
                print(error)
                XCTAssert(false,error!.localizedDescription)
            } else {
                print(retData!)
                XCTAssert(true)
            }
            asyncExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10) { (error) -> Void in
        }
    }
    
    func testVerifyAddress() {
        let api = EircodeAPI(developerKey: EircodeKitTests.MY_DEVELOPER_KEY)
        let asyncExpectation = self.expectationWithDescription("verify address returns")
        api.verifyAddress("P50 270A", address: "1 Woodlands Road, Cabinteely, Dublin 18", language: .English) { (error, retData) -> Void in
            if error  != nil {
                print(error)
                XCTAssert(false,error!.localizedDescription)
            } else {
                print(retData!)
                XCTAssert(true)
            }
            asyncExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10) { (error) -> Void in
        }
    }
    
    func testGetEcadData() {
        let api = EircodeAPI(developerKey: EircodeKitTests.MY_DEVELOPER_KEY)
        let asyncExpectation = self.expectationWithDescription("ecad lookup returns")
        api.getEcadData("1004102963") { (error, retData) -> Void in
            if error  != nil {
                print(error)
                XCTAssert(false,error!.localizedDescription)
            } else {
                print(retData!)
                XCTAssert(true)
            }
            asyncExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10) { (error) -> Void in
        }
    }
}
