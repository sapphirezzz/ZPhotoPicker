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
            let checkedImage: UIImage = UIImage(named: "image_checked", in: Bundle(for: ZPhotoPicker.self), compatibleWith: nil)!
            checkedImage.draw(at: CGPoint(x: viewWidth - checkedImage.size.width, y: 0))
        }

        if videoDuration > 0 {

            let shadowImage: UIImage = UIImage(named: "shadow", in: Bundle(for: ZPhotoPicker.self), compatibleWith: nil)!
            shadowImage.draw(in: CGRect.init(x: 0, y: viewWidth - 28, width: viewWidth, height: 28))
            
            let total = Int(ceil(videoDuration))
            let hours: Int = total / 3600
            let seconds = total % 60
            let minutes = (total - hours * 3600 - seconds ) / 60
            let time: String = {
                let hourString: String = hours > 0 ? "\( hours > 9 ? "" : "0")\(hours) ):" : ""
                let minuteString: String = "\( minutes > 9 ? "" : "0" )\(minutes):"
                let secondString: String = "\( seconds > 9 ? "" : "0" )\(seconds)"
                return "\(hourString)\(minuteString)\(secondString)"
            }()
            
            let label = UILabel()
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .right
            label.text = time
            label.drawText(in: CGRect(x: 0, y: viewWidth - 20, width: viewWidth - 5, height: 20))
        }

        if !canSelected {
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor(white: 1.0, alpha: 0.7).cgColor)
            context?.fill(rect)
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
    
    var canSelected: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var videoDuration: TimeInterval = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
    }
}
