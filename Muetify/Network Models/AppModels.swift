//
//  AppModels.swift
//  Muetify
//
//  Created by Theodore Teddy on 12/18/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


struct FolderData: Decodable, Hashable, Comparable {
    
    static func < (lhs: FolderData, rhs: FolderData) -> Bool {
        return lhs.title < rhs.title
    }
    
    var title: String
    var description: String
    
}


extension FolderData {
    
    init?(json: JSON?) {
        if let json = json {
            self.title = json["title"] as! String
            self.description = json["description"] as! String
        } else {
            return nil
        }
    }
    
}


struct SongData: Decodable {
    
    var pk: Int
    var title: String
    var genre: String
    var created: String
    var updated: String
    var media: String
    var duration: Float
    var singers: [String]
    var poster: String?
    var text: String
    
}


extension SongData {
    
    init?(json: JSON?) {
        if let json = json {
            self.pk = json["pk"] as! Int
            self.title = json["title"] as! String
            self.genre = json["genre"] as! String
            self.created = json["created"] as! String
            self.updated = json["updated"] as! String
            self.media = json["media"] as! String
            self.duration = (json["duration"] as? NSNumber)?.floatValue ?? 0
            self.singers = json["singers"] as! [String]
            self.poster = json["poster"] as? String
            self.text = json["text"] as! String
        } else {
            return nil
        }
    }
    
}


struct SongReferenceData: Decodable {
    
    var songData: SongData?
    var folderData: FolderData?
    
}


extension SongReferenceData {
    
    init?(json: JSON?) {
        if let json = json {
            self.songData = SongData(json: json["song"] as? JSON)
            self.folderData = FolderData(json: json["folder"] as? JSON)
        } else {
            return nil
        }
    }
    
}


protocol AlbumBase {
    
    func getCount() -> Int
    
    func getTitle() -> String
    
    func getKey() -> String
    
}


struct UserGenreData: AlbumBase, Decodable {

    
    var genre: String
    var count: Int
    
    func getKey() -> String {
        return genre
    }
    
    func getCount() -> Int {
        return count
    }
    
    func getTitle() -> String {
        return genre
    }
    
}


extension UserGenreData {
    
    init?(json: JSON?) {
        if let json = json {
            self.genre = json["genre"] as! String
            self.count = json["songs_count"] as! Int
        } else {
            return nil
        }
    }
    
}



struct UserSingerData: AlbumBase, Decodable {
    
    var pk: Int
    var firstName: String
    var lastName: String
    var count: Int
    
    func getKey() -> String {
        return "\(pk)"
    }
    
    func getCount() -> Int {
        return count
    }
    
    func getTitle() -> String {
        return "\(firstName) \(lastName)"
    }
    
}


extension UserSingerData {
    
    init?(json: JSON?) {
        if let json = json {
            self.pk = json["pk"] as! Int
            self.firstName = json["first_name"] as! String
            self.lastName = json["last_name"] as! String
            self.count = json["songs_count"] as! Int
        } else {
            return nil
        }
    }
    
}



struct UserFolderData: AlbumBase, Decodable {
        
    var pk: Int
    var title: String
    var description: String
    var count: Int
    
    func getKey() -> String {
        return "\(pk)"
    }
    
    func getCount() -> Int {
        return count
    }
    
    func getTitle() -> String {
        return title
    }
    
}


extension UserFolderData {
    
    init?(json: JSON?) {
        if let json = json {
            self.pk = json["pk"] as! Int
            self.title = json["title"] as! String
            self.description = json["description"] as! String
            self.count = json["songs_count"] as! Int
        } else {
            return nil
        }
    }
    
}
