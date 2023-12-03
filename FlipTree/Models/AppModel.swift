//
//  AppModel.swift
//  FlipTree
//
//  Created by Farhana Khan on 02/12/23.
//

import UIKit
import CoreData

// MARK: - AppModel
public class AppModel: Codable {
    var feed: Feed?
}

// MARK: - Feed
struct Feed: Codable {
    var title: String?
    var id: String?
    var author: Author?
    var links: [Link]?
    var copyright, country: String?
    var icon: String?
    var updated: String?
    var results: [Result]?
}

// MARK: - Author
struct Author: Codable {
    var name: String?
    var url: String?
}

// MARK: - Link
struct Link: Codable {
    var linkSelf: String?

    enum CodingKeys: String, CodingKey {
        case linkSelf = "self"
    }
}

// MARK: - Result
struct Result: Codable {
    var artistName, id, name, releaseDate: String?
    var kind: Kind?
    var artworkUrl100: String?
    var genres: [Genre]?
    var url: String?
    
    // Custom initializer to convert from AppEntity to Result
    init(appEntity: AppEntity) {
        id = appEntity.id
        name = appEntity.name
        artistName = appEntity.artistName
        releaseDate = appEntity.releaseDate
        artworkUrl100 = appEntity.artworkUrl100
        
        // Convert comma-separated genres string to an array of Genre
        if let genresString = appEntity.genres {
            let genreNames = genresString.components(separatedBy: ", ")
            genres = genreNames.map { Genre(genreID: nil, name: $0, url: nil) }
        } else {
            genres = []
        }
    }
}

// MARK: - Genre
struct Genre: Codable {
    var genreID, name: String?
    var url: String?

    enum CodingKeys: String, CodingKey {
        case genreID = "genreId"
        case name, url
    }
}

// MARK: - Kind
enum Kind: String, Codable {
    case apps = "apps"
}
