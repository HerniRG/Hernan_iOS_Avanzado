//
//  SplashViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 14/10/24.
//

import UIKit

// MARK: - SplashViewController
class SplashViewController: UIViewController {
    
    @IBOutlet weak var dragonBallImage: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startDragonBallAnimation()
    }
    
    // MARK: - Animation
    private func startDragonBallAnimation() {
        UIView.animateKeyframes(withDuration: 3.0, delay: 0, options: [.autoreverse], animations: {
            self.addKeyframeAnimations()
        }) {_ in 
            self.navigateToLogin()
        }
    }
    
    private func addKeyframeAnimations() {
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
            self.dragonBallImage.transform = CGAffineTransform(translationX: 0, y: -20)
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
            self.dragonBallImage.transform = .identity
        }
    }
    
    private func navigateToLogin() {
        if SecureDataStore.shared.getToken() != nil {
            let heroesViewController = HeroesViewController()
            navigationController?.pushViewController(heroesViewController, animated: true)
        } else {
            let loginViewController = LoginViewController()
            navigationController?.pushViewController(loginViewController, animated: true)
        }
    }
}
