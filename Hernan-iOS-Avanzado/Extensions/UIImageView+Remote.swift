//
//  UIImageView+Remote.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import UIKit

extension UIImageView {
    
    // MARK: - Set Image from URL
    func setImage(from urlString: String) {
        // Placeholder de imagen por defecto
        self.image = UIImage(systemName: "photo")

        // Intentar convertir el string en URL
        guard let url = URL(string: urlString) else {
            debugPrint("URL inválida: \(urlString)")
            return
        }
        
        // Descargar la imagen
        downloadWithURLSession(url: url) { [weak self] image in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    // MARK: - Download Image with URLSession
    private func downloadWithURLSession(url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
}
