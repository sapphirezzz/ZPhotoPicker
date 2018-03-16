//
//  IndicatorView.swift
//  ZPhotoPicker
//
//  Created by Zack･Zheng on 2018/3/16.
//

import UIKit

class IndicatorView: UIView {
    
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {

        super.awakeFromNib()
        centerView.clipsToBounds = true
        centerView.layer.cornerRadius = 5
    }
}
