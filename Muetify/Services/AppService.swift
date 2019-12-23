//
//  AuthService.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/17/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


final class AppService {
    
    private let client = WebClient(baseUrl: "http://172.20.10.12:8080")
    
    func setToken(token: String) -> AppService {
        client.token = "Token \(token)"
        return self
    }

    @discardableResult
    func getAllSongs(search: String, completion: @escaping ([SongData], ServiceError?) -> ()) -> URLSessionDataTask? {
        let params = [
            "ordering": "title",
            "search": search
        ]
        return client.load(path: "/songs/all/", method: .get, params: params) { result, error in
            let items = result as? [JSON]
            let songs = items?.map({ (item) -> SongData? in SongData(json: item as JSON?)}) ?? []
            var filteredSongs: [SongData] = []
            for song in songs {
                if let song = song {
                    filteredSongs.append(song)
                }
            }
            completion(filteredSongs, error)
        }
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
    
    @discardableResult
    func getFriendSongs(friendId: Int, completion: @escaping ([SongReferenceData], ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/songs/friends/\(friendId)/", method: .get, params: [:]) { result, error in
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
    
    @discardableResult
    func getUserGenres(completion: @escaping ([UserGenreData], ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/songs/genres/", method: .get, params: [:]) { result, error in
            let items = result as? [JSON]
            let userGenres = items?.map({ (item) -> UserGenreData? in UserGenreData(json: item as JSON?)}) ?? []
            var filteredUserGenres: [UserGenreData] = []
            for userGenre in userGenres {
                if let userGenre = userGenre {
                    filteredUserGenres.append(userGenre)
                }
            }
            completion(filteredUserGenres, error)
        }
    }
    
    @discardableResult
    func getUserSingers(completion: @escaping ([UserSingerData], ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/songs/singers/", method: .get, params: [:]) { result, error in
            let items = result as? [JSON]
            let userSingers = items?.map({ (item) -> UserSingerData? in UserSingerData(json: item as JSON?)}) ?? []
            var filteredUserSingers: [UserSingerData] = []
            for userSinger in userSingers {
                if let userSinger = userSinger {
                    filteredUserSingers.append(userSinger)
                }
            }
            completion(filteredUserSingers, error)
        }
    }
    
    @discardableResult
    func getUserFolders(completion: @escaping ([UserFolderData], ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/songs/folders/", method: .get, params: [:]) { result, error in
            let items = result as? [JSON]
            let userFolders = items?.map({ (item) -> UserFolderData? in UserFolderData(json: item as JSON?)}) ?? []
            var filteredUserFolders: [UserFolderData] = []
            for userFolder in userFolders {
                if let userFolder = userFolder {
                    filteredUserFolders.append(userFolder)
                }
            }
            completion(filteredUserFolders, error)
        }
    }
    
    @discardableResult
    func getGenreSongs(genre: String, completion: @escaping ([SongData], ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/songs/filter/genres/\(genre)/", method: .get, params: [:]) { result, error in
            let items = result as? [JSON]
            let songs = items?.map({ (item) -> SongData? in SongData(json: item as JSON?)}) ?? []
            var filteredSongs: [SongData] = []
            for song in songs {
                if let song = song {
                    filteredSongs.append(song)
                }
            }
            completion(filteredSongs, error)
        }
    }
    
    @discardableResult
    func getSingerSongs(singer: String, completion: @escaping ([SongData], ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/songs/filter/singers/\(singer)/", method: .get, params: [:]) { result, error in
            let items = result as? [JSON]
            let songs = items?.map({ (item) -> SongData? in SongData(json: item as JSON?)}) ?? []
            var filteredSongs: [SongData] = []
            for song in songs {
                if let song = song {
                    filteredSongs.append(song)
                }
            }
            completion(filteredSongs, error)
        }
    }
    
    @discardableResult
    func getFolderSongs(folder: String, completion: @escaping ([SongData], ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/songs/filter/folders/\(folder)/", method: .get, params: [:]) { result, error in
            let items = result as? [JSON]
            let songs = items?.map({ (item) -> SongData? in SongData(json: item as JSON?)}) ?? []
            var filteredSongs: [SongData] = []
            for song in songs {
                if let song = song {
                    filteredSongs.append(song)
                }
            }
            completion(filteredSongs, error)
        }
    }
    
    
    @discardableResult
    func addContacts(phoneNumbers: [String], completion: @escaping ([String], ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/contacts/virtual/add_phone_numbers/", method: .post, params: ["phone_numbers": phoneNumbers]) { result, error in
            let items = (result as? JSON)?["phone_numbers"]
            var filteredPhoneNumbers: [String] = []
            if let items = items as? [String] {
                for item in items {
                    filteredPhoneNumbers.append(item)
                }
            }
            completion(filteredPhoneNumbers, error)
        }
    }
    
    
    @discardableResult
    func getContacts(completion: @escaping ([UserData], ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/contacts/", method: .get, params: [:]) { result, error in
            let items = result as? [JSON]
            let contacts = items?.map({ (item) -> UserData? in UserData(json: item as JSON?)}) ?? []
            var filteredContacts: [UserData] = []
            for contact in contacts {
                if let contact = contact {
                    filteredContacts.append(contact)
                }
            }
            completion(filteredContacts, error)
        }
    }
    
    @discardableResult
    func getContact(completion: @escaping (UserData?, ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/auth/user/", method: .get, params: [:]) { result, error in
            completion(UserData(json: result as? JSON), error)
        }
    }
    
    
    @discardableResult
    func createFolder(folder: UserFolderPostData, completion: @escaping (UserFolderData?, ServiceError?) -> ()) -> URLSessionDataTask? {
        
        return client.load(path: "/songs/folders/", method: .post, params: [
            "title": folder.title,
            "description": folder.description
        ]) { result, error in
            completion(UserFolderData(json: result as? JSON), error)
        }
    }
    
    @discardableResult
    func updateFolder(folderKey: String, toFolder: UserFolderPostData, completion: @escaping (UserFolderData?, ServiceError?) -> ()) -> URLSessionDataTask? {
        
        return client.load(path: "/songs/folders/\(folderKey)/", method: .put, params: [
            "title": toFolder.title,
            "description": toFolder.description
        ]) { result, error in
            completion(UserFolderData(json: result as? JSON), error)
        }
    }
    
    @discardableResult
    func removeFolder(folderKey: String, completion: @escaping (ServiceError?) -> ()) -> URLSessionDataTask? {
        return client.load(path: "/songs/folders/\(folderKey)/", method: .delete, params: [:]) { result, error in
            completion(error)
        }
    }
    
}
