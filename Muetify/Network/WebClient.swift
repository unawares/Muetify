//
//  WebClient.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/17/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


typealias JSON = [String: Any?]


enum ServiceError: Error {
    
    case noInternetConnection
    case custom(String)
    case other
    
}


extension ServiceError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No Internet connection"
        case .other:
            return "Internal Error"
        case .custom(let message):
            return message
        }
    }
    
}


extension ServiceError {
    
    init(json: JSON) {
        
        if let message =  json["message"] as? String {
            self = .custom(message)
        } else {
            self = .other
        }
        
    }
    
}


enum RequestMethod: String {
    
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    
}


extension URL {
    
    init(baseUrl: String, path: String, params: JSON, method: RequestMethod) {
        
        var components = URLComponents(string: baseUrl)!
        components.path += path
        
        switch method {
        case .get, .delete:
            components.queryItems = params.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
            }
        default:
            break
        }
        
        self = components.url!
        
    }
    
}


extension URLRequest {
    
    init(baseUrl: String, path: String, method: RequestMethod, params: JSON) {
        let url = URL(baseUrl: baseUrl, path: path, params: params, method: method)
        self.init(url: url)
        httpMethod = method.rawValue
        setValue("application/json", forHTTPHeaderField: "Accept")
        setValue("application/json", forHTTPHeaderField: "Content-Type")
        switch method {
        case .post, .put:
            httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
        default:
            break
        }
    }
    
}



final class WebClient {
    
    private var baseUrl: String
    public var token: String?
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func load(path: String, method: RequestMethod, params: JSON, completion: @escaping (Any?, ServiceError?) -> ()) -> URLSessionDataTask? {

        if !Reachability.isConnectedToNetwork() {
            completion(nil, ServiceError.noInternetConnection)
            return nil
        }
        
        var request = URLRequest(baseUrl: baseUrl, path: path, method: method, params: params)
            
        if let token = token {
            request.addValue(token, forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error?.localizedDescription, error == "cancelled" {
                return
            }
            var object: Any? = nil
            if let data = data {
                object = try? JSONSerialization.jsonObject(with: data, options: [])
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200..<300) ~= httpResponse.statusCode {
                completion(object, nil)
            } else {
                let error = (object as? JSON).flatMap(ServiceError.init) ?? ServiceError.other
                completion(nil, error)
            }
        }
        
        task.resume()
        
        return task
        
    }
    
}
