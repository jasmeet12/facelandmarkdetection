//
//  OrientationHelper.swift
//  faceDetection
//
//  Created by Jasmeet Kaur on 11/06/18.
//  Copyright © 2018 Jasmeet Kaur. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit


enum EXIFOrientation : Int32 {
    case topLeft = 1
    case topRight
    case bottomRight
    case bottomLeft
    case leftTop
    case rightTop
    case rightBottom
    case leftBottom
    
    var isReflect:Bool {
        switch self {
        case .topLeft,.bottomRight,.rightTop,.leftBottom: return false
        default: return true
        }
    }
}

/**
 Returns EXIFOrientation that will adjust an image.
 
 - parameter deviceOrientation: physical orientation of the device when the image was captured. Must not be FaceUp or FaceDown
 - parameter position: position of the camera used for capture. Must be .Front or .Back
 
 - returns an EXIFOrientation, whose rawValue can be used as a CGImagePropertyOrientation,
 
 */
func compensatingEXIFOrientation(forDevicePosition position:AVCaptureDevice.Position,
                                 deviceOrientation:UIDeviceOrientation) -> EXIFOrientation
{
    switch (deviceOrientation,position) {
    case (.landscapeRight,.back): return .topLeft
    case (.landscapeRight,.front): return .bottomRight
    case (.landscapeLeft,.back): return .bottomRight
    case (.landscapeLeft,.front): return .topLeft
    case (.portrait,.back): return .rightTop
    case (.portrait,.front): return .rightTop
    case (.portraitUpsideDown,.back): return .leftBottom
    case (.portraitUpsideDown,.front): return .leftBottom
        
    case (.faceUp,_): fallthrough
    case (.faceDown,_): fallthrough
    case (_,.unspecified): fallthrough
    default:
        NSLog("Called in unrecognized orientation")
        return .rightTop
    }
}
