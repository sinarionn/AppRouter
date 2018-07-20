import UIKit
import ReusableView
import RxSwift

class ViewFactoryTestableViewController: UIViewController, NonReusableType {
    var recevedViewModel: String?
    func onUpdate(with viewModel: String, reuseBag: DisposeBag) {
        recevedViewModel = viewModel
    }
}
