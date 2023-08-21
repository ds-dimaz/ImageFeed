import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var gradientView: UIView!
    
    private var gradientInited = false
    
    static let reuseIdentifier = "ImagesListCell"
    
    func addGradient(for cell: ImagesListCell) {
        if !gradientInited {
            let gradient = CAGradientLayer()
            gradient.frame = gradientView.bounds
            gradient.colors = [UIColor.clear.cgColor, UIColor.ypBlack.withAlphaComponent(0.5).cgColor]
            gradientView.layer.insertSublayer(gradient, at: 0)
            let path = UIBezierPath(roundedRect: gradientView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 16, height: 16))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            gradientView.layer.mask = maskLayer
            
            gradientInited.toggle()
        }
    }
}
