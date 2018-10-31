import Foundation
import UIKit

/// 🚲 Just few example animation methods
public enum ARAnimators {
    open class SimpleSetRootAnimator {
        public init() {}
        open func animate(router: AppRouterType, controller: UIViewController, completion: ((Bool)->())? = nil) {
            router.rootViewController = controller
            completion?(true)
        }
    }
    
    /// Uses UIView.animateWithDuration to animate router.rootViewController change.
    open class SnapshotUpscaleRootAnimator {
        public let upscaleTo: CGFloat
        public let opacityTo: Float
        public let duration: TimeInterval
        
        /// Uses UIView.animateWithDuration to animate router.rootViewController change.
        ///
        /// - parameter controller: controller becoming rootViewController
        /// - parameter upscaleTo: final snapshot scale
        /// - parameter opacityTo: final snapshot opacity
        /// - parameter duration: animation duration
        /// - parameter callback: called after controller becomes rootViewController
        public init(upscaleTo: CGFloat = 1.2, opacityTo: Float = 0, duration: TimeInterval = 0.3) {
            self.upscaleTo = upscaleTo
            self.opacityTo = opacityTo
            self.duration = duration
        }
        
        open func animate(router: AppRouterType, controller: UIViewController, completion: ((Bool)->())? = nil) {
            if let root = router.rootViewController, let window = root.view.window, let snapshot:UIView = window.snapshotView(afterScreenUpdates: true) {
                controller.view.addSubview(snapshot)
                router.rootViewController = controller
                UIView.animate(withDuration: duration, animations: {
                    snapshot.layer.opacity = self.opacityTo
                    snapshot.layer.transform = CATransform3DMakeScale(self.upscaleTo, self.upscaleTo, self.upscaleTo);
                }, completion: { state in
                    snapshot.removeFromSuperview()
                    completion?(state)
                })
            } else {
                router.rootViewController = controller
                completion?(false)
            }
        }
    }
    
    /// Uses UIView.transitionFromView to animate router.rootViewController change.
    open class ViewRootAnimator {
        public let options: UIView.AnimationOptions
        public let duration: TimeInterval
        
        /// Uses UIView.transitionFromView to animate router.rootViewController change.
        ///
        /// - parameter controller: controller becoming rootViewController.
        /// - parameter options: animation options used to animate transition.
        /// - parameter duration: animation duration
        /// - parameter callback: called after controller becomes rootViewController
        public init(options: UIView.AnimationOptions = .transitionFlipFromLeft, duration: TimeInterval = 0.3) {
            self.options = options
            self.duration = duration
        }
        
        open func animate(router: AppRouterType, controller: UIViewController, completion: ((Bool)->())? = nil) {
            if let rootController = router.rootViewController {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                UIView.transition(from: rootController.view, to: controller.view, duration: duration, options: options, completion: { state in
                    router.rootViewController = controller
                    UIView.setAnimationsEnabled(oldState)
                    completion?(state)
                })
            } else {
                router.rootViewController = controller
                completion?(false)
            }
        }
    }
    
    /// Uses UIView.transitionWithView to animate router.rootViewController change.
    open class WindowRootAnimator {
        public let options: UIView.AnimationOptions
        public let duration: TimeInterval
        
        /// Uses UIView.transitionWithView to animate router.rootViewController change.
        ///
        /// - parameter controller: controller becoming rootViewController
        /// - parameter options: animation options used to animate transition.
        /// - parameter duration: animation duration
        /// - parameter callback: called after controller becomes rootViewController
        public init(options: UIView.AnimationOptions = .transitionFlipFromLeft, duration: TimeInterval = 0.3) {
            self.options = options
            self.duration = duration
        }
        
        open func animate(router: AppRouterType, controller: UIViewController, completion: ((Bool)->())? = nil) {
            if let root = router.rootViewController, let window = root.view.window {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                UIView.transition(with: window, duration: duration, options: options, animations: {
                    router.rootViewController = controller
                }, completion: { state in
                    UIView.setAnimationsEnabled(oldState)
                    completion?(state)
                })
            } else {
                router.rootViewController = controller
                completion?(true)
            }
        }
    }
}

