//
//  movieDetailsViewController.swift
//  Finial Task last
//
//  Created by Sara Syam on 20/12/2024.
//

import UIKit
import Cosmos
import Kingfisher
import Alamofire
import AlamofireEasyLogger
import CoreData
import NVActivityIndicatorView

class moviesDetailsViewController: UIViewController {
    
    private var customView: UIView!
    
    var movieId: Int?
    var movieDetailsArray : [MovieDetailsResponse] = []
    var movieDetails: MovieDetailsResponse?
    var genres: [Genre]? = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let network: NetworkManagerProtocol = NetworkManager(bearerToken: "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ODAwMWExMWVjODhjMmZiNzg1ZDlkYTU2MWI1YmE3MyIsIm5iZiI6MTczMzEzOTkzMi4wMzIsInN1YiI6IjY3NGQ5ZGRjZDU3NzQ3ZjIxMTU3OTZjZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.nxd-VfhwhyG0y7HVcAME3v35InTb1zdPfB48JVvmMeU")
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "No Movie Data Found"
        label.textColor = .gray
        label.textAlignment = .center
        label.isHidden = true // Initially hidden
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 5.0 // Adjust opacity as needed
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    private lazy var ratingView: CosmosView = {
        let view = CosmosView()
        view.settings.updateOnTouch = true
        view.settings.fillMode = .half
        view.settings.starSize = 20
        view.settings.starMargin = 5
        view.settings.filledColor = UIColor(named: "mainColor") ?? .yellow
        view.settings.emptyBorderColor = .gray
        //        view.settings.filledBorderColor = .gray
        view.settings.totalStars = 5 // Set the total number of stars
        
        // Add a background image for the empty stars
        let emptyStarsImage = UIImage(named: "empty_stars_background") // Replace with your asset name
        view.settings.emptyImage = emptyStarsImage?.resizableImage(withCapInsets: .zero, resizingMode: .tile)
        
        return view
    }()
    private lazy var bundle: Bundle = {
        let bundle = Bundle(for: Self.self) // Get the bundle for this class
        return bundle
    }()
    
    @IBOutlet weak var indicator: NVActivityIndicatorView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var movieDetailsImage: UIImageView!
    @IBOutlet weak var movieDetailsTitle: UILabel!
    @IBOutlet weak var movieDetailsDate: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var movieDetailsReview: CosmosView!
    @IBOutlet weak var movieDetailsLanguage: UILabel!
    @IBOutlet weak var movieDetailsMediaType: UILabel!
    @IBOutlet weak var movieDetailsCensour: UILabel!
    @IBOutlet weak var movieDetailsDescriptions: UILabel!
    @IBOutlet weak var movieDetailsView: UIView!
    @IBOutlet weak var languageTranslate: UILabel!
    @IBOutlet weak var mediaTypeTranslate: UILabel!
    @IBOutlet weak var censorshipTranslate: UILabel!
    @IBOutlet weak var storylineTranslate: UILabel!
    @IBOutlet weak var genersTranslate: UILabel!
    @IBOutlet weak var genersCollectionView: UICollectionView!
    @IBOutlet weak var seeMoreTranslate: UIButton!
    @IBOutlet weak var bookTicketTranslate: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .black
        navigationController?.isNavigationBarHidden = true
        
        movieDetailsView.layer.cornerRadius = 16
        genersCollectionView.delegate = self
        genersCollectionView.dataSource = self
        genersCollectionView.register(UINib(nibName: "genersCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "genersCollectionViewCell")
        
        if let movieId = movieId {
            fetchMovieDetails(movieId: movieId)
        } else {
            // Handle the case where movieId is not set
            print("Error: movieId is not set")
        }
        // Add errorView to the view hierarchy
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add noDataLabel to the errorView
        errorView.addSubview(noDataLabel)
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor)
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name("languageChanged"), object: nil)
        let currentLanguage = UserDefaults.standard.string(forKey: "language") ?? NSLocale.preferredLanguages.first ?? "en"
        updateLanguage(language: currentLanguage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true // Hide the tab bar when this view appears
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false // Show the tab bar when this view disappears
        navigationController?.isNavigationBarHidden = true
    }
    
    func fetchMovieDetails(movieId: Int) {
        indicator.startAnimating()
        network.request(RemoteRequests.productDetails(movieId), response: MovieDetailsResponse.self) { result in
            switch result {
            case .success(let movieDetails):
                self.indicator.stopAnimating()
                DispatchQueue.main.async {
                    self.movieDetails = movieDetails // Store the received movie details
                    self.genres = movieDetails.genres ?? []  // Set an empty array if no genres found;''
                    self.genersCollectionView.reloadData()
                    self.movieDetailsImage.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500\(movieDetails.posterPath ?? "")")) // Assuming posterPath is a URL string
                    self.movieDetailsTitle.text = movieDetails.originalTitle
                    self.movieDetailsDate.text = movieDetails.releaseDate
                    if let voteAverage = movieDetails.voteAverage {
                        self.reviewLabel.text =  String(format: "%.1f", voteAverage) + " (\(movieDetails.voteCount ?? 0))"
                    } else {
                        self.reviewLabel.text = "N/A"
                    }
                    if let spokenLanguage = movieDetails.spokenLanguages?.first {
                        self.movieDetailsLanguage.text = spokenLanguage.englishName
                    } else {
                        self.movieDetailsLanguage.text = "N/A" // Set a default value
                    }
                    self.movieDetailsLanguage.text = movieDetails.originalLanguage
                    self.movieDetailsDescriptions.numberOfLines = 3 // Set initial lines to show
                    self.movieDetailsDescriptions.sizeToFit() // Adjust height based on content
                    let voteCount = movieDetails.voteCount
                    self.updateMovieDetailsUI(voteCount: voteCount ?? 0)
                }
            case .failure(let error):
                if case let .afError(afError) = error {
                    if afError.responseCode == 404 {
                        
                        // Handle 404 Not Found specifically
                        DispatchQueue.main.async {
                            self.handle404Error()
                        }
                        
                    } else {
                        // Handle other AFError cases (e.g., network issues)
                        print("AFError: \(afError)")
                        
                        // Handle 404 Not Found specifically
                        DispatchQueue.main.async {
                            self.handle404Error()
                        }
                    }
                } else {
                    // Handle other types of errors (e.g., decoding errors)
                    print("Error fetching movie details: \(error)")
                    
                    // Handle 404 Not Found specifically
                    DispatchQueue.main.async {
                        self.handle404Error()
                    }
                    
                }
            }
        }
    }
    
    @objc private func handle404Error() {
        DispatchQueue.main.async {
            self.errorView.isHidden = false
            self.noDataLabel.isHidden = false
            
            // Optionally animate the appearance of the label
            UIView.animate(withDuration: 5.0) {
                self.noDataLabel.alpha = 1.0
            }
        }
    }
    
    @objc private func handleTap() {
        // Navigate back to the previous view controller
        navigationController?.popViewController(animated: true)
    }
    
    private func updateMovieDetailsUI( voteCount: Int) {
        if let movieDetails = self.movieDetails {
            self.movieDetailsImage.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500\(movieDetails.posterPath ?? "")"))
            self.movieDetailsTitle.text = movieDetails.originalTitle
            self.movieDetailsDate.text = movieDetails.releaseDate
            if let voteAverage = movieDetails.voteAverage {
                self.reviewLabel.text =  String(format: "%.1f", voteAverage) + " (\(movieDetails.voteCount ?? 0))"
            } else {
                self.reviewLabel.text = "N/A"
            }
            if let spokenLanguage = movieDetails.spokenLanguages?.first {
                self.movieDetailsLanguage.text = spokenLanguage.englishName
            } else {
                self.movieDetailsLanguage.text = "N/A"
            }
            self.movieDetailsDescriptions.text = movieDetails.overview
            self.movieDetailsDescriptions.numberOfLines = 3
            self.movieDetailsDescriptions.sizeToFit()
        }else{
            movieDetailsImage.image = UIImage(named: "noDataImage") // Replace with a placeholder image
            movieDetailsTitle.text = "Movie details not available"
            movieDetailsReview.rating = 0
            movieDetailsDescriptions.text = ""
            // Hide other UI elements that rely on movie details (e.g., language, genres)
            movieDetailsLanguage.isHidden = true
            genersCollectionView.isHidden = true
            seeMoreTranslate.isHidden = true
            bookTicketTranslate.isHidden = true
        }
    }
    
    private func saveMovieToCoreData(movieDetails: MovieDetailsResponse) {
        let ticket = Ticket(context: context)
        ticket.title = movieDetails.originalTitle
        ticket.posterPath = movieDetails.posterPath
        ticket.releaseDate = movieDetails.releaseDate
        ticket.timeStamp = Date()
        
        do {
            try context.save()
            print("Movie saved to Core Data successfully!")
            showAlert(
                title: localize("success"),
                message: localize("movie added")
            )
        } catch {
            print("Failed to save ticket: \(error)")
            showAlert(
                title: localize("error"),
                message: localize("failed to add")
            )
        }
    }
    // Function to get localized strings
    func localize(_ key: String) -> String {
        return NSLocalizedString(key, tableName: nil, bundle: bundle, comment: "") // Use the class's bundle
    }
    
    private func showErrorMessage(_ message: String) {
        // Create and present an alert to display the error message
        let alert = UIAlertController(
            title: localize("error"),
            message: localize("error message"),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString(title, tableName: nil, bundle: bundle, comment: ""),
            message: NSLocalizedString(message, tableName: nil, bundle: bundle, comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("ok", tableName: nil, bundle: bundle, comment: ""),
            style: .default
        ))
        present(alert, animated: true)
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
        // Update all labels with localized text
        mediaTypeTranslate.text = NSLocalizedString("media type", bundle: bundle , comment: "")
        censorshipTranslate.text = NSLocalizedString("censorship", bundle: bundle , comment: "")
        languageTranslate.text = NSLocalizedString("language", bundle: bundle , comment: "")
        storylineTranslate.text = NSLocalizedString("storyline", bundle: bundle , comment: "")
        genersTranslate.text = NSLocalizedString("genres", bundle: bundle , comment: "")
        bookTicketTranslate.setTitle(NSLocalizedString("Book Ticket", bundle: bundle ,comment: ""), for: .normal)
        
    }
    
    @IBAction func navButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bookTicketTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: localize("Book Ticket"),
            message: localize("Are you sure you want to add \(movieDetails?.title ?? "Movie") to your ticket?"),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: localize("Yes"), style: .default) { _ in
            guard let movieDetails = self.movieDetails else { return }
            
            // Check for existing movie with the same title
            let fetchRequest: NSFetchRequest<Ticket> = Ticket.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Ticket.title), movieDetails.originalTitle ?? "")
            
            do {
                let existingTickets = try self.context.fetch(fetchRequest)
                if existingTickets.isEmpty {
                    // No existing movie found, proceed with saving
                    self.saveMovieToCoreData(movieDetails: movieDetails)
                } else {
                    // Movie already exists, display message
                    print("Movie already added to tickets!")
                    self.showAlert(
                        title: self.localize("warning"),
                        message: self.localize("movie already added"))
                }
            } catch {
                print("Error checking for existing movie: \(error)")
            }
        })
        
        alert.addAction(UIAlertAction(title: localize("Cancel"), style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func seeMoreTapped(_ sender: Any) {
        if movieDetailsDescriptions.numberOfLines == 0 {
            movieDetailsDescriptions.numberOfLines = 3
            (sender as AnyObject).setTitle(localize("see More"), for: .normal) // Update button title
        } else {
            movieDetailsDescriptions.numberOfLines = 0
            (sender as AnyObject).setTitle(localize("see Less"), for: .normal)
        }
    }
}
extension moviesDetailsViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genersCollectionViewCell", for: indexPath) as? genersCollectionViewCell
        cell?.genersLabel.text = genres?[indexPath.row].name
        cell?.layer.cornerRadius = 16
        
        return cell ?? UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate dynamic size based on genre name (optional)
        let label = UILabel()
        label.text = genres?[indexPath.row].name
        label.sizeToFit()
        let width = label.frame.width + 16 // Add some padding
        return CGSize(width: width, height: 50)
    }
}
