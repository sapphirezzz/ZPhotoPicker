//
//  ZVideoSinglePickerHostController.swift
//  ZPhotoPicker
//
//  Created by mooyoo on 2020/6/15.
//

import UIKit
import Photos

class ZVideoSinglePickerHostController: ZPhotoesListController {
    
    weak var delegate: ZVideoSinglePickerHostControllerDelegate?
    
    var maxVideoDurationInSecond: Int?
    var minVideoDurationInSecond: Int?
    
    deinit {
        print("\(self) \(#function)")
    }

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        self.mediaType = .video
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.mediaType = .video
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        collectionView?.allowsMultipleSelection = false
        clickedCancelHandler = { [weak self] in
            guard let `self` = self else {return}
            self.delegate?.videoSinglePickerHostControllerDidCancel(self)
        }
    }
}

extension ZVideoSinglePickerHostController {

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {

        let asset = fetchResult.object(at: indexPath.item)

        if let maxVideoDurationInSecond = maxVideoDurationInSecond, asset.duration > TimeInterval(maxVideoDurationInSecond) {
            delegate?.videoSinglePickerHostController(self, didForbidSelectionDuration: asset.duration)
            return false
        }

        if let minVideoDurationInSecond = minVideoDurationInSecond, asset.duration < TimeInterval(minVideoDurationInSecond) {
            delegate?.videoSinglePickerHostController(self, didForbidSelectionDuration: asset.duration)
            return false
        }
        imageManager?.startCachingImages(for: [asset], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil)
        return true
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! PhotoPickerImageCell
        cell.canSelected = true
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let asset = fetchResult.object(at: indexPath.item)

        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true // 默认为false，会导致iCloud的照片无法下载
        options.version = .original
        options.deliveryMode = .automatic
        showIndicatorView()
        DispatchQueue.global().async { [weak self] in

            self?.imageManager?.requestAVAsset(forVideo: asset, options: options, resultHandler: { [weak self] (avasset, _, info) in

                guard let `self` = self else { return }
                guard let avURLAsset = avasset as? AVURLAsset else {
                    return
                }
                
                DispatchQueue.main.async(execute: { [weak self] in

                    guard let `self` = self else { return }
                    self.hideIndicatorView()
                    self.delegate?.videoSinglePickerHostController(self, didFinishPickingVideo: avURLAsset)
                })
            })
        }
    }
}

protocol ZVideoSinglePickerHostControllerDelegate: class {
    
    func videoSinglePickerHostController(_ controller: ZVideoSinglePickerHostController, didFinishPickingVideo video: AVURLAsset)
    func videoSinglePickerHostControllerDidCancel(_ controller: ZVideoSinglePickerHostController)
    func videoSinglePickerHostController(_ controller: ZVideoSinglePickerHostController, didForbidSelectionDuration videoDuration: TimeInterval)
}
