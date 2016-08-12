//
//  AttributedLabel.swift
//  AttributedLabel
//
//  Created by Kyohei Ito on 2015/07/17.
//  Copyright © 2015年 Kyohei Ito. All rights reserved.
//

import UIKit

class AttributedLabel: UILabel {
    enum ContentAlignment: Int {
        case Center
        case Top
        case Bottom
        case Left
        case Right
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight
        
        func alignOffset(viewSize viewSize: CGSize, containerSize: CGSize) -> CGPoint {
            let xMargin = viewSize.width - containerSize.width
            let yMargin = viewSize.height - containerSize.height
            
            switch self {
            case Center:
                return CGPoint(x: max(xMargin / 2, 0), y: max(yMargin / 2, 0))
            case Top:
                return CGPoint(x: max(xMargin / 2, 0), y: 0)
            case Bottom:
                return CGPoint(x: max(xMargin / 2, 0), y: max(yMargin, 0))
            case Left:
                return CGPoint(x: 0, y: max(yMargin / 2, 0))
            case Right:
                return CGPoint(x: max(xMargin, 0), y: max(yMargin / 2, 0))
            case TopLeft:
                return CGPoint(x: 0, y: 0)
            case TopRight:
                return CGPoint(x: max(xMargin, 0), y: 0)
            case BottomLeft:
                return CGPoint(x: 0, y: max(yMargin, 0))
            case BottomRight:
                return CGPoint(x: max(xMargin, 0), y: max(yMargin, 0))
            }
        }
    }
    
    override var frame: CGRect {
        didSet {
            self.textContainer.size = self.frame.size
        }
    }
    
    /// default is `0`.
    override var numberOfLines: Int {
        didSet {
            self.textContainer.maximumNumberOfLines = self.numberOfLines
            setNeedsDisplay()
        }
    }
    /// default is `Left`.
    var contentAlignment: ContentAlignment = .Left {
        didSet { setNeedsDisplay() }
    }
    /// `lineFragmentPadding` of `NSTextContainer`. default is `0`.
    var padding: CGFloat = 0 {
        didSet {
            self.textContainer.lineFragmentPadding = self.padding
            setNeedsDisplay()
        }
    }

    /// default is `ByTruncatingTail`.
    override var lineBreakMode: NSLineBreakMode  {
        didSet {
            self.textContainer.lineBreakMode = self.lineBreakMode
            setNeedsDisplay()
        }
    }


    
    var textStorage = NSTextStorage()
    var textContainer = NSTextContainer()
    var layoutManager = NSLayoutManager()
    
    /// default is nil.
    override var attributedText: NSAttributedString? {
        didSet {
            if let attributedString = self.attributedText {
                self.textStorage.setAttributedString(attributedString)
            }
            
            setNeedsDisplay()
        }
    }
    
    private func setup() {
        opaque = true
        contentMode = .Redraw
        self.textContainer = self.textContainer(self.bounds.size)
        self.layoutManager = self.layoutManager(self.textContainer)
        self.textStorage = NSTextStorage()
        self.textStorage.addLayoutManager(self.layoutManager)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func setNeedsDisplay() {
        if NSThread.isMainThread() {
            super.setNeedsDisplay()
        }
    }
    
    override func drawTextInRect(rect: CGRect) {
        guard self.attributedText != nil else { return }
        
        let range = NSRange(location: 0, length: textStorage.length)
        
        let frame = layoutManager.usedRectForTextContainer(textContainer)
        let point = contentAlignment.alignOffset(viewSize: rect.size, containerSize: CGRectIntegral(frame).size)
        

        layoutManager.drawBackgroundForGlyphRange(range, atPoint: point)
        layoutManager.drawGlyphsForGlyphRange(range, atPoint: point)

    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        guard self.attributedText != nil else {
            return super.sizeThatFits(size)
        }
        
        self.textContainer.size = size
        let frame = layoutManager.usedRectForTextContainer(textContainer)
        return CGRectIntegral(frame).size
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        frame.size = sizeThatFits(CGSize(width: bounds.width, height: CGFloat.max))
    }
    
    private func textContainer(size: CGSize) -> NSTextContainer {
        let container = NSTextContainer(size: size)
        container.lineBreakMode = lineBreakMode
        container.lineFragmentPadding = padding
        container.maximumNumberOfLines = numberOfLines
        return container
    }
    
    private func layoutManager(container: NSTextContainer) -> NSLayoutManager {
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(container)
        return layoutManager
    }
    
}
