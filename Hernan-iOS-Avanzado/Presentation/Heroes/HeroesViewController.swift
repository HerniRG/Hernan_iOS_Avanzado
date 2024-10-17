//
//  HeroesViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import UIKit

// MARK: - SectionsHeroes Enum
enum SectionsHeroes {
    case main
}

// MARK: - HeroesViewController Class
class HeroesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    private var viewModel: HeroesViewModel
    private var dataSource: UICollectionViewDiffableDataSource<SectionsHeroes, Hero>?
    
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
        configureNavigationBar(title: "Heroes", backgroundColor: .systemBackground)
        configureLogoutButton()
        setBinding()
        viewModel.loadData(filter: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Logout Button Configuration
    func configureLogoutButton() {
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped))
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
            if let hero = self.viewModel.heroAt(index: indexPath.row) {
                cell.heroNameLabel.text = hero.name
                cell.heroImage.setImage(from: hero.photo)
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
        let itemsPerRow: CGFloat = 2 // Número de columnas que quieres
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
}
