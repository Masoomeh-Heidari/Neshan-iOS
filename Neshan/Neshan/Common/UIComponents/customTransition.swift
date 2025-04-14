//
//  customTransition.swift
//  CustomMap
//
//  Created by Bahar on 9/30/1403 AP.
//

import UIKit

class customTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.4
    let presenting: Bool

    init(presenting: Bool) {
        self.presenting = presenting
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else { return }

        let containerView = transitionContext.containerView
        if presenting {
            containerView.addSubview(toView)
            toView.frame = fromView.frame.offsetBy(dx: fromView.frame.width, dy: 0)
            UIView.animate(withDuration: duration, animations: {
                toView.frame = fromView.frame
                fromView.alpha = 0.8
            }) { _ in
                fromView.alpha = 1.0
                transitionContext.completeTransition(true)
            }
        } else {
            containerView.addSubview(toView)
            containerView.sendSubviewToBack(toView)
            toView.frame = fromView.frame
            UIView.animate(withDuration: duration, animations: {
                fromView.frame = fromView.frame.offsetBy(dx: fromView.frame.width, dy: 0)
                toView.alpha = 1.0
            }) { _ in
                transitionContext.completeTransition(true)
            }
        }
    }
}

