//
//  FileSource.swift
//  Muetify
//
//  Created by Theodore Teddy on 11/9/19.
//  Copyright © 2019 Theodore Teddy. All rights reserved.
//

import Foundation
import AVKit

let BUFFER_SIZE = 1024

class StreamSource {
    
    private let stream: InputStream
    let data: Data
    
    init(from stream: InputStream) {
        self.stream = stream
        self.data = Data(reading: stream)
        
    }
    
}


extension Data {
    
    init(reading input: InputStream) {
        self.init()
        input.open()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            self.append(buffer, count: read)
        }
        buffer.deallocate()
        input.close()
    }
    
    init(reading input: InputStream, for byteCount: Int) {
        self.init()
        input.open()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: byteCount)
        let read = input.read(buffer, maxLength: byteCount)
        self.append(buffer, count: read)
        buffer.deallocate()
    }
    
}
