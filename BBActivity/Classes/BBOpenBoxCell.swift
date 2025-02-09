//
//  BBOpenBoxCell.swift
//  bb_planet_ios
//
//  Created by jack on 2024/8/6.
//

import UIKit

open class BBOpenBoxCell: UICollectionViewCell {
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var priceL: UILabel!
    @IBOutlet weak var moneyIconV: UIImageView!
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }

}
