import Foundation
import UIKit

public typealias Action = ()->()

/// Namespacing class 
open class AppRouter {
    /// Provides application keyWindow. In normal cases returns UIApplication.sharedApplication().delegate?.window if available or creates new one if not.
    /// If appDelegate does not implement UIApplicationDelegate.window property - returns UIApplication.sharedApplication().keyWindow
    open class var window: UIWindow {
        guard let delegate = UIApplication.shared.delegate else { fatalError("no appDelegate found") }
        if let windowProperty = delegate.window {
            if let window = windowProperty {
                return window
            } else {
                let newWindow = UIWindow(frame: UIScreen.main.bounds)
                delegate.perform(#selector(setter: UIApplicationDelegate.window), with: newWindow)
                newWindow.makeKeyAndVisible()
                return newWindow
            }
        } else {
            guard let window = UIApplication.shared.keyWindow else { fatalError("delegate doesn't implement window property and no UIApplication.sharedApplication().keyWindow available") }
            return window
        }
    }
    
    public init() {}
    
    /// Defines AppRouter output target
    open static var debugOutput: ARDebugOutputProtocol = DebugOutput.nsLog
    internal static func print(_ str: String) {
        debugOutput.debugOutput(str)
    }
    
    /// Few predefined debugOutput targets
    public enum DebugOutput : ARDebugOutputProtocol {
        /// hides output
        case none
        
        /// uses Swift.print for output. Can't be seen in Device Console
        case print
        
        /// uses Foundation.NSLog for output. Visible in Device Console
        case nsLog
        
        public func debugOutput(_ str: String) {
            switch self {
            case .none: return
            case .print: return Swift.print(str)
            case .nsLog: return Foundation.NSLog(str)
            }
        }
    }
}

/// AppRouter protocol used to specify proper debug outup mechanic
public protocol ARDebugOutputProtocol {
    func debugOutput(_ str: String)
}
