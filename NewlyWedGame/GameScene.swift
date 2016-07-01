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
    
    let congratzScreen = STButton()
    
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
        
        congratzScreen.color = SKColor.fromHexCode("000000", alpha: 0.8)
        congratzScreen.zPosition = 5000
        congratzScreen.action = dismissCongratzScreen
        congratzScreen.overEffectAction = {}
        congratzScreen.size = self.size
        congratzScreen.position.y = self.size.height / 2
        congratzScreen.hidden = true
        self.addChild(congratzScreen)
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
        if videos.count > 0 {
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
        } else {
            let textLines: [String] = [
                "Instructions for adding videos:",
                "• Add video files (with any video extension) to \"Documents/_newlyWedVideos\" folder",
                "",
                "• Add a text line to \"Documents/_newlyWedConfig.txt\" for every video with information:",
                "Video file name (video.mp4), pause time (10.4) and title/question (Who is faster?)",
                "• Example:",
                "FirstQuestion.mp4 20 Who asked the other one out first?",
                "",
                "• Run the application again and this text will be gone. Instead: VIDEOS! Good luck :)"
            ]
            
            for i in 0..<textLines.count {
                let line: String = textLines[i]
                
                let label = SKLabelNode(fontNamed: "Avenir Medium")
                label.fontSize = 40
                label.fontColor = SKColor.blackColor()
                label.horizontalAlignmentMode = .Left
                label.position.y = -150 - CGFloat(i * 60)
                label.position.x = -nodeOrganizer.size.width / 2 + 100
                label.zPosition = 5
                label.text = line
                
                nodeOrganizer.addUnorganizedChild(label)
            }
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
        videoNode = nil
        
        let videoFilePath: String = SuttUtil.appDelegate().getVideosDirectoryPath() + "/\(video.videoName)"
        
        videoNode = GameVideoNode(videoFilePath: videoFilePath)
        videoNode!.pauseTime = video.pauseTime
        videoNode!.title = "\(currentVideoIndex + 1)) \(video.title ?? "")"
        videoNode!.onCloseButtonTouch = hideNextVideoButton
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
        hideNextVideoButton()
        
        let videos = SuttUtil.appDelegate().videos
        let newIndex = currentVideoIndex + 1
        if newIndex < videos.count {
            showVideo(newIndex, video: videos[newIndex])
        } else {
            videoNode?.close()
        }
    }
    
    func hideNextVideoButton() {
        nextVideoButton?.alpha = 1
        nextVideoButton?.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.2),SKAction.hide()]))
        
        if currentVideoIndex + 1 >= SuttUtil.appDelegate().videos.count {
            showCongratulationsScreen()
        }
    }
    
    func showCongratulationsScreen() {
        congratzScreen.alpha = 0
        congratzScreen.hidden = false
        congratzScreen.runAction(SKAction.sequence([SKAction.fadeInWithDuration(1),SKAction.runBlock(self.addFireworks)]))
    }
    
    func dismissCongratzScreen(info: [String : AnyObject]?) {
        congratzScreen.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.2),SKAction.hide(),SKAction.runBlock({
            self.removeAllActions()
            self.congratzScreen.removeAllActions()
            self.congratzScreen.removeAllChildren()
        })]))
    }
    
    func addFireworks() {
        func addFireWorkWithXPosition(positionX: CGFloat) {
            if let fireworkLight = SKEmitterNode(fileNamed: "FireworkLight") {
                
                fireworkLight.zPosition = 3
                fireworkLight.position.y = -500
                fireworkLight.position.x = positionX
                
                self.runAction(SKAction.sequence([
                    SKAction.runBlock({
                        self.congratzScreen.addChild(fireworkLight)
                    }),
                    SKAction.waitForDuration(2),
                    SKAction.runBlock({
                        fireworkLight.removeFromParent()
                        
                        if let fireworkLaunch = SKEmitterNode(fileNamed: "FireworkLaunch") {
                            fireworkLaunch.zPosition = 2
                            fireworkLaunch.position.y = -500
                            fireworkLaunch.position.x = positionX
                            self.congratzScreen.addChild(fireworkLaunch)
                        }
                    }),
                    SKAction.waitForDuration(1),
                    SKAction.runBlock({
                        if let fireworkExplosion = SKEmitterNode(fileNamed: "FireworkExplosion") {
                            fireworkExplosion.zPosition = 4
                            fireworkExplosion.position.y = 100
                            fireworkExplosion.position.x = positionX
                            self.congratzScreen.addChild(fireworkExplosion)
                        }
                    })
                ]))
            }
        }
        
        let wait = SKAction.waitForDuration(0.2)
        self.runAction(SKAction.sequence([
            SKAction.runBlock({
                addFireWorkWithXPosition(-800)
            }),wait,
            SKAction.runBlock({
                addFireWorkWithXPosition(-400)
            }),wait,
            SKAction.runBlock({
                addFireWorkWithXPosition(0)
            }),wait,
            SKAction.runBlock({
                addFireWorkWithXPosition(400)
            }),wait,
            SKAction.runBlock({
                addFireWorkWithXPosition(800)
            })
        ]))
        
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(7),
            SKAction.runBlock({
                let label = SKLabelNode(fontNamed: "Avenir Black")
                label.zPosition = 10
                label.text = "YOU DID IT."
                label.fontSize = 150
                label.fontColor = SKColor.whiteColor()
                label.verticalAlignmentMode = .Center
                label.alpha = 0
                self.congratzScreen.addChild(label)
                label.runAction(SKAction.fadeInWithDuration(1))
            }),
            SKAction.waitForDuration(1),
            SKAction.runBlock(addRandomExplosionsForever)
        ]))
    }
    
    func addRandomExplosionsForever() {
        if let fireworkExplosion = SKEmitterNode(fileNamed: "FireworkExplosion") {
            fireworkExplosion.zPosition = 4
            fireworkExplosion.position.y = -self.size.height / 2 + CGFloat(arc4random() % UInt32(self.size.height))
            fireworkExplosion.position.x = -self.size.width / 2 + CGFloat(arc4random() % UInt32(self.size.width))
            self.congratzScreen.addChild(fireworkExplosion)
            
            self.runAction(SKAction.sequence([SKAction.waitForDuration(1),SKAction.runBlock(self.addRandomExplosionsForever)]))
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        videoNode?.update()
    }
    
}





