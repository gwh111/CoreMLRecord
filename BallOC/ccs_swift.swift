//
//  SW_Share.swift
//  testSwiftOC
//
//  Created by gwh on 2019/7/26.
//  Copyright © 2019 gwh. All rights reserved.
//

import Foundation

// MARK:ui
func W() -> CGFloat {
    return CGFloat(ccs.width())
}

func H() -> CGFloat {
    return CGFloat(ccs.height())
}

func RH(_ height:CGFloat) -> CGFloat {
    return CGFloat(CC_CoreUI.shared().relativeHeight(Float(height)))
}

func RF(_ fontSize:CGFloat) -> UIFont {
    return CC_CoreUI.shared().relativeFont(nil, fontSize: Float(fontSize))
}

func BRF(_ fontSize:CGFloat) -> UIFont {
    return CC_CoreUI.shared().relativeFont("Helvetica-Bold", fontSize: Float(fontSize))
}

// MARK:color
func COLOR_WHITE() -> UIColor {
    return UIColor.white
}

func COLOR_BLACK() -> UIColor {
    return UIColor.black
}

func COLOR_CLEAR() -> UIColor {
    return UIColor.clear
}

func HEX(_ hexStr:NSString) -> UIColor {
    return UIColor.cc_hexA(hexStr as String, alpha: 1)
}

func HEXA(_ hexStr:NSString, _ alpha:CGFloat) -> UIColor {
    return UIColor.cc_hexA(hexStr as String, alpha: Float(alpha))
}

func RGB(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat) -> UIColor {
    return UIColor.cc_rgbA(Float(r), green: Float(g), blue: Float(b), alpha: 1)
}

func RGBA(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ alpha:CGFloat) -> UIColor {
    return UIColor.cc_rgbA(Float(r), green: Float(g), blue: Float(b), alpha: Float(alpha))
}
