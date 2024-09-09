//
//  PexelEnums.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import Foundation
enum AnyItem {
    case photo(PexelsPhoto)
    case video(PexelsVideo)
}

enum DataType {
    case photo
    case overlay
    case video
}
