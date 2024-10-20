//
//  UIViewController+NavigationBar.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import UIKit

extension UIViewController {
    
    // MARK: - NavigationBar Configuration
    func configureNavigationBar(title: String?, backgroundColor: UIColor, extendedBar: Bool = false) {
        self.title = title
        navigationController?.navigationBar.prefersLargeTitles = extendedBar ? true : false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = UIColor.black
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .label
    }
}
