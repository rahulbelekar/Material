//
// Copyright (C) 2015 - 2016 CosmicMind, Inc. <http://cosmicmind.io>. All rights reserved. 
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program located at the root of the software package
// in a file called LICENSE.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

public protocol TextFieldDelegate : UITextFieldDelegate {}

public class TextField : UITextField {
	/// The bottom border layer.
	public private(set) lazy var bottomBorderLayer: CAShapeLayer = CAShapeLayer()
	
	/**
	This property is the same as clipsToBounds. It crops any of the view's
	contents from bleeding past the view's frame. If an image is set using
	the image property, then this value does not need to be set, since the
	visualLayer's maskToBounds is set to true by default.
	*/
	public var masksToBounds: Bool {
		get {
			return layer.masksToBounds
		}
		set(value) {
			layer.masksToBounds = value
		}
	}
	
	/// A property that accesses the backing layer's backgroundColor.
	public override var backgroundColor: UIColor? {
		didSet {
			layer.backgroundColor = backgroundColor?.CGColor
		}
	}
	
	/// A property that accesses the layer.frame.origin.x property.
	public var x: CGFloat {
		get {
			return layer.frame.origin.x
		}
		set(value) {
			layer.frame.origin.x = value
		}
	}
	
	/// A property that accesses the layer.frame.origin.y property.
	public var y: CGFloat {
		get {
			return layer.frame.origin.y
		}
		set(value) {
			layer.frame.origin.y = value
		}
	}
	
	/**
	A property that accesses the layer.frame.origin.width property.
	When setting this property in conjunction with the shape property having a
	value that is not .None, the height will be adjusted to maintain the correct
	shape.
	*/
	public var width: CGFloat {
		get {
			return layer.frame.size.width
		}
		set(value) {
			layer.frame.size.width = value
			if .None != shape {
				layer.frame.size.height = value
			}
		}
	}
	
	/**
	A property that accesses the layer.frame.origin.height property.
	When setting this property in conjunction with the shape property having a
	value that is not .None, the width will be adjusted to maintain the correct
	shape.
	*/
	public var height: CGFloat {
		get {
			return layer.frame.size.height
		}
		set(value) {
			layer.frame.size.height = value
			if .None != shape {
				layer.frame.size.width = value
			}
		}
	}
	
	/// A property that accesses the backing layer's shadowColor.
	public var shadowColor: UIColor? {
		didSet {
			layer.shadowColor = shadowColor?.CGColor
		}
	}
	
	/// A property that accesses the backing layer's shadowOffset.
	public var shadowOffset: CGSize {
		get {
			return layer.shadowOffset
		}
		set(value) {
			layer.shadowOffset = value
		}
	}
	
	/// A property that accesses the backing layer's shadowOpacity.
	public var shadowOpacity: Float {
		get {
			return layer.shadowOpacity
		}
		set(value) {
			layer.shadowOpacity = value
		}
	}
	
	/// A property that accesses the backing layer's shadowRadius.
	public var shadowRadius: CGFloat {
		get {
			return layer.shadowRadius
		}
		set(value) {
			layer.shadowRadius = value
		}
	}
	
	/**
	A property that sets the shadowOffset, shadowOpacity, and shadowRadius
	for the backing layer. This is the preferred method of setting depth
	in order to maintain consitency across UI objects.
	*/
	public var depth: MaterialDepth {
		didSet {
			let value: MaterialDepthType = MaterialDepthToValue(depth)
			shadowOffset = value.offset
			shadowOpacity = value.opacity
			shadowRadius = value.radius
		}
	}
	
	/**
	A property that sets the cornerRadius of the backing layer. If the shape
	property has a value of .Circle when the cornerRadius is set, it will
	become .None, as it no longer maintains its circle shape.
	*/
	public var cornerRadius: MaterialRadius {
		didSet {
			if let v: MaterialRadius = cornerRadius {
				layer.cornerRadius = MaterialRadiusToValue(v)
				if .Circle == shape {
					shape = .None
				}
			}
		}
	}
	
	/**
	A property that manages the overall shape for the object. If either the
	width or height property is set, the other will be automatically adjusted
	to maintain the shape of the object.
	*/
	public var shape: MaterialShape {
		didSet {
			if .None != shape {
				if width < height {
					frame.size.width = height
				} else {
					frame.size.height = width
				}
			}
		}
	}
	
	/**
	A property that accesses the layer.borderWith using a MaterialBorder
	enum preset.
	*/
	public var borderWidth: MaterialBorder {
		didSet {
			layer.borderWidth = MaterialBorderToValue(borderWidth)
		}
	}
	
	/// A property that accesses the layer.borderColor property.
	public var borderColor: UIColor? {
		didSet {
			layer.borderColor = borderColor?.CGColor
		}
	}
	
	/// A property that accesses the layer.position property.
	public var position: CGPoint {
		get {
			return layer.position
		}
		set(value) {
			layer.position = value
		}
	}
	
	/// A property that accesses the layer.zPosition property.
	public var zPosition: CGFloat {
		get {
			return layer.zPosition
		}
		set(value) {
			layer.zPosition = value
		}
	}
	
	/**
	The title UILabel that is displayed when there is text. The
	titleLabel text value is updated with the placeholder text 
	value before being displayed.
	*/
	public var titleLabel: UILabel? {
		didSet {
			prepareTitleLabel()
		}
	}
	
	/// The color of the titleLabel text when the textField is not active.
	public var titleLabelTextColor: UIColor? {
		didSet {
			titleLabel?.textColor = titleLabelTextColor
			bottomBorderLayer.backgroundColor = titleLabelTextColor?.CGColor
		}
	}
	
	/// The color of the titleLabel text when the textField is active.
	public var titleLabelActiveTextColor: UIColor?
	
	/**
	:name:	detailLabelActiveTextColor
	*/
	public var detailLabelActiveTextColor: UIColor?
	
	/**
	The detail UILabel that is displayed when the detailLabelHidden property
	is set to false.
	*/
	public var detailLabel: UILabel? {
		didSet {
			prepareDetailLabel()
		}
	}
	
	/**
	:name:	detailLabelHidden
	*/
	public var detailLabelHidden: Bool = false {
		didSet {
			if detailLabelHidden {
				bottomBorderLayer.backgroundColor = editing ? titleLabelActiveTextColor?.CGColor : titleLabelTextColor?.CGColor
				hideDetailLabel()
			} else {
				detailLabel?.textColor = detailLabelActiveTextColor
				bottomBorderLayer.backgroundColor = detailLabelActiveTextColor?.CGColor
				showDetailLabel()
			}
		}
	}
	
	/**
	:name:	init
	*/
	public required init?(coder aDecoder: NSCoder) {
		depth = .None
		shape = .None
		cornerRadius = .None
		borderWidth = .None
		super.init(coder: aDecoder)
		prepareView()
	}
	
	/**
	:name:	init
	*/
	public override init(frame: CGRect) {
		depth = .None
		shape = .None
		cornerRadius = .None
		borderWidth = .None
		super.init(frame: frame)
		prepareView()
	}
	
	/**
	:name:	init
	*/
	public convenience init() {
		self.init(frame: CGRectNull)
	}
	
	/// Overriding the layout callback for sublayers.
	public override func layoutSublayersOfLayer(layer: CALayer) {
		super.layoutSublayersOfLayer(layer)
		if self.layer == layer {
			bottomBorderLayer.frame = CGRectMake(0, bounds.height + 8, bounds.width, 1)
			layoutShape()
		}
	}
	
	/**
	A method that accepts CAAnimation objects and executes them on the
	view's backing layer.
	- Parameter animation: A CAAnimation instance.
	*/
	public func animate(animation: CAAnimation) {
		animation.delegate = self
		if let a: CABasicAnimation = animation as? CABasicAnimation {
			a.fromValue = (nil == layer.presentationLayer() ? layer : layer.presentationLayer() as! CALayer).valueForKeyPath(a.keyPath!)
		}
		if let a: CAPropertyAnimation = animation as? CAPropertyAnimation {
			layer.addAnimation(a, forKey: a.keyPath!)
		} else if let a: CAAnimationGroup = animation as? CAAnimationGroup {
			layer.addAnimation(a, forKey: nil)
		} else if let a: CATransition = animation as? CATransition {
			layer.addAnimation(a, forKey: kCATransition)
		}
	}
	
	/**
	A delegation method that is executed when the backing layer starts
	running an animation.
	- Parameter anim: The currently running CAAnimation instance.
	*/
	public override func animationDidStart(anim: CAAnimation) {
		(delegate as? MaterialAnimationDelegate)?.materialAnimationDidStart?(anim)
	}
	
	/**
	A delegation method that is executed when the backing layer stops
	running an animation.
	- Parameter anim: The CAAnimation instance that stopped running.
	- Parameter flag: A boolean that indicates if the animation stopped
	because it was completed or interrupted. True if completed, false
	if interrupted.
	*/
	public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
		if let a: CAPropertyAnimation = anim as? CAPropertyAnimation {
			if let b: CABasicAnimation = a as? CABasicAnimation {
				MaterialAnimation.animationDisabled {
					self.layer.setValue(nil == b.toValue ? b.byValue : b.toValue, forKey: b.keyPath!)
				}
			}
			(delegate as? MaterialAnimationDelegate)?.materialAnimationDidStop?(anim, finished: flag)
			layer.removeAnimationForKey(a.keyPath!)
		} else if let a: CAAnimationGroup = anim as? CAAnimationGroup {
			for x in a.animations! {
				animationDidStop(x, finished: true)
			}
		}
	}
	
	/**
	Prepares the view instance when intialized. When subclassing,
	it is recommended to override the prepareView method
	to initialize property values and other setup operations.
	The super.prepareView method should always be called immediately
	when subclassing.
	*/
	public func prepareView() {
		backgroundColor = MaterialColor.white
		shadowColor = MaterialColor.black
		borderColor = MaterialColor.black
		masksToBounds = false
		prepareBottomBorderLayer()
	}
	
	/**
	:name:	textFieldDidBegin
	*/
	internal func textFieldDidBegin(textField: TextField) {
		titleLabel?.text = placeholder
		if 0 == text?.utf16.count {
			titleLabel?.textColor = titleLabelTextColor
			bottomBorderLayer.backgroundColor = titleLabelTextColor?.CGColor
			detailLabelHidden = true
		} else {
			titleLabel?.textColor = titleLabelActiveTextColor
			bottomBorderLayer.backgroundColor = detailLabelHidden ? titleLabelActiveTextColor?.CGColor : detailLabelActiveTextColor?.CGColor
		}
	}
	
	/**
	:name:	textFieldDidChange
	*/
	internal func textFieldDidChange(textField: TextField) {
		if 0 < text?.utf16.count {
			showTitleLabel()
			titleLabel?.textColor = titleLabelActiveTextColor
			bottomBorderLayer.backgroundColor = detailLabelHidden ? titleLabelActiveTextColor?.CGColor : detailLabelActiveTextColor?.CGColor
		} else if 0 == text?.utf16.count {
			hideTitleLabel()
			detailLabelHidden = true
		}
	}
	
	/**
	:name:	textFieldDidEnd
	*/
	internal func textFieldDidEnd(textField: TextField) {
		if 0 < text?.utf16.count {
			showTitleLabel()
		} else if 0 == text?.utf16.count {
			hideTitleLabel()
		}
		titleLabel?.textColor = titleLabelTextColor
		bottomBorderLayer.backgroundColor = detailLabelHidden ? titleLabelTextColor?.CGColor : detailLabelActiveTextColor?.CGColor
	}
	
	/// Manages the layout for the shape of the view instance.
	internal func layoutShape() {
		if .Circle == shape {
			layer.cornerRadius = width / 2
		}
	}
	
	/**
	:name:	prepareTitleLabel
	*/
	private func prepareTitleLabel() {
		if let v: UILabel = titleLabel {
			MaterialAnimation.animationDisabled {
				v.hidden = true
				v.alpha = 0
			}
			titleLabel?.text = placeholder
			let h: CGFloat = v.font.pointSize
			v.frame = CGRectMake(0, -h, bounds.width, h)
			addSubview(v)
			addTarget(self, action: "textFieldDidBegin:", forControlEvents: .EditingDidBegin)
			addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
			addTarget(self, action: "textFieldDidEnd:", forControlEvents: .EditingDidEnd)
		}
	}
	
	/**
	:name:	prepareDetailLabel
	*/
	private func prepareDetailLabel() {
		if let v: UILabel = detailLabel {
			MaterialAnimation.animationDisabled {
				v.hidden = true
				v.alpha = 0
			}
			let h: CGFloat = v.font.pointSize
			v.frame = CGRectMake(0, h + 12, bounds.width, h)
			addSubview(v)
			addTarget(self, action: "textFieldDidBegin:", forControlEvents: .EditingDidBegin)
			addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
			addTarget(self, action: "textFieldDidEnd:", forControlEvents: .EditingDidEnd)
		}
	}
	
	/**
	:name:	prepareBottomBorderLayer
	*/
	private func prepareBottomBorderLayer() {
		layer.addSublayer(bottomBorderLayer)
	}
	
	/**
	:name:	showTitleLabel
	*/
	private func showTitleLabel() {
		if let v: UILabel = titleLabel {
			v.frame.size.height = v.font.pointSize
			v.hidden = false
			UIView.animateWithDuration(0.25, animations: {
				v.alpha = 1
				v.frame.origin.y = -v.frame.height - 4
			})
		}
	}
	
	/**
	:name:	hideTitleLabel
	*/
	private func hideTitleLabel() {
		if let v: UILabel = titleLabel {
			UIView.animateWithDuration(0.25, animations: {
				v.alpha = 0
				v.frame.origin.y = -v.frame.height
			}) { _ in
				v.hidden = true
			}
		}
	}
	
	/**
	:name:	showDetailLabel
	*/
	private func showDetailLabel() {
		if let v: UILabel = detailLabel {
			v.frame.size.height = v.font.pointSize
			v.hidden = false
			UIView.animateWithDuration(0.25, animations: {
				v.alpha = 1
				v.frame.origin.y = v.frame.height + 28
			})
		}
	}
	
	/**
	:name:	hideDetailLabel
	*/
	private func hideDetailLabel() {
		if let v: UILabel = detailLabel {
			UIView.animateWithDuration(0.25, animations: {
				v.alpha = 0
				v.frame.origin.y = v.frame.height + 20
			}) { _ in
				v.hidden = true
			}
		}
	}
}