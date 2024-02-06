//
//  APIManager.swift
//  KSH_CodeTestProj
//
//  Created by lyl on 2024/2/4.
//

import Foundation
import Alamofire

struct SearchResponse: Codable {
    let resultCount: Int
    let results: [AppStoreModel]
}

extension String {
    // 去除HTML标签
    func removeHTMLTags() -> String {
        do {
            // 将HTML文本转换为NSAttributedString
            let attributedString = try NSAttributedString(data: Data(utf8),
                                                          options: [
                                                              .documentType: NSAttributedString.DocumentType.html,
                                                              .characterEncoding: String.Encoding.utf8.rawValue
                                                          ],
                                                          documentAttributes: nil)

            // 从NSAttributedString中提取纯文本
            let plainText = attributedString.string
            return plainText
        } catch {
            print("Error while removing HTML tags: \(error)")
            return self
        }
    }
}

class APIManager {
    
    func searchApps(searchTerm: String, completion: @escaping (Result<[AppStoreModel], Error>) -> Void) {
        NetworkService.shared.fetchApps(searchTerm: searchTerm) { result in
            switch result {
            case .success(let data):
                do {
                    // json解析
                    let jsonDecoder = JSONDecoder()
                    let searchResponse = try jsonDecoder.decode(SearchResponse.self, from: data)
                    completion(.success(searchResponse.results))
                } catch {
                    if let errorString = String(data: data, encoding: .utf8) {
                        
                        if let decodingError = error as? DecodingError, case .dataCorrupted = decodingError {
                            let corruptedError = NSError(domain: "https://itunes.apple.com", code: 1, userInfo: [NSLocalizedDescriptionKey: errorString.removeHTMLTags()]) as Error
                            completion(.failure(corruptedError))
                        }
                    }
                    
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}




