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
        public static func setRootWithViewAnimation(_ controller: UIViewController, options: UIViewAnimationOptions = .transitionFlipFromLeft, duration: TimeInterval = 0.3, callback: Func<Bool, Void>? = nil) {
            if let rootController = AppRouter.rootViewController {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                UIView.transition(from: rootController.view, to: controller.view, duration: duration, options: options, completion: { state in
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
        public static func setRootWithWindowAnimation(_ controller: UIViewController, options: UIViewAnimationOptions = .transitionFlipFromLeft, duration: TimeInterval = 0.3, callback: Func<Bool, Void>? = nil) {
            if let _ = AppRouter.rootViewController {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                UIView.transition(with: AppRouter.window, duration: duration, options: options, animations: {
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
        public static func setRootWithSnapshotAnimation(_ controller: UIViewController, upscaleTo: CGFloat = 1.2, opacityTo: Float = 0, duration: TimeInterval = 0.3, callback: Func<Bool, Void>? = nil) {
            if let _ = AppRouter.rootViewController, let snapshot:UIView = AppRouter.window.snapshotView(afterScreenUpdates: true) {
                controller.view.addSubview(snapshot)
                AppRouter.rootViewController = controller
                UIView.animate(withDuration: duration, animations: {
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

