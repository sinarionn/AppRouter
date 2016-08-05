import Foundation
import UIKit

public typealias Action = ()->()

public class AppRouter {
    public class var window: UIWindow {
        guard let delegate = UIApplication.sharedApplication().delegate else { fatalError("no appDelegate found") }
        if let window = delegate.window {
            if let window = window {
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
    
    public static var debugOutput: ARDebugOutputProtocol = DebugOutput.NSLog
    internal static func print(str: String) {
        debugOutput.output(str)
    }
    
    public enum DebugOutput : ARDebugOutputProtocol {
        case None
        case Print
        case NSLog
        
        public func output(str: String) {
            switch self {
            case None: return
            case Print: return Swift.print(str)
            case NSLog: return Foundation.NSLog(str)
            }
        }
    }
}

public protocol ARDebugOutputProtocol {
    func output(str: String)
}