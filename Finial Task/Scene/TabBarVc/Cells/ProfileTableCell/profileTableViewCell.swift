//
//  profileTableViewCell.swift
//  FinialTask
//
//  Created by Sara Syam on 23/12/2024.
//

import UIKit

class profileTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ProfileIcon: UIImageView!
    
    @IBOutlet weak var profileCellLabel: UILabel!
    
    @IBOutlet weak var profileCellNavimg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.semanticContentAttribute = .forceLeftToRight
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(with icon: UIImage, labelText: String) {
        ProfileIcon.image = icon
        profileCellLabel.text = labelText

        // Update contentView direction based on current language
        if let language = UserDefaults.standard.string(forKey: "language"), language == "ar" {
            contentView.semanticContentAttribute = .forceRightToLeft
        } else {
            contentView.semanticContentAttribute = .forceLeftToRight
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset semanticContentAttribute to default
        contentView.semanticContentAttribute = .forceLeftToRight
    }
    
}
