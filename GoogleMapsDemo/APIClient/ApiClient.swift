//
//  ApiClient.swift
//  GoogleMapsDemo
//
//  Created by Abbas Angouti on 5/20/18.
//  Copyright © 2018 Abbas Angouti. All rights reserved.
//

import Foundation

class ApiClient {
    static let shared = ApiClient()
    
    private init() {}
    
    func getAddresses(for address: String, completion:@escaping (_ result: ResultType) -> Void) {
                
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)&sensor=false") else {
            completion(ResultType.error(e: DataFetchError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            /* GUARD: Was there an error? */
            guard error == nil else {
                completion(ResultType.error(e: DataFetchError.networkError(message: error!.localizedDescription)))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 399 else {
                completion(ResultType.error(e: DataFetchError.invalidResponse))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completion(ResultType.error(e: DataFetchError.nilResult))
                return
            }
            
            do {
                let apiResult = try JSONDecoder().decode(GeoCodeApiResponse.self, from: data)
                if apiResult.status.lowercased() == "OK".lowercased() {
                    completion(ResultType.success(r: apiResult.results))
                } else {
                    completion(ResultType.error(e: DataFetchError.invalidDataFormat))
                }
            } catch let parseError {
                completion(ResultType.error(e: DataFetchError.jsonError(message: parseError.localizedDescription)))
            }
        }
        
        task.resume()
        
    }
}

