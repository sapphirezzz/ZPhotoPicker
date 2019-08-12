//
//  PhotoPickerImageCountView.swift
//
//  Created by Zack･Zheng on 2018/2/1.
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
