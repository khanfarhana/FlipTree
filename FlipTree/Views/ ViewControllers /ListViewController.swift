//
//  ListViewController.swift
//  FlipTree
//
//  Created by Farhana Khan on 02/12/23.
//

import UIKit
import SDWebImage

class ListViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    var viewModel = AppListViewModel()
    let cellSpacingHeight: CGFloat = 5
    var activityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup loading indicator
        LoadingIndicatorHelper.setupLoader(for: view)
        
        // Setup pull-to-refresh control
        setupRefreshControl()
        
        // Set initial navigation item title
        self.navigationItem.title = ""
        
        // Set delegate for AppListViewModel
        viewModel.delegate = self
        
        // Load initial data
        viewModel.loadMoreData {
            DispatchQueue.main.async {
                LoadingIndicatorHelper.stopLoader()
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        
        LoadingIndicatorHelper.startLoader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigation bar when view appears
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show navigation bar when view disappears
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Refresh Control
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .gray
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refreshData() {
        // Refresh data from network
        viewModel.loadMoreData { [weak self] in
            DispatchQueue.main.async {
                LoadingIndicatorHelper.stopLoader()
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
        
        LoadingIndicatorHelper.startLoader()
        viewModel.fetchFromNetwork() {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.apps.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure and return the custom cell for each row
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        cell.app = viewModel.getApp(at: indexPath.section)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Navigate to DetailViewController when a row is selected
        let vc = storyboard?.instantiateViewController(identifier: "DetailViewController") as! DetailViewController
        let detailViewModel = viewModel
        detailViewModel.selectedIndexPath = indexPath
        vc.viewModel = viewModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Load more data when reaching the end of the table view
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            viewModel.loadMoreData {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - AppListViewModelDelegate

extension ListViewController: AppListViewModelDelegate {
    
    func didUpdateApps(addedIndexPaths: [IndexPath]) {
        // Update table view with newly added data
        DispatchQueue.main.async {
            let lastSectionIndex = self.tableView.numberOfSections - 1
            
            if lastSectionIndex >= 0 {
                let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex) - 1
                
                if let lastIndexPath = addedIndexPaths.last {
                    let newLastRowIndex = lastIndexPath.row
                    let newLastSectionIndex = lastIndexPath.section
                    
                    if newLastSectionIndex == lastSectionIndex && newLastRowIndex > lastRowIndex {
                        self.tableView.insertRows(at: addedIndexPaths, with: .automatic)
                    }
                }
            }
        }
    }
    
    func didFailWithError(_ error: Error) {
        // Handle and log errors when fetching data
        print("Error fetching data: \(error)")
    }
}
