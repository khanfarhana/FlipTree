//
//  UIViewController+Extensions.swift
//  FlipTree
//
//  Created by Farhana Khan on 03/12/23.
//

import Foundation
import UIKit

extension UIViewController {

    // MARK: - Navigation Bar Style

    /// Enumeration to represent the style of the navigation bar.
    enum NavigationBarStyle {
        case dark, light
    }

    /// Sets the style of the navigation bar, including color, background, and item tint.
    ///
    /// - Parameter style: The desired style for the navigation bar.
    func setNavigationBar(style: NavigationBarStyle) {

        // Ensure that the navigation bar is accessible
        guard let navigationBar = navigationController?.navigationBar else { return }

        // Determine the text color based on the selected style
        let color: UIColor = style == .dark ? .white : .black

        // Update navigation bar background color and text attributes
        navigationBar.barStyle = style == .dark ? .black : .default
        navigationBar.tintColor = color
        navigationBar.titleTextAttributes = [.foregroundColor: color]

        // Update status bar style
        setNeedsStatusBarAppearanceUpdate()

        // Update navigation item tint color
        if let items = navigationBar.items {
            for item in items {
                item.rightBarButtonItem?.tintColor = color
                item.leftBarButtonItem?.tintColor = color
            }
        }
    }
}
