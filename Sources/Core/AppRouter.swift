import Foundation
import UIKit

public typealias Action = ()->()

/// Namespacing class 
public class AppRouter {
    /// Provides application keyWindow. In normal cases returns UIApplication.sharedApplication().delegate?.window if available or creates new one if not.
    /// If appDelegate does not implement UIApplicationDelegate.window property - returns UIApplication.sharedApplication().keyWindow
    public class var window: UIWindow {
        guard let delegate = UIApplication.sharedApplication().delegate else { fatalError("no appDelegate found") }
        if let windowProperty = delegate.window {
            if let window = windowProperty {
                return window
            } else {
                let newWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
                delegate.performSelector(Selector("setWindow:"), withObject: newWindow)
                newWindow.makeKeyAndVisible()
                return newWindow
            }
        } else {
            guard let window = UIApplication.sharedApplication().keyWindow else { fatalError("delegate doesn't implement window property and no UIApplication.sharedApplication().keyWindow available") }
            return window
        }
    }
    
    
    /// Defines AppRouter output target
    public static var debugOutput: ARDebugOutputProtocol = DebugOutput.NSLog
    internal static func print(str: String) {
        debugOutput.debugOutput(str)
    }
    
    /// Few predefined debugOutput targets
    public enum DebugOutput : ARDebugOutputProtocol {
        /// hides output
        case None
        
        /// uses Swift.print for output. Can't be seen in Device Console
        case Print
        
        /// uses Foundation.NSLog for output. Visible in Device Console
        case NSLog
        
        public func debugOutput(str: String) {
            switch self {
            case None: return
            case Print: return Swift.print(str)
            case NSLog: return Foundation.NSLog(str)
            }
        }
    }
}

/// AppRouter protocol used to specify proper debug outup mechanic
public protocol ARDebugOutputProtocol {
    func debugOutput(str: String)
}