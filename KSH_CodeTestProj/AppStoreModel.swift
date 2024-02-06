//
//  AppStoreModel.swift
//  KSH_CodeTestProj
//
//  Created by lyl on 2024/2/4.
//

import Foundation

var wrapperType: String?
//    var kind: String?
//    var collectionId: Int = 0
//    var trackId: Int = 0
//    var artistName: String?
//    var collectionName: String?
//    var trackName: String?
//    var collectionCensoredName: String?
//    var trackCensoredName: String?
//    var collectionArtistId: Int = 0
//    var collectionArtistViewUrl: String?
//    var collectionViewUrl: String?
//    var trackViewUrl: String?
//    var previewUrl: String?
//    var artworkUrl30: String?
//    var artworkUrl60: String?
//    var artworkUrl100: String?
//    var collectionPrice: Int = 0
//    var trackPrice: Int = 0
//    var trackRentalPrice: Int = 0
//    var collectionHdPrice: Int = 0
//    var trackHdPrice: Int = 0
//    var trackHdRentalPrice: Int = 0
//    var releaseDate: String?
//    var collectionExplicitness: String?
//    var trackExplicitness: String?
//    var trackCount: Int = 0
//    var trackNumber: Int = 0
//    var trackTimeMillis: Int = 0
//    var country: String?
//    var currency: String?
//    var primaryGenreName: String?
//    var contentAdvisoryRating: String?
//    var longDescription: String?
    var hasITunesExtras: Bool = false
struct AppStoreModel: Codable {
    let trackName: String
    let artistName: String
    let trackPrice: Double?
    let averageUserRating: Float?
    let releaseDate: String
    let formattedPrice: String?
    let artworkUrl100:String?
    
    enum CodingKeys: String, CodingKey {
        case trackName, artistName, trackPrice, averageUserRating, releaseDate
        case formattedPrice = "formattedPrice",artworkUrl100 = "artworkUrl100"
    }
}
