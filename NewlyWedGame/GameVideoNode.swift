//
//  NewlyWedVideo.swift
//  NewlyWedGame
//
//  Created by Todd Sutter on 6/28/16.
//  Copyright © 2016 toddsutter. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class GameVideoNode : AppVideoHolder {
    
    private var hasControls: Bool = false
    private var fillBar: SKSpriteNode?
    private var playerDuration: Double?
    private var currentTimeLabel: SKLabelNode?
    private let fillBarWidth: CGFloat = 1500
    private let fillBarHeight: CGFloat = 18
    private let rewindFastForwardAmount: Double = 5
    private var playPauseButton: STButton?
    
    let videoSize: CGSize = CGSizeMake(1920, 1080)
    let buttonSize: CGSize = CGSizeMake(50,50)
    
    var continueScreen: STButton?
    var endAction: (Void -> Void)?
    
    var hasPaused: Bool = false
    var pauseTime: Double?
    
    var titleNode = SKLabelNode()
    var title: String? { didSet {
        addTitle()
    }}
    
    override func initUI() {
        
        if let duration = video?.avPlayer?.currentItem?.asset.duration.seconds {
            playerDuration = duration < 1 ? 1 : duration // make minimum 1 second
        }
        
        video?.onVideoEndHandler = {
            self.playPauseButton?.texture = SKTexture(imageNamed: "play")
            self.endAction?()
        }
        
        self.setupContinueScreen()
        self.addControls()
    }
    
    func update() {
        updateFillBar()
        
        if pauseTime != nil && !hasPaused {
            let cmPauseTime = CMTime(seconds: pauseTime!, preferredTimescale: 1000)
            if video?.avPlayerItem?.currentTime() >= cmPauseTime {
                pauseForAnswer()
            }
        }
    }
    
    func pauseForAnswer() {
        video?.pause()
        hasPaused = true
        
        continueScreen?.hidden = false
    }
    
    // UI
    
    func setupContinueScreen() {
        continueScreen = STButton(imageName: nil, action: touchContinueScreen)
        continueScreen!.zPosition = 100
        continueScreen!.size = videoSize
        continueScreen!.color = SKColor.fromHexCode("000000", alpha: 0.5)
        continueScreen!.hidden = true
        self.addChild(continueScreen!)
        
        let label = SKLabelNode(fontNamed: "Avenir Black")
        label.text = "CLICK TO SEE ANSWER"
        label.zPosition = 10
        label.fontSize = 60
        label.fontColor = SKColor.whiteColor()
        label.verticalAlignmentMode = .Center
        continueScreen!.addChild(label)
    }
    
    func addControls() {
        if !hasControls {
            hasControls = true
            
            let topBar = SKSpriteNode(color: SKColor.blackColor(), size: CGSizeMake(videoSize.width, buttonSize.height))
            topBar.anchorPoint.y = 1
            topBar.alpha = 0.5
            topBar.zPosition = 9
            topBar.position.y = videoSize.height / 2
            self.addChild(topBar)
            
            let bottomBar = SKSpriteNode(color: SKColor.blackColor(), size: CGSizeMake(videoSize.width, buttonSize.height))
            bottomBar.anchorPoint.y = 0
            bottomBar.alpha = 0.5
            bottomBar.zPosition = 9
            bottomBar.position.y = -videoSize.height / 2
            self.addChild(bottomBar)
            
            let closeButton = STButton(imageName: "close", action: touchCloseButton)
            closeButton.zPosition = 10
            closeButton.anchorPoint = CGPointMake(1, 1)
            closeButton.position = CGPointMake(videoSize.width / 2, videoSize.height / 2)
            closeButton.name = "control"
            self.addChild(closeButton)
            
            playPauseButton = STButton(imageName: "pause", action: touchPlayPauseButton)
            playPauseButton!.zPosition = 10
            playPauseButton!.anchorPoint = CGPointMake(1, 0)
            playPauseButton!.position = CGPointMake(videoSize.width / 2, -videoSize.height / 2)
            playPauseButton!.name = "control"
            self.addChild(playPauseButton!)
            
            let rewindButton = STButton(imageName: "rr", action: touchRewindButton)
            rewindButton.zPosition = 10
            rewindButton.anchorPoint = CGPointMake(1,0.5)
            rewindButton.position = CGPointMake(-videoSize.width / 2 + buttonSize.width, -videoSize.height / 2 + buttonSize.height / 2)
            rewindButton.name = "control"
            self.addChild(rewindButton)
            
            let fastForwardButton = STButton(imageName: "ff", action: touchFastForwardButton)
            fastForwardButton.zPosition = 10
            fastForwardButton.anchorPoint = CGPointMake(0,0.5)
            fastForwardButton.position = CGPointMake(rewindButton.position.x + 20, rewindButton.position.y)
            fastForwardButton.name = "control"
            self.addChild(fastForwardButton)
            
            let emptyBar = SKSpriteNode()
            emptyBar.size = CGSizeMake(fillBarWidth, fillBarHeight)
            emptyBar.color = SKColor.grayColor()
            emptyBar.zPosition = 10
            emptyBar.position.y = -videoSize.height / 2 + emptyBar.size.height / 2 + 5
            emptyBar.name = "control"
            self.addChild(emptyBar)
            
            fillBar = SKSpriteNode(color: SKColor.whiteColor(), size: CGSize(width: 0, height: fillBarHeight))
            fillBar!.zPosition = 1
            fillBar!.anchorPoint = CGPointZero
            fillBar!.name = "control"
            fillBar!.position = CGPointMake(-fillBarWidth / 2, -fillBarHeight / 2)
            emptyBar.addChild(fillBar!)
            
            currentTimeLabel = SKLabelNode(fontNamed: "Avenir Black")
            currentTimeLabel!.zPosition = 10
            currentTimeLabel!.text = "0:00"
            currentTimeLabel!.fontSize = 20
            currentTimeLabel!.fontColor = SKColor.whiteColor()
            currentTimeLabel!.horizontalAlignmentMode = .Left
            currentTimeLabel!.position = CGPointMake(-fillBarWidth / 2, 16)
            currentTimeLabel!.name = "control"
            emptyBar.addChild(currentTimeLabel!)
            
            if playerDuration != nil {
                let durationLabel = SKLabelNode(fontNamed: "Avenir Black")
                durationLabel.zPosition = 10
                durationLabel.text = SuttUtil.formatTimeFromSeconds(playerDuration!)
                durationLabel.fontSize = 20
                durationLabel.fontColor = SKColor.whiteColor()
                durationLabel.horizontalAlignmentMode = .Right
                durationLabel.position.x = fillBarWidth / 2
                durationLabel.position.y = currentTimeLabel!.position.y
                durationLabel.name = "control"
                emptyBar.addChild(durationLabel)
            }
        }
    }
    
    func addTitle() {
        titleNode.text = title?.uppercaseString
        
        if titleNode.parent == nil {
            titleNode.zPosition = 10
            titleNode.fontSize = 40
            titleNode.fontColor = SKColor.whiteColor()
            titleNode.fontName = "Avenir Black"
            titleNode.horizontalAlignmentMode = .Left
            titleNode.verticalAlignmentMode = .Center
            titleNode.position = CGPointMake(-videoSize.width / 2 + 10, videoSize.height / 2 - buttonSize.height / 2)
            self.addChild(titleNode)
        }
    }
    
    // Touches
    
    func touchContinueScreen(info: [String : AnyObject]?) {
        video?.play()
        continueScreen?.hidden = true
    }
    
    func removeControls() {
        if hasControls {
            hasControls = false
            
            self.enumerateChildNodesWithName("control") {
                node, _ in
                node.removeFromParent()
            }
        }
    }
    
    func updateFillBar() {
        if hasControls, let duration = playerDuration, let currentDuration = video?.avPlayer?.currentTime().seconds {
            fillBar?.size.width = CGFloat(currentDuration / duration) * fillBarWidth
            currentTimeLabel?.text = SuttUtil.formatTimeFromSeconds(currentDuration)
        }
    }
    
    func changeTimeBy(seconds: Double) {
        if video?.avPlayer != nil, let endDuration = playerDuration {
            let currentTime = video!.avPlayer!.currentTime().seconds
            
            var newTime = Double(Int(currentTime + seconds)) // round down to whole number
            if newTime < 0 {
                newTime = 0
            } else if newTime > endDuration {
                newTime = endDuration
            }
    
            if seconds > 0 && currentTime + 1 > newTime {
                // do nothing
                return
            }
            
            let cmNewTime: CMTime = CMTime(seconds: newTime, preferredTimescale: 1000)
            video?.avPlayer?.seekToTime(cmNewTime)
            
            if let pt = pauseTime where cmNewTime < CMTime(seconds: pt, preferredTimescale: 1000) {
                hasPaused = false
            }
            
        }
    }
    
    // Touch Buttons
    
    func touchCloseButton(info: [String : AnyObject]?) {
        self.close()
    }
    
    func touchPlayPauseButton(info: [String : AnyObject]?) {
        if video != nil {
            if video!.isPlaying() {
                video!.pause()
                playPauseButton?.texture = SKTexture(imageNamed: "play")
            } else {
                video!.play()
                playPauseButton?.texture = SKTexture(imageNamed: "pause")
            }
        }
    }
    
    func touchRewindButton(info: [String : AnyObject]?) {
        changeTimeBy(-rewindFastForwardAmount)
    }
    
    func touchFastForwardButton(info: [String : AnyObject]?) {
        changeTimeBy(rewindFastForwardAmount)
    }
    
    func nillify() {
        fillBar = nil
        playerDuration = nil
        currentTimeLabel = nil
    }
    
    // Overrides
    
    override func cleanUp() {
        self.removeControls()
        self.nillify()
        super.cleanUp()
    }
    
}




