//
//  searchViewController.swift
//  FinialTask
//
//  Created by Sara Syam on 27/12/2024.
//

import UIKit
import CoreData
import Kingfisher
import AlamofireEasyLogger
import NVActivityIndicatorView

class searchViewController: UIViewController {

    var movieID: Int?
    var searchArray: [datum] = []

    private lazy var context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Could not get app delegate")
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
    let network: NetworkManagerProtocol = NetworkManager(bearerToken: "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ODAwMWExMWVjODhjMmZiNzg1ZDlkYTU2MWI1YmE3MyIsIm5iZiI6MTczMzEzOTkzMi4wMzIsInN1YiI6IjY3NGQ5ZGRjZDU3NzQ3ZjIxMTU3OTZjZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.nxd-VfhwhyG0y7HVcAME3v35InTb1zdPfB48JVvmMeU")
    
    @IBOutlet weak var indicator: NVActivityIndicatorView!
    @IBOutlet weak var movieSearch: UISearchBar!
    @IBOutlet weak var searchTitleLabel: UILabel!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        movieSearch.delegate = self // Set search bar delegate
        self.navigationController?.navigationBar.isHidden = true
    }
    func setupCollectionView(){
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.register(UINib(nibName: "searchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "searchCollectionViewCell")
    }
    func fetchSearchResults() {
      guard let searchValue = movieSearch.text, !searchValue.isEmpty else {
        print("Empty search query")
        return
      }
      indicator.startAnimating()  // Start activity indicator
        network.request(RemoteRequests.search( searchValue), response: searchResponse.self) {
        result in
        self.indicator.stopAnimating()  // Stop activity indicator
        switch result {
        case .success(let data):
          self.searchArray = data.results ?? []
          self.searchCollectionView.reloadData()
        case .failure(let error):
          print(error.localizedDescription)
          // Handle error (e.g., show an alert to the user)
        }
      }
    }


    @IBAction func navigationButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension searchViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        searchArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCollectionViewCell", for: indexPath)as!searchCollectionViewCell
        let search = searchArray[indexPath.row]
        cell.searchTitle.text = search.title
        cell.searchDate.text = search.releaseDate
        cell.searchImage.kf.setImage(with: search.photoURL)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt
                        indexPath: IndexPath) -> CGSize {
        let width = CGFloat(collectionView.frame.width - 20) / 2
        let height = CGFloat(342)
        return CGSize(width: width, height:height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = searchArray[indexPath.row]
        let movieDetailsVC = moviesDetailsViewController()
        movieDetailsVC.movieId = selectedMovie.id
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(movieDetailsVC, animated: true)
    }
  }
extension searchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    fetchSearchResults()
  }
}
