//
//  BBOpenBoxPayPopCell.swift
//  bb_planet_ios
//
//  Created by Jack-iOS on 2024/8/17.
//

import UIKit

class BBOpenBoxPayPopCell: UICollectionViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var desL: UILabel!
    @IBOutlet weak var priceL: UILabel!

    @IBOutlet weak var iconV: UIImageView!
    var model: OpenBoxPayModel? {
        didSet {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if model?.isSelect == true {
            contentView.wp.addNormalJb(["#5E30E1".wp.color,"#CC28D8".wp.color])
        }else {
            contentView.js_RemoveGradientLayer()
        }
        
    }

}
