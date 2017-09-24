//
//  ViewController.swift
//  Minimal
//
//  Created by Luka Kerr on 23/9/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa
import Foundation

class RegexViewController: NSViewController, NSWindowDelegate {
	
	@IBOutlet var textOutput: NSTextView!
	@IBOutlet weak var regexInput: NSTextField!
	@IBOutlet weak var invalidLabel: NSTextField!
	@IBOutlet weak var topHalf: NSVisualEffectView!
	@IBOutlet weak var bottomHalf: NSVisualEffectView!
	@IBOutlet weak var referenceButton: NSButton!
	
	@objc dynamic var textInput: String = "" {
		didSet {
			let attr = setRegexHighlight(regex: regexInput.stringValue, text: self.textInput, event: nil)
			setOutputHighlight(attr: attr)
		}
	}
	
	// Needed because NSTextView only has an "Attributed String" binding
	@objc private static let keyPathsForValuesAffectingAttributedTextInput: Set<String> = [
		#keyPath(textInput)
	]
	
	@objc private var attributedTextInput: NSAttributedString {
		get { return NSAttributedString(string: self.textInput) }
		set { self.textInput = newValue.string }
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
			self.keyDown(with: aEvent)
			return aEvent
		}
		textOutput.font = NSFont(name: "Monaco", size: 15)
		textOutput.textColor = NSColor.white
	}
	
	func matches(for regex: String, in text: String) -> [NSTextCheckingResult] {
		do {
			invalidLabel.stringValue = ""
			let regex = try NSRegularExpression(pattern: regex, options: [])
			let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.characters.count))
			return results
		} catch _ {
			if (regex.count > 0) {
				invalidLabel.stringValue = "Expression is invalid"
			}
			return []
		}
	}
	
	func setOutputHighlight(attr: NSMutableAttributedString) {
		textOutput.textStorage?.mutableString.setString("")
		textOutput.textStorage?.append(attr)
		textOutput.font = NSFont(name: "Monaco", size: 15)
		textOutput.textColor = NSColor.white
	}
	
	func setRegexHighlight(regex regexInput: String?, text textInput: String?, event: NSEvent?) -> NSMutableAttributedString {
		let topBox = regexInput
		let bottomBox = textInput
		
		if let topBox = topBox, let bottomBox = bottomBox {
			var foundMatches : [NSTextCheckingResult] = []
			// If backspace, drop backspace character from regex
			// Otherwise get topBox regex and current key character
			if let event = event {
				if event.charactersIgnoringModifiers == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
					foundMatches = matches(for: String(topBox.characters.dropLast()), in: bottomBox)
				} else {
					foundMatches = matches(for: topBox + String(describing: event.characters!), in: bottomBox)
				}
			} else {
				foundMatches = matches(for: topBox, in: bottomBox)
			}
			
			
			let attribute = NSMutableAttributedString(string: bottomBox)
			let attributeLength = attribute.string.characters.count
			
			var newColor = false
			
			for match in foundMatches {
				var range = match.range(at: 0)
				var index = bottomBox.index(bottomBox.startIndex, offsetBy: range.location + range.length)
				var outputStr = String(bottomBox[..<index])
				index = bottomBox.index(bottomBox.startIndex, offsetBy: range.location)
				outputStr = String(outputStr.suffix(from: index))
				let matchLength = outputStr.count
				
				if (newColor) {
					attribute.addAttribute(NSAttributedStringKey.backgroundColor, value: NSColor(red: 0.60, green: 0.26, blue: 0.77, alpha: 1), range: NSRange(location: range.location, length: matchLength))
					range = NSMakeRange(range.location + range.length, attributeLength - (range.location + range.length))
					newColor = false
				} else {
					attribute.addAttribute(NSAttributedStringKey.backgroundColor, value: NSColor(red: 0.25, green: 0.51, blue: 0.77, alpha: 1), range: NSRange(location: range.location, length: matchLength))
					range = NSMakeRange(range.location + range.length, attributeLength - (range.location + range.length))
					newColor = true
				}
			}
			return attribute
		}
		let empty = NSMutableAttributedString(string: "")
		return empty
	}
	
	override func keyDown(with event: NSEvent) {
		let attr = setRegexHighlight(regex: regexInput.stringValue, text: textOutput.textStorage?.string, event: event)
		setOutputHighlight(attr: attr)
	}
	
	@IBAction func referenceButtonClicked(_ sender: NSButton) {
		if let splitViewController = self.parent as? NSSplitViewController {
			let splitViewItem = splitViewController.splitViewItems
			
			splitViewItem.last!.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
			
			splitViewItem.last!.animator().isCollapsed = !splitViewItem.last!.isCollapsed
		}
	}

	override var representedObject: Any? {
		didSet {
		
		}
	}


}

