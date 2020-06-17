//
//  ZVideoSinglePickerController.swift
//  ZPhotoPicker
//
//  Created by mooyoo on 2020/6/15.
//

import UIKit
import Photos

class ZVideoSinglePickerController: UINavigationController {
    
    private var maxVideoDurationInSecond: Int?
    private var minVideoDurationInSecond: Int?

    private var videoPickedHandler: ((_ video: AVURLAsset) -> Void)?
    private var cancelledHandler: (() -> Void)?
    private var selectionDurationForbidHandler: ((_ duration: TimeInterval) -> Void)? = nil

    deinit {
        print("\(self) \(#function)")
    }
    
    convenience init(maxVideoDurationInSecond: Int?, minVideoDurationInSecond: Int?, videoPickedHandler: @escaping (_ video: AVURLAsset) -> Void, cancelledHandler: (() -> Void)? = nil, selectionDurationForbidHandler: ((_ duration: TimeInterval) -> Void)? = nil) {

        let vc = ZPhotoAlbumListController()
        self.init(rootViewController: vc)
        self.maxVideoDurationInSecond = maxVideoDurationInSecond
        self.minVideoDurationInSecond = minVideoDurationInSecond
        self.videoPickedHandler = videoPickedHandler
        self.cancelledHandler = cancelledHandler
        self.selectionDurationForbidHandler = selectionDurationForbidHandler
        vc.albumListdelegate = self
        vc.mediaType = .video
        self.pushZVideoSinglePickerHostController()
    }
}

extension ZVideoSinglePickerController {
    
    class func pickVideo(onPresentingViewController controller: UIViewController, maxVideoDurationInSecond: Int?, minVideoDurationInSecond: Int?, videoPickedHandler: @escaping (_ video: AVURLAsset) -> Void, cancelledHandler: (() -> Void)? = nil, selectionDurationForbidHandler: ((_ duration: TimeInterval) -> Void)? = nil) {

        let vc = ZVideoSinglePickerController(maxVideoDurationInSecond: maxVideoDurationInSecond, minVideoDurationInSecond: minVideoDurationInSecond, videoPickedHandler: videoPickedHandler, cancelledHandler: cancelledHandler, selectionDurationForbidHandler: selectionDurationForbidHandler)
        vc.modalPresentationStyle = .fullScreen
        controller.present(vc, animated: true, completion: nil)
    }

    @available(iOS 12.0, *)
    class func pickVideo(onPresentingViewController controller: UIViewController, maxVideoDurationInSecond: Int?, minVideoDurationInSecond: Int?, videoPickedHandler: @escaping (_ video: AVURLAsset) -> Void, cancelledHandler: (() -> Void)? = nil, selectionDurationForbidHandler: ((_ duration: TimeInterval) -> Void)? = nil, userInterfaceStyle: UIUserInterfaceStyle = .unspecified) {

        let vc = ZVideoSinglePickerController(maxVideoDurationInSecond: maxVideoDurationInSecond, minVideoDurationInSecond: minVideoDurationInSecond, videoPickedHandler: videoPickedHandler, cancelledHandler: cancelledHandler, selectionDurationForbidHandler: selectionDurationForbidHandler)
        if #available(iOS 13.0, *) {
            vc.overrideUserInterfaceStyle = userInterfaceStyle
        }
        vc.modalPresentationStyle = .fullScreen
        controller.present(vc, animated: true, completion: nil)
    }
}

extension ZVideoSinglePickerController: ZVideoSinglePickerHostControllerDelegate {
    
    func videoSinglePickerHostController(_ controller: ZVideoSinglePickerHostController, didFinishPickingVideo video: AVURLAsset) {

        dismiss(animated: true) { [weak self] in
             self?.videoPickedHandler?(video)
         }
    }

    func videoSinglePickerHostControllerDidCancel(_ controller: ZVideoSinglePickerHostController) {
        self.dismiss(animated: true) { [weak self] in
            self?.cancelledHandler?()
        }
    }

    func videoSinglePickerHostController(_ controller: ZVideoSinglePickerHostController, didForbidSelectionDuration videoDuration: TimeInterval) {
        selectionDurationForbidHandler?(videoDuration)
    }
}

extension ZVideoSinglePickerController: ZPhotoAlbumListControllerDelegate {

    func photoAlbumListController(_ controller: ZPhotoAlbumListController, didSelectAlbum album: AlbumItem) {

        pushZVideoSinglePickerHostController(with: album)
    }
    
    func photoAlbumListControllerDidCancel(_ controller: ZPhotoAlbumListController) {

        self.dismiss(animated: true) { [weak self] in
            self?.cancelledHandler?()
        }
    }
}

private extension ZVideoSinglePickerController {
    
    func pushZVideoSinglePickerHostController(with album: AlbumItem? = nil) {

        let vc = ZVideoSinglePickerHostController(collectionViewLayout: UICollectionViewFlowLayout())
        vc.maxVideoDurationInSecond = maxVideoDurationInSecond
        vc.minVideoDurationInSecond = minVideoDurationInSecond
        vc.delegate = self
        if let album = album {
            vc.selectedAlbum = album
        }
        pushViewController(vc, animated: true)
    }
}
