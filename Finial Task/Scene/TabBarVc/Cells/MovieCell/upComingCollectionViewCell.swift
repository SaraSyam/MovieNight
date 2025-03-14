//
//  upComingCollectionViewCell.swift
//  Finial Task last 
//
//  Created by Sara Syam on 20/12/2024.
//

import UIKit

class upComingCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var upComingImage: UIImageView!
    @IBOutlet weak var upComingTitle: UILabel!
    @IBOutlet weak var upComingDate: UILabel!
    @IBOutlet weak var upComingMediaType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        upComingImage.layer.cornerRadius = 16
    }

}
