//
//  Helpers.swift
//  GoogleMapsDemo
//
//  Created by Abbas Angouti on 5/20/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import Foundation

struct Helper {   
    
    static func encodeQueryParameters(_ parameters: [String: AnyObject]) -> String {
        if parameters.isEmpty {
            return ""
        }
        
        var keyValuePairs = Set<String>()
        for (key, value) in parameters {
            // make sure the value is a string
            let stringValue = "\(value)"
            
            // encode it
            let encodedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
            
            // append it
            keyValuePairs.insert(key + "=" + "\(encodedValue!)")
        }
        
        return "\(keyValuePairs.joined(separator: "&"))"
    }
}
