//
//  SplashViewController.swift
//  Hernan-iOS-Avanzado
//
//  Created by Hernán Rodríguez on 14/10/24.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet weak var dragonBallImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startDragonBallAnimation()
    }
    
    private func startDragonBallAnimation() {
        UIView.animateKeyframes(withDuration: 3.0, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.addKeyframeAnimations()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.stopAnimationAndNavigate()
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
    
    private func stopAnimationAndNavigate() {
        UIView.animate(withDuration: 0.5, animations: {
            self.dragonBallImage.transform = .identity
        }) { _ in
            self.navigateToLogin()
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
