//
//  CustomRoundedRectangle.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 29/5/23.
//

import SwiftUI

struct TextEditorShape: Shape {
    let cornerRadius: CGFloat
    let gap: CGFloat
    let offset: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addLine(to: CGPoint(x: cornerRadius+offset, y: 0))
        path.move(to: CGPoint(x: cornerRadius+offset+gap, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX-cornerRadius, y: 0))
        path.addArc(tangent1End:
                        CGPoint(x: rect.maxX, y: 0),
                    tangent2End: CGPoint(x: rect.maxX, y: cornerRadius), radius: cornerRadius)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY-cornerRadius))
        path.addArc(tangent1End:
                        CGPoint(x: rect.maxX, y: rect.maxY),
                    tangent2End: CGPoint(x: rect.maxX-cornerRadius, y: rect.maxY), radius: cornerRadius)
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.maxY))
        path.addArc(tangent1End:
                        CGPoint(x: 0, y: rect.maxY),
                    tangent2End: CGPoint(x: 0, y: rect.maxY-cornerRadius), radius: cornerRadius)
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(tangent1End:
                        CGPoint(x: 0, y: 0),
                    tangent2End: CGPoint(x: cornerRadius, y: 0), radius: cornerRadius)
        return path
    }
}
