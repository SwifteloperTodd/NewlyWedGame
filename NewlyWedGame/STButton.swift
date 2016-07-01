//
//  TSButton.swift
//  MoneyBuddy
//
//  Created by Todd Sutter on 6/4/16.
//  Copyright © 2016 SpecialT. All rights reserved.
//

import Foundation
import SpriteKit

class STButton : SKSpriteNode {
    
    private var defaultTexture: SKTexture?
    private var activeTexture: SKTexture?
    
    var overEffectAction: (Void -> Void)?
    var undoOverEffectAction: (Void -> Void)?
    
    var action: (([String : AnyObject]?) -> (Void))?
    private var arguments: [String : AnyObject]?
    
    let pointContainer = SKSpriteNode()
    
    override var size: CGSize {
        didSet {
            changedSize()
        }
    }
    
    override var anchorPoint: CGPoint {
        didSet {
            changedAnchorPoint()
        }
    }
    
    // INITIALIZERS
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(texture: SKTexture?, activeTexture: SKTexture?, action: (([String : AnyObject]?) -> (Void))?) {
        self.action = action
        self.defaultTexture = texture
        self.activeTexture = activeTexture
        
        super.init(texture: texture, color: SKColor.clearColor(), size: texture?.size() ?? CGSizeZero)
        
        userInteractionEnabled = true
        
        pointContainer.zPosition = 100
        self.addChild(pointContainer)
    }
    
    convenience init(imageName: String? = nil, activeImageName: String? = nil, action: (([String : AnyObject]?) -> (Void))? = nil) {
        let texture: SKTexture? = imageName != nil ? SKTexture(imageNamed: imageName!) : nil
        let activeTexture: SKTexture? = activeImageName != nil ? SKTexture(imageNamed: activeImageName!) : nil
        self.init(texture: texture, activeTexture: activeTexture, action: action)
    }
    
    // EFFECTS
    
    func applyActiveState() {
        if overEffectAction != nil {
            overEffectAction!()
            return
        }
        
        if activeTexture != nil {
            self.texture = activeTexture
        } else {
            self.alpha = 0.5
        }
    }
    
    func applyDefaultState() {
        if undoOverEffectAction != nil {
            undoOverEffectAction!()
            return
        }
        
        if activeTexture != nil {
            self.texture = defaultTexture
        } else {
            self.alpha = 1
        }
    }
    
    func deactivate() {
        self.userInteractionEnabled = false
        self.alpha = 0.5
    }
    
    func reactivate() {
        self.userInteractionEnabled = true
        self.alpha = 1
    }
    
    // SETTERS
    
    func setArguments(arguments: [String : AnyObject]?) {
        self.arguments = arguments
    }
    
    private func changedSize() {
        pointContainer.size = self.size
    }
    
    private func changedAnchorPoint() {
        pointContainer.anchorPoint = self.anchorPoint
    }
    
    // TOUCHES
    
    override func mouseDown(theEvent: NSEvent) {
        applyActiveState()
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
            
        if pointContainer.containsPoint(location) {
            applyActiveState()
        } else {
            applyDefaultState()
        }
    }
        
    override func mouseUp(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        
        if pointContainer.containsPoint(location) {
            self.action?(arguments)
        }
        
        applyDefaultState()
    }
    
}