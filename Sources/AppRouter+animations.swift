import Foundation
import UIKit

extension AppRouter {
    /// 🚲 Just few example animation methods
    public enum animations {
        /// Uses UIView.transitionFromView to animate AppRouter.rootViewController change.
        ///
        /// - parameter controller: controller becoming rootViewController.
        /// - parameter options: animation options used to animate transition.
        /// - parameter duration: animation duration
        /// - parameter callback: called after controller becomes rootViewController
        public static func setRootWithViewAnimation(controller: UIViewController, options: UIViewAnimationOptions = .TransitionFlipFromLeft, duration: NSTimeInterval = 0.3, callback: ((Bool)->())? = nil) {
            if let rootController = AppRouter.rootViewController {
                let oldState = UIView.areAnimationsEnabled()
                UIView.setAnimationsEnabled(false)
                UIView.transitionFromView(rootController.view, toView: controller.view, duration: duration, options: options, completion: { state in
                    AppRouter.rootViewController = controller
                    UIView.setAnimationsEnabled(oldState)
                    callback?(state)
                })
            } else {
                AppRouter.rootViewController = controller
                callback?(true)
            }
        }
        
        /// Uses UIView.transitionWithView to animate AppRouter.rootViewController change.
        ///
        /// - parameter controller: controller becoming rootViewController
        /// - parameter options: animation options used to animate transition.
        /// - parameter duration: animation duration
        /// - parameter callback: called after controller becomes rootViewController
        public static func setRootWithWindowAnimation(controller: UIViewController, options: UIViewAnimationOptions = .TransitionFlipFromLeft, duration: NSTimeInterval = 0.3, callback: ((Bool)->())? = nil) {
            if let _ = AppRouter.rootViewController {
                let oldState = UIView.areAnimationsEnabled()
                UIView.setAnimationsEnabled(false)
                UIView.transitionWithView(AppRouter.window, duration: duration, options: options, animations: {
                    AppRouter.rootViewController = controller
                }, completion: { state in
                    UIView.setAnimationsEnabled(oldState)
                    callback?(state)
                })
            } else {
                AppRouter.rootViewController = controller
                callback?(true)
            }
        }
        
        /// Uses UIView.animateWithDuration to animate AppRouter.rootViewController change.
        ///
        /// - parameter controller: controller becoming rootViewController
        /// - parameter upscaleTo: final snapshot scale
        /// - parameter opacityTo: final snapshot opacity
        /// - parameter duration: animation duration
        /// - parameter callback: called after controller becomes rootViewController
        public static func setRootWithSnapshotAnimation(controller: UIViewController, upscaleTo: CGFloat = 1.2, opacityTo: Float = 0, duration: NSTimeInterval = 0.3, callback: ((Bool)->())? = nil) {
            if let _ = AppRouter.rootViewController, let snapshot:UIView = AppRouter.window.snapshotViewAfterScreenUpdates(true) {
                controller.view.addSubview(snapshot)
                AppRouter.rootViewController = controller
                UIView.animateWithDuration(duration, animations: {
                    snapshot.layer.opacity = opacityTo
                    snapshot.layer.transform = CATransform3DMakeScale(upscaleTo, upscaleTo, upscaleTo);
                }, completion: { state in
                    snapshot.removeFromSuperview()
                    callback?(state)
                })
            } else {
                AppRouter.rootViewController = controller
                callback?(true)
            }
        }
    }
}

