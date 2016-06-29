//
//  ToggleNode.swift
//  ScoreExtremeDemo
//
//  Created by Todd Sutter on 1/22/16.
//  Copyright © 2016 igroupcreative. All rights reserved.
//

import Foundation
import SpriteKit

class ToggleNode : STButton {
    
    private var toggled = false
    private let toggledImageName: String
    private var originalTexture: SKTexture?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(imageName: String, toggledImageName: String, action: (info: [String : AnyObject]?) -> Void) {
        self.toggledImageName = toggledImageName
        let texture: SKTexture? = SKTexture(imageNamed: imageName)
        
        super.init(texture: texture, activeTexture: SKTexture(imageNamed: toggledImageName), action: action)
        
        self.originalTexture = texture
    }
    
    func getToggled() -> Bool {
        return toggled
    }
    
    func forceToggle(toggled: Bool) {
        if toggled != self.toggled {
            toggle()
        }
    }
    
    func forceToggleVisual(toggled: Bool) {
        if toggled != self.toggled {
            toggleVisual()
        }
    }
    
    func toggle() {
        self.toggleVisual()
        self.action?(nil)
    }
    
    func toggleVisual() {
        toggled = !toggled
        self.texture = toggled ? SKTexture(imageNamed: self.toggledImageName) : self.originalTexture
        self.size = self.texture!.size()
    }
    
    override func applyActiveState() {
        self.alpha = 0.5
    }
    
    override func applyDefaultState() {
        self.alpha = 1
    }
    
    override func mouseUp(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        self.applyDefaultState()
        
        if self.pointContainer.containsPoint(location) && !self.hidden {
            toggle()
        }
    }
    
}