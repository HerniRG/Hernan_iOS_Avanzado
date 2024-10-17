//
//  HeroCollectionViewCell.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import UIKit

class HeroCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Identifier
    static var identifier: String {
        return String(describing: HeroCollectionViewCell.self)
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var heroNameLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI() // Configura la UI al inicializar la celda
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Configuración de la containerView
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.clipsToBounds = true
        
        // Configuración de la heroImage
        heroImage.layer.cornerRadius = 10
        heroImage.layer.borderWidth = 0.5
        heroImage.layer.borderColor = UIColor.black.cgColor
        heroImage.clipsToBounds = true
    }
}
