//
//  AppListViewModel.swift
//  FlipTree
//
//  Created by Farhana Khan on 02/12/23.
//

import Foundation
import CoreData
import UIKit

// MARK: - AppListViewModelDelegate
protocol AppListViewModelDelegate: AnyObject {
    func didUpdateApps(addedIndexPaths: [IndexPath])
    func didFailWithError(_ error: Error)
}
// MARK: - AppListViewModel

class AppListViewModel {
    // MARK: - Properties

    var apps: [Result] = []
    var selectedIndexPath: IndexPath?
    weak var delegate: AppListViewModelDelegate?
    var currentPage: Int = 0
    let pageSize: Int = 3
    
    // MARK: - Network Data Fetching
    func fetchFromNetwork(completion: @escaping () -> Void) {
        // Fetch data from the network using a URL
        let apiUrl = URL(string: "https://rss.applemarketingtools.com/api/v2/in/apps/top-free/100/apps.json")!
        NetworkService.shared.fetchData(from: apiUrl) { [weak self] data, error in
            guard let self = self else { return }

            if let data = data {
                do {
                    let appModel = try JSONDecoder().decode(AppModel.self, from: data)
                    print("Fetch decoding JSON: \(data)")
                    if let results = appModel.feed?.results {
                        self.saveDataToCoreData(results)
                        self.apps = results
                        let addedIndexPaths = (apps.count - pageSize..<apps.count).map { IndexPath(row: $0, section: 0) }
                           delegate?.didUpdateApps(addedIndexPaths: addedIndexPaths)
                        completion()
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                    self.delegate?.didFailWithError(error)
                }
            } else if let error = error {
                print("Error fetching data: \(error)")
                self.delegate?.didFailWithError(error)
            }
        }
    }

    // MARK: - Local Data Fetching
    func fetchLocalData(page: Int, pageSize: Int, completion: @escaping ([Result]) -> Void) {
        // Fetch data from Core Data based on the page and pageSize
        let context = CoreDataStack.shared.viewContext
        let fetchRequest: NSFetchRequest<AppEntity> = AppEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchOffset = page * pageSize
        fetchRequest.fetchLimit = pageSize

        do {
            let results = try context.fetch(fetchRequest)
            let mappedResults = results.map { appEntity -> Result in
                return Result(appEntity: appEntity)
            }
            completion(mappedResults)
        } catch {
            print("Error fetching saved data: \(error)")
            completion([])
        }
    }
    
    // MARK: - Core Data Saving
    func saveDataToCoreData(_ results: [Result]) {
        // Save the given results to Core Data as AppEntity instances
        let context = CoreDataStack.shared.viewContext

        for result in results {
            guard let id = result.id else {
                continue
            }
            DispatchQueue.main.async {
                let appEntity = AppEntity(context: context)
                appEntity.id = id
                appEntity.name = result.name ?? ""
                appEntity.artistName = result.artistName ?? ""
                appEntity.releaseDate = result.releaseDate ?? ""
                
                if let genres = result.genres, !genres.isEmpty {
                    let genresString = genres.compactMap { $0.name }.joined(separator: ", ")
                    appEntity.genres = genresString
                }
                
                appEntity.artworkUrl100 = result.artworkUrl100 ?? ""
                appEntity.timestamp = Date()
            }
            DispatchQueue.main.async {
                CoreDataStack.shared.saveContext()
            }
        }
    }
    
    // MARK: - Data Access Methods
    func getApp(at index: Int) -> Result? {
        // Get the app at the specified index in the apps array
        guard index >= 0, index < apps.count else {
            return nil
        }

        return apps[index]
    }
    
    // MARK: - Date Formatting
    func formattedDate(from dateString: String) -> String {
        // Format the given date string into a human-readable format
         let inputFormatter = DateFormatter()
         inputFormatter.dateFormat = "yyyy-MM-dd"
         
         if let date = inputFormatter.date(from: dateString) {
             let outputFormatter = DateFormatter()
             outputFormatter.dateFormat = "MMMM d, yyyy"
             return outputFormatter.string(from: date)
         } else {
             return "Invalid Date"
         }
    }
    
    // MARK: - Load More Data
    func loadMoreData(completion: @escaping () -> Void) {
        // Load more data either from local storage or from the network
        fetchLocalData(page: currentPage, pageSize: pageSize) { [weak self] mappedResults in
            guard let self = self else { return }

            if !mappedResults.isEmpty {
                let uniqueResults = mappedResults.filter { result in
                    guard let resultID = result.id else {
                        return false
                    }
                    return !self.apps.contains { $0.id == resultID }
                }

                if !uniqueResults.isEmpty {
                    let addedIndexPaths = (self.apps.count..<self.apps.count + uniqueResults.count).map { IndexPath(row: $0, section: 0) }
                    self.apps.append(contentsOf: uniqueResults)
                    self.currentPage += 1
                    self.delegate?.didUpdateApps(addedIndexPaths: addedIndexPaths)
                    completion()
                } else {
                    self.fetchFromNetwork {
                        completion()
                    }
                }
            } else {
                self.fetchFromNetwork {
                    completion()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func updateTableView() {
        // Helper method to update the table view with added index paths
          let addedIndexPaths = (apps.count - pageSize..<apps.count).map { IndexPath(row: $0, section: 0) }
          delegate?.didUpdateApps(addedIndexPaths: addedIndexPaths)
      }
}
