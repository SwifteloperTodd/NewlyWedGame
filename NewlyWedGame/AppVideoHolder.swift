//
//  AppVideoHolder.swift
//  ScoreExtremeDemo
//
//  Created by Todd Sutter on 6/15/16.
//  Copyright © 2016 igroupcreative. All rights reserved.
//

// AppVideoHolder is a class that holds an AppVideoNode.
// • Composed of two nodes: self (background node) and a video node.
// • This class fixes the SKVideoNode bug where it sometimes forgets to render the video
//   due to adding video to the scene too soon.

import Foundation
import SpriteKit
import AVFoundation

class AppVideoHolder : SKSpriteNode {
    
    var video: AppVideoNode?
    override var size: CGSize { didSet {
        video?.size = self.size
    }}
    var shouldAutoPlay: Bool = false { didSet {
        video?.shouldAutoPlay = shouldAutoPlay
    }}
    var shouldLoop: Bool = false { didSet {
        video?.shouldLoop = shouldLoop
    }}
    let fadeDuration: Double = 0.2
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience init(videoFileName: String, defaultTexture: SKTexture? = nil, onVideoEnd endAction: (Void -> Void)? = nil) {
        self.init(videoFilePath: NSBundle.mainBundle().pathForResource(videoFileName, ofType: "")!, defaultTexture: defaultTexture, onVideoEnd: endAction)
    }
    
    init(videoFilePath: String, defaultTexture: SKTexture? = nil, onVideoEnd endAction: (Void -> Void)? = nil) {
        video = AppVideoNode(videoFilePath: videoFilePath, onVideoEnd: endAction)
        
        var texture = defaultTexture
        if texture == nil {
            texture = SuttUtil.getFirstFrameFromVideo(videoFilePath)
        }
        
        super.init(texture: texture, color: SKColor.clearColor(), size: texture?.size() ?? CGSizeZero)
        
        video!.zPosition = 5
        
        // Let video initialize before adding to scene!!!!!! (wait a sec before adding)
        self.alpha = 0
        self.runAction(SKAction.sequence([
            SKAction.fadeInWithDuration(fadeDuration),
            SKAction.runBlock(self.addVideo)
        ]))
        
        initUI()
    }
    
    func initUI() {
        // Override
    }
    
    func addVideo() {
        if video != nil {
            self.addChild(video!)
            video!.didSetParent()
        }
    }
    
    func cleanUp() {
        video?.cleanUp()
        self.removeAllActions()
        self.removeAllChildren()
        self.removeFromParent()
    }
    
    func close() {
        self.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(self.fadeDuration),
            SKAction.runBlock(self.cleanUp)
        ]))
    }
    
}