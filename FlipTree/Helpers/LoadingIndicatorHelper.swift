//
//  LoadingIndicatorHelper.swift
//  FlipTree
//
//  Created by Farhana Khan on 02/12/23.
//
import UIKit

/// Helper class for managing and displaying loading indicators.
class LoadingIndicatorHelper {
    /// The shared activity indicator instance.
    private static var activityIndicator: UIActivityIndicatorView?

    /// Sets up a loading indicator for the specified view.
    ///
    /// - Parameter view: The view on which the loading indicator should be displayed.
    static func setupLoader(for view: UIView) {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.color = .gray
        activityIndicator?.hidesWhenStopped = true
        view.addSubview(activityIndicator!)
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator!.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    /// Starts the loading indicator animation.
    static func startLoader() {
        activityIndicator?.startAnimating()
    }

    /// Stops the loading indicator animation.
    static func stopLoader() {
        activityIndicator?.stopAnimating()
    }
}
