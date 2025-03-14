//
//  nowPlayingCollectionViewCell.swift
//  Finial Task last 
//
//  Created by Sara Syam on 20/12/2024.
//

import UIKit

class nowPlayingCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var nowPlayingImage: UIImageView!
    @IBOutlet weak var nowPlayingTitle: UILabel!
    @IBOutlet weak var noePlayingReview: UILabel!
    @IBOutlet weak var nowPlayingDuration: UILabel!
    @IBOutlet weak var nowPlayingMediaType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nowPlayingImage.layer.cornerRadius = 16
    }

}
