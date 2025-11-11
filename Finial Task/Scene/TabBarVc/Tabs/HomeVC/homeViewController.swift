//
//  homeViewController.swift
//  Finial Task
//
//  Created by Sara Syam on 24/11/2024.
//

import UIKit
import CoreData
import Kingfisher
import AlamofireEasyLogger
import NVActivityIndicatorView

class homeViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var movieID: Int?
    private var currentPage = 1
    var homeArray : [Movie] = []
    private lazy var context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Could not get app delegate")
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
    private let searchTapGesture = UITapGestureRecognizer()
    let network: NetworkManagerProtocol = NetworkManager(bearerToken: "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ODAwMWExMWVjODhjMmZiNzg1ZDlkYTU2MWI1YmE3MyIsIm5iZiI6MTczMzEzOTkzMi4wMzIsInN1YiI6IjY3NGQ5ZGRjZDU3NzQ3ZjIxMTU3OTZjZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.nxd-VfhwhyG0y7HVcAME3v35InTb1zdPfB48JVvmMeU")
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var welcomeMessageLabel: UILabel!
    @IBOutlet weak var SearchView: UIView!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var indicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        self.movieCollectionView.delegate = self
        self.movieCollectionView.dataSource = self
        getPosts()
        movieCollectionView.register(UINib(nibName: "movieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "movieCollectionViewCell")
        fetchUserName()
        // Add tap gesture to SearchView
        searchTapGesture.addTarget(self, action: #selector(handleSearchTap))
        SearchView.addGestureRecognizer(searchTapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name("languageChanged"), object: nil)
        let currentLanguage = UserDefaults.standard.string(forKey: "language") ?? NSLocale.preferredLanguages.first ?? "en"
        updateLanguage(language: currentLanguage)
        
        indicator.type = .ballSpinFadeLoader
        indicator.color = .white
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: Notification.Name("LanguageChanged"), object: nil)
        updateUIForLanguage()

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func languageDidChange(_ notification: Notification) {
        if let language = notification.userInfo?["language"] as? String {
            updateLanguage(language: language)
        }
    }
    
    @objc func handleLanguageChange(_ notification: Notification) {
      updateUIForLanguage()
    }
    
    func getPosts() {
        indicator.startAnimating()
        let endpoint = RemoteRequests.getPosts(page: currentPage) // Pass the current page
        network.request(endpoint, response: MovieResponse.self) {
            result in
            switch result {
            case .success(let data):
                self.indicator.stopAnimating()
                self.homeArray = data.results
                self.movieCollectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateUIForLanguage() {
      // Update labels, buttons, and other UI elements using localized strings from LocalizationManager
     // title = LocalizationManager.shared.localizedString("Home") // Example
      // ...
    }
    
    @objc func handleSearchTap() {
        // Navigate to searchViewController
        let searchVC = searchViewController() // Assuming you have a searchViewController class
        navigationController?.pushViewController(searchVC, animated: true)
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
        userLabel.text = NSLocalizedString("Hi" , bundle: bundle, comment: "")
        welcomeMessageLabel.text = NSLocalizedString("welcome label", bundle: bundle, comment: "")
        // Update layout direction if needed
        if language == "ar" { // Adjust for Arabic language
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
    }
}

extension homeViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionViewCell", for: indexPath) as! movieCollectionViewCell
        
        let movie = homeArray[indexPath.row]

        cell.movieTitle.text = movie.displayTitle
        cell.movieType.text = movie.mediaType
        cell.movieDate.text = movie.displayDate
        cell.moviePhoto.kf.setImage(with: movie.posterURL)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt
                        indexPath: IndexPath) -> CGSize {
        let width = CGFloat(collectionView.frame.width - 20) / 2
        let height = CGFloat(342)
        return CGSize(width: width, height:height)
    }
    private func fetchUserName() {
        guard let context = context else {
          print("Core Data context is nil. Cannot fetch user name.")
          return // Very important to return here!
        }
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        // Sort by the most recent entry
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        fetchRequest.fetchLimit = 1  // Get only the most recent user
        
        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                let userName = user.userName ?? ""
//                let greetingMessage = ), " \(userName) ")// Combine text with emoji
                let greeting = NSLocalizedString("Hi,", comment: "") + "\(userName)" + "👋"
                userLabel.text = greeting
                userNameLabel.text = "\(userName)" + "👋"
            } else {
                // Handle case where no user is found
                userLabel.text = "Welcome Back!" // Placeholder if no user exists
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = homeArray[indexPath.row]
        let movieDetailsVC = moviesDetailsViewController()
        movieDetailsVC.movieId = selectedMovie.id
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(movieDetailsVC, animated: true)
    }
  }
