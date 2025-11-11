//
//  onboardingViewController.swift
//  Finial Task
//
//  Created by Sara Syam on 21/11/2024.
//

import UIKit
import Network
import CoreData

class onboardingViewController: UIViewController ,UICollectionViewDelegate ,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var pageControllerForMovieCollectionView: UIPageControl!
    @IBOutlet weak var welcomeBackLabel: UILabel!
    @IBOutlet weak var enjoyLabel: UILabel!
    @IBOutlet weak var registerLabelButton: UIButton!
    @IBOutlet weak var loginLabelButton: UIButton!
    @IBOutlet weak var bySignLabel: UILabel!
    
    var imageArray = [UIImage(named: "mainPhoto"),UIImage(named: "guaroians"),UIImage(named: "avatarPoster")]
    var currentIndex = 0
    var timer: Timer?
    var blurView: BlurEffectView? // Declare blurView as optional
    //here you can name your protocol and the function whatever you want and set the values you want to pass back, in our case a boolean
    protocol esconderBlurProtocol {
        func isEsconder(value: Bool)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = .black
        movieCollectionView.layer.cornerRadius = 10
        movieCollectionView.layer.borderWidth = 1
        movieCollectionView.register(UINib(nibName: "onboardingViewControllerCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "onboardingViewControllerCellCollectionViewCell")
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        pageControllerForMovieCollectionView.numberOfPages = imageArray.count
        startTimer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name("languageChanged"), object: nil)
        let currentLanguage = UserDefaults.standard.string(forKey: "language") ?? NSLocale.preferredLanguages.first ?? "en"
        updateLanguage(language: currentLanguage)
//        let language = UserDefaults.standard.string(forKey: "language") ?? "en"
        
        NetworkMonitor.shared.startMonitoring() // Start monitoring network status
        UIView.animate(withDuration: 0.3) {
            self.blurView?.alpha = 0 // Fade out blur on disappear
            NetworkMonitor.shared.stopMonitoring()
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissTranslationVC))
        tapGestureRecognizer.cancelsTouchesInView = false // Allow taps to propagate to underlying buttons
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func dismissTranslationVC() {
      dismiss(animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3) {
            self.blurView?.alpha = 0 // Fade out blur on disappear
            NetworkMonitor.shared.stopMonitoring()
        }
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let loginViewController = loginViewController()
        loginViewController.onLoginSuccess = {
            let tabBarController = myTabBarController()
            self.navigationController?.popViewController(animated: true)

            guard let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene else { return }
            scene.windows.first?.rootViewController = tabBarController
        }
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        let VC = registerViewController()
        navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func translateButton(_ sender: Any) {
        // Check if a blur view already exists
        if let existingBlurView = blurView {
            // Remove the existing blur view
            existingBlurView.removeFromSuperview()
            blurView = nil // Clear the reference
        }

        // Create and add a new blur view
        blurView = BlurEffectView(frame: view.bounds)
        view.addSubview(blurView!)
        blurView?.alpha = 0 // Start with 0 alpha and gradually increase
        UIView.animate(withDuration: 0.3) {
            self.blurView?.alpha = 0.5 // Set the desired blur intensity
        }

        // Present the translationViewController
        let VC = translationViewController()
        VC.modalTransitionStyle = .crossDissolve

        if let sheet = VC.sheetPresentationController {
            sheet.detents = [.custom { context in
                return 350
            }]
            sheet.prefersGrabberVisible = true
        }

        present(VC, animated: true, completion: nil)

        // Add dismissal observer
        NotificationCenter.default.addObserver(self, selector: #selector(removeBlurAndDismiss(_:)), name: .translationViewControllerDismissed, object: nil)
    }
    
    @objc func removeBlurAndDismiss(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.blurView?.alpha = 0 // Fade out the blur
        } completion: { _ in
            self.blurView?.removeFromSuperview() // Remove the blur view immediately after animation
            self.blurView = nil // Clear the blurView reference
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func removeBlurView() {
        if let blurView = blurView {
            blurView.removeFromSuperview()
            self.blurView = nil // Clear reference
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onboardingViewControllerCellCollectionViewCell", for: indexPath)as! onboardingViewControllerCellCollectionViewCell
        let image = imageArray[indexPath.row]
        cell.imageCollectionViewCell.image = image
        cell.imageCollectionViewCell.contentMode = .scaleAspectFill

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(updateImage), userInfo: nil, repeats: true)
    }
    
    @objc func updateImage() {
        if currentIndex < imageArray.count - 1 {
            currentIndex += 1
        }else{
            currentIndex = 0
        }
            movieCollectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated:true)
        pageControllerForMovieCollectionView.currentPage = currentIndex
        }
    
    @objc func languageChanged(_ notification: Notification) {
        if let language = notification.userInfo?["language"] as? String {
            updateLanguage(language: language)
        }
    }

    func updateLanguage(language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            print("Error: Could not find language resource for \(language)")
            return
        }
        let bundle = Bundle(path: path)!
        welcomeBackLabel.text = NSLocalizedString("Welcome Back", bundle: bundle, comment: "")
        enjoyLabel.text = NSLocalizedString("Enjoy your favorite movies", bundle: bundle, comment: "")
        translateButton.setTitle(NSLocalizedString("Arabic_button", bundle: bundle, comment: ""), for: .normal)
        registerLabelButton.setTitle(NSLocalizedString("Register", bundle: bundle, comment: ""), for: .normal)
        loginLabelButton.setTitle(NSLocalizedString("Login", bundle: bundle, comment: ""), for: .normal)
        bySignLabel.text = NSLocalizedString("By sign in or sign up, you agree to our Terms of Service and Privacy Policy",bundle: bundle, comment: "")
    }
}
 

