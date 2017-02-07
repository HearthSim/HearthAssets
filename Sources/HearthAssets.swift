//
//  AssetGenerator.swift
//  HearthAssets
//
//  Created by Benjamin Michotte on 7/02/17.
//  Copyright © 2017 Benjamin Michotte. All rights reserved.
//

import Foundation

public class HearthAssets {

    public enum AssetError: Error {

        case invalidCardType,
             invalidCardPlayerClass,
             invalidCardRarity,
             invalidCardSet,
             invalidCardId,
             invalidTexture,
             invalidCardback,
             invalidCardName

        case invalidGraphicsContext

        case fontNotFound(name: String)
    }

    let artUrl = "https://art.hearthstonejson.com/v1/512x/"

    var cardBack: String?
    var rarity: String?
    var bgLogo: String?
    var assets: [String: NSImage] = [:]
    let imageSize = 764.0

    private let belweBdBT = "Belwe Bd BT"

    public var debug = false
    public var locale = "enUS"

    public init() {
    }

    public func generate(card: [String: Any],
                         completed: @escaping ((NSImage?, AssetError?) -> Void)) {

        guard let type = card["type"] as? String else {
            completed(nil, AssetError.invalidCardType)
            return
        }
        guard let playerClass = card["playerClass"] as? String else {
            completed(nil, AssetError.invalidCardPlayerClass)
            return
        }
        guard let rarity = card["rarity"] as? String else {
            completed(nil, AssetError.invalidCardRarity)
            return
        }
        guard let set = card["set"] as? String else {
            completed(nil, AssetError.invalidCardSet)
            return
        }

        let s = imageSize / 764.0

        self.cardBack = type.sub(start: 0, end: 1).lowercased()
                + playerClass.sub(start: 0, end: 1)
                + playerClass.sub(start: 1, end: playerClass.characters.count)
                .lowercased()
        var loadList: [String] = [cardBack!, "gem"]

        if type == "MINION" {
            loadList.append("attack")
            loadList.append("health")
            loadList.append("title")

            if rarity == "LEGENDARY" {
                loadList.append("dragon")
            }

            if rarity != "FREE" && !(rarity == "COMMON" && set == "CORE") {
                self.rarity = "rarity-\(rarity.lowercased())"
                loadList.append(self.rarity!)
            }
        }

        if type == "SPELL" {
            loadList.append("attack")
            loadList.append("title-spell")

            if rarity != "FREE" && !(rarity == "COMMON" && set == "CORE") {
                self.rarity = "spell-rarity-\(rarity.lowercased())"
                loadList.append(self.rarity!)
            }
        }

        if type == "WEAPON" {
            loadList.append("swords")
            loadList.append("shield")
            loadList.append("title-weapon")

            if rarity != "FREE" && !(rarity == "COMMON" && set == "CORE") {
                self.rarity = "weapon-rarity-\(rarity.lowercased())"
                loadList.append(self.rarity!)
            }
        }

        if ["BRM", "GVG", "LOE", "NAX", "TGT", "OG", "GANGS"].contains(set) {
            self.bgLogo = "bg-\(set.lowercased())"
        } else {
            self.bgLogo = "bg-cl"
        }
        if type == "SPELL" {
            self.bgLogo = "spell-\(self.bgLogo!)"
        } else if type == "WEAPON" {
            self.bgLogo = "w-\(self.bgLogo!)"
        }

        loadList.append(self.bgLogo!)

        if let _ = card["race"] as? String {
            loadList.append("race")
        }

        if let texture = card["id"] as? String, set != "CHEAT" {
            if s <= 0.5 {
                loadList.append("h:\(texture)")
            } else {
                loadList.append("u:\(texture)")
            }
        }

        print("Assets prepared, now loading")
        fetchAssets(loadAssets: loadList) { [weak self] in
            print("Assets loaded for: \(card["name"])")

            do {
                let image = try self?.draw(card: card)
                completed(image, nil)
            } catch {
                completed(nil, error as? AssetError)
            }
        }
    }

    private func draw(card: [String: Any]) throws -> NSImage? {
        guard let texture = card["id"] as? String else {
            throw AssetError.invalidCardId
        }
        guard let type = card["type"] as? String else {
            throw AssetError.invalidCardType
        }
        guard let set = card["set"] as? String else {
            throw AssetError.invalidCardSet
        }

        let width = imageSize
        let height = round(imageSize * 1.4397905759)
        let imgRect = NSRect(x: 0.0, y: 0.0, width: width, height: height)
        let image = NSImage(size: imgRect.size)
        image.lockFocus()

        guard let ctx = NSGraphicsContext.current() else {
            throw AssetError.invalidGraphicsContext
        }

        let s: CGFloat = CGFloat(imageSize) / 764.0

        guard let t = assets[texture] else {
            throw AssetError.invalidTexture
        }

        ctx.saveGraphicsState()

        if type == "MINION" {
            let path = NSBezierPath(ovalIn: NSRect(x: 180 * s,
                    y: 425 * s,
                    width: 430 * s,
                    height: 590 * s))
            path.addClip()
            NSColor.red.setFill()
            path.fill()

            t.draw(in: NSRect(x: 100 * s, y: 425 * s, width: 590 * s, height: 590 * s),
                    from: NSRect(x: 0, y: 0, width: t.size.width, height: t.size.height),
                    operation: .sourceOver,
                    fraction: 1.0)

        } else if type == "SPELL" {
            let path = NSBezierPath(rect: NSRect(x: 125 * s,
                    y: 500 * s,
                    width: 529 * s,
                    height: 434 * s))
            path.addClip()
            NSColor.red.setFill()
            path.fill()

            t.draw(in: NSRect(x: 125 * s, y: 450 * s, width: 529 * s, height: 529 * s),
                    from: NSRect(x: 0, y: 0, width: t.size.width, height: t.size.height),
                    operation: .sourceOver,
                    fraction: 1.0)

        } else if type == "WEAPON" {
            let path = NSBezierPath(ovalIn: NSRect(x: 150 * s,
                    y: 480 * s,
                    width: 476 * s,
                    height: 468 * s))
            path.addClip()
            NSColor.red.setFill()
            path.fill()

            t.draw(in: NSRect(x: 150 * s, y: 495 * s, width: 476 * s, height: 476 * s),
                    from: NSRect(x: 0, y: 0, width: t.size.width, height: t.size.height),
                    operation: .sourceOver,
                    fraction: 1.0)
        }

        ctx.restoreGraphicsState()

        guard let cardBack = self.cardBack, let c = assets[cardBack] else {
            throw AssetError.invalidCardback
        }
        c.draw(in: NSRect(x: 0, y: 0, width: imgRect.size.width, height: imgRect.size.height),
                from: NSRect(x: 0, y: 0, width: 764, height: 1100),
                operation: .sourceOver,
                fraction: 1.0)

        if let gem = assets["gem"] {
            gem.draw(in: NSRect(x: 24 * s, y: (1100 - 248) * s, width: 182 * s, height: 180 * s),
                    from: NSRect(x: 0, y: 0, width: 182, height: 180),
                    operation: .sourceOver,
                    fraction: 1.0)
        }

        if type == "MINION" {
            if let rarity = self.rarity, let ra = assets[rarity] {
                ra.draw(in: NSRect(x: 326 * s, y: 348 * s, width: 146 * s, height: 146 * s),
                        from: NSRect(x: 0, y: 0, width: 146, height: 146),
                        operation: .sourceOver,
                        fraction: 1.0)
            }

            if let image = assets["title"] {
                image.draw(in: NSRect(x: 94 * s, y: 415 * s, width: 608 * s, height: 144 * s),
                        from: NSRect(x: 0, y: 0, width: 608, height: 144),
                        operation: .sourceOver,
                        fraction: 1.0)
            }
            if let _ = card["race"] as? String, let image = assets["race"] {
                image.draw(in: NSRect(x: 125 * s, y: 50 * s, width: 529 * s, height: 106 * s),
                        from: NSRect(x: 0, y: 0, width: 529, height: 106),
                        operation: .sourceOver,
                        fraction: 1.0)
            }
            if let image = assets["attack"] {
                image.draw(in: NSRect(x: 0 * s, y: 0 * s, width: 214 * s, height: 238 * s),
                        from: NSRect(x: 0, y: 0, width: 214, height: 238),
                        operation: .sourceOver,
                        fraction: 1.0)
            }
            if let image = assets["health"] {
                image.draw(in: NSRect(x: 575 * s, y: 0 * s, width: 167 * s, height: 218 * s),
                        from: NSRect(x: 0, y: 0, width: 167, height: 218),
                        operation: .sourceOver,
                        fraction: 1.0)
            }

            if let rarity = card["rarity"] as? String, let image = assets["dragon"],
               rarity == "LEGENDARY" {
                image.draw(in: NSRect(x: 196 * s, y: 685 * s, width: 569 * s, height: 417 * s),
                        from: NSRect(x: 0, y: 0, width: 569, height: 417),
                        operation: .sourceOver,
                        fraction: 1.0)
            }
        } else if type == "SPELL" {
            if let rarity = self.rarity, let ra = assets[rarity] {
                ra.draw(in: NSRect(x: 311 * s, y: 348 * s, width: 150 * s, height: 150 * s),
                        from: NSRect(x: 0, y: 0, width: 149, height: 149),
                        operation: .sourceOver,
                        fraction: 1.0)
            }

            if let image = assets["title-spell"] {
                image.draw(in: NSRect(x: 66 * s, y: 375 * s, width: 646 * s, height: 199 * s),
                        from: NSRect(x: 0, y: 0, width: 646, height: 199),
                        operation: .sourceOver,
                        fraction: 1.0)
            }
        } else if type == "WEAPON" {
            if let rarity = self.rarity, let ra = assets[rarity] {
                ra.draw(in: NSRect(x: 315 * s, y: 364 * s, width: 146 * s, height: 144 * s),
                        from: NSRect(x: 0, y: 0, width: 146, height: 144),
                        operation: .sourceOver,
                        fraction: 1.0)
            }
            if let image = assets["title-weapon"] {
                image.draw(in: NSRect(x: 56 * s, y: 415 * s, width: 660 * s, height: 140 * s),
                        from: NSRect(x: 0, y: 0, width: 660, height: 140),
                        operation: .sourceOver,
                        fraction: 1.0)
            }
            if let image = assets["swords"] {
                image.draw(in: NSRect(x: 32 * s, y: 0 * s, width: 187 * s, height: 183 * s),
                        from: NSRect(x: 0, y: 0, width: 312, height: 306),
                        operation: .sourceOver,
                        fraction: 1.0)
            }
            if let image = assets["shield"] {
                image.draw(in: NSRect(x: 584 * s, y: 0 * s, width: 186 * s, height: 205 * s),
                        from: NSRect(x: 0, y: 0, width: 301, height: 333),
                        operation: .sourceOver,
                        fraction: 1.0)
            }
        }

        if set != "CORE" {
            let xPos: CGFloat = 256

            if let bgLogo = self.bgLogo, let image = assets[bgLogo] {
                if let _ = card["race"] as? String, type == "MINION" {
                    image.draw(in: NSRect(x: xPos * s,
                            y: 124 * s,
                            width: (281 * 0.95) * s,
                            height: (244 * 0.95) * s),
                            from: NSRect(x: 0, y: 0, width: 281, height: 244),
                            operation: .sourceOver,
                            fraction: 0.6)
                } else if type == "SPELL" {
                    image.draw(in: NSRect(x: xPos * s, y: 140 * s, width: 253 * s, height: 220 * s),
                            from: NSRect(x: 0, y: 0, width: 281, height: 244),
                            operation: .sourceOver,
                            fraction: 0.6)
                } else {
                    image.draw(in: NSRect(x: xPos * s,
                            y: 130 * s,
                            width: 259 * s,
                            height: 209 * s),
                            from: NSRect(x: 0, y: 0, width: 281, height: 244),
                            operation: .sourceOver,
                            fraction: 0.6)
                }
            }
        }

        try drawNumber(x: 75 * s,
                y: 850 * s,
                s: s,
                number: card["cost"] as? Int ?? 0,
                size: 170 * s,
                drawStyle: card["costStyle"])
        try drawCardTitle(ctx: ctx,
                rect: NSRect(x: (395 - (580 / 2)) * s,
                        y: 380 * s,
                        width: 580 * s,
                        height: 200 * s),
                s: s,
                card: card)

        if type == "MINION" {
            if let _ = card["race"] as? String {
                try renderRaceText(s: s, card: card)
            }

            try drawNumber(x: 80 * s,
                    y: 15 * s,
                    s: s,
                    number: card["attack"] as? Int ?? 0,
                    size: 170 * s,
                    drawStyle: card["attackStyle"])
            try drawNumber(x: 625 * s,
                    y: 15 * s,
                    s: s,
                    number: card["health"] as? Int ?? 0,
                    size: 170 * s,
                    drawStyle: card["healthStyle"])
        } else if type == "WEAPON" {
            try drawNumber(x: 80 * s,
                    y: 15 * s,
                    s: s,
                    number: card["attack"] as? Int ?? 0,
                    size: 170 * s,
                    drawStyle: card["attackStyle"])
            try drawNumber(x: 625 * s,
                    y: 15 * s,
                    s: s,
                    number: card["durability"] as? Int ?? 0,
                    size: 170 * s,
                    drawStyle: card["durabilityStyle"])
        }

        if let text = card["text"] as? String, !text.isEmpty {
            try drawBodyText(s: s, type: type, text: text)
        }

        image.unlockFocus()

        return image
    }

    private func drawBodyText(s: CGFloat, type: String, text: String) throws {

        let pluralRegex = "(\\d+) \\|4\\((\\w+),(\\w+)\\)"
        let bodyText = text.replace(pluralRegex) { (string, matches) in
            guard matches.count > 4 else {
                return string
            }

            let single = matches[1].value
            let plural = matches[2].value
            let count = Int(matches[0].value) ?? 0

            let replace = "\(count) \(count <= 1 ? single : plural)"
            return string.replace(pluralRegex, with: replace)
        }.replace("\\$", with: "")
                .replace("#", with: "")
                .replace("\\n", with: "\n")
                .replace("\\[x\\]", with: "")

        print("Rendering body \(bodyText)")

        var bufferText = NSRect(x: 123 * s, y: 80, width: 520 * s, height: 290 * s)

        if type == "SPELL" {
            bufferText.origin.x = 135 * s
            bufferText.size.width = 480 * s
            bufferText.size.height = 290 * s
        } else if type == "WEAPON" {
            bufferText.size.width = 470 * s
            bufferText.size.height = 250 * s
        }

        var fontSize: CGFloat = 52
        let totalLength = bodyText.replace("<\\/*.>", with: "").characters.count
        if totalLength >= 80 {
            fontSize *= 0.9
        } else if (totalLength >= 100) {
            fontSize *= 0.8
        }

        let fontName: String
        if ["jaJP", "thTH", "koKR", "zhCN", "zhTW"].contains(locale) {
            fontName = "NanumGothic"
        } else if "ruRU" == locale {
            fontName = "BenguiatBold"
        } else {
            fontName = "ITC Franklin Condensed"
        }
        let styles = [
                "text-align": "center",
                "color": type == "WEAPON" ? "#ffffff" : "#000000",
                "font-size": "\(fontSize)px",
                "font-family": fontName,
                "background-color": debug ? "rgba(255, 0, 0, 0.5)" : "transparent"
        ]
                .map {
                    "\($0): \($1)"
                }
                .joined(separator: ";")

        let htmlText = "<p style='\(styles)'>\(bodyText)</p>"
        print("\(htmlText)")
        guard let html = htmlText.data(using: .utf8) else {
            return
        }
        let text = try NSAttributedString(data: html,
                options: [
                        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                        NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil)

        text.draw(in: bufferText)
    }

    private func renderRaceText(s: CGFloat, card: [String: Any]) throws {
        guard let race = card["race"] as? String else {
            return
        }

        let fontSize: CGFloat = 40
        guard let font = NSFont(name: belweBdBT, size: fontSize) else {
            throw AssetError.fontNotFound(name: belweBdBT)
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let text = NSAttributedString(string: NSLocalizedString(race.lowercased(), comment: ""),
                attributes: [
                        NSFontAttributeName: font,
                        NSForegroundColorAttributeName: NSColor.white,
                        NSStrokeWidthAttributeName: -4.0,
                        NSStrokeColorAttributeName: NSColor.black,
                        NSParagraphStyleAttributeName: paragraph
                ])
        let textWidth = text.size().width
        text.draw(at: NSPoint(x: (394 - (textWidth / 2)) * s, y: 70))
    }

    private func drawCardTitle(ctx: NSGraphicsContext, rect: NSRect, s: CGFloat,
                               card: [String: Any]) throws {
        guard let type = card["type"] as? String else {
            throw AssetError.invalidCardType
        }
        guard let name = card["name"] as? String else {
            throw AssetError.invalidCardName
        }

        let context = ctx.cgContext

        context.textMatrix = CGAffineTransform.identity

        let maxWidth: CGFloat = 580
        let math = Math()

        if type == "SPELL" {
            math._P0 = NSPoint(x: 10, y: 80)
            math._P1 = NSPoint(x: 212, y: 135)
            math._P2 = NSPoint(x: 368, y: 135)
            math._P3 = NSPoint(x: 570, y: 85)
        } else if type == "WEAPON" {
            math._P0 = NSPoint(x: 10, y: 110)
            math._P1 = NSPoint(x: 50, y: 110)
            math._P2 = NSPoint(x: 500, y: 110)
            math._P3 = NSPoint(x: 570, y: 110)
        } else {
            math._P0 = NSPoint(x: 0, y: 80)
            math._P1 = NSPoint(x: 102, y: 30)
            math._P2 = NSPoint(x: 368, y: 160)
            math._P3 = NSPoint(x: 580, y: 90)
        }

        let fontSize: CGFloat = 62
        guard let font = NSFont(name: belweBdBT, size: fontSize) else {
            throw AssetError.fontNotFound(name: belweBdBT)
        }
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        var attrs: [String: Any] = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: NSColor.white,
                NSStrokeWidthAttributeName: -4.0,
                NSStrokeColorAttributeName: NSColor.black,
                NSParagraphStyleAttributeName: paragraph
        ]
        if debug {
            attrs[NSBackgroundColorAttributeName] = NSColor.red.withAlphaComponent(0.5)
        }
        let text = NSAttributedString(string: name, attributes: attrs)

        let textWidth = text.size().width

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer() // Inifinite-sized container.
        let textStorage = NSTextStorage()

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textStorage.beginEditing()
        textStorage.setAttributedString(text)
        textStorage.endEditing()

        context.translateBy(x: rect.minX, y: rect.minY)

        // Stroke the arc in red for verification.
        if debug {
            context.beginPath()
            context.move(to: math._P0)
            context.addCurve(to: math._P3, control1: math._P1, control2: math._P2)
            context.setStrokeColor(NSColor.green.cgColor)
            context.setLineWidth(4)
            context.strokePath()
        }

        var glyphRange = NSRange()
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: 0, effectiveRange: &glyphRange)

        var offset: CGFloat = 0
        var lastGlyphPoint = math._P0
        var startAt = (maxWidth / 2) - (textWidth / 2) - (lastGlyphPoint.x * 2)
        var lastX: CGFloat = 0

        for glyphIndex in glyphRange.location ... NSMaxRange(glyphRange) {
            ctx.saveGraphicsState()
            let location = layoutManager.location(forGlyphAt: glyphIndex)

            let distance = startAt + location.x - lastX  // Assume single line
            if startAt > 0 {
                startAt = 0
            }
            offset = math.offsetAtDistance(distance, lastGlyphPoint, offset)
            let glyphPoint = math.pointForOffset(offset)
            let angle = math.angleForOffset(offset)

            lastGlyphPoint = glyphPoint
            lastX = location.x

            context.translateBy(x: glyphPoint.x, y: glyphPoint.y)
            context.rotate(by: angle)

            layoutManager.drawGlyphs(forGlyphRange: NSMakeRange(glyphIndex, 1),
                    at: NSPoint(x: -(lineRect.origin.x + location.x),
                            y: -(lineRect.origin.y + location.y)))

            ctx.restoreGraphicsState()
        }
        context.translateBy(x: -rect.minX, y: -rect.minY)
    }

    private func drawNumber(x: CGFloat, y: CGFloat,
                            s: CGFloat, number: Int,
                            size: CGFloat, drawStyle: Any?) throws {
        guard let font = NSFont(name: belweBdBT, size: size) else {
            throw AssetError.fontNotFound(name: belweBdBT)
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        var attributes: [String: Any] = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: NSColor.white,
                NSStrokeWidthAttributeName: -2.0,
                NSStrokeColorAttributeName: NSColor.black,
                NSParagraphStyleAttributeName: paragraph
        ]
        if debug {
            attributes[NSBackgroundColorAttributeName] = NSColor.red.withAlphaComponent(0.5)
        }
        let text = NSAttributedString(string: "\(number)", attributes: attributes)
        var x = x
        if number > 9 {
            x -= 45
        }
        text.draw(at: NSPoint(x: x, y: y))
    }

    private func fetchAssets(loadAssets: [String], callback: () -> ()) {
        loadAssets.forEach { (asset) in
            var key = asset
            var isUrl = false

            if ["h:", "t:"].contains(key.sub(start: 0, end: 2)) {
                key = key.sub(start: 2, end: key.characters.count)
            } else if key.sub(start: 0, end: 2) == "u:" {
                isUrl = true
                key = key.sub(start: 2, end: key.characters.count)
                print("\(artUrl)\(key).jpg")
            }

            if let url = URL(string: "\(artUrl)\(key).jpg"), isUrl {
                if let image = NSImage(contentsOf: url) {
                    assets[key] = image
                } else {
                    print("can't load art : \(artUrl)\(key).png")
                }
            } else {
                if let image = NSImage(named: key) {
                    assets[key] = image
                } else {
                    print("can't load image : \(key).png")
                }
            }
        }

        callback()
    }
}

private extension String {

    func sub(start: Int, end: Int) -> String {
        if start < 0 || start > self.characters.count {
            print("start index \(start) out of bounds")
            return ""
        } else if end < 0 || end > self.characters.count {
            print("end index \(end) out of bounds")
            return ""
        }
        let range = self.characters.index(self.startIndex, offsetBy: start) ..< self.characters.index(self.startIndex, offsetBy: end)
        return self.substring(with: range)
    }

    func sub(from: Int) -> String {
        if from < 0 || from > self.characters.count {
            print("start index \(from) out of bounds")
            return ""
        }
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
    }
}

// todo code from HSTracker, move to a separate lib

private struct Match {
    var range: Range<String.Index>
    var value: String
}

private struct Regex {
    let expression: String

    init(expression: String) {
        self.expression = expression
    }

    func match(_ someString: String) -> Bool {
        do {
            let regularExpression = try NSRegularExpression(pattern: expression, options: [])
            let range = NSRange(location: 0, length: someString.characters.count)
            let matches = regularExpression.numberOfMatches(in: someString,
                    options: [],
                    range: range)
            return matches > 0
        } catch {
            return false
        }
    }

    func matches(_ someString: String) -> [Match] {
        var matches = [Match]()
        do {
            let regularExpression = try NSRegularExpression(pattern: expression, options: [])
            let range = NSRange(location: 0, length: someString.characters.count)
            let results = regularExpression.matches(in: someString,
                    options: [],
                    range: range)
            for result in results {
                for index in 1 ..< result.numberOfRanges {
                    let resultRange = result.rangeAt(index)
                    let startPos = someString.characters
                            .index(someString.startIndex, offsetBy: resultRange.location)
                    let end = resultRange.location + resultRange.length
                    let endPos = someString.characters.index(someString.startIndex, offsetBy: end)
                    let range = startPos ..< endPos

                    let value = someString.substring(with: range)
                    let match = Match(range: range, value: value)
                    matches.append(match)
                }
            }
        } catch {
        }
        return matches
    }
}

private extension String {
    func match(_ pattern: String) -> Bool {
        return Regex(expression: pattern).match(self)
    }

    func matches(_ pattern: String) -> [Match] {
        return Regex(expression: pattern).matches(self)
    }

    func replace(_ pattern: String, with: String) -> String {
        do {
            let regularExpression = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: self.characters.count)
            return regularExpression.stringByReplacingMatches(in: self,
                    options: [],
                    range: range,
                    withTemplate: with)
        } catch {
        }
        return self
    }

    func replace(_ pattern: String, using: (String, [Match]) -> String) -> String {
        let matches = self.matches(pattern)
        return using(self, matches)
    }
}