//
//  movieViewController.swift
//  Finial Task
//
//  Created by Sara Syam on 24/11/2024.
//

import UIKit
import Kingfisher
import NVActivityIndicatorView
import CoreData

class movieViewController: UIViewController {
    
    private let context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Could not get app delegate") // Add a print statement for debugging
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    private var nowPlayingMovies: [Movie] = []
    private var comingSoonMovies: [Movie] = []
    let network: NetworkManagerProtocol = NetworkManager(bearerToken: "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ODAwMWExMWVjODhjMmZiNzg1ZDlkYTU2MWI1YmE3MyIsIm5iZiI6MTczMzEzOTkzMi4wMzIsInN1YiI6IjY3NGQ5ZGRjZDU3NzQ3ZjIxMTU3OTZjZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.nxd-VfhwhyG0y7HVcAME3v35InTb1zdPfB48JVvmMeU")
    
    @IBOutlet weak var movieSegmantedControl: UISegmentedControl!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var indicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.type = .ballSpinFadeLoader
        indicator.color = .white
        
        setupCollectionView()
        setupSegmentedControl()
        fetchNowPlayingMovies()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLanguageChange), name: Notification.Name("LanguageChanged"), object: nil)
        updateUIForLanguage()
    }
    
    private func loadSegmentedControlTitles() -> [String] {
      let language = (UserDefaults.standard.string(forKey: "language") ?? Locale.current.language.languageCode?.identifier) ?? ""
      let localizedDescriptions = loadLocalizedDescriptions(forLanguage: language)
      return localizedDescriptions
    }
    
    @objc func handleLanguageChange(_ notification: Notification) {
      updateUIForLanguage()
    }
    
    func updateUIForLanguage() {
      // Update labels, buttons, and other UI elements using localized strings from LocalizationManager
        
      title = LocalizationManager.shared.localizedString("Movie") // Example
        let localizedDescriptions = loadSegmentedControlTitles()
        movieSegmantedControl.setTitle(localizedDescriptions[0], forSegmentAt: 0)
        movieSegmantedControl.setTitle(localizedDescriptions[1], forSegmentAt: 1)
        
        // Reload the collection view to update cell titles
        movieCollectionView.reloadData()
    }
    
    @objc func languageDidChange() {
        refreshData() // Call refreshData to reload UI with localized strings
    }
    
    private func loadLocalizedDescriptions(forLanguage language: String) -> [String] {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            print("Error: Could not find language resource for \(language)")
            return loadLocalizedDescriptions(forLanguage: "en") // Fallback to English
        }
        let bundle = Bundle(path: path)!
        return [
            NSLocalizedString("nowPlaying", bundle: bundle, comment: ""),
            NSLocalizedString("comingSoon", bundle: bundle, comment: ""),
        ]
    }
    
    private func setupCollectionView() {
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        movieCollectionView.register(UINib(nibName: "nowPlayingCollectionViewCell", bundle: Bundle.main),
                                     forCellWithReuseIdentifier: "nowPlayingCollectionViewCell")
        movieCollectionView.register(UINib(nibName: "upComingCollectionViewCell", bundle: Bundle.main),
                                     forCellWithReuseIdentifier: "upComingCollectionViewCell")
    }
    
    private func setupSegmentedControl() {
        let localizedDescriptions = loadSegmentedControlTitles()

        movieSegmantedControl.setTitle(localizedDescriptions[0], forSegmentAt: 0)
        movieSegmantedControl.setTitle(localizedDescriptions[1], forSegmentAt: 1)
        movieSegmantedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    func updateLanguage(language: String) {
        // ... (your existing code) ...

        let localizedDescriptions = loadLocalizedDescriptions(forLanguage: language)
        movieSegmantedControl.setTitle(localizedDescriptions[0], forSegmentAt: 0)
        movieSegmantedControl.setTitle(localizedDescriptions[1], forSegmentAt: 1)

        // ... (rest of your updateLanguage code) ...
    }
    
    @objc private func segmentedControlValueChanged() {
        switch movieSegmantedControl.selectedSegmentIndex {
        case 0:
            fetchNowPlayingMovies()
        case 1:
            fetchComingSoonMovies()
        default:
            break
        }
    }
    
    @objc private func refreshData() {
        // Fetch data based on current segment
        if movieSegmantedControl.selectedSegmentIndex == 0 {
            fetchNowPlayingMovies()
        } else {
            fetchComingSoonMovies()
        }
    }
    
    private func fetchNowPlayingMovies() {
        indicator.startAnimating()
        network.request(RemoteRequests.getNowPlaying, response: MovieResponse.self) { result in
            switch result {
            case.success(let data):
                self.indicator.stopAnimating()
                self.nowPlayingMovies = data.results
                self.movieCollectionView.reloadData()
            case.failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    
    private func fetchComingSoonMovies() {
        indicator.startAnimating()
        network.request(RemoteRequests.getComingSoon, response: MovieResponse.self) { result in
            switch result {
            case.success(let data):
                self.indicator.stopAnimating()
                self.comingSoonMovies = data.results
                self.movieCollectionView.reloadData()
            case.failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("ok", comment: ""),
            style: .default
        ))
        present(alert, animated: true)
    }
    
    func updateLanguage(to language: String) {
        LocalizationManager.shared.setLanguage(language)
        // Update other UI elements based on language
        if language == "ar" {
            // Example: Adjust layout for RTL
            movieCollectionView.semanticContentAttribute = .forceRightToLeft
        } else {
            // Reset for LTR (if applicable)
            movieCollectionView.semanticContentAttribute = .forceLeftToRight
        }
        movieCollectionView.reloadData()
        updateUIForLanguage() // Call updateUIForLanguage() to reload data and update titles
        refreshData() // Call refreshData to reload UI with localized strings
    }
}

// MARK: - UICollectionViewDataSource
extension movieViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieSegmantedControl.selectedSegmentIndex == 0 ? nowPlayingMovies.count : comingSoonMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if movieSegmantedControl.selectedSegmentIndex == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nowPlayingCollectionViewCell", for: indexPath) as! nowPlayingCollectionViewCell
            
            let movie = nowPlayingMovies[indexPath.item]
            cell.nowPlayingTitle.text = movie.displayTitle
            cell.noePlayingReview.text = String(movie.voteAverage) + " " + "(\(movie.displayPopularity ?? ""))"
            cell.nowPlayingDuration.text = movie.releaseDate
            cell.nowPlayingMediaType.text = movie.displayMediaType
            
            if let posterURL = movie.posterURL {
                cell.nowPlayingImage.kf.setImage(with: posterURL)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upComingCollectionViewCell", for: indexPath) as! upComingCollectionViewCell
            
            let movie = comingSoonMovies[indexPath.item]
            cell.upComingTitle.text = movie.displayTitle
            cell.upComingDate.text = movie.displayDate
            cell.upComingMediaType.text = movie.displayMediaType
            
            if let posterURL = movie.posterURL {
                cell.upComingImage.kf.setImage(with: posterURL)
            }
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension movieViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(collectionView.frame.width - 20) / 2
        let height = CGFloat(400)
        return CGSize(width: width, height:height)
    }
}

// MARK: - UICollectionViewDelegate
extension movieViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie: Movie // Declare a variable to hold the selected movie
        
        if movieSegmantedControl.selectedSegmentIndex == 0 {
            selectedMovie = nowPlayingMovies[indexPath.item]
        } else {
            selectedMovie = comingSoonMovies[indexPath.item]
        }
        
        let movieDetailsVC = moviesDetailsViewController()
        movieDetailsVC.movieId = selectedMovie.id // Access the movie ID from the selectedMovie object
        
        movieDetailsVC.modalPresentationStyle = .fullScreen
        self.tabBarController?.tabBar.isHidden = true
        
        navigationController?.pushViewController(movieDetailsVC, animated: true)
    }
}
