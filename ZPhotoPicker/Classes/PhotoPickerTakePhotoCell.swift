//
//  PhotoPickerTakePhotoCell.swift
//  ZPhotoPicker
//
//  Created by mooyoo on 2020/6/16.
//

import UIKit

class PhotoPickerTakePhotoCell: UICollectionViewCell {
    
    class func size(inCollectionView view: UICollectionView, itemSpacing: CGFloat) -> CGSize {

        let countPerLine = 4
        let totalSpacing = itemSpacing * CGFloat(countPerLine - 1)
        let side = (view.bounds.width - totalSpacing) / CGFloat(countPerLine)
        let size = CGSize(width: side, height: side)
        return size
    }

    override func draw(_ rect: CGRect) {

        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor(white: 1.0, alpha: 1.0).cgColor)
        context?.fill(rect)
        
        let image: UIImage = UIImage(named: "take_photo", in: Bundle(for: ZPhotoPicker.self), compatibleWith: nil)!
        image.draw(at: CGPoint(x: (rect.width - image.size.width) / 2, y: (rect.height - image.size.height) / 2))
    }
}
