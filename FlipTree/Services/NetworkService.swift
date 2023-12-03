//
//  NetworkService.swift
//  FlipTree
//
//  Created by Farhana Khan on 02/12/23.
//

import Foundation

// MARK: - NetworkService

class NetworkService {
    // MARK: - Singleton Instance
    
    static let shared = NetworkService()
    
    // MARK: - Public Methods
    
    /// Fetches data from the specified URL.
    ///
    /// - Parameters:
    ///   - url: The URL from which to fetch data.
    ///   - completion: The completion handler to be called when the fetch operation is complete.
    ///                 It provides the fetched data and any error encountered during the operation.
    func fetchData(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            completion(data, error)
        }.resume()
    }
}
