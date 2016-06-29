//
//  Created by Todd Sutter on 10/1/15.
//  All rights reserved by Todd
//

import Foundation
import SpriteKit
import SystemConfiguration
import AVFoundation

public extension SKNode {
    
    public func runActionMove(moveX: CGFloat, moveY: CGFloat, duration: Double) {
        self.runAction(SKAction.moveByX(moveX, y: moveY, duration: duration))
    }
    
    public func runActionMoveByEase(moveX: CGFloat, moveY: CGFloat, duration: Double) {
        let stacks = 100
        let moveAction = SKAction.moveBy(CGVector(dx: moveX / CGFloat(stacks), dy: moveY / CGFloat(stacks)), duration: duration / 2)
        for i in 0..<stacks {
            SuttUtil.delay(Double(i) * duration / 2 / Double(stacks)) {
                self.runAction(moveAction)
            }
        }
    }
    
    public func runActionMoveDecelerate(moveX: CGFloat, moveY: CGFloat, duration: Double, withKey key: String = "") {
        let stacks = 100
        var actions = [SKAction]()
        for i in 0..<stacks {
            let moveAction = SKAction.moveBy(CGVector(dx: moveX / CGFloat(stacks), dy: moveY / CGFloat(stacks)), duration: duration * Double(i) / Double(stacks))
            actions.append(moveAction)
        }
        self.runAction(SKAction.group(actions), withKey: key)
    }
    
    public func runActionMoveAccelerate(moveX: CGFloat, moveY: CGFloat, duration: Double) {
        let stacks = 100
        for i in 0..<stacks {
            let moveAction = SKAction.moveBy(CGVector(dx: moveX / CGFloat(stacks), dy: moveY / CGFloat(stacks)), duration: duration * Double(i) / Double(stacks))
            SuttUtil.delay(duration - moveAction.duration) {
                self.runAction(moveAction)
            }
        }
    }
    
    public func runActionShakeX(shakes: Int, distance: CGFloat) {
        self.runAction(SKAction.shakeX(shakes, distance: distance))
    }
    
    public func runActionShakeY(shakes: Int, distance: CGFloat) {
        self.runAction(SKAction.shakeY(shakes, distance: distance))
    }
    
}

public extension String {
    func hexComponents() -> [String?] {
        let code = self
        let offset = code.hasPrefix("#") ? 1 : 0
        let start: String.Index = code.startIndex
        return [
            code[start.advancedBy(offset)..<start.advancedBy(offset + 2)],
            code[start.advancedBy(offset + 2)..<start.advancedBy(offset + 4)],
            code[start.advancedBy(offset + 4)..<start.advancedBy(offset + 6)]
        ]
    }
}

public extension SKColor {
    class func fromHexCode(code: String, alpha: CGFloat = 1.0) -> SKColor {
        let rgbValues = code.hexComponents().map {
            (component: String?) -> CGFloat in
            if let hex = component {
                var rgb: CUnsignedInt = 0
                if NSScanner(string: hex).scanHexInt(&rgb) {
                    return CGFloat(rgb) / 255.0
                }
            }
            return 0.0
        }
        return SKColor(red: rgbValues[0], green: rgbValues[1], blue: rgbValues[2], alpha: alpha)
    }
}

public extension SKAction {
    
    public static func shakeX(shakes: Int, distance: CGFloat) -> SKAction {
        let shakeDuration = 0.1
        var sequence: SKAction?
        for _ in 0..<shakes {
            let actionRight = SKAction.moveByX(distance / 2, y: 0, duration: shakeDuration / 4)
            let actionLeft = SKAction.moveByX(-distance, y: 0, duration: shakeDuration / 2)
            if sequence == nil {
                sequence = SKAction.sequence([actionRight,actionLeft,actionRight])
            } else {
                sequence = SKAction.sequence([sequence!,actionRight,actionLeft,actionRight])
            }
        }
        if sequence != nil {return sequence!}
        return SKAction.shakeX(1, distance: distance)
    }
    
    public static func shakeY(shakes: Int, distance: CGFloat) -> SKAction {
        let shakeDuration = 0.1
        var sequence: SKAction?
        for _ in 0..<shakes {
            let actionUp = SKAction.moveByX(0, y: distance / 2, duration: shakeDuration / 4)
            let actionDown = SKAction.moveByX(0, y: -distance, duration: shakeDuration / 2)
            if sequence == nil {
                sequence = SKAction.sequence([actionUp,actionDown,actionUp])
            } else {
                sequence = SKAction.sequence([sequence!,actionUp,actionDown,actionUp])
            }
        }
        if sequence != nil {return sequence!}
        return SKAction.shakeY(1, distance: distance)
    }
    
}

public extension CGPoint {
    
    public mutating func flipY(sceneHeight sceneHeight: CGFloat) {
        y = sceneHeight - y
    }
    
    public mutating func flipX(sceneWidth sceneWidth: CGFloat) {
        x = sceneWidth - x
    }
    
}

public class SuttUtil: AnyObject {
    
    static func appDelegate() -> AppDelegate {
        return NSApplication.sharedApplication().delegate as! AppDelegate
    }
    
    static func halfSizeOf(thisSize: CGSize) -> CGSize {
        return CGSize(width: thisSize.width / 2, height: thisSize.height / 2)
    }
    
    static func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    static func moveNodes(nodes: [SKNode], moveX: CGFloat, moveY: CGFloat, duration: Double) {
        for node in nodes {
            node.runActionMove(moveX, moveY: moveY, duration: duration)
        }
    }
    
    static func moveNodesByEase(nodes: [SKNode], moveX: CGFloat, moveY: CGFloat, duration: Double) {
        for node in nodes {
            node.runActionMoveByEase(moveX, moveY: moveY, duration: duration)
        }
    }
    
    static func moveNodesDecelerate(nodes: [SKNode], moveX: CGFloat, moveY: CGFloat, duration: Double, withKey key: String = "") {
        for node in nodes {
            node.runActionMoveDecelerate(moveX, moveY: moveY, duration: duration, withKey: key)
        }
    }
    
    static func moveNodesAccelerate(nodes: [SKNode], moveX: CGFloat, moveY: CGFloat, duration: Double) {
        for node in nodes {
            node.runActionMoveAccelerate(moveX, moveY: moveY, duration: duration)
        }
    }
    
    static func shakeNodesX(nodes: [SKNode], shakes: Int, distance: CGFloat) {
        for node in nodes {
            node.runActionShakeX(shakes, distance: distance)
        }
    }
    
    static func shakeNodesY(nodes: [SKNode], shakes: Int, distance: CGFloat) {
        for node in nodes {
            node.runActionShakeY(shakes, distance: distance)
        }
    }
    
    static func nilAction() {
        
    }
    
    static func normalizeIndexBetween(startIndex startIndex: Int = 0, endIndex: Int, index: Int) -> Int {
        if index >= startIndex && index <= endIndex {return index}
        let multiplier = index < startIndex ? 1 : -1
        let newIndex = (index + multiplier) + multiplier * (endIndex - startIndex)
        return normalizeIndexBetween(endIndex: endIndex, index: newIndex)
    }
    
    static func isConnectedToNetwork() -> Bool {
        
        // Martin R - StackOverflow http://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    static func convertNumToWeekday(x: Int) -> String {
        switch (x) {
        case 1:
            return "SUN"
        case 2:
            return "MON"
        case 3:
            return "TUE"
        case 4:
            return "WED"
        case 5:
            return "THU"
        case 6:
            return "FRI"
        case 7:
            return "SAT"
        default:
            return "ERR"
        }
    }
    
    static func convertNumToMonth(x: Int) -> String {
        switch (x) {
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Apr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Aug"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dec"
        default:
            return "ERR"
        }
    }
    
    static func convertFrameSceneToView(scene scene: SKScene, view: SKView?, frame: CGRect) -> CGRect {
        if let _ = view {
            let viewWidth = view!.frame.size.width
            let viewHeight = view!.frame.size.height
            let sceneWidth = scene.size.width
            let sceneHeight = scene.size.height
            let newX = frame.origin.x * viewWidth / sceneWidth
            let newY = frame.origin.y * viewHeight / sceneHeight
            let newWidth = frame.size.width * viewWidth / sceneWidth
            let newHeight = frame.size.height * viewHeight / sceneHeight
            return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        }
        print("view did not exist, could not convert frame")
        return frame
    }
    
    static func convertNumberSceneToView(scene scene: SKScene, view: SKView?, number: CGFloat) -> CGFloat {
        if let _ = view {
            return number * view!.frame.size.width / scene.size.width
        }
        print("view did not exist, could not convert number")
        return number
    }
    
    static func sizeDownToFit(inout size: CGSize, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil) {
        if maxWidth != nil && maxWidth! < size.width {
            size.height = size.height * maxWidth! / size.width // scale proportionally to maxWidth
            size.width = maxWidth!
        }
        if maxHeight != nil && maxHeight! < size.height {
            size.width = size.width * maxHeight! / size.height // scale proportionally to newHieght if still too tall
            size.height = maxHeight!
        }
    }
    
    static func formatTimeFromSeconds(seconds: Double) -> String {
        let minutes: Int = Int(seconds) / 60
        let secs: Int = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    static func getFirstFrameFromVideo(videoFilePath: String) -> SKTexture? {
        do {
            if let asset : AVURLAsset = AVURLAsset(URL: NSURL(fileURLWithPath: videoFilePath), options: nil) {
                let generate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                generate.appliesPreferredTrackTransform = true
                
                let imgRef : CGImageRef =  try generate.copyCGImageAtTime(CMTimeMake(0,1), actualTime: nil)
                return SKTexture(CGImage: imgRef)
            }
        } catch {
            print("Failed finding first frame of video - returning nil")
        }
        
        return nil
    }
    
}







