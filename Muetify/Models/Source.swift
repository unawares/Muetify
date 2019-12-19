//
//  Source.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/14/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation


protocol Source {
    
    func getId() -> Int
    
    func getUrl() -> URL
    
    func getTitle() -> String
        
    func getSinger() -> String
    
    func getDuration() -> TimeInterval
    
}
