import Foundation
import UIKit

public typealias Func<T, U> = (T) -> U

/// Namespacing class 
open class AppRouter {
    /// Provides default AppRouter instance
    public static var shared = AppRouter()
    
    /// Provides application keyWindow. In normal cases returns UIApplication.sharedApplication().delegate?.window if available or creates new one if not.
    /// If appDelegate does not implement UIApplicationDelegate.window property - returns UIApplication.sharedApplication().keyWindow
    public static var window: UIWindow {
        return shared.window
    }
    
    /// Current window which Router work with
    open var window: UIWindow {
        return windowProvider()
    }
    open var windowProvider: () -> UIWindow
    
    public convenience init() {
        self.init(windowProvider: WindowProvider.dynamic.window)
    }
    
    public init(windowProvider: @escaping () -> UIWindow) {
        self.windowProvider = windowProvider
    }
    
    /// Defines AppRouter output target
    open static var debugOutput: (String) -> () = DebugOutput.nsLog.debugOutput
    internal static func print(_ str: String) {
        debugOutput(str)
    }
    
    /// Few predefined debugOutput targets
    public enum DebugOutput {
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
    
    public enum WindowProvider {
        case `static`(UIWindow)
        case dynamic
        
        func window() -> UIWindow {
            switch self {
            case .static(let window):
                return window
            case .dynamic:
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
        }
    }
}
