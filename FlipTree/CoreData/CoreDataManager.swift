//
//  CoreDataManager.swift
//  FlipTree
//
//  Created by Farhana Khan on 02/12/23.
//

import CoreData

/// Singleton class responsible for managing the Core Data stack.
class CoreDataStack {
    /// Shared instance of the Core Data stack.
    static let shared = CoreDataStack()

    /// The persistent container for the Core Data stack.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FlipTree")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Core Data Error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    /// The view context for the Core Data stack.
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    /// Saves changes to the Core Data stack's view context.
    func saveContext() {
        guard viewContext.hasChanges else {
            return
        }
        DispatchQueue.main.async {
            do {
                try self.viewContext.save()
            } catch {
                if let error = error as NSError? {
                    print("Core Data Error: \(error), \(error.userInfo)")
                }
            }
        }
    }
}
