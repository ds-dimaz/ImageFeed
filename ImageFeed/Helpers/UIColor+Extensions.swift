import UIKit

extension UIColor {
    static var ypRed: UIColor { UIColor(named: "YP Red") ?? UIColor.red }
    static var ypBlack: UIColor { UIColor(named: "YP Black") ?? UIColor.black}
    static var ypBackground: UIColor { UIColor(named: "YP Background") ?? UIColor.darkGray }
    static var ypGray: UIColor { UIColor(named: "YP Gray") ?? UIColor.gray }
    static var ypWhite: UIColor { UIColor(named: "YP White") ?? UIColor.white }
    static var ypWhiteAlpha50: UIColor { UIColor(named: "YP White (Alpha 50)") ?? UIColor.white.withAlphaComponent(0.5) }
    static var ypBlue: UIColor { UIColor(named: "YP Blue") ?? UIColor.blue }
}
