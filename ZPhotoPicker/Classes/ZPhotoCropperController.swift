//
//  ZPhotoCropperController.swift
//  ZPhotoPicker
//
//  Created by Zack･Zheng on 2018/2/4.
//

import UIKit

class ZPhotoCropperController: UIViewController {
    
    var image: UIImage!
    var imageCroppedHandler: ((_ image: UIImage) -> Void)?
    var cancelledHandler: (() -> Void)?

    private var imageViewOriginalFrame: CGRect!

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isMultipleTouchEnabled = true
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var cropView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    private var toolBar: UIToolbar = {

        let bar = UIToolbar()
        let value: CGFloat = 20.0 / 255
        bar.barTintColor = UIColor(red: value, green: value, blue: value, alpha: 0.8)

        let cancelButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(ZPhotoCropperController.clickCancelButton(sender:)))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let completeButton = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(ZPhotoCropperController.clickCompleteButton(sender:)))
        bar.setItems([cancelButton, flexButton, completeButton], animated: false)

        cancelButton.tintColor = .white
        completeButton.tintColor = .white
        
        return bar
    }()

    deinit {
        print("\(self) \(#function)")
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        // 防止ImageView放大时，dismiss过渡动画异常
        view.clipsToBounds = true
        view.backgroundColor = UIColor.black
        image = image.fixOrientation()
        imageView.image = image
        imageView.frame = calculateImageViewFrame()
        imageViewOriginalFrame = imageView.frame

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(pinchGestureRecognizer:)))
        imageView.addGestureRecognizer(pinchGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panView(panGestureRecognizer:)))
        imageView.addGestureRecognizer(panGestureRecognizer)

        view.addSubview(imageView)
        view.addSubview(cropView)
        view.addSubview(toolBar)
    }

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        let toolBarHeight: CGFloat = 50
        cropView.frame = CGRect(x: 0, y: (view.bounds.height - view.bounds.width) / 2, width: view.bounds.width, height: view.bounds.width)
        toolBar.frame = CGRect(x: 0, y: view.bounds.height - toolBarHeight - bottomLayoutGuide.length, width: view.bounds.width, height: toolBarHeight)
    }
}

private extension ZPhotoCropperController {
    
    @objc func clickCancelButton(sender: UIBarButtonItem) {
        cancelledHandler?()
    }

    @objc func clickCompleteButton(sender: UIBarButtonItem) {

        let cropViewFrameRelativeToImageView: CGRect = {

            let x = cropView.frame.minX - imageView.frame.minX
            let y = cropView.frame.minY - imageView.frame.minY
            let rect = CGRect(origin: CGPoint(x: x, y: y), size: cropView.frame.size)
            return rect
        }()

        let croppingRectRelativeToImage: CGRect = {

            let imageViewScale = imageView.frame.width / (image.size.width * image.scale)
            let x = cropViewFrameRelativeToImageView.minX / imageViewScale
            let y = cropViewFrameRelativeToImageView.minY / imageViewScale
            let width = cropViewFrameRelativeToImageView.width / imageViewScale
            let height = cropViewFrameRelativeToImageView.height / imageViewScale
            let rect = CGRect(x: x, y: y, width: width, height: height)
            return rect
        }()
        let cgImage = image.cgImage!
        guard let imagePartRef = cgImage.cropping(to: croppingRectRelativeToImage) else {return}
        let croppedImage = UIImage(cgImage: imagePartRef)

        imageCroppedHandler?(croppedImage)
    }
    
    @objc func pinchView(pinchGestureRecognizer: UIPinchGestureRecognizer) {
    
        guard let view = pinchGestureRecognizer.view else {return}
        if pinchGestureRecognizer.state == .began || pinchGestureRecognizer.state == .changed {

            let scale = pinchGestureRecognizer.scale
            view.transform = view.transform.scaledBy(x: scale, y: scale)
            if view.frame.size.width < imageViewOriginalFrame.size.width || view.frame.size.height < imageViewOriginalFrame.size.height {
                view.frame = imageViewOriginalFrame
            }
            pinchGestureRecognizer.scale = 1
        }
    }
    
    @objc func panView(panGestureRecognizer: UIPanGestureRecognizer) {
        
        guard let view = panGestureRecognizer.view else {return}
        if panGestureRecognizer.state == .began || panGestureRecognizer.state == .changed {
            
            let translation = panGestureRecognizer.translation(in: view.superview!)
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
            if view.frame.origin.x > 0 {
                let oldFrame = view.frame
                view.frame = CGRect(origin: CGPoint(x: 0, y: oldFrame.minY), size: oldFrame.size)
            }
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let MaxMinX: CGFloat = 0.0
            if view.frame.minX > MaxMinX {
                let oldFrame = view.frame
                view.frame = CGRect(origin: CGPoint(x: MaxMinX, y: oldFrame.minY), size: oldFrame.size)
            }
            let maxMinY = (screenHeight - screenWidth) / 2
            if view.frame.minY > maxMinY {
                let oldFrame = view.frame
                view.frame = CGRect(origin: CGPoint(x: oldFrame.minX, y: maxMinY), size: oldFrame.size)
            }
            let minMaxX = screenWidth
            if view.frame.maxX < minMaxX {
                let oldFrame = view.frame
                let minX = oldFrame.minX + minMaxX - view.frame.maxX
                view.frame = CGRect(origin: CGPoint(x: minX, y: oldFrame.minY), size: oldFrame.size)
            }
            let minMaxY = screenWidth + maxMinY
            if view.frame.maxY < minMaxY {
                let oldFrame = view.frame
                let minY = oldFrame.minY + minMaxY - view.frame.maxY
                view.frame = CGRect(origin: CGPoint(x: oldFrame.minX, y: minY), size: oldFrame.size)
            }
            panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
        }
    }
    
    func calculateImageViewFrame() -> CGRect {
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        if imageWidth == imageHeight {

            return CGRect(x: 0, y: (screenHeight - screenWidth) / 2, width: screenWidth, height: screenWidth)
        } else if imageWidth > imageHeight {

            let width = imageWidth / imageHeight * screenWidth
            let x = (screenWidth - width) / 2
            return CGRect(x: x, y: (screenHeight - screenWidth) / 2, width: width, height: screenWidth)
        } else {
            
            let height = imageHeight / imageWidth * screenWidth
            let y = (screenHeight - height) / 2
            return CGRect(x: 0, y: y, width: screenWidth, height: height)
        }
    }
}

extension ZPhotoCropperController: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CoverHorizontalAnimatedTransitioning(type: .present)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CoverHorizontalAnimatedTransitioning(type: .dismiss)
    }
}
