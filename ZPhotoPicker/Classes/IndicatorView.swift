//
//  IndicatorView.swift
//
//  Created by Zack･Zheng on 2017/9/11.
//

import UIKit

class IndicatorView: UIView {
    
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tipsLabel: UILabel!
    
    override func awakeFromNib() {

        super.awakeFromNib()
        centerView.clipsToBounds = true
        centerView.layer.cornerRadius = 5
        tipsLabel.text = "uploadingPhotos".locale
    }
}
