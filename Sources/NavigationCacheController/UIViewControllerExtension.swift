//
//  UIViewControllerExtension.swift
//  
//
//  Created by Carl Hung on 23/11/2020.
//

import Foundation
import UIKit

extension UIViewController: TypeName {
    public class var typeName: String {
        String(describing: Self.self)
    }
}
