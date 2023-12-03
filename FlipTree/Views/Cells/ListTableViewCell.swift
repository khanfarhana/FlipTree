//
//  ListTableViewCell.swift
//  FlipTree
//
//  Created by Farhana Khan on 02/12/23.
//
import UIKit

class ListTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    
    var app: Result? {
        didSet {
            configureCell()
        }
    }
    
    // MARK: - Cell Configuration
    
    private func configureCell() {
        // Ensure app is not nil before configuring the cell
        guard let app = app else {
            // Handle nil case
            return
        }
        
        // Set title label with app name
        titleLabel.text = app.name
        
        // Display artist name or "Unknown Artist" if not available
        if let artistName = app.artistName {
            artistLabel.text = "By \(artistName)"
        } else {
            artistLabel.text = "By Unknown Artist"
        }
        
        // Load app image or display a default image if not available
        if let urlString = app.artworkUrl100, let url = URL(string: urlString) {
            listImageView.sd_cancelCurrentImageLoad()
            listImageView.sd_setImage(with: url, placeholderImage: nil)
        }
    }
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Apply corner radius and border to the image view for a polished look
        listImageView.layer.cornerRadius = 10
        listImageView.layer.masksToBounds = true
        listImageView.layer.borderColor = UIColor.white.cgColor
        listImageView.layer.borderWidth = 1.0
        
        // Apply corner radius and border to the cell for a consistent appearance
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
    }
    
    // MARK: - Cell Selection
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Add custom selection behavior if needed
    }
    
    // MARK: - Prepare For Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Cancel ongoing image loading and reset image when cell is reused
        listImageView.sd_cancelCurrentImageLoad()
        listImageView.image = nil
    }
}
