//
//  HeroesViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 15/10/24.
//

import UIKit

enum SectionsHeroes{
    case main
}

class HeroesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var viewModel: HeroesViewModel
    private var dataSource: UICollectionViewDiffableDataSource<SectionsHeroes, Hero>?
    
    
    
    init(viewModel: HeroesViewModel = HeroesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HeroesViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    
    func configureLogoutButton() {
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped))
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc func logoutButtonTapped() {
        viewModel.clearData()
    }
    
    func setBinding() {
        viewModel.statusHero.bind { [weak self] status in
            switch status {
            case .loading:
                self?.loadingIndicator.startAnimating()
                self?.loadingIndicator.isHidden = false
            case .dataUpdated:
                self?.loadingIndicator.stopAnimating()
                self?.loadingIndicator.isHidden = true
                
                var snapshot = NSDiffableDataSourceSnapshot<SectionsHeroes, Hero>()
                snapshot.appendSections([.main])
                snapshot.appendItems(self?.viewModel.heroes ?? [], toSection: .main)
                
                self?.dataSource?.apply(snapshot, animatingDifferences: true)
            case .clearDataSuccess:
                self?.navigateToSplash()
            case .error(msg: let msg):
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                debugPrint("error")
            case .none:
                break
            }
        }
    }
    
    func navigateToSplash() {
        navigationController?.popToRootViewController(animated: true)
    }
    
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

extension HeroesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 2 // Número de columnas que quieres
        let padding: CGFloat = 2 // Espacio entre celdas
        let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Márgenes laterales
        
        // Cálculo del ancho disponible restando márgenes y padding
        let totalPadding = (itemsPerRow - 1) * padding + sectionInsets.left + sectionInsets.right
        let availableWidth = collectionView.frame.width - totalPadding
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 200) // Altura fija, puedes ajustarla según necesidad
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Espacio vertical entre filas
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2 // Espacio horizontal entre las celdas
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Márgenes de la sección
    }
}

