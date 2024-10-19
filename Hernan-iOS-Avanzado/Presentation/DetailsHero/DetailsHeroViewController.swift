//
//  DetailsHeroViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 17/10/24.
//

// MARK: - DetailsHeroViewController.swift

import UIKit
import Kingfisher

// MARK: - SectionsHeroes Enum
enum SectionsTransformations {
    case main
}

class DetailsHeroViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var heroLabel: UILabel!
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var transformationsCollectionView: UICollectionView!
    
    // MARK: - Properties
    private var viewModel: DetailsHeroViewModel
    private var dataSource: UICollectionViewDiffableDataSource<SectionsTransformations, Transformation>?
    
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
        configureCollectionView()
        setupUI()
        setBinding()
        viewModel.loadData()
    }
    
    // MARK: - Setup inicial de la UI
    private func setupUI() {
        // Ocultar inicialmente el contenido del héroe
        heroLabel.alpha = 0
        heroImage.alpha = 0
        configureHeroImageAppearance()
        activityIndicator.startAnimating()
        
        // Configurar el título del NavigationBar
        configureNavigationBar(title: viewModel.hero.name, backgroundColor: .systemBackground)
    }
    
    // MARK: - Configurar apariencia de la imagen
    private func configureHeroImageAppearance() {
        heroImage.layer.cornerRadius = 10
        heroImage.layer.borderWidth = 0.5
        heroImage.layer.borderColor = UIColor.label.cgColor
        heroImage.clipsToBounds = true
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
            navigationItem.rightBarButtonItem = nil
        } else {
            let mapIcon = UIImage(systemName: "map")
            let rightButton = UIBarButtonItem(image: mapIcon, style: .plain, target: self, action: #selector(mapButtonTapped))
            rightButton.tintColor = .label
            navigationItem.rightBarButtonItem = rightButton
        }
    }
    
    // MARK: - Acción al tocar el botón de mapa
    @objc private func mapButtonTapped() {
        let mapViewController = MapViewController()
        mapViewController.configure(with: viewModel.annotations)
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    // MARK: - Mostrar estado de carga
    private func showLoadingState() {
        activityIndicator.startAnimating()
        heroLabel.alpha = 0
        heroImage.alpha = 0
        
        // Actualizar la visibilidad del ítem en la barra de navegación
        updateMapItemVisibility()
    }
    
    // MARK: - Mostrar estado de éxito
    private func showSuccessState() {
        // Detener el indicador de carga
        activityIndicator.stopAnimating()
        
        // Mostrar la información del héroe
        heroLabel.text = viewModel.hero.info
        if let imageUrl = URL(string: viewModel.hero.photo) {
            heroImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
        }
        
        // Animación para mostrar los elementos
        UIView.animate(withDuration: 0.5) {
            self.heroLabel.alpha = 1
            self.heroImage.alpha = 1
        }
        
        // Actualizar la visibilidad del ítem en la barra de navegación
        updateMapItemVisibility()
        updateCollectionView()
    }
    
    private func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionsTransformations, Transformation>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.transformations, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Mostrar Error
    private func showError(message: String) {
        activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Collection View Configuration
    func configureCollectionView() {
        transformationsCollectionView.contentInsetAdjustmentBehavior = .never
        transformationsCollectionView.delegate = self
        let cellRegister = UICollectionView.CellRegistration<HeroCollectionViewCell, Transformation>(cellNib: UINib(nibName: HeroCollectionViewCell.identifier, bundle: nil)) { cell, indexPath, transformation in
            
            cell.heroNameLabel.text = transformation.name
            // Animación personalizada de escala (zoom)
            if let url = URL(string: transformation.photo) {
                cell.heroImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"), options: [.cacheOriginalImage]) { result in
                    switch result {
                    case .success(_):
                        // Animación de zoom cuando se carga la imagen
                        cell.heroImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.heroImage.transform = CGAffineTransform.identity
                        })
                    case .failure(let error):
                        print("Error al cargar la imagen: \(error)")
                    }
                }
            }
            
        }
        
        dataSource = UICollectionViewDiffableDataSource<SectionsTransformations, Transformation>(collectionView: transformationsCollectionView, cellProvider: { collectionView, indexPath, transformation in
            collectionView.dequeueConfiguredReusableCell(using: cellRegister, for: indexPath, item: transformation)
        })
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DetailsHeroViewController: UICollectionViewDelegateFlowLayout {

    func transformationsCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) // Márgenes laterales
        
        // Cálculo del ancho disponible restando márgenes y padding
        let availableHeight = collectionView.frame.height - sectionInsets.top - sectionInsets.bottom
        let widthPerItem = collectionView.frame.width / 2 // Ajusta la proporción del ancho si quieres más items en pantalla

        return CGSize(width: widthPerItem, height: availableHeight) // Ajustar el ancho y mantener la altura completa
    }

    func transformationsCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Espacio horizontal entre celdas
    }

    func transformationsCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // Sin espacio entre los items en la misma fila (solo horizontal en este caso)
    }

    func transformationsCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) // Márgenes horizontales
    }
}
