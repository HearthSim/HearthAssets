//
//  Math.swift
//  HearthAssets
//
//  Created by Benjamin Michotte on 7/02/17.
//  Copyright © 2017 Benjamin Michotte. All rights reserved.
//

import Foundation

final class Math {
    var _P0 = NSPoint.zero
    var _P1 = NSPoint.zero
    var _P2 = NSPoint.zero
    var _P3 = NSPoint.zero

    func bezier(_ t: CGFloat, _ P0: CGFloat, _ P1: CGFloat, _ P2: CGFloat, _ P3: CGFloat) -> CGFloat {
        return (1 - t) * (1 - t) * (1 - t) * P0
            + 3 * (1 - t) * (1 - t) * t * P1
            + 3 * (1 - t) * t * t * P2
            + t * t * t * P3
    }

    //https://github.com/iosptl/ios7ptl/blob/master/ch21-Text/CurvyText/CurvyText/CurvyTextView.m
    func pointForOffset(_ t: CGFloat) -> NSPoint {
        let x = bezier(t, _P0.x, _P1.x, _P2.x, _P3.x)
        let y = bezier(t, _P0.y, _P1.y, _P2.y, _P3.y)
        return NSPoint(x: x, y: y)
    }

    func bezierPrime(_ t: CGFloat,
                     _ P0: CGFloat, _ P1: CGFloat,
                     _ P2: CGFloat, _ P3: CGFloat) -> CGFloat {
        return  -3 * (1 - t) * (1 - t) * P0
            + (3 * (1 - t) * (1 - t) * P1) - (6 * t * (1 - t) * P1)
            - (3 * t * t * P2) + (6 * t * (1 - t) * P2)
            + 3 * t * t * P3
    }

    func angleForOffset(_ t: CGFloat) -> CGFloat {
        let dx = bezierPrime(t, _P0.x, _P1.x, _P2.x, _P3.x)
        let dy = bezierPrime(t, _P0.y, _P1.y, _P2.y, _P3.y)
        return atan2(dy, dx)
    }

    func distance(_ a: NSPoint, _ b: NSPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return hypot(dx, dy)
    }

    // Simplistic routine to find the offset along Bezier that is
    // aDistance away from aPoint. anOffset is the offset used to
    // generate aPoint, and saves us the trouble of recalculating it
    // This routine just walks forward until it finds a point at least
    // aDistance away. Good optimizations here would reduce the number
    // of guesses, but this is tricky since if we go too far out, the
    // curve might loop back on leading to incorrect results. Tuning
    // kStep is good start.
    func offsetAtDistance(_ aDistance: CGFloat, _ aPoint: NSPoint, _ anOffset: CGFloat) -> CGFloat {
        let kStep: CGFloat = 0.001 // 0.0001 - 0.001 work well
        var newDistance: CGFloat = 0
        var newOffset: CGFloat = anOffset + kStep
        while (newDistance <= aDistance && newOffset < 1.0) {
            newOffset += kStep
            newDistance = distance(aPoint, pointForOffset(newOffset))
        }
        return newOffset
    }
}
