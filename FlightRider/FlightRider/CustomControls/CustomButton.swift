
import UIKit

class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    
    private func setupButton() {
        backgroundColor     = #colorLiteral(red: 0.4801740832, green: 0.7935865502, blue: 1, alpha: 1)
        alpha               = 0.9
        titleLabel?.font    = UIFont(name: "Helvetica", size: 22)
        layer.cornerRadius  = frame.size.height/2
        setTitleColor(.white, for: .normal)
    }
}
