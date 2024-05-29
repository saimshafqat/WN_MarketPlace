//
//  TransitionDelegate.swift
//  WorldNoor
//
//  Created by Raza najam on 4/9/20.
//  Copyright © 2020 Raza najam. All rights reserved.
//

import UIKit

class InteractiveTransition: UIPercentDrivenInteractiveTransition {
        public var hasStarted: Bool = false
        public var shouldFinish: Bool = false
    }

class Transition {
    public var isPresenting: Bool = false
    public var presentDuration: TimeInterval = 0.35
    public var dismissDuration: TimeInterval = 0.35
}

class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    lazy var transition: Transition = Transition()
    lazy var interactiveTransition: InteractiveTransition = InteractiveTransition()

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        self.transition.isPresenting = true
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transition.isPresenting = false
        return self
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactiveTransition.hasStarted ? self.interactiveTransition : nil
    }
}


extension TransitionDelegate:  UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transition.isPresenting ? self.transition.presentDuration : self.transition.dismissDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                transitionContext.completeTransition(false)
                return
        }

        let containerView = transitionContext.containerView
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        if self.transition.isPresenting {

            let finalFrameForVC = transitionContext.finalFrame(for: toVC)
            toVC.view.frame = finalFrameForVC.offsetBy(dx: 0, dy: UIScreen.main.bounds.size.height)
            containerView.addSubview(toVC.view)

            // Additional ways to animate, Spring velocity & damping
            UIView.animate(withDuration: self.transition.presentDuration,
                           delay: 0.0,
                           options: .transitionCrossDissolve,
                           animations: {
                            toVC.view.frame = finalFrameForVC
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })

        } else {

            var finalFrame = fromVC.view.frame
            finalFrame.origin.y += finalFrame.height

            // Additional ways to animate, Spring velocity & damping
            UIView.animate(withDuration: self.transition.dismissDuration,
                           delay: 0.0,
                           options: .curveEaseOut,
                           animations: {
                            fromVC.view.frame = finalFrame
                            toVC.view.alpha = 1.0
            },
                           completion: { _ in
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
