//
//  Controller.swift
//  HearthAssets
//
//  Created by Benjamin Michotte on 7/02/17.
//  Copyright © 2017 Benjamin Michotte. All rights reserved.
//

import Foundation
import Cocoa
import HearthAssets

class Controller: NSViewController {

    @IBOutlet weak var localeChooser: NSPopUpButton!
    @IBOutlet weak var cardChooser: NSPopUpButton!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var debug: NSButton!

    var locale = "enUS"
    var cards: [String: [String: Any]] = [:]

    let assetGenerator = HearthAssets()

    override func viewWillAppear() {
        super.viewWillAppear()
        load()
    }

    @IBAction func changeLocale(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton,
              let item = popup.selectedItem else {
            cardChooser.isEnabled = false
            return
        }

        print("Change locale : \(item.title)")
        locale = item.title
        load()
    }

    private func load() {
        cardChooser.menu?.removeAllItems()

        guard let jsonFile = Bundle.main.path(forResource: "cardsDB.\(locale)", ofType: "json") else {
            print("! cards.\(locale).json")
            cardChooser.isEnabled = false
            return
        }
        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonFile)) else {
            print("\(jsonFile) is not a valid file")
            cardChooser.isEnabled = false
            return
        }
        guard let _jsonCards = try? JSONSerialization
                .jsonObject(with: jsonData, options: []) as? [[String: Any]],
              let jsonCards = _jsonCards else {
            print("\(jsonFile) is not a valid file")
            cardChooser.isEnabled = false
            return
        }

        cards.removeAll()
        for jsonCard: [String: Any] in jsonCards {
            guard let cardId = jsonCard["id"] as? String else {
                continue
            }
            guard let jsonSet = jsonCard["set"] as? String,
                  let set = CardSet(rawValue: jsonSet.lowercased()) else {
                continue
            }
            guard CardSet.allValues().contains(set) else {
                continue
            }
            guard let rarity = jsonCard["rarity"] as? String else {
                continue
            }

            cards[cardId] = jsonCard

            let name: String
            if let n = jsonCard["name"] as? String {
                name = "\(n) (\(cardId))"
            } else {
                name = cardId
            }
            let item = NSMenuItem(title: name,
                    action: nil,
                    keyEquivalent: "")
            item.representedObject = cardId
            cardChooser.menu?.addItem(item)
        }

        cardChooser.isEnabled = true
    }

    @IBAction func changeCard(_ sender: Any) {
        guard let popup = sender as? NSPopUpButton,
              let item = popup.selectedItem else {
            return
        }

        print("Change card : \(item.title) (\(item.representedObject))")

        guard let cardId = item.representedObject as? String,
              let card = cards[cardId] else {return}

        //let fontURL = Bundle.main.url(forResource: "1553", withExtension: "ttf")
        //CTFontManagerRegisterFontsForURL(fontURL! as CFURL, CTFontManagerScope.process, nil)

        assetGenerator.debug = debug.state == NSOnState
        assetGenerator.generate(card: card) { [weak self] (image, error) in
            if let error = error {
                print("\(error)")
            } else if let image = image {
                self?.imageView.image = image
            }
        }
    }
}
