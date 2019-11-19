import UIKit

class Tap {
    private static var instances: [Tap] = []

    private var view: UIView
    private var action: () -> Void

    static func on(view: UIView, fires action: @escaping () -> Void) {
        let tap = Tap(view: view, action: action)
        instances.append(tap)
    }

    private init(view: UIView, action: @escaping () -> Void) {
        self.view = view
        self.action = action

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func onTap(_ gesture: UIGestureRecognizer) {
        if (gesture.state == .ended) {
            fireAction()
        }
    }

    private func fireAction() {
        action()
    }
}
