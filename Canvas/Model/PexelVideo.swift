//
//  PexelVideo.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import Foundation
struct PexelsVideo: Codable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let image: String
    let videoFiles: [PexelsVideoFile]
}

struct PexelsVideoFile: Codable {
    let id: Int
    let quality: String
    let fileType: String
    let link: String
}

struct PexelsVideoResponse: Codable {
    let page: Int
    let perPage: Int
    let videos: [PexelsVideo]
    let nextPage: String?
}
