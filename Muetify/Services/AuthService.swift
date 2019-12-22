//
//  AuthService.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/17/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


final class AuthService {
    
    private let client = WebClient(baseUrl: "http://172.20.10.12:8080")
    
    func setToken(token: String) -> AuthService {
        client.token = "Token \(token)"
        return self
    }
    
    @discardableResult
    func syncPhoneNumber(forPhoneNumber phoneNumber: PhoneNumberModel, completion: @escaping (PhoneNumberModel?, ServiceError?) -> ()) -> URLSessionDataTask? {
        let params: JSON = ["phone_number": phoneNumber.phoneNumber]
        
        return client.load(path: "/auth/phone/", method: .post, params: params) { result, error in
            completion(PhoneNumberModel(json: result as? JSON), error)
        }
    }
    
    @discardableResult
    func getUser(completion: @escaping (UserData?, ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/auth/user/", method: .get, params: [:]) { result, error in
            completion(UserData(json: result as? JSON), error)
        }
    }
    
    @discardableResult
    func syncSignIn(forSignInData signInData: SignInData, completion: @escaping (TokenAuthData?, ServiceError?) -> ()) -> URLSessionDataTask? {
        
        let params: JSON = [
            "uuid": signInData.uuid,
            "data": signInData.data,
        ]
        
        return client.load(path: "/auth/signin/", method: .post, params: params) { result, error in
            completion(TokenAuthData(json: result as? JSON), error)
        }
    }
    
    @discardableResult
    func syncSignUp(forSignUpData signUpData: SignUpData, completion: @escaping (TokenAuthData?, ServiceError?) -> ()) -> URLSessionDataTask? {
        
        let params: JSON = [
            "uuid": signUpData.uuid,
            "data": signUpData.data,
            "user": [
                "first_name": signUpData.userData.firstName,
                "last_name": signUpData.userData.lastName
            ]
        ]
        
        return client.load(path: "/auth/signup/", method: .post, params: params) { result, error in
            completion(TokenAuthData(json: result as? JSON), error)
        }
    }
    
}
