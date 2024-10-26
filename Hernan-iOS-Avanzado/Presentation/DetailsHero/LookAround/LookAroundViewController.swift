//
//  LookAroundViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 24/10/24.
//

import UIKit
import MapKit

class LookAroundViewController: UIViewController {
    
    private let viewModel: LookAroundViewModel
    
    init(viewModel: LookAroundViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLookAroundView()
    }
    
    private func setupLookAroundView() {
        let lookAroundVC = MKLookAroundViewController(scene: viewModel.scene)
        lookAroundVC.delegate = self
        lookAroundVC.view.frame = view.bounds
        lookAroundVC.badgePosition = .bottomTrailing
        
        addChild(lookAroundVC)
        view.addSubview(lookAroundVC.view)
        lookAroundVC.didMove(toParent: self)
    }
}

extension LookAroundViewController: MKLookAroundViewControllerDelegate {
    func lookAroundViewControllerWillDismissFullScreen(_ viewController: MKLookAroundViewController) {
        dismiss(animated: true, completion: nil)
    }
}
