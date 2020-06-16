//
//  ZPhotoPicker.swift
//
//  Created by Zack･Zheng on 2018/1/30.
//

import UIKit
import Photos

public class ZPhotoPicker {

    public enum PhotoPickType {

        case camera(allowsEditing: Bool)
        case singlePhoto(allowsEditing: Bool)
        case singleVideo(maxVideoDurationInSecond: Int?, minVideoDurationInSecond: Int?)
        case multiPhotoes(maxCount: Int)
        case multiVideoOrPhotoes(maxCount: Int, canMultiSelectVideo: Bool, maxVideoDurationInSecond: Int?, minVideoDurationInSecond: Int?)
    }

    @available(iOS 12.0, *)
    public class func pickVideoOrPhoto(onViewController controller: UIViewController, type: PhotoPickType, imagePickedHandler: ((_ image: UIImage) -> Void)? = nil, imagesPickedHandler: ((_ images: [UIImage]) -> Void)? = nil, videoPickedHandler: ((_ videos: AVURLAsset) -> Void)? = nil, videosPickedHandler: ((_ videos: [AVURLAsset]) -> Void)? = nil, cancelledHandler: (() -> Void)? = nil, selectionDurationForbidHandler: ((_ duration: TimeInterval) -> Void)? = nil, userInterfaceStyle: UIUserInterfaceStyle = .unspecified) {

        switch type {
        case let .camera(allowsEditing):

            let sourceType: UIImagePickerController.SourceType = .camera
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                alertUnsupportTypeError(onViewController: controller)
                return
            }
            ZPhotoTakingController.takePhoto(onPresentingViewController: controller, allowsCropping: allowsEditing, imageTookHandler: imagePickedHandler ?? { _ in}, cancelledHandler: cancelledHandler, userInterfaceStyle: userInterfaceStyle)
        case let .singlePhoto(allowsEditing):

            let sourceType: UIImagePickerController.SourceType = .photoLibrary
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                alertUnsupportTypeError(onViewController: controller)
                return
            }
            ZPhotoSinglePickerController.pickPhoto(onPresentingViewController: controller, allowsCropping: allowsEditing, imageTookHandler: imagePickedHandler ?? { _ in}, cancelledHandler: cancelledHandler, userInterfaceStyle: userInterfaceStyle)
                
        case let .singleVideo(maxVideoDurationInSecond, minVideoDurationInSecond):
            ZVideoSinglePickerController.pickVideo(onPresentingViewController: controller, maxVideoDurationInSecond: maxVideoDurationInSecond, minVideoDurationInSecond: minVideoDurationInSecond, videoPickedHandler: videoPickedHandler ?? { _ in}, cancelledHandler: cancelledHandler, userInterfaceStyle: userInterfaceStyle)
            
        case let .multiPhotoes(maxCount):
            
            ZPhotoMutilPickerController.pickPhotoes(onPresentingViewController: controller, maxCount: maxCount, imagesPickedHandler: imagesPickedHandler ?? {_ in}, cancelledHandler: cancelledHandler, userInterfaceStyle: userInterfaceStyle)
            break
            
        case let .multiVideoOrPhotoes(maxCount, canMultiSelectVideo, maxVideoDurationInSecond, minVideoDurationInSecond):
            ZVideoPhotoMutilPickerController.pickPhotoes(onPresentingViewController: controller, maxCount: maxCount, canMultiSelectVideo: canMultiSelectVideo, maxVideoDurationInSecond: maxVideoDurationInSecond, minVideoDurationInSecond: minVideoDurationInSecond, imagesPickedHandler: imagesPickedHandler, videosPickedHandler: videosPickedHandler, cancelledHandler: cancelledHandler, selectionDurationForbidHandler: selectionDurationForbidHandler, userInterfaceStyle: userInterfaceStyle)
        }
    }
    
    public class func pickVideoOrPhoto(onViewController controller: UIViewController, type: PhotoPickType, imagePickedHandler: ((_ image: UIImage) -> Void)? = nil, imagesPickedHandler: ((_ images: [UIImage]) -> Void)? = nil, videoPickedHandler: ((_ videos: AVURLAsset) -> Void)? = nil, videosPickedHandler: ((_ videos: [AVURLAsset]) -> Void)? = nil, cancelledHandler: (() -> Void)? = nil, selectionDurationForbidHandler: ((_ duration: TimeInterval) -> Void)? = nil) {

        switch type {
        case let .camera(allowsEditing):

            let sourceType: UIImagePickerController.SourceType = .camera
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                alertUnsupportTypeError(onViewController: controller)
                return
            }
            ZPhotoTakingController.takePhoto(onPresentingViewController: controller, allowsCropping: allowsEditing, imageTookHandler: imagePickedHandler ?? { _ in}, cancelledHandler: cancelledHandler)
        case let .singlePhoto(allowsEditing):

            let sourceType: UIImagePickerController.SourceType = .photoLibrary
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                alertUnsupportTypeError(onViewController: controller)
                return
            }
            ZPhotoSinglePickerController.pickPhoto(onPresentingViewController: controller, allowsCropping: allowsEditing, imageTookHandler: imagePickedHandler ?? { _ in}, cancelledHandler: cancelledHandler)
                
        case let .singleVideo(maxVideoDurationInSecond, minVideoDurationInSecond):
            ZVideoSinglePickerController.pickVideo(onPresentingViewController: controller, maxVideoDurationInSecond: maxVideoDurationInSecond, minVideoDurationInSecond: minVideoDurationInSecond, videoPickedHandler: videoPickedHandler ?? { _ in}, cancelledHandler: cancelledHandler)

        case let .multiPhotoes(maxCount):
            
            ZPhotoMutilPickerController.pickPhotoes(onPresentingViewController: controller, maxCount: maxCount, imagesPickedHandler: imagesPickedHandler ?? {_ in}, cancelledHandler: cancelledHandler)
            break
            
        case let .multiVideoOrPhotoes(maxCount, canMultiSelectVideo, maxVideoDurationInSecond, minVideoDurationInSecond):
            ZVideoPhotoMutilPickerController.pickPhotoes(onPresentingViewController: controller, maxCount: maxCount, canMultiSelectVideo: canMultiSelectVideo, maxVideoDurationInSecond: maxVideoDurationInSecond, minVideoDurationInSecond: minVideoDurationInSecond, imagesPickedHandler: imagesPickedHandler, videosPickedHandler: videosPickedHandler, cancelledHandler: cancelledHandler, selectionDurationForbidHandler: selectionDurationForbidHandler)
        }
    }

    private class func alertUnsupportTypeError(onViewController controller: UIViewController) {

        let alertVC = UIAlertController(title: "不支持的方式", message: "该设备不支持以该方式选取图片~", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
        controller.present(alertVC, animated: true, completion: nil)
    }
}
