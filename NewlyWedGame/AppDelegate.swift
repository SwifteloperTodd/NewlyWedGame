//
//  AppDelegate.swift
//  NewlyWedGame
//
//  Created by Todd Sutter on 6/28/16.
//  Copyright (c) 2016 toddsutter. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    var videos: [QuestionVideo] = [QuestionVideo]()
    var scene: GameScene!
    
    var exampleVideos: [[String : AnyObject]] = [
        [
            "title": "Which one of you asked the other one out?",
            "pauseTime": 4
        ],
        [
            "title": "Who is prettier?",
            "pauseTime": 6.2
        ],
        [
            "title": "Which one of you laughs harder?",
            "pauseTime": 10
        ]
    ]
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let sceneSize: CGSize = CGSizeMake(1920,1080)
        
        if !windowIsFullScreen() {
            window.toggleFullScreen(self)
        }
        
        scene = GameScene(size: sceneSize)
        scene.scaleMode = .AspectFit
        self.skView!.ignoresSiblingOrder = true
        self.skView!.presentScene(scene)
        
        setupVideos()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    func windowIsFullScreen() -> Bool {
        return window.styleMask & NSFullScreenWindowMask != 0
    }
    
    // Videos
    
    private func setupVideos() {
        ensureVideosDirectory()
        let configContents = getConfigContents()
        let configLines: [String] = configContents.componentsSeparatedByString("\n")
        
        for line : String in configLines {
            let components: [String] = line.componentsSeparatedByString(" ")
            if components.count < 1 || components[0] == "//" {
                continue
            }
            
            let videoName: String = components[0]
            var pauseTime: Double?
            var title: String?
            
            if components.count >= 2 {
                pauseTime = Double(components[1])
            }
            
            if components.count >= 3 {
                title = components[2]
                for i in 3..<components.count {
                    title! += " " + components[i]
                }
            }
            
            videos.append(QuestionVideo(videoName: videoName, title: title, pauseTime: pauseTime))
        }
        
        scene.addVideoButtons(videos)
    }
    
    // Helpers
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getConfigFilePath() -> String {
        return getDocumentsDirectory() + "/_newlyWedConfig.txt"
    }
    
    func getConfigFileURL() -> NSURL {
        return NSURL(fileURLWithPath: getConfigFilePath())
    }
    
    func getVideosDirectoryPath() -> String {
        return getDocumentsDirectory() + "/_newlyWedVideos"
    }
    
    private func getConfigContents() -> String {
        do {
            let configContents: NSString = try NSString(contentsOfURL: getConfigFileURL(), encoding: NSUTF8StringEncoding)
            return configContents as String
        } catch {
            do {
                let starterText = "// This line is a comment. It is not read in the code.\n// For every newly wed video, add the video to _newlyWedVideos folder\n// and write the video name, pause time, and title in this file in order from top to bottom.\n// Example: VideoOne.mp4 12.4 Who asked the other one out first?"
                try starterText.writeToURL(getConfigFileURL(), atomically: true, encoding: NSUTF8StringEncoding)
                return starterText
            } catch {
                return "// Failed"
            }
        }
    }
    
    private func ensureVideosDirectory() {
        let videosDirectoryPath: String = getVideosDirectoryPath()
        
        let fileManager = NSFileManager.defaultManager()
        var isDir : ObjCBool = true
        if !fileManager.fileExistsAtPath(videosDirectoryPath, isDirectory: &isDir) {
            do {
                try fileManager.createDirectoryAtPath(videosDirectoryPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("Failed to create directory at:",videosDirectoryPath)
            }
        }
    }
    
}





