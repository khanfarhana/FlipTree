//
//  DetailViewController.swift
//  FlipTree
//
//  Created by Farhana Khan on 02/12/23.
//
import UIKit

class DetailViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var releaseDataLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    
    // MARK: - Properties
    
    var viewModel: AppListViewModel!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    // MARK: - UI Setup
    
    func setupUI() {
        // Apply corner radius to the image view for rounded corners
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        titleLabel.textColor =  UIColor { text in
            switch text.userInterfaceStyle {
            case .dark:
                return UIColor.white
            default:
                return UIColor.black
            }
        }
        setNavigationBar(style: traitCollection.userInterfaceStyle == .dark ? .dark : .light)
    }
    
    // MARK: - Data Setup
    
    func setupData() {
        // Retrieve selected app information from the view model
        if let indexPath = viewModel.selectedIndexPath,
           let app = viewModel.getApp(at: indexPath.section) {
            
            // Set UI elements with app data
            titleLabel.text = app.name
            
            // Display artist name or "Unknown Artist" if not available
            if let artistName = app.artistName {
                detailLabel.text = "By \(artistName)"
            } else {
                detailLabel.text = "By Unknown Artist"
            }
            
            // Display release date or "Not available" if not present
            if let releaseDate = app.releaseDate {
                releaseDataLabel.text = "Release Date: \(viewModel.formattedDate(from: releaseDate))"
            } else {
                releaseDataLabel.text = "Release Date: Not available"
            }
            
            // Display genres or "Not available" if not present
            if let genres = app.genres, !genres.isEmpty {
                let genresString = genres.map { $0.name ?? "" }.joined(separator: ", ")
                genresLabel.text = "Genres: \(genresString)"
            } else {
                genresLabel.text = "Genres: Not available"
            }
            
            // Load app image or display a default image if not available
            if let urlString = app.artworkUrl100, let url = URL(string: urlString) {
                imageView.sd_cancelCurrentImageLoad()
                imageView.sd_setImage(with: url, placeholderImage: nil)
            } else {
                imageView.image = UIImage(named: "DefaultImage")
            }
        }
    }
}
