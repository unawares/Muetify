//
//  AuthService.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/17/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


final class AppService {
    
    private let client = WebClient(baseUrl: "http://192.168.1.9:8000")
    
    func setToken(token: String) -> AppService {
        client.token = "Token \(token)"
        return self
    }

    @discardableResult
    func getUserSongs(completion: @escaping ([SongReferenceData], ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/songs/user/", method: .get, params: [:]) { result, error in
            let items = result as? [JSON]
            let songs = items?.map({ (item) -> SongReferenceData? in SongReferenceData(json: item as JSON?)}) ?? []
            var filteredSongs: [SongReferenceData] = []
            for song in songs {
                if let song = song {
                    filteredSongs.append(song)
                }
            }
            completion(filteredSongs, error)
        }
    }
    
}
