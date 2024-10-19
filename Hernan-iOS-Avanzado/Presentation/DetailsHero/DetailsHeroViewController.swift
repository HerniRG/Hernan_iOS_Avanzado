//
//  DetailsHeroViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 17/10/24.
//

import UIKit
import Kingfisher

class DetailsHeroViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var heroLabel: UILabel!
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var transformationsCollectionView: UICollectionView!
    
    // MARK: - Properties
    private var viewModel: DetailsHeroViewModel
    
    // MARK: - Initializer
    init(viewModel: DetailsHeroViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: DetailsHeroViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureNavigationBarWithItem()
        setBinding()
        viewModel.loadData()
        
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Ocultar inicialmente el contenido del héroe y mostrar el indicador de carga
        heroLabel.alpha = 0 // Oculto al principio
        heroImage.alpha = 0 // Oculto al principio
        
        // Iniciar el indicador de carga
        activityIndicator.startAnimating()
    }
    
    private func configureNavigationBarWithItem() {
        // Configurar el título
        configureNavigationBar(title: viewModel.heroName, backgroundColor: .systemBackground)
        
        // Comprobar si hay anotaciones
        updateMapItemVisibility()
    }
    
    // Acción al tocar el botón de mapa
    @objc private func mapButtonTapped() {
        let mapViewController = MapViewController()
        mapViewController.configure(with: viewModel.annotations)
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    // MARK: - Bindings
    private func setBinding() {
        viewModel.status.bind { [weak self] status in
            switch status {
            case .loading:
                self?.showLoadingState()
            case .success:
                self?.showSuccessState()
            case .error(let message):
                self?.showError(message: message)
            }
        }
    }
    
    // MARK: - Mostrar/Ocultar el ítem de mapa en la barra de navegación
    private func updateMapItemVisibility() {
        if viewModel.annotations.isEmpty {
            // Si no hay anotaciones, quitar el botón
            navigationItem.rightBarButtonItem = nil
        } else {
            // Si hay anotaciones, mostrar solo el icono de mapa con animación
            let mapIcon = UIImage(systemName: "map")
            let rightButton = UIBarButtonItem(image: mapIcon, style: .plain, target: self, action: #selector(mapButtonTapped))
            rightButton.tintColor = .label
            
            UIView.transition(with: navigationController?.navigationBar ?? UINavigationBar(), duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.navigationItem.rightBarButtonItem = rightButton
            }, completion: nil)
        }
    }
    
    // MARK: - Show Loading State
    private func showLoadingState() {
        // Mostrar el indicador de carga
        activityIndicator.startAnimating()
        
        // Ocultar la información del héroe (aún más si hay algo visible)
        UIView.animate(withDuration: 0.3) {
            self.heroLabel.alpha = 0
            self.heroImage.alpha = 0
        }
    }
    
    // MARK: - Show Success State
    private func showSuccessState() {
        // Detener el indicador de carga con animación
        UIView.animate(withDuration: 0.3, animations: {
            self.activityIndicator.alpha = 0
        }, completion: { _ in
            self.activityIndicator.stopAnimating()
        })
        
        // Mostrar la información del héroe con una animación suave (fade in)
        UIView.animate(withDuration: 0.5) {
            self.heroLabel.alpha = 1
            self.heroImage.alpha = 1
        }
        
        // Configurar el contenido del héroe
        heroLabel.text = viewModel.heroInfo
        if let imageUrl = URL(string: viewModel.heroPhoto) {
            heroImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
        }
        
        // Actualizar la visibilidad del ítem en la barra de navegación
        updateMapItemVisibility()
    }
    
    // MARK: - Show Error
    private func showError(message: String) {
        // Detener el indicador de carga con animación
        UIView.animate(withDuration: 0.3, animations: {
            self.activityIndicator.alpha = 0
        }, completion: { _ in
            self.activityIndicator.stopAnimating()
        })
        
        // Mostrar una alerta con el mensaje de error
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
