//
//  PhotoPickerImageCountView.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/2/1.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit

class PhotoPickerImageCountView: UICollectionReusableView {
    
    let label: UILabel = {
        
        let view = UILabel()
        view.textAlignment = NSTextAlignment.center
        view.backgroundColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 15)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    static var reuseIdentifier = "PhotoPickerImageCountView"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    fileprivate func setup() {
        addSubview(label)
    }
    
    var count: Int = 0 {
        didSet {
            label.text = "\(count) 张照片"
        }
    }
}
