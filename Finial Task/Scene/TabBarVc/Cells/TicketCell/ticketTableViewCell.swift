//
//  ticketTableViewCell.swift
//  Finial Task
//
//  Created by Sara Syam on 18/12/2024.
//

import UIKit
import Kingfisher
import AlamofireEasyLogger

class ticketTableViewCell: UITableViewCell {
    var onDelete: (() -> Void)? // Closure to notify the delegate about deletion
    
    @IBOutlet weak var ticketView: UIView!
    @IBOutlet weak var ticketImage: UIImageView!
    @IBOutlet weak var ticketTitle: UILabel!
    @IBOutlet weak var ticketDate: UILabel!
    @IBOutlet weak var ticketMediaType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 16
        ticketView.layer.cornerRadius = 16
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func configure(with ticket: MovieTicket) {
        ticketTitle.text = ticket.title
        ticketDate.text = ticket.releaseDate
        ticketMediaType.text = ticket.mediaType
        
        if let posterPath = ticket.posterPath, let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
            ticketImage.kf.setImage(with: url)
        } else {
            // Handle case where posterPath is nil
            ticketImage.image = UIImage(systemName: "noDataImage") // Or a placeholder image
        }
    }
}
extension ticketTableViewCell {
    func configure(with ticket: Ticket) {
        self.ticketTitle.text = ticket.title
        self.ticketDate.text = ticket.releaseDate
        if let posterPath = ticket.posterPath, let url = URL(string: posterPath) {
            self.ticketImage.kf.setImage(with: url)
        } else {
            self.ticketImage.image = UIImage(named: "noDataImage") // Fallback image
        }
    }
}
