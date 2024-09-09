//
//  PexelPhoto.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import Foundation

struct PexelsPhotoResponse: Decodable {
    let page: Int
    let per_page: Int?
    let photos: [PexelsPhoto]
    let next_page: String?
}

struct PexelsPhoto: Decodable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographer_url: String
    let photographer_id: Int
    let avg_color: String?
    let src: PexelsPhotoSource
    let liked: Bool
    let alt: String
}

struct PexelsPhotoSource: Decodable {
    let original: String
    let large2x: String?
    let large: String?
    let medium: String?
    let small: String?
    let portrait: String?
    let landscape: String?
    let tiny: String?
}
