//
//  searchCollectionViewCell.swift
//  FinialTask
//
//  Created by Sara Syam on 27/12/2024.
//

import UIKit

class searchCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var searchImage: UIImageView!
    
    @IBOutlet weak var searchTitle: UILabel!
    
    @IBOutlet weak var searchMediaType: UILabel!
    @IBOutlet weak var searchDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        searchImage.layer.cornerRadius = 16
        // Initialization code
    }

}
