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
    
    @IBOutlet weak var heroNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
