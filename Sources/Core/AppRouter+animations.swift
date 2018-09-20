import Foundation
import UIKit

extension AppRouterType {
    var animator: AppRouter.Animators.RootAnimator { return .init(router: self) }
}

extension AppRouter {
    /// 🚲 Just few example animation methods
    public enum Animators {
        public struct RootAnimator {
            let router: AppRouterType
            
            public func setRoot(controller: UIViewController, animation: AnimationType, callback: ((Bool)->())? = nil) {
                switch animation {
                case .none:
                    router.rootViewController = controller
                    callback?(true)
                case .snapshotUpscale(let scaleTo, let opacityTo, let duration):
                    setRootWithSnapshotAnimation(controller, upscaleTo: scaleTo, opacityTo: opacityTo, duration: duration, callback: callback)
                case .view(let options, let duration):
                    setRootWithViewAnimation(controller, options: options, duration: duration, callback: callback)
                case .window(let options, let duration):
                    setRootWithWindowAnimation(controller, options: options, duration: duration, callback: callback)
                }
            }
            
            
            /// Uses UIView.transitionFromView to animate router.rootViewController change.
            ///
            /// - parameter controller: controller becoming rootViewController.
            /// - parameter options: animation options used to animate transition.
            /// - parameter duration: animation duration
            /// - parameter callback: called after controller becomes rootViewController
            public func setRootWithViewAnimation(_ controller: UIViewController, options: UIView.AnimationOptions = .transitionFlipFromLeft, duration: TimeInterval = 0.3, callback: ((Bool)->())? = nil) {
                if let rootController = router.rootViewController {
                    let oldState = UIView.areAnimationsEnabled
                    UIView.setAnimationsEnabled(false)
                    UIView.transition(from: rootController.view, to: controller.view, duration: duration, options: options, completion: { state in
                        self.router.rootViewController = controller
                        UIView.setAnimationsEnabled(oldState)
                        callback?(state)
                    })
                } else {
                    router.rootViewController = controller
                    callback?(true)
                }
            }
            
            /// Uses UIView.transitionWithView to animate router.rootViewController change.
            ///
            /// - parameter controller: controller becoming rootViewController
            /// - parameter options: animation options used to animate transition.
            /// - parameter duration: animation duration
            /// - parameter callback: called after controller becomes rootViewController
            public func setRootWithWindowAnimation(_ controller: UIViewController, options: UIView.AnimationOptions = .transitionFlipFromLeft, duration: TimeInterval = 0.3, callback: ((Bool)->())? = nil) {
                if let _ = router.rootViewController {
                    let oldState = UIView.areAnimationsEnabled
                    UIView.setAnimationsEnabled(false)
                    UIView.transition(with: router.window, duration: duration, options: options, animations: {
                        self.router.rootViewController = controller
                    }, completion: { state in
                        UIView.setAnimationsEnabled(oldState)
                        callback?(state)
                    })
                } else {
                    router.rootViewController = controller
                    callback?(true)
                }
            }
            
            /// Uses UIView.animateWithDuration to animate router.rootViewController change.
            ///
            /// - parameter controller: controller becoming rootViewController
            /// - parameter upscaleTo: final snapshot scale
            /// - parameter opacityTo: final snapshot opacity
            /// - parameter duration: animation duration
            /// - parameter callback: called after controller becomes rootViewController
            public func setRootWithSnapshotAnimation(_ controller: UIViewController, upscaleTo: CGFloat = 1.2, opacityTo: Float = 0, duration: TimeInterval = 0.3, callback: ((Bool)->())? = nil) {
                if let _ = router.rootViewController, let snapshot:UIView = router.window.snapshotView(afterScreenUpdates: true) {
                    controller.view.addSubview(snapshot)
                    router.rootViewController = controller
                    UIView.animate(withDuration: duration, animations: {
                        snapshot.layer.opacity = opacityTo
                        snapshot.layer.transform = CATransform3DMakeScale(upscaleTo, upscaleTo, upscaleTo);
                    }, completion: { state in
                        snapshot.removeFromSuperview()
                        callback?(state)
                    })
                } else {
                    router.rootViewController = controller
                    callback?(true)
                }
            }
        }
        
        public enum AnimationType {
            case none
            case view(options: UIView.AnimationOptions, duration: TimeInterval)
            case window(options: UIView.AnimationOptions, duration: TimeInterval)
            case snapshotUpscale(scaleTo: CGFloat, opacityTo: Float, duration: TimeInterval)
        }
    }
}
