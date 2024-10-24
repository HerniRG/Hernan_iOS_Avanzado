//
//  HeroAnnotationView.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 19/10/24.
//

import MapKit

class HeroAnnotationView: MKAnnotationView {
    static var identifier: String {
        return String(describing: HeroAnnotationView.self)
    }
    
    private var streetViewButton: UIButton!
    
    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        self.canShowCallout = true
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .clear
        let view = UIImageView(image: UIImage(resource: .dragonBall))
        addSubview(view)
        view.frame = self.bounds
        
        // Añadir el botón de street view
        streetViewButton = UIButton(type: .infoLight)
        self.rightCalloutAccessoryView = streetViewButton
    }
    
    // Método para configurar la acción del botón
    func configureButtonAction(target: AnyObject, action: Selector) {
        streetViewButton.addTarget(target, action: action, for: .touchUpInside)
    }

}
