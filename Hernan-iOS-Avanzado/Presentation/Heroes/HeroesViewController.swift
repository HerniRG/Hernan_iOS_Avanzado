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
        setBinding()
        viewModel.loadData(filter: nil)
        
    }
    
    func setBinding() {
        viewModel.statusHero.bind { status in
            switch status {
            case .dataUpdated:
                var snapshot = NSDiffableDataSourceSnapshot<SectionsHeroes, Hero>()
                snapshot.appendSections([.main])
                snapshot.appendItems(self.viewModel.heroes, toSection: .main)
                
                self.dataSource?.apply(snapshot, animatingDifferences: true)
                
                
            case .error(msg: let msg):
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                debugPrint("error")
            case .none:
                break
            }
        }
    }

    
    func configureCollectionView() {
        collectionView.delegate = self
        let cellRegister = UICollectionView.CellRegistration<HeroCollectionViewCell, Hero>(cellNib: UINib(nibName: HeroCollectionViewCell.identifier, bundle: nil)) { cell, indexPath, hero in
            if let hero = self.viewModel.heroAt(index: indexPath.row) {
                cell.heroNameLabel.text = hero.name
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<SectionsHeroes, Hero>(collectionView: collectionView, cellProvider: { collectionView, indexPath, hero in
            collectionView.dequeueConfiguredReusableCell(using: cellRegister, for: indexPath, item: hero)
        })
    }
}

extension HeroesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Dividimos el ancho del collectionView entre 2 para lograr 2 columnas
        let width = collectionView.frame.width / 2 - 10 // Ajustamos un poco con padding si es necesario
        return CGSize(width: width, height: 100)
    }
    
}
