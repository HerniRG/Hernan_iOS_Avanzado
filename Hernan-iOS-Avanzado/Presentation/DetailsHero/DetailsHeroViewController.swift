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
    @IBOutlet weak var stackViewTransformations: UIStackView!
    
    // MARK: - Properties
    private var viewModel: DetailsHeroViewModel
    private var mapViewController: MapViewController?
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCollectionView()
    }
    
    // MARK: - Setup inicial de la UI
    private func setupUI() {
        configureHeroLabel()
        configureHeroImage()
        configureStackViewTransformations()
        configureActivityIndicator()
        configureNavigationBar()
    }
    
    private func configureHeroLabel() {
        heroLabel.alpha = 0
    }
    
    private func configureHeroImage() {
        heroImage.alpha = 0
        heroImage.layer.cornerRadius = 10
        heroImage.layer.borderWidth = 0.5
        heroImage.layer.borderColor = UIColor.label.cgColor
        heroImage.clipsToBounds = true
    }
    
    private func configureStackViewTransformations() {
        stackViewTransformations.alpha = 0
        stackViewTransformations.isHidden = true
    }
    
    private func configureActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func configureNavigationBar() {
        configureNavigationBar(title: viewModel.getHero().name, backgroundColor: .systemBackground)
    }
    
    // MARK: - Bindings
    private func setBinding() {
        viewModel.status.bind { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .loading:
                self.showLoadingState()
            case .success:
                self.showSuccessState()
            case .error(let message):
                self.showError(message: message)
            }
        }
    }
    
    // MARK: - Actualizar visibilidad del ítem del mapa
    private func updateMapItemVisibility() {
        if viewModel.getAnnotations().isEmpty {
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
        if mapViewController == nil {
            mapViewController = MapViewController()
        }
        mapViewController?.configure(with: viewModel.getAnnotations())
        if let mapVC = mapViewController {
            navigationController?.pushViewController(mapVC, animated: true)
        }
    }
    
    // MARK: - Mostrar estado de carga
    private func showLoadingState() {
        activityIndicator.startAnimating()
        hideUIElements()
        updateMapItemVisibility()
    }
    
    // MARK: - Mostrar estado de éxito
    private func showSuccessState() {
        activityIndicator.stopAnimating()
        updateHeroInfo()
        updateStackViewTransformations()
        updateMapItemVisibility()
        animateUIElements()
        updateCollectionView()
    }
    
    // MARK: - Mostrar error
    private func showError(message: String) {
        activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actualizar colección
    private func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionsTransformations, Transformation>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.getTransformations(), toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Ocultar elementos de la UI
    private func hideUIElements() {
        heroLabel.alpha = 0
        heroImage.alpha = 0
        stackViewTransformations.alpha = 0
        stackViewTransformations.isHidden = true
    }
    
    // MARK: - Actualizar información del héroe
    private func updateHeroInfo() {
        heroLabel.text = viewModel.getHero().info
        if let imageUrl = URL(string: viewModel.getHero().photo) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.heroImage.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
            }
        }
    }
    
    // MARK: - Actualizar StackView de transformaciones
    private func updateStackViewTransformations() {
        if viewModel.getTransformations().isEmpty {
            stackViewTransformations.isHidden = true
        } else {
            stackViewTransformations.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.stackViewTransformations.alpha = 1
            }
        }
    }
    
    
    // MARK: - Animaciones de la UI
    private func animateUIElements() {
        UIView.animate(withDuration: 0.5) {
            self.heroLabel.alpha = 1
            self.heroImage.alpha = 1
            if !self.stackViewTransformations.isHidden {
                self.stackViewTransformations.alpha = 1
            }
        }
        
        // Aparecer con retraso y de abajo hacia arriba
        transformationsCollectionView.transform = CGAffineTransform(translationX: 0, y: 50)
        transformationsCollectionView.alpha = 0
        
        UIView.animate(withDuration: 0.7, delay: 0.5, options: [.curveEaseInOut], animations: {
            self.transformationsCollectionView.transform = .identity
            self.transformationsCollectionView.alpha = 1
        }, completion: nil)
    }
    
    // MARK: - Configuración del Collection View
    func configureCollectionView() {
        transformationsCollectionView.contentInsetAdjustmentBehavior = .never
        transformationsCollectionView.delegate = self
        let cellRegister = UICollectionView.CellRegistration<HeroCollectionViewCell, Transformation>(cellNib: UINib(nibName: HeroCollectionViewCell.identifier, bundle: nil)) { cell, indexPath, transformation in
            cell.heroNameLabel.text = transformation.name
            if let url = URL(string: transformation.photo) {
                cell.heroImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<SectionsTransformations, Transformation>(collectionView: transformationsCollectionView, cellProvider: { collectionView, indexPath, transformation in
            collectionView.dequeueConfiguredReusableCell(using: cellRegister, for: indexPath, item: transformation)
        })
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DetailsHeroViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedTransformation = viewModel.transformationAt(index: indexPath.row) else { return }
        
        let detailsTransformationViewModel = DetailsTransformationViewModel(transformation: selectedTransformation)
        let detailsTransformationViewController = DetailsTransformationViewController(viewModel: detailsTransformationViewModel)
        
        present(detailsTransformationViewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) // Márgenes laterales
        let widthPerItem: CGFloat = 300
        let heightPerItem = collectionView.frame.height - sectionInsets.top - sectionInsets.bottom
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}
