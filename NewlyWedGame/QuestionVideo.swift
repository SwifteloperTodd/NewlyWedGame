//
//  QuestionVideo.swift
//  NewlyWedGame
//
//  Created by Todd Sutter on 6/28/16.
//  Copyright © 2016 toddsutter. All rights reserved.
//

import Foundation
import SpriteKit

class QuestionVideo {
    
    var title: String?
    var pauseTime: Double?
    var videoName: String
    
    convenience init(videoName: String, title: String?, pauseTime: Double?) {
        self.init(videoName: videoName)
        
        self.title = title
        self.pauseTime = pauseTime
    }
    
    convenience init(videoName: String, pauseTime: Double?) {
        self.init(videoName: videoName)
        
        self.pauseTime = pauseTime
    }
    
    init(videoName: String) {
        self.videoName = videoName
    }
    
}