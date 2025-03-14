//
//  onboardingViewControllerCellCollectionViewCell.swift
//  Finial Task
//
//  Created by Sara Syam on 22/11/2024.
//

import UIKit

class onboardingViewControllerCellCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageCollectionViewCell: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()

        imageCollectionViewCell.layer.cornerRadius = 10
        imageCollectionViewCell.layer.borderWidth = 1
    }

}
