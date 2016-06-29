//
//  HorizontalNodeStacker.swift
//  ScoreExtremeDemo
//
//  Created by Todd Sutter on 6/21/16.
//  Copyright © 2016 igroupcreative. All rights reserved.
//

import Foundation
import SpriteKit

class NodeOrganizer : SKSpriteNode {
    
    var onChangedSize: (Void -> Void)?
    
    private var rows: [[SKSpriteNode]] = [[SKSpriteNode]]()
    private var currentRowIndex: Int = 0
    
    private let headerNode: SKSpriteNode = SKSpriteNode()
    private let footerNode: SKSpriteNode = SKSpriteNode()
    
    private var width: CGFloat = 0 { didSet {
        didSetSize()
    }}
    private var height: CGFloat = 0 { didSet {
        didSetSize()
    }}
    override var size: CGSize { didSet {
        didSetSize()
    }}
    override var anchorPoint: CGPoint { didSet {
        // don't allow for changing of anchorPoint
        super.anchorPoint = CGPointMake(0.5,1)
        print("WARNING - Cannot change anchorPoint on NodeOrganizers\nanchorPoint set to \(self.anchorPoint)")
    }}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    convenience init() {
        self.init(width: 0, headerImage: nil, footerImage: nil)
    }
    
    convenience init(width: CGFloat) {
        self.init(width: width, headerImage: nil, footerImage: nil)
    }
    
    convenience init(headerImageName: String?, footerImageName: String?) {
        let headerImage: SKTexture? = headerImageName != nil ? SKTexture(imageNamed: headerImageName!) : nil
        let footerImage: SKTexture? = footerImageName != nil ? SKTexture(imageNamed: footerImageName!) : nil
        let width: CGFloat = max(headerImage?.size().width ?? 0, footerImage?.size().width ?? 0)
        self.init(width: width, headerImage: headerImage, footerImage: footerImage)
    }
    
    convenience init(width: CGFloat, headerImageName: String?, footerImageName: String?) {
        let headerImage: SKTexture? = headerImageName != nil ? SKTexture(imageNamed: headerImageName!) : nil
        let footerImage: SKTexture? = footerImageName != nil ? SKTexture(imageNamed: footerImageName!) : nil
        self.init(width: width, headerImage: headerImage, footerImage: footerImage)
    }
    
    convenience init(headerImage: SKTexture?, footerImage: SKTexture?) {
        let width: CGFloat = max(headerImage?.size().width ?? 0, footerImage?.size().width ?? 0)
        self.init(width: width, headerImage: headerImage, footerImage: footerImage)
    }
    
    init(width: CGFloat, headerImage: SKTexture?, footerImage: SKTexture?) {
        super.init(texture: nil, color: SKColor.clearColor(), size: CGSizeZero)
        
        super.anchorPoint = CGPointMake(0.5,1)
        
        headerNode.zPosition = 20
        headerNode.texture = headerImage
        headerNode.size = headerImage?.size() ?? CGSizeZero
        headerNode.anchorPoint.y = 1
        super.addChild(headerNode)
        
        footerNode.zPosition = 20
        footerNode.texture = footerImage
        footerNode.size = footerImage?.size() ?? CGSizeZero
        footerNode.anchorPoint.y = 0
        super.addChild(footerNode)
        
        self.width = width
        updateHeight()
    }
    
    // GETTERS AND SETTERS
    
    private func didSetSize() {
        // Lock size to self.width and self.height
        super.size = CGSizeMake(self.width, self.height)
        
        // set footer to bottom and notify that size changed
        footerNode.position.y = -self.height
        onChangedSize?()
    }
    
    func setOnChangedSizeAction(action: (Void -> Void)?) {
        self.onChangedSize = action
    }
    
    // ADD CHILDREN
    
    override func addChild(node: SKNode) {
        // append Node if SKSpriteNode
        // add other nodes but don't add to the organized structure
        if let sprite = node as? SKSpriteNode {
            self.appendNode(sprite)
        } else {
            print("WARNING - Only SKSpriteNodes will behave in NodeOrganizers")
            super.addChild(node)
        }
    }
    
    func addUnorganizedChild(node: SKNode) {
        super.addChild(node)
    }
    
    private func appendNode(node: SKSpriteNode) {
        // If appending a node that exceeds width - make a new row
        let rowWidth = getCurrentRowSize().width
        if rowWidth > 0 && rowWidth + node.size.width > self.width {
            currentRowIndex += 1
        }
        
        ensureCurrentRow()
        
        // position new node and update height
        node.anchorPoint = CGPointMake(0,1)
        node.position = getNextPosition()
        node.zPosition = 1
        super.addChild(node)
        
        rows[currentRowIndex].append(node)
        
        updateHeight()
    }
    
    func updateHeight() {
        // calculate and set height
        let lastRowPosition = getCurrentRowPosition()
        let lastRowHeight = getCurrentRowSize().height
        
        self.height = -lastRowPosition + lastRowHeight + footerNode.size.height
    }
    
    // HELPERS
    
    private func ensureCurrentRow() {
        // Make sure rows exist up to currentRow
        while currentRowIndex >= rows.count {
            rows.append([])
        }
    }
    
    private func getRowSize(index: Int) -> CGSize {
        if index >= rows.count {
            return CGSizeZero
        }
        
        // loop through nodes in row - return combined width and max height
        var rowSize = CGSizeZero
        for node in rows[index] {
            rowSize.width += node.size.width
            if node.size.height > rowSize.height {
                rowSize.height = node.size.height
            }
        }
        return rowSize
    }
    
    private func getCurrentRowSize() -> CGSize {
        return getRowSize(currentRowIndex)
    }
    
    private func getRowPosition(index: Int) -> CGFloat {
        // set start y to right below header node
        var y: CGFloat = -headerNode.size.height
        
        if index >= rows.count {
            return y
        }
        
        // return height of all rows leading up to current row
        for i in 0..<index {
            y -= getRowSize(i).height
        }
        return y
    }
    
    private func getCurrentRowPosition() -> CGFloat {
        return getRowPosition(currentRowIndex)
    }
    
    private func getNextPosition() -> CGPoint {
        // get row position and current row width to position next node
        let rowPosition = getCurrentRowPosition()
        let rowWidth = getCurrentRowSize().width
        return CGPointMake(-self.width / 2 + rowWidth, rowPosition)
        // note: anchorPoint.x always == 0.5 so -self.width / 2 gives left edge
    }
    
}