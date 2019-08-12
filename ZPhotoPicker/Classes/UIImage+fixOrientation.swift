//
//  UIImage+fixOrientation.swift
//
//  Created by Zack･Zheng on 2018/2/5.
//

import UIKit

internal extension UIImage {
    
    func fixOrientation() -> UIImage {

        guard imageOrientation != .up else {return self}
        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {

        case .down, .downMirrored:

            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:

            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:

            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        switch imageOrientation {

        case .upMirrored, .downMirrored:

            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:

            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }

        let ctx = CGContext(data: nil,
                            width: Int(size.width),
                            height: Int(size.height),
                            bitsPerComponent: cgImage!.bitsPerComponent,
                            bytesPerRow: 0,
                            space: cgImage!.colorSpace!,
                            bitmapInfo: cgImage!.bitmapInfo.rawValue)!
        ctx.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            let rect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
            ctx.draw(cgImage!, in: rect)
        default:
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            ctx.draw(cgImage!, in: rect)
        }
        
        let cgimg = ctx.makeImage()!
        let img = UIImage(cgImage: cgimg)
        return img
    }
}
