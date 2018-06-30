//
//  Utils.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/11/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func toString(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension UIViewController {
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
