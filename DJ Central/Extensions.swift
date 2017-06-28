//
//  Extensions.swift
//  DJ Central
//
//  Created by William Thompson on 6/27/17.
//  Copyright © 2017 J. W. Enterprises, LLC. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    
    func createARGBBitmapContext(_ inImage: CGImage) -> CGContext {
        var bitmapByteCount = 0
        var bitmapBytesPerRow = 0
        let pixelsWide = inImage.width
        let pixelsHigh = inImage.height
        bitmapBytesPerRow = Int(pixelsWide) * 4
        bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapData = malloc(bitmapByteCount)
        let context = CGContext(data: bitmapData, width: pixelsWide, height: pixelsHigh, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        return context!
    }
    
    func getPixelColor(_ point: CGPoint) -> UIColor {
        let provider = self.cgImage?.dataProvider
        let pixelData = provider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * Int(point.y)) + Int(point.x)) * 4
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func inversedColor(_ point: CGPoint) -> UIColor {
        let provider = self.cgImage?.dataProvider
        let pixelData = provider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * Int(point.y)) + Int(point.x)) * 4
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        return UIColor(red: 1.0 - r , green: 1.0 - g, blue: 1.0 - b, alpha: a)
    }

}

extension TimeInterval {
    var mmss_: String {
        return self < 0 ? "00:00" : String(format:"-%02d:%02d", Int(self / 60), Int(self.truncatingRemainder(dividingBy: 60)))
    }
    
    var mmss: String {
        return self < 0 ? "00:00" : String(format:"%02d:%02d", Int(self / 60), Int(self.truncatingRemainder(dividingBy: 60)))
    }
}

extension UIColor {
    
    static func <= (firstColor: UIColor, secondColor: UIColor) -> Bool {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        firstColor.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0
        secondColor.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        return red1 <= red2 && green1 <= green2 && blue1 <= blue2 && alpha1 <= alpha2
        
        
    }
    
    static func >= (firstColor: UIColor, secondColor: UIColor) -> Bool {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        firstColor.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0
        secondColor.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        return red1 >= red2 && green1 >= green2 && blue1 >= blue2 && alpha1 >= alpha2
    }
    
    static func == (firstColor: UIColor, secondColor: UIColor) -> Bool {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        firstColor.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0
        secondColor.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        return red1 == red2 && green1 == green2 && blue1 == blue2 && alpha1 == alpha2
    }
}

