//
//  movieCollectionViewCell.swift
//  Finial Task
//
//  Created by Sara Syam on 02/12/2024.
//

import UIKit

class movieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var moviePhoto: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieType: UILabel!
    @IBOutlet weak var movieDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moviePhoto.layer.cornerRadius = 16
    }

}
