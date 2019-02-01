//
//  Model.swift
//  GoogleMapsDemo
//
//  Created by Abbas Angouti on 5/20/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import Foundation
import GoogleMaps

protocol APIResult {}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct Geometry: Codable {
    let rawLocation: Location
    var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(rawLocation.lat, rawLocation.lng)
    }
    
    private enum CodingKeys: String, CodingKey {
        case rawLocation = "location"
    }
}

struct GeoCodeLocation: Codable {
    let formattedAddress: String // formatted_address
    let geometry: Geometry
    
    private enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
        case geometry
    }
    
}

struct GeoCodeApiResponse: Codable {
    let status: String
    let results: [GeoCodeLocation]
}




// different possible error types
enum DataFetchError: Error {
    case invalidURL
    case networkError(message: String)
    case invalidResponse
    case serverError
    case nilResult
    case invalidDataFormat
    case jsonError(message: String)
    case invalideDataType(message: String)
    case unknownError
}

enum ResultType {
    case success(r: APIResult)
    case error(e: DataFetchError)
}

extension GeoCodeLocation: APIResult {}

extension Array: APIResult where Element: APIResult {}


