import UIKit

extension UIViewController {
    func showSpinner(view: UIView, spinnerView: UIView, ai: UIActivityIndicatorView) {
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        ai.startAnimating()
        ai.center = self.view.center
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            view.addSubview(spinnerView)
        }
    }

    func removeSpinner(spinnerView: UIView, ai: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            ai.stopAnimating()
            spinnerView.removeFromSuperview()
        }
    }
}
