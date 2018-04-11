//
//  PhotoPickerImageCell.swift
//  hhh
//
//  Created by Zack･Zheng on 2018/1/31.
//  Copyright © 2018年 Zack･Zheng. All rights reserved.
//

import UIKit

class PhotoPickerImageCell: UICollectionViewCell {
    
    class func size(inCollectionView view: UICollectionView, itemSpacing: CGFloat) -> CGSize {
        
        let countPerLine = 4
        let totalSpacing = itemSpacing * CGFloat(countPerLine - 1)
        let side = (view.bounds.width - totalSpacing) / CGFloat(countPerLine)
        let size = CGSize(width: side, height: side)
        return size
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        backgroundColor = UIColor.white
    }

    override func draw(_ rect: CGRect) {

        super.draw(rect)
        
        let viewWidth = rect.size.width

        if let image = image {

            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let imageRect: CGRect = {
                
                if imageWidth > imageHeight {
                    let a = ((imageWidth / imageHeight - 1) * viewWidth) / 2
                    return CGRect(x: -a, y: 0, width: 2 * a + viewWidth, height: viewWidth)
                } else if imageWidth < imageHeight {
                    let a = ((imageHeight / imageWidth - 1) * viewWidth) / 2
                    return CGRect(x: 0, y: -a, width: viewWidth, height: 2 * a + viewWidth)
                } else {
                    return rect
                }
            }()
            image.draw(in: imageRect)
        }

        if self.isSelected {
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor(white: 1.0, alpha: 0.3).cgColor)
            context?.fill(rect)

            let checkedImage: UIImage = UIImage(named: "image_checked", in: Bundle(for: ZPhotoPicker.self), compatibleWith: nil)!
            checkedImage.draw(at: CGPoint(x: viewWidth - checkedImage.size.width, y: 0))
        }
    }

    var representedAssetIdentifier: String!
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }

    override var isSelected: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
    }
}
