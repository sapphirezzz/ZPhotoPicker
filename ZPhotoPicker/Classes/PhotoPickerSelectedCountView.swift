//
//  PhotoPickerSelectedCountView.swift
//
//  Created by Zack･Zheng on 2018/2/1.
//

import UIKit

protocol PhotoPickerSelectedCountViewDelegate: class {
    func photoPickerSelectedCountViewDidCompletePicking()
}

class PhotoPickerSelectedCountView: UIView {

    let label: UILabel = {

        let view = UILabel()
        view.textAlignment = NSTextAlignment.center
        view.backgroundColor = .clear
        view.font = UIFont.systemFont(ofSize: 15)
        return view
    }()
    let button: UIButton = {

        let view = UIButton(type: .custom)
        view.backgroundColor = .clear
        view.setTitle("完成", for: .normal)
        view.setTitleColor(ZPhotoPicker.themeColor, for: .normal)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: 50)
        button.frame = CGRect(x: bounds.size.width - 65, y: 0, width: 65, height: 50)
    }

    fileprivate func setup() {

        addSubview(label)
        addSubview(button)
        button.addTarget(self, action: #selector(PhotoPickerSelectedCountView.clickCompleteButton), for: .touchUpInside)
        backgroundColor = UIColor(red: 248.0 / 255, green: 248.0 / 255, blue: 248.0 / 255, alpha: 1.0)
    }

    weak var delegate: PhotoPickerSelectedCountViewDelegate?

    var maxCount: Int = 0 {
        didSet {
            label.text = "\(selectedCount)/\(maxCount)"
        }
    }

    var selectedCount: Int = 0 {
        didSet {
            label.text = "\(selectedCount)/\(maxCount)"
        }
    }
    
    @objc private func clickCompleteButton() {
        delegate?.photoPickerSelectedCountViewDidCompletePicking()
    }
}
