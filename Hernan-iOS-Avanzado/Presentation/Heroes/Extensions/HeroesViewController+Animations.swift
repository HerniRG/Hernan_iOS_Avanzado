//
//  HeroesViewController+Animations.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 23/10/24.
//

import UIKit

extension HeroesViewController {
    
    /// Animación para escalar la imagen del héroe al cargarla.
    func animateCellImage(cell: HeroCollectionViewCell) {
        cell.heroImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3) {
            cell.heroImage.transform = CGAffineTransform.identity
        }
    }
    
    /// Animación para mostrar u ocultar el mensaje de "No hay héroes".
    func animateNoHeroesLabel(show: Bool) {
        if show {
            noHeroesLabel.isHidden = false
            noHeroesLabel.alpha = 0
            noHeroesLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.noHeroesLabel.alpha = 1
                self.noHeroesLabel.transform = CGAffineTransform.identity
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.noHeroesLabel.alpha = 0
                self.collectionView.alpha = 1
            }) { _ in
                self.noHeroesLabel.isHidden = true
                self.collectionView.isHidden = false
            }
        }
    }
    
    /// Animación para mostrar el indicador de carga.
    func showLoadingIndicator() {
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
    }
    
    /// Animación para ocultar el indicador de carga.
    func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
    }
}
