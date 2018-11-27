//
//  CoverHorizontalAnimatedTransitioning.swift
//  Meijiabang
//
//  Created by Zack･Zheng on 2017/9/11.
//  Copyright © 2017年 Double. All rights reserved.
//

import UIKit

enum AnimationType {
    case present
    case dismiss
}

class CoverHorizontalAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    var type: AnimationType = .present

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let vc = transitionContext.viewController(forKey: (type == .present ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from))!

        if type == .dismiss {
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            transitionContext.containerView.addSubview(toVC.view)
        }

        let initialFrame: CGRect = {
            switch type {
            case .present:
                return transitionContext.finalFrame(for: vc).offsetBy(dx: UIScreen.main.bounds.width, dy: 0)
            case .dismiss:
                return transitionContext.initialFrame(for: vc)
            }
        }()

        let finalFrame: CGRect = {
            switch type {
            case .present:
                return transitionContext.finalFrame(for: vc)
            case .dismiss:
                return transitionContext.initialFrame(for: vc).offsetBy(dx: UIScreen.main.bounds.width, dy: 0)
            }
        }()
        vc.view.frame = initialFrame
        transitionContext.containerView.addSubview(vc.view)

        //开始动画，这里使用了UIKit提供的弹簧效果动画，usingSpringWithDamping越接近1弹性效果越不明显，此API在IOS7之后才能使用
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.95,
                       initialSpringVelocity: 0,
                       options: UIView.AnimationOptions.curveEaseIn, animations: {
                        vc.view.frame = finalFrame
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }

    init(type: AnimationType) {
        super.init()
        self.type = type
    }
}
