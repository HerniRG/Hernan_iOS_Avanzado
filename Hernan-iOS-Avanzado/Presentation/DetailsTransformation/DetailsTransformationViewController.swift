// DetailsTransformationViewController.swift
// Hernan-iOS-Avanzado
//
// Created by Hernán Rodríguez on 20/10/24.

import UIKit
import Kingfisher

class DetailsTransformationViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var transformationNameLabel: UILabel!
    @IBOutlet weak var transformationDescriptionLabel: UILabel!
    @IBOutlet weak var dragIndicatorView: UIView!
    @IBOutlet weak var transformationImageView: UIImageView!
    
    // MARK: - Properties
    private var viewModel: DetailsTransformationViewModel
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: - Initializer
    init(viewModel: DetailsTransformationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: DetailsTransformationViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPanGesture()
    }
}

// MARK: - UI Configuration
extension DetailsTransformationViewController {
    
    // MARK: - Setup UI
    private func setupUI() {
        // Configura la UI con la información que viene del ViewModel
        transformationNameLabel.text = viewModel.getTransformationName()
        transformationDescriptionLabel.text = viewModel.getTransformationDescription()
        
        // Cargar la imagen utilizando Kingfisher con manejo de errores
        if let url = viewModel.getTransformationPhotoURL() {
            transformationImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholderImage"),
                options: nil,
                completionHandler: { result in
                    switch result {
                    case .success(_):
                        // La imagen se cargó correctamente, no es necesario hacer nada adicional
                        break
                    case .failure(let error):
                        // Ocurrió un error al cargar la imagen
                        debugPrint("Error al cargar la imagen: \(error)")
                    }
                }
            )
        }
        // Añadir esquinas redondeadas y borde a la containerView
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.label.cgColor
        containerView.clipsToBounds = true
        
        // Añadir esquinas redondeadas y borde a la imagen de la transformación
        transformationImageView.layer.cornerRadius = 10
        transformationImageView.layer.borderWidth = 0.5
        transformationImageView.layer.borderColor = UIColor.label.cgColor
        transformationImageView.clipsToBounds = true
        
        dragIndicatorView.layer.cornerRadius = 3
    }
}

// MARK: - Pan Gesture Handling
extension DetailsTransformationViewController {
    
    // MARK: - Setup Pan Gesture
    private func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Handle Pan Gesture
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        // Si el gesto es hacia abajo y la vista es un modal, permitir el cierre
        if translation.y > 0 {
            view.frame.origin.y = translation.y
        }
        
        // Cuando el gesto finaliza
        if gesture.state == .ended {
            // Si el deslizamiento hacia abajo es suficiente, cerrar el modal
            if translation.y > 200 {
                dismiss(animated: true, completion: nil)
            } else {
                // Si no es suficiente, volver a la posición original
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = 0
                }
            }
        }
    }
}
