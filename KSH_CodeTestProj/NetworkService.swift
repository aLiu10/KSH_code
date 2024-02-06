//
//  NetworkService.swift
//  KSH_CodeTestProj
//
//  Created by lyl on 2024/2/4.
//

import Foundation
import Alamofire
import ProgressHUD

class NetworkService {
    
    //创建单例
    static let shared = NetworkService()
    private let baseURL = "https://itunes.apple.com/search"
    func fetchApps(searchTerm: String, completion: @escaping (Result<Data, AFError>) -> Void) {
        let searchQuery = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "song"
        let urlString = "\(baseURL)?term=\(searchQuery)&limit=200&country=HK"
        //https://itunes.apple.com/search?term=歌&limit=200&country=HK
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    private init() {}
}



