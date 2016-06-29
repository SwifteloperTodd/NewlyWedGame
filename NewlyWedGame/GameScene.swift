//
//  GameScene.swift
//  NewlyWedGame
//
//  Created by Todd Sutter on 6/28/16.
//  Copyright (c) 2016 toddsutter. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var scrollArea: AppScrollNode!
    var nodeOrganizer: NodeOrganizer!
    
    var videoNode: GameVideoNode?
    var currentVideoIndex = -1
    
    var nextVideoButton: STButton?
    var lastVideoHighlight: SKSpriteNode!
    
    let rowCount: CGFloat = 7
    
    var buttonSize: CGSize = CGSizeZero
    
    // UI
    
    override func didMoveToView(view: SKView) {
        setupUI()
    }
    
    func setupUI() {
        self.anchorPoint = CGPointMake(0.5,0)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = self.anchorPoint
        background.zPosition = -1
        self.addChild(background)
        
        scrollArea = AppScrollNode(size: self.size)
        scrollArea.anchorPoint = self.anchorPoint
        scrollArea.scrollBar.color = SKColor.blackColor()
        scrollArea.scrollBar.alpha = 0.8
        scrollArea.setBottomPadding(150)
        self.addChild(scrollArea)
        
        nodeOrganizer = NodeOrganizer(width: self.size.width - scrollArea.scrollBarWidth)
        nodeOrganizer.position.x = -scrollArea.scrollBarWidth / 2
        nodeOrganizer.position.y = -150
        nodeOrganizer.onChangedSize = scrollArea.updateContentHeight
        scrollArea.addChild(nodeOrganizer)
        
        buttonSize = CGSizeMake(nodeOrganizer.size.width / rowCount, nodeOrganizer.size.width / rowCount)
        
        nextVideoButton = STButton(imageName: "next-video", action: touchNextVideoButton)
        nextVideoButton!.zPosition = 1100
        nextVideoButton!.anchorPoint.x = 1
        nextVideoButton!.position = CGPointMake(self.size.width / 2 - 40, self.size.height / 2)
        nextVideoButton!.hidden = true
        self.addChild(nextVideoButton!)
        
        lastVideoHighlight = SKSpriteNode(imageNamed: "button-highlight")
        lastVideoHighlight.size = buttonSize
        lastVideoHighlight.zPosition = 5
        lastVideoHighlight.hidden = true
        nodeOrganizer.addUnorganizedChild(lastVideoHighlight)
    }
    
    func relocateVideoHighlight() {
        lastVideoHighlight.hidden = false
        
        let xMod: CGFloat = CGFloat(currentVideoIndex % Int(rowCount))
        let yMod: CGFloat = CGFloat(currentVideoIndex / Int(rowCount))
        
        lastVideoHighlight.position.x = -nodeOrganizer.size.width / 2 + xMod * buttonSize.width + buttonSize.width / 2
        lastVideoHighlight.position.y = -yMod * buttonSize.height - buttonSize.height / 2
    }
    
    // Video
    
    func addVideoButtons(videos: [QuestionVideo]) {
        for index in 0..<videos.count {
            let button = STButton(action: touchedVideoButton)
            button.setArguments(["index": index, "video":videos[index]])
            button.name = scrollArea.touchableNodeNames[0]
            button.size = buttonSize
            button.color = index % 2 == 0 ? SKColor.darkGrayColor() : SKColor.blackColor()
            nodeOrganizer.addChild(button)
            
            let label = SKLabelNode(fontNamed: "Avenir Black")
            label.text = String(index + 1)
            label.fontColor = SKColor.whiteColor()
            label.fontSize = 100
            label.zPosition = 1
            label.verticalAlignmentMode = .Center
            label.position = CGPointMake(button.size.width / 2, -button.size.height / 2)
            button.addChild(label)
        }
    }
    
    // Touches
    
    func touchedVideoButton(info: [String:AnyObject]?) {
        
        if let video = info?["video"] as? QuestionVideo {
            showVideo(info?["index"] as? Int, video: video)
        }
        
    }
    
    func showVideo(index: Int?, video: QuestionVideo) {
        if index != nil {
            currentVideoIndex = index!
        } else {
            currentVideoIndex = 0
        }
        
        videoNode?.cleanUp()
        
        let videoFilePath: String = SuttUtil.appDelegate().getVideosDirectoryPath() + "/\(video.videoName)"
        
        videoNode = GameVideoNode(videoFilePath: videoFilePath)
        videoNode!.pauseTime = video.pauseTime
        videoNode!.title = "\(currentVideoIndex + 1)) \(video.title ?? "")"
        videoNode!.zPosition = 1000
        videoNode!.size = self.size
        videoNode!.position.y = self.size.height / 2
        videoNode!.shouldAutoPlay = true
        
        videoNode!.endAction = {
            self.promptForNextVideo()
        }
        
        self.addChild(videoNode!)
        
        relocateVideoHighlight()
    }
    
    func promptForNextVideo() {
        nextVideoButton?.alpha = 0
        nextVideoButton?.hidden = false
        nextVideoButton?.runAction(SKAction.fadeInWithDuration(0.2))
    }
    
    func touchNextVideoButton(info: [String : AnyObject]?) {
        nextVideoButton?.alpha = 1
        nextVideoButton?.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.2),SKAction.hide()]))
        
        let videos = SuttUtil.appDelegate().videos
        let newIndex = currentVideoIndex + 1
        if newIndex < videos.count {
            showVideo(newIndex, video: videos[newIndex])
        } else {
            videoNode?.close()
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        videoNode?.update()
    }
    
}





