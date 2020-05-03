//
//  View.swift
//  ChatKit
//
//  Created by saran on 03/05/20.
//  Copyright © 2020 saran. All rights reserved.
//

import Foundation

extension UIView {
  func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
      let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
      let mask = CAShapeLayer()
      mask.path = path.cgPath
      self.layer.mask = mask
 }
}
