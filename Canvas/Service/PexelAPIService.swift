//
//  PexelsAPIService.swift
//  Canvas
//
//  Created by Rabia Abdioğlu on 9.09.2024.
//

import Foundation
import Alamofire

class PexelsAPIService {
    
    // MARK: - Properties
    static let shared = PexelsAPIService()
    private let baseURL = "https://api.pexels.com/v1"
    private let apiKey = "0rWBGhCRoFiVbbq4duycTLqsvROdrjKqHdGkciUBYdubEU21DoqNC6yY"
    
    // MARK: - Fetch Curated Photos
    func fetchCuratedPhotos(perPage: Int, completion: @escaping (Result<[PexelsPhoto], Error>) -> Void) {
        let url = "\(baseURL)/curated"
        let headers: HTTPHeaders = [
            "Authorization": apiKey
        ]
        let parameters: [String: Any] = [
            "per_page": perPage,
            "page": 1
        ]
        
        AF.request(url, parameters: parameters, headers: headers)
            .responseDecodable(of: PexelsPhotoResponse.self) { response in
                switch response.result {
                case .success(let photoResponse):
                    completion(.success(photoResponse.photos))
                case .failure(let error):
                    print("Failed to fetch photos: \(error)")
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Fetch Popular Videos
    func fetchPopularVideos(perPage: Int, completion: @escaping (Result<[PexelsVideo], Error>) -> Void) {
        let url = "\(baseURL)/videos/popular"
        let headers: HTTPHeaders = [
            "Authorization": apiKey
        ]
        let parameters: [String: Any] = [
            "per_page": perPage
        ]
        
        AF.request(url, parameters: parameters, headers: headers)
            .responseDecodable(of: PexelsVideoResponse.self) { response in
                switch response.result {
                case .success(let videoResponse):
                    completion(.success(videoResponse.videos))
                case .failure(let error):
                    print("Failed to fetch videos: \(error)")
                    completion(.failure(error))
                }
            }
    }
}
