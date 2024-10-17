//
//  UIImageView+Remote.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 16/10/24.
//

import UIKit

extension UIImageView {
    func setImage(from urlString: String) {
        // Intentar convertir el string en URL
        guard let url = URL(string: urlString) else {
            print("URL inválida: \(urlString)")
            return
        }
        
        // Llamamos al método para descargar la imagen
        downloadWithURLSession(url: url) { [weak self] image in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    // Este método obtiene una imagen a partir de una URL utilizando URLSession
    private func downloadWithURLSession(
        url: URL,
        completion: @escaping (UIImage?) -> Void
    ) {
        // No manejamos errores para simplificar el ejercicio
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else {
                // Si no se puede desempaquetar la data o la imagen
                completion(nil)
                return
            }
            completion(image)
        }
        .resume()
    }
}
