//
//  AppVideoNode.swift
//  SEDisplay
//
//  Created by Corey Spitzer on 9/8/15.
//  Copyright © 2015 iGroup Creative. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

public class AppVideoNode: SKVideoNode
{
    var avPlayer: AVPlayer?
    var avPlayerItem: AVPlayerItem?
    var shouldLoop: Bool = false
    var shouldAutoPlay: Bool = false
    public var onVideoEndHandler: ((Void) -> (Void))?
    
    convenience init(videoFileName: String, onVideoEnd endAction: ((Void) -> (Void))? = nil) {
        self.init(videoFilePath: NSBundle.mainBundle().pathForResource(videoFileName, ofType: "")!, onVideoEnd: endAction)
    }
    
    init(videoFilePath: String, onVideoEnd endAction: ((Void) -> (Void))? = nil) {
        //super.init(URL: NSURL(fileURLWithPath: videoFilePath))
        
        self.avPlayerItem = AVPlayerItem(URL: NSURL(fileURLWithPath: videoFilePath))
        self.avPlayer = AVPlayer(playerItem: self.avPlayerItem!)
        
        super.init(AVPlayer: self.avPlayer!)
        
        self.onVideoEndHandler = endAction
        
        self.avPlayer!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions([.New, .Initial]), context: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppVideoNode.onVideoEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.avPlayerItem)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onVideoEnd(notification: NSNotification) {
        if(notification.object as? AVPlayerItem != self.avPlayerItem){
            return
        }
        
        if shouldLoop {
            self.avPlayerItem?.seekToTime(kCMTimeZero)
            self.play()
        } else {
            self.pause()
            self.onVideoEndHandler?()
        }        
    }
    
    func cleanUp() {
        self.pause()

        if(self.avPlayerItem != nil){
            NSNotificationCenter.defaultCenter().removeObserver(self.avPlayerItem!)
        }
        self.avPlayerItem = nil
        
        self.avPlayer?.pause()
        self.avPlayer?.removeObserver(self, forKeyPath: "status")
        // self.avPlayer = AVPlayer(URL: NSURL())
        self.avPlayer = nil
        
        self.removeAllChildren()
        self.removeAllActions()
        self.removeFromParent()
    }
    
    func isPlaying() -> Bool {
        return self.avPlayer?.rate != 0 && avPlayer?.error == nil
    }
    
    override public func play() {
        self.shouldAutoPlay = true
        super.play()
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object != nil && (object as? AVPlayer) == self.avPlayer && keyPath != nil && keyPath! == "status" {
            if self.avPlayer!.status == AVPlayerStatus.ReadyToPlay {
//                Util.log("Finished loading video into memory")
                
                if self.shouldAutoPlay && self.parent != nil {
                    self.play()
                } else {
                    self.pause()
                }
            } else {
                if self.avPlayer!.status == AVPlayerStatus.Failed {
                    print("video status: FAILED")
                } else if self.avPlayer!.status == AVPlayerStatus.Unknown {
//                    Util.log("video status: UNKNOWN")
                }
            }
        }
    }
    
    func didSetParent() {
        if self.shouldAutoPlay {
            self.play()
        }
    }
    
    func dumpLogs() {
        var logs: String
        
        logs = "---------------------" +
            "\n\(self.name ?? "VideoNode"):" +
            "\nsize: \(self.size), zPos: \(self.zPosition), position: \(self.position)" +
            "\nalpha: \(self.alpha), hidden: \(self.hidden)" +
            "\nPlayerStatus Ready: \(self.avPlayer?.status == AVPlayerStatus.ReadyToPlay)" +
            "\nItemStatus Ready: \(self.avPlayerItem?.status == AVPlayerItemStatus.ReadyToPlay)" +
            "\navplayer: \(self.avPlayer)" +
            "\navplayeritem: \(self.avPlayerItem)" +
            "\nParent: \(self.parent)" +
            "\n---------------------"
            
        print(logs)
    }
    
 }