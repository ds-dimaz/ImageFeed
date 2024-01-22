//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Дмитрий Зайцев on 13.12.23.
//

import Foundation
import UIKit

final class AlertPresenter {
    
    weak var delegate: UIViewController?
    
    func showAlert(title: String,message: String,handler: @escaping () -> Void) {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default) { _ in
                handler()
            }
            alert.addAction(alertAction)
            delegate?.present(alert, animated: true)
        }
}
