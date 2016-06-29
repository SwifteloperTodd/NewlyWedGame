//
//  AppScrollNode.swift
//  ScoreExtremeDemo
//
//  Created by Todd Sutter on 6/20/16.
//  Copyright © 2016 igroupcreative. All rights reserved.
//

import Foundation
import SpriteKit

class AppScrollNode : SKCropNode {
    
    // Nodes inside scroll area with these names will recieve touches
    // An empty string: "" will account for nodes with name == "" or name == nil
    var touchableNodeNames: [String] = ["touchableNode"]
    
    private let scroller: SKNode = SKNode()
    private var contentHeight: CGFloat = 0
    private var bottomPadding: CGFloat = 10
    
    private var background: SKSpriteNode
    private var overlayNode: SKSpriteNode
    
    let scrollBar: SKSpriteNode = SKSpriteNode()
    
    // INITS - GETTERS - SETTERS
    var scrollBarWidth: CGFloat = 20 { didSet {
        didSetScrollBarWidth()
    }}
    var touchZPosition: CGFloat = 200 { didSet {
        didSetTouchZPosition()
    }}
    var size: CGSize { didSet {
        didSetSize()
    }}
    var anchorPoint: CGPoint { didSet {
        didSetAnchorPoint()
    }}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience init(color: SKColor, size: CGSize) {
        self.init(texture: nil, color: color, size: size)
    }
    
    convenience init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        self.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
    }
    
    convenience init(size: CGSize) {
        self.init(texture: nil, color: SKColor.clearColor(), size: size)
    }
    
    init(texture: SKTexture?, color: SKColor, size: CGSize) {
        self.size = size
        self.anchorPoint = CGPointMake(0.5,0.5)
        self.background = SKSpriteNode(texture: texture, color: color, size: size)
        self.overlayNode = SKSpriteNode(color: SKColor.clearColor(), size: size)
        
        super.init()
        
        maskNode = SKSpriteNode(color: SKColor.whiteColor(), size: size)
        
        super.addChild(background)
        super.addChild(overlayNode)
        super.addChild(scroller)
        createScrollBar()
        
        self.userInteractionEnabled = true
        
        didSetScrollBarWidth()
        didSetSize()
        didSetAnchorPoint()
        didSetTouchZPosition()
    }
    
    // Getters and Setters
    
    func setBottomPadding(padding: CGFloat) {
        // Update the amount of padding below the bottom content
        bottomPadding = padding
        updateContentHeight()
    }
    
    private func didSetScrollBarWidth() {
        scrollBar.size.width = scrollBarWidth
    }
    
    private func didSetSize() {
        // Update mask size, touchSize (overlay), and background size
        (self.maskNode as? SKSpriteNode)?.size = size
        overlayNode.size = size
        background.size = size
    }
    
    private func didSetAnchorPoint() {
        // Update anchorPoint for mask and others
        // Set scroller to top of screen
        (self.maskNode as? SKSpriteNode)?.anchorPoint = anchorPoint
        overlayNode.anchorPoint = anchorPoint
        
        background.position.x = self.size.width * (0.5 - self.anchorPoint.x)
        background.position.y = self.size.height * (0.5 - self.anchorPoint.y)
        scroller.position.y = getTopOfScreen()
        updateScrollBarPosition()
    }
    
    private func didSetTouchZPosition() {
        self.overlayNode.zPosition = touchZPosition
        self.scrollBar.zPosition = touchZPosition + 1
    }
    
    private func getContentHeight() -> CGFloat {
        // Return size of mask if content doesn't overflow
        return max(contentHeight, self.size.height)
    }
    
    private func getBottomContentPosition() -> CGFloat {
        // Return bottom of content
        return scroller.position.y - getContentHeight()
    }
    
    private func getTopOfScreen() -> CGFloat {
        // Top of masked area calculated with anchorPoint
        return self.size.height * (1 - self.anchorPoint.y)
    }
    
    private func getBottomOfScreen() -> CGFloat {
        // Bottom of masked area calculated with anchorPoint
        return -self.size.height * self.anchorPoint.y
    }
    
    // Scroll Bar
    
    private func createScrollBar() {
        scrollBar.color = SKColor.blackColor()
        scrollBar.alpha = 0.5
        scrollBar.anchorPoint = CGPointMake(1, 1)
        scrollBar.position.x = self.size.width / 2
        background.addChild(scrollBar)
        
        updateScrollBarHeight()
        updateScrollBarPosition()
    }
    
    private func updateScrollBarHeight() {
        scrollBar.size.height = self.size.height / getContentHeight() * self.size.height
    }
    
    private func updateScrollBarPosition() {
        // Update scroll bar position based on scroller
        
        let scrollerPosition: CGFloat = scroller.position.y - getTopOfScreen()
        let scrollerContentRatio: CGFloat = scrollerPosition / getContentHeight()
        let scrollBarPosition: CGFloat = self.size.height / 2 - self.size.height * scrollerContentRatio
        scrollBar.runAction(SKAction.moveToY(scrollBarPosition, duration: 0.05))
    }
    
    private func moveScrollBar(currentTouchY currentTouch: CGFloat) {
        var newPosition: CGFloat = lastScrollBarY + currentTouch - lastTouchY
        let topPosition: CGFloat = self.size.height / 2
        let bottomPosition: CGFloat = -self.size.height / 2 + scrollBar.size.height
        
        if newPosition > topPosition {
            newPosition = topPosition
        } else if newPosition < bottomPosition {
            newPosition = bottomPosition
        }
        
        scrollBar.runAction(SKAction.moveToY(newPosition, duration: 0.05))
        updateScrollerPosition(scrollBarY: newPosition)
    }
    
    func setScrollBarHidden(hidden: Bool) {
        scrollBar.hidden = hidden
    }
    
    // Add children
    
    override func addChild(node: SKNode) {
        // Add all children to scroller
        scroller.addChild(node)
        updateContentHeight()
    }
    
    func updateContentHeight() {
        // Calculate bottom most position of all children and add bottom padding
        contentHeight = 0
        for child in scroller.children {
            let childBottom = child.frame.minY
            let height = abs(childBottom)
            if height > contentHeight {
                contentHeight = height
            }
        }
        contentHeight += bottomPadding
        
        // Update Scroll Bar
        updateScrollBarHeight()
    }
    
    // Touches and Scrolling
    
    var isUsingScrollBar: Bool = false
    
    var lastTouchY: CGFloat = 0
    var lastScrollY: CGFloat = 0
    var lastScrollBarY: CGFloat = 0
    
    var lastMoveLocation: CGPoint = CGPointZero
    var lastMovedTime: Double = 0
    
    var scrollSpeed: CGFloat = 0
    let maxScrollSpeed: CGFloat = 150
    
    var touchedNode: SKNode?
    
    override func mouseDown(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        
        // Remember Touched location
        lastMoveLocation = location
        lastTouchY = location.y
        lastScrollY = scroller.position.y
        lastScrollBarY = scrollBar.position.y
        scroller.removeAllActions()
        
        if nodeAtPoint(location) == scrollBar {
            
            // Scroll Bar
            isUsingScrollBar = true
            
        } else {
            
            // Touch Nodes
            for node in nodesAtPoint(location) {
                // if node's name is included in touchableNodeNames
                let nodeName: String = node.name ?? ""
                if touchableNodeNames.indexOf(nodeName) >= 0 {
                    touchedNode = node
                    node.mouseDown(theEvent)
                    break
                }
            }
            
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        // Move Content and calculate current speed of scrolling
        
        if isUsingScrollBar {
            moveScrollBar(currentTouchY: location.y)
        } else {
            moveScroller(currentTouchY: location.y)
            calculateScrollSpeed(location.y)
        }
        
        lastMoveLocation = location
        
        
        // Touch Nodes
        
        // call touches ended with no touches if scrolling distance is far
        if touchedNode != nil && abs(location.y - lastTouchY) > 20 {
            touchedNode?.mouseUp(NSEvent())
            touchedNode = nil
        }
        
        touchedNode?.mouseDragged(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        
        // Gracefully slow down scroll depending on scrollSpeed
        if !isUsingScrollBar {
            decelerateScroller(fromTouchLocationY: location.y)
        }
        
        // Scroll Bar
        isUsingScrollBar = false
        
        // Touch Nodes
        touchedNode?.mouseUp(theEvent)
        touchedNode = nil
    }
    
    // Scroller
    
    private func moveScroller(currentTouchY currentTouch: CGFloat) {
        // newPosition = position for scroller to move to
        let newPosition: CGFloat = lastScrollY + currentTouch - lastTouchY
        
        moveScrollerTo(newPosition)
        
        updateScrollBarPosition()
    }
    
    private func moveScrollerTo(positionY: CGFloat) {
        var newTopPosition: CGFloat = positionY
        var newBottomPosition: CGFloat = newTopPosition - getContentHeight()
        let topOfScreen = getTopOfScreen()
        let bottomOfScreen = getBottomOfScreen()
        
        // If moving content out of area - slow down scrolling drastically
        if newTopPosition < topOfScreen {
            let distanceFromTop: CGFloat = divideDistance(topOfScreen - newTopPosition)
            newTopPosition = topOfScreen - distanceFromTop
        } else if newBottomPosition > bottomOfScreen {
            let distanceFromBottom: CGFloat = divideDistance(newBottomPosition - bottomOfScreen)
            newBottomPosition = bottomOfScreen + distanceFromBottom
            newTopPosition = newBottomPosition + getContentHeight()
        }
        
        // Move scroller
        scroller.runAction(SKAction.moveToY(newTopPosition, duration: 0.05))
    }
    
    private func calculateScrollSpeed(locationY: CGFloat) {
        // Calculate touchesMoved speed and prime lastMovedLocation for next call
        let currentTime: Double = CACurrentMediaTime()
        let dt: Double = currentTime - lastMovedTime
        
        let calculatedSpeed = (locationY - lastMoveLocation.y) / CGFloat(dt / 0.017)
        scrollSpeed = min(calculatedSpeed, maxScrollSpeed)
        
        lastMovedTime = currentTime
    }
    
    private func decelerateScroller(fromTouchLocationY locationY: CGFloat) {
        // calculate amount to move after touch end quadratically to get right effect. Multiplier maintains direction through squaring.
        
        let multiplier: CGFloat = scrollSpeed < 0 ? -1 : 1
        var moveY: CGFloat = scrollSpeed * scrollSpeed / 3 * multiplier
        var duration: Double = Double(abs(scrollSpeed)) / 30 // calculate how long take to move depending on speed
        
        // Figure out where it will stop scrolling
        let newTopPosition = scroller.position.y + moveY
        let newBottomPosition = newTopPosition - contentHeight
        let topOfScreen = getTopOfScreen()
        let bottomOfScreen = getBottomOfScreen()
        
        // If will pass the end - stop it at the end
        // If is already scrolled past end - snap back to end
        var didChangeMoveY: Bool = false
        let prevMoveY = moveY
        
        if newTopPosition < topOfScreen {
            moveY = topOfScreen - scroller.position.y
            didChangeMoveY = true
        } else if newBottomPosition > bottomOfScreen {
            moveY = bottomOfScreen - getBottomContentPosition()
            didChangeMoveY = true
        }
        
        if didChangeMoveY {
            if scroller.position.y < topOfScreen || scroller.position.y - contentHeight > bottomOfScreen {
                duration = 0.5
            } else {
                duration *= Double(moveY / prevMoveY)
            }
        }
        
        // Run graceful deceleration and reset scroll speed
        scroller.removeAllActions()
        runDececlerateScrollerAction(moveY, duration: duration)
        
        scrollSpeed = 0
    }
    
    private func runDececlerateScrollerAction(moveY: CGFloat, duration: Double) {
        let stacks = 50 // smoothness (higher = smoother)
        var actions = [SKAction]()
        var updateScrollBarActions = [SKAction]()
        for i in 0..<stacks {
            let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: moveY / CGFloat(stacks)), duration: duration * Double(i) / Double(stacks))
            actions.append(moveAction)
            
            // Scroll Bar
            updateScrollBarActions.append(SKAction.runBlock(updateScrollBarPosition))
            updateScrollBarActions.append(SKAction.waitForDuration(duration / Double(stacks)))
        }
        scroller.runAction(SKAction.group(actions))
        self.runAction(SKAction.sequence(updateScrollBarActions))
    }
    
    private func divideDistance(distance: CGFloat) -> CGFloat {
        // Equation to limit scrolling past edge
        return pow(distance,4/5)
    }
    
    private func updateScrollerPosition(scrollBarY scrollBarY: CGFloat? = nil) {
        // Update scroller position based on scroll bar
        let scrollBarY = scrollBarY ?? scrollBar.position.y
        
        let scrollBarPosition: CGFloat = self.size.height / 2 - scrollBarY
        let scrollBarRatio: CGFloat = scrollBarPosition / self.size.height
        let scrollerPosition: CGFloat = getTopOfScreen() + getContentHeight() * scrollBarRatio
        scroller.runAction(SKAction.moveToY(scrollerPosition, duration: 0.05))
    }
    
}


