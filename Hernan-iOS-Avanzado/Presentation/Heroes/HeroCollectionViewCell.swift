//
//  HeroCollectionViewCell.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import UIKit

class HeroCollectionViewCell: UICollectionViewCell {

    static var identifier: String {
        return String(describing: HeroCollectionViewCell.self)
    }
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var heroNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
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
