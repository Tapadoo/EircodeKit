EircodeKit
----------

EircodeKit is an open source library, written in Swift to access the Autoaddress Eircode API
This API is documented at [The Autoaddress Developer Center](https://www.autoaddress.ie/support/developer-centre/api)

The repository consists of a single XCode project with the main API code in EircodeAPI.swift, and sample unit tests in EircodeKitTests.swift

# Using EircodeKit
See the unit tests file for examples, but using EircodeKit is straight forward
1. Obtain a developer key from Autoaddress by visiting their developer center. You have to fill out a form to request a key
2. The key needs to be supplied when initialising the EircodeAPI object:
```swift
let api = EircodeAPI("YOUR DEVELOPER KEY GOES HERE")
```
3. There are 4 public methods on the API, and they are fully documented
4. Each API call takes a completion handler callback described in EircodeAPI.swift:
```swift
public typealias EircodeCompletionHandler = (error:NSError?, retData:AnyObject?) -> Void
```

The data is returned in the completion handler as AnyObject?, which will typically be an NSDictionary
We've not parsed the individual dictionaries, but a full breakdown of the returned data is suppled on the Autoaddress site.

This software is supplied open source. See the LICENSE file for details.

# Future Enhancements
We encourage people to branch and make pull requests. For example, parsing the returned data for each API call is something that could improve this API

All errors, enhancements and feedback to [Tapadoo](mailto:feedback@tapadoo.com)
