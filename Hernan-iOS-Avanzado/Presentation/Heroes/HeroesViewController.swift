//
//  HeroesViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

// HeroesViewController.swift
// Hernan-iOS-Avanzado
//
// Created by Hernán Rodríguez on 15/10/24.

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
        viewModel.sortHeroes()
        updateCollectionView()
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
        searchController.searchBar.setValue("Cancelar", forKey: "cancelButtonText")
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func configureSortButton() {
        let sortIcon = UIImage(systemName: "arrow.up.arrow.down")
        let sortButton = UIBarButtonItem(image: sortIcon, style: .plain, target: self, action: #selector(sortButtonTapped))
        sortButton.tintColor = .label
        navigationItem.leftBarButtonItem = sortButton
    }
    
    @objc func sortButtonTapped() {
        viewModel.isAscendingOrder.toggle()
        viewModel.sortHeroes()
    }

    private func configureLogoutButton() {
        let logoutIcon = UIImage(systemName: "power")
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
        let noResults = viewModel.heroes.isEmpty
        
        if noResults {
            animateNoHeroesLabel(show: true)
            collectionView.isHidden = true
        } else {
            animateNoHeroesLabel(show: false)
            collectionView.isHidden = false
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func navigateToSplash() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Collection View Configuration
    func configureCollectionView() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        let cellRegister = UICollectionView.CellRegistration<HeroCollectionViewCell, Hero>(cellNib: UINib(nibName: HeroCollectionViewCell.identifier, bundle: nil)) { cell, indexPath, hero in
            
            cell.heroNameLabel.text = hero.name
            if let url = URL(string: hero.photo) {
                cell.heroImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"), options: [.cacheOriginalImage]) { result in
                    switch result {
                    case .success(_):
                        self.animateCellImage(cell: cell)
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
    
    // Este método define el tamaño de cada celda en la colección.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Determina cuántos elementos por fila habrá, basándose en si la anchura es mayor que la altura
        let itemsPerRow: CGFloat = collectionView.frame.width > collectionView.frame.height ? 3 : 2
        
        // Espaciado entre los elementos de la colección
        let padding: CGFloat = 2
        
        // Inset de la sección (margen superior, izquierdo, inferior y derecho)
        let sectionInsets = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        
        // Calcula el padding total (es decir, el espacio que ocupa entre los elementos y los insets de la sección)
        let totalPadding = (itemsPerRow - 1) * padding + sectionInsets.left + sectionInsets.right
        
        // Calcula el ancho disponible en la colección restando el padding total de la anchura total de la colección
        let availableWidth = collectionView.frame.width - totalPadding
        
        // Calcula el ancho que tendrá cada celda dividiendo el ancho disponible por el número de elementos por fila
        let widthPerItem = availableWidth / itemsPerRow
        
        // Devuelve el tamaño de la celda, con el ancho calculado y una altura fija de 200
        return CGSize(width: widthPerItem, height: 200)
    }
    
    // Este método define el espacio mínimo entre las líneas de las celdas en la colección.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2 // Espacio mínimo entre líneas de celdas
    }
    
    // Este método define el espacio mínimo entre las celdas en la misma línea.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2 // Espacio mínimo entre celdas en la misma línea
    }
    
    // Este método define los insets para la sección, es decir, el margen de la sección.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Margen superior, izquierdo, inferior y derecho para la sección
    }
    
    // Este método maneja la acción cuando se selecciona una celda en la colección.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Obtiene el héroe asociado a la celda seleccionada
        guard let hero = viewModel.heroAt(index: indexPath.row) else { return }
        
        // Inicializa el ViewModel para la vista de detalles del héroe
        let detailsHeroViewModel = DetailsHeroViewModel(hero: hero)
        
        // Inicializa el controlador de vista de detalles del héroe con el ViewModel
        let detailsHeroViewController = DetailsHeroViewController(viewModel: detailsHeroViewModel)
        
        // Navega hacia la vista de detalles del héroe
        navigationController?.pushViewController(detailsHeroViewController, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension HeroesViewController: UISearchResultsUpdating {
    
    // Este método actualiza los resultados de búsqueda en función del texto ingresado.
    func updateSearchResults(for searchController: UISearchController) {
        // Obtiene el texto de búsqueda
        let searchText = searchController.searchBar.text ?? ""
        
        // Cancela cualquier trabajo de búsqueda anterior
        searchWorkItem?.cancel()
        
        // Crea un nuevo trabajo de búsqueda
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // Carga los datos con el filtro de búsqueda
            self.viewModel.loadData(filter: searchText.isEmpty ? nil : searchText)
        }
        
        // Asigna el trabajo de búsqueda
        searchWorkItem = workItem
        
        // Ejecuta el trabajo después de un retraso de 0.5 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
}
