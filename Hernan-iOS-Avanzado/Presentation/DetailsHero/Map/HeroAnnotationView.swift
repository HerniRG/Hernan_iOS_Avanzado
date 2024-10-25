//
//  HeroAnnotationView.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 19/10/24.
//

import MapKit

class HeroAnnotationView: MKAnnotationView {
    static let identifier = String(describing: HeroAnnotationView.self)
    
    private let streetViewButton: UIButton = UIButton(type: .infoLight)
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        canShowCallout = true
        
        backgroundColor = .clear
        let imageView = UIImageView(image: UIImage(resource: .dragonBall))
        imageView.frame = bounds
        addSubview(imageView)
        
        rightCalloutAccessoryView = streetViewButton
    }
    
    // Configurar la acción del botón de Street View
    func configureButtonAction(target: AnyObject, action: Selector) {
        streetViewButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
