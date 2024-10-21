//
//  HeroesViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import UIKit
import Kingfisher

// MARK: - SectionsHeroes Enum
enum SectionsHeroes {
    case main
}

// MARK: - HeroesViewController Class
class HeroesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var noHeroesLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var viewModel: HeroesViewModel
    private var dataSource: UICollectionViewDiffableDataSource<SectionsHeroes, Hero>?
    private var isAscendingOrder: Bool = true
    private var searchController = UISearchController(searchResultsController: nil)
    private var searchWorkItem: DispatchWorkItem?
    
    // MARK: - Initializer
    init(viewModel: HeroesViewModel = HeroesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroesViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        title = "Heroes"
        configureLogoutButton()
        configureSearchController()
        configureSortButton()
        setBinding()
        viewModel.loadData(filter: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(false, animated: animated)
        configureNavigationBar(title: "Heroes", backgroundColor: .systemBackground)
        searchController.searchBar.text = ""
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Search Configuration
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar héroe"
        
        // Cambiar el texto del botón "Cancel" a "Cancelar"
        searchController.searchBar.setValue("Cancelar", forKey: "cancelButtonText")
        // Evitar que el UISearchController encoge la barra de navegación
        searchController.hidesNavigationBarDuringPresentation = false
        
        // Hacer que la barra de búsqueda se muestre directamente en la navegación
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // Configuración de los botones de orden
    private func configureSortButton() {
        let sortIcon = UIImage(systemName: "arrow.up.arrow.down")
        let sortButton = UIBarButtonItem(image: sortIcon, style: .plain, target: self, action: #selector(sortButtonTapped))
        sortButton.tintColor = .label
        navigationItem.leftBarButtonItem = sortButton
    }
    
    @objc func sortButtonTapped() {
        isAscendingOrder.toggle()
        viewModel.sortHeroes(ascending: isAscendingOrder)
    }
    
    
    // MARK: - Logout Button Configuration
    func configureLogoutButton() {
        let logoutIcon = UIImage(systemName: "power") // Icono de un botón de apagado para representar el logout
        let logoutButton = UIBarButtonItem(image: logoutIcon, style: .plain, target: self, action: #selector(logoutButtonTapped))
        logoutButton.tintColor = .label
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc func logoutButtonTapped() {
        viewModel.clearData()
    }
    
    // MARK: - Binding ViewModel
    func setBinding() {
        viewModel.statusHero.bind { [weak self] status in
            switch status {
            case .loading:
                self?.loadingIndicator.startAnimating()
                self?.loadingIndicator.isHidden = false
            case .dataUpdated:
                self?.loadingIndicator.stopAnimating()
                self?.loadingIndicator.isHidden = true
                self?.updateCollectionView()
            case .clearDataSuccess:
                self?.navigateToSplash()
            case .error(msg: let msg):
                self?.showErrorAlert(message: msg)
            case .none:
                break
            }
        }
    }
    
    private func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionsHeroes, Hero>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.heroes, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        // Mostrar u ocultar el mensaje "No hay héroes"
        let noResults = viewModel.heroes.isEmpty
        
        if noResults {
            // Si no hay héroes, animar la aparición del label
            noHeroesLabel.isHidden = false
            noHeroesLabel.alpha = 0
            noHeroesLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.noHeroesLabel.alpha = 1
                self.noHeroesLabel.transform = CGAffineTransform.identity
            })
            
            // Ocultar la collectionView si no hay resultados
            collectionView.isHidden = true
        } else {
            // Si hay héroes, ocultar el label y mostrar la collectionView
            UIView.animate(withDuration: 0.3, animations: {
                self.noHeroesLabel.alpha = 0
                self.collectionView.alpha = 1
            }) { _ in
                self.noHeroesLabel.isHidden = true
                self.collectionView.isHidden = false
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigate to Splash
    func navigateToSplash() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Collection View Configuration
    func configureCollectionView() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        let cellRegister = UICollectionView.CellRegistration<HeroCollectionViewCell, Hero>(cellNib: UINib(nibName: HeroCollectionViewCell.identifier, bundle: nil)) { cell, indexPath, hero in
            
            cell.heroNameLabel.text = hero.name
            // Animación personalizada de escala (zoom)
            if let url = URL(string: hero.photo) {
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
        
        dataSource = UICollectionViewDiffableDataSource<SectionsHeroes, Hero>(collectionView: collectionView, cellProvider: { collectionView, indexPath, hero in
            collectionView.dequeueConfiguredReusableCell(using: cellRegister, for: indexPath, item: hero)
        })
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HeroesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = collectionView.frame.width > collectionView.frame.height ? 3 : 2 // Cambia el número de columnas según la orientación
        let padding: CGFloat = 2 // Espacio entre celdas
        let sectionInsets = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10) // Márgenes laterales
        
        // Cálculo del ancho disponible restando márgenes y padding
        let totalPadding = (itemsPerRow - 1) * padding + sectionInsets.left + sectionInsets.right
        let availableWidth = collectionView.frame.width - totalPadding
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 200) // Altura fija, puedes ajustarla según necesidad
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2 // Espacio vertical entre filas
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2 // Espacio horizontal entre las celdas
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Márgenes de la sección
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let hero = viewModel.heroAt(index: indexPath.row) else { return }
        
        let detailsHeroViewModel = DetailsHeroViewModel(hero: hero)
        let detailsHeroViewController = DetailsHeroViewController(viewModel: detailsHeroViewModel)
        
        navigationController?.pushViewController(detailsHeroViewController, animated: true)
    }
}


// MARK: - UISearchResultsUpdating
extension HeroesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        
        // Cancelar cualquier búsqueda anterior
        searchWorkItem?.cancel()
        
        // Crear un nuevo WorkItem para retrasar la búsqueda
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.viewModel.loadData(filter: searchText.isEmpty ? nil : searchText)
        }
        
        // Guardar el nuevo WorkItem y ejecutarlo después de un pequeño retraso
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
}
