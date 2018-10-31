import Dip
import UIKit

extension DependencyContainer: ViewFactoryType {
    public func buildView<T>() throws -> T where T: UIViewController {
        return try resolver{ try self.resolve() }
    }
    
    public func buildView<T, ARG1>(arg: ARG1) throws -> T where T: UIViewController {
        return try resolver{ try self.resolve(arguments: arg) }
    }
    
    public enum ViewFactoryError: LocalizedError {
        case failedToBuild
        
        public var errorDescription: String? {
            switch self {
            case .failedToBuild: return "ViewFactory failed to build viewController using default builder. Fix your file hierarchy or manually register you controller in factory."
            }
        }
    }
    
    func resolver<T: UIViewController>(factory: () throws -> T) throws -> T {
        // supressing redundant console spam
        let logLevel = Dip.logLevel
        Dip.logLevel = .None
        defer { Dip.logLevel = logLevel }
        
        do {
            return try factory()
        } catch let error as ViewFactoryError {
            throw error
        } catch {
            register { // if failed to resolve controller - registering universal factory
                try T.instantiate(initial: true) ?? ViewFactoryError.failedToBuild.rethrow()
            }
            return try buildView()
        }
    }
}

extension DependencyContainer: ViewModelFactoryType {
    public func buildViewModel<T>() throws -> T {
        return try resolve()
    }
    
    public func buildViewModel<T, ARG>(arg: ARG) throws -> T {
        return try resolve(arguments: arg)
    }
    
    public func buildViewModel<T, ARG, ARG2>(arg: ARG, arg2: ARG2) throws -> T {
        return try resolve(arguments: arg, arg2)
    }
    
    public func buildViewModel<T, ARG, ARG2, ARG3>(arg: ARG, arg2: ARG2, arg3: ARG3) throws -> T {
        return try resolve(arguments: arg, arg2, arg3)
    }
}

