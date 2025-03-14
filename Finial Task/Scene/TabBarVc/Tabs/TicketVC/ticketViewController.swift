//
//  ticketViewController.swift
//  Finial Task
//
//  Created by Sara Syam on 24/11/2024.
//

import UIKit
import CoreData
import Kingfisher
import Localize_Swift

class ticketViewController: UIViewController {
    
    //    var selectedMovie: MovieDetailsResponse?
    var bookedTickets: [Ticket] = []  // Array to hold the booked tickets
    private lazy var context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Could not get app delegate")
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    @IBOutlet weak var ticketViewControllerTitle: UILabel!
    @IBOutlet weak var ticketTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        
        ticketViewControllerTitle.text = NSLocalizedString("my tickets", comment: "")
        ticketViewControllerTitle.text = LocalizationManager.shared.localizedString("my tickets")
        setupTableView()
        fetchBookedTickets()
        // Enable swipe to delete
        ticketTableView.allowsSelectionDuringEditing = true
        ticketTableView.isEditing = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)

        let currentLanguage = UserDefaults.standard.string(forKey: "language") ?? Locale.preferredLanguages.first ?? "en"
        updateLanguage(language: currentLanguage)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBookedTickets()
    }
    
    @objc func languageDidChange(_ notification: Notification) {
        if let language = notification.userInfo?["language"] as? String {
            updateLanguage(language: language)
            // Update UI elements with localized strings
            ticketViewControllerTitle.text = "My Tickets".localized()
            // ...
            ticketTableView.reloadData() // Reload table view to update cell content

        }
    }
    
    func updateLanguage(language: String) {
        Localize.setCurrentLanguage(language)
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            print("Error: Could not find language resource for \(language)")
            return
        }
        let bundle = Bundle(path: path)!
        ticketViewControllerTitle.text = NSLocalizedString("my tickets" , bundle: bundle, comment: "")
    }
    
    private func setupTableView() {
        ticketTableView.delegate = self
        ticketTableView.dataSource = self
        ticketTableView.register(UINib(nibName: "ticketTableViewCell", bundle: nil), forCellReuseIdentifier: "ticketTableViewCell")
    }
    private func fetchBookedTickets() {
        guard let context = context else {
            print("Core Data context is nil. Cannot fetch user name.")
            return // Very important to return here!
        }
        let fetchRequest: NSFetchRequest<Ticket> = Ticket.fetchRequest()
        
        do {
            bookedTickets = try context.fetch(fetchRequest)
            ticketTableView.reloadData()
        } catch {
            print("Failed to fetch user: \(error)")
            showAlert(title: "Error".localized(), message: "Failed to fetch tickets".localized())
        }
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "ok".localized(),
            style: .default
        )
        )
        present(alert, animated: true)
    }
    private func saveChangesToCoreData() {
        guard let context = context else { return }
        
        do {
            try context.save()
        } catch {
            print("Error saving changes to Core Data: \(error)")
            // Optionally handle the error, e.g., show an alert
        }
    }
    @objc func languageChanged(_ notification: Notification) {
        if let language = notification.userInfo?["language"] as? String {
            updateLanguage(language: language)
        }
    }
}


// MARK: - UICollectionViewDataSource
extension ticketViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookedTickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticketTableViewCell", for: indexPath)as! ticketTableViewCell
        
        cell.layer.cornerRadius = 16
        let ticket = bookedTickets[indexPath.row]
        cell.configure(with: ticket)
        cell.ticketTitle?.text = ticket.title
        cell.ticketDate?.text = ticket.releaseDate
        if let posterPath = ticket.posterPath {
            cell.ticketImage.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"))
            // Set the onDelete closure for the cell
            cell.onDelete = { [weak self] in
                guard let self = self else { return }
                
                // Remove ticket from data source
                self.bookedTickets.remove(at: indexPath.row)
                
                // Delete the row from the table view with animation
                self.ticketTableView.deleteRows(at: [indexPath], with: .fade)
                
                // Optionally, save changes to Core Data
                self.saveChangesToCoreData() // Implement this method to save changes
            }
        } else {
            // Handle missing poster path (e.g., set a placeholder image)
            cell.ticketImage.image = UIImage(named: "noDataImage") // Replace with your placeholder image logic
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if bookedTickets.isEmpty {
            let noTicketsView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
            noTicketsView.backgroundColor = UIColor.clear // Set background to clear for better visibility

            let label = UILabel(frame: noTicketsView.bounds)
            label.text = "No Tickets Added Yet".localized()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            label.textColor = UIColor.gray

            // Add a simple animation (optional)
            let animation = CABasicAnimation(keyPath: "position.x")
            animation.fromValue = noTicketsView.frame.width / 2 - 10
            animation.toValue = noTicketsView.frame.width / 2 + 10
            animation.duration = 1
            animation.autoreverses = true
            animation.repeatCount = Float.infinity
            label.layer.add(animation, forKey: "pulse")

            noTicketsView.addSubview(label)
            return noTicketsView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return bookedTickets.isEmpty ? 200 : 0 // Adjust height as needed
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             // Remove ticket from data source
             let ticketToDelete = bookedTickets[indexPath.row]
             bookedTickets.remove(at: indexPath.row)

             // Delete the row from the table view with animation
             tableView.deleteRows(at: [indexPath], with: .fade)

             // Delete ticket from Core Data
             context?.delete(ticketToDelete)
             do {
                 try context?.save()
             } catch {
                 print("Error deleting ticket from Core Data: \(error)")
                 // Handle error (e.g., display alert to the user)
             }
         }
     }
}

