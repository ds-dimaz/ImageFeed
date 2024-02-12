
import UIKit

class SplashViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let alertPresenter = AlertPresenter()
    
    private let showAuthenticationScreen = "ShowAuthenticationScreen"
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter.delegate = self
        
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkAuthStatus()
    }
    
    private func checkAuthStatus() {
        if oauth2Service.isAuthenticated {
            fetchProfile { [ weak self] in
                self?.switchToTabBarController()
            }
        } else {
            switchToAuthViewController()
        }
    }
    
    private func switchToAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(identifier: "AuthViewController")
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") } //TODO: Реализовать по-другому не используя fatalError
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
    
    private func setUpView() {
        let rootView = UIView()
        rootView.frame = CGRect(x: 0.0, y: 0.0, width: 393, height: 852)
        rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootView.backgroundColor = UIColor(named: "YP Black")

        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "LaunchScreenIcon")
        imageView.translatesAutoresizingMaskIntoConstraints = false

        rootView.addSubview(imageView)

        let safeAreaGuide = UILayoutGuide()
        rootView.addLayoutGuide(safeAreaGuide)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: rootView.centerYAnchor)
        ])

        view = rootView
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showAuthenticationScreen {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreen)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code){ [weak self] authResult in
            switch authResult {
            case .success(_):
                self?.fetchProfile(completion: { UIBlockingProgressHUD.dismiss() } )
            case .failure (let error):
                self?.showLoginAlert(error: error)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    private func fetchProfile(completion: @escaping () -> Void) {
        profileService.fetchProfile() { [weak self] profileResult in
            switch profileResult {
            case .success(_):
                guard let username = self?.profileService.profile?.username else { return }
                self?.profileImageService.fetchProfileImageURL(username: username) { _ in }
                self?.switchToTabBarController()
            case .failure(let error):
                self?.showLoginAlert(error: error)
            }
            completion()
        }
    }
    
    private func showLoginAlert(error: Error) {
        alertPresenter.showAlert(title: "Something went wrong",
                                 message: "Couldn't log in, \(error.localizedDescription)") {
            self.performSegue(withIdentifier: self.showAuthenticationScreen, sender: nil)
        }
    }
}
