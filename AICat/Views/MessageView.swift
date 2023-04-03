//
//  MessageView.swift
//  AICat
//
//  Created by Lei Pan on 2023/3/21.
//

import SwiftUI
import MarkdownUI

/// generated by ChatGPT, not verified seriously
func isMarkdown(_ string: String) -> Bool {
    let regex = try! NSRegularExpression(pattern: "(^#{1,6}\\s+.+)|([*_]{1,2}.+?[*_]{1,2})|(\\[.+?\\]\\(.+?\\))|(!\\[.+?\\]\\(.+?\\))|(>\\s+.+)|(-\\s+.+)|([0-9]+\\.\\s+.+)|(```(?:[^\n\r`]+|```)*)|(\\|?.+\\|\\n?)+", options: .anchorsMatchLines)
    return regex.firstMatch(in: string, range: NSRange(location: 0, length: string.utf16.count)) != nil
}

struct MineMessageView: View {
    let message: ChatMessage
    var body: some View {
        ZStack {
            HStack {
                Spacer(minLength: 40)
                ZStack {
                    if isMarkdown(message.content) {
                        Markdown(message.content.trimmingCharacters(in: .whitespacesAndNewlines))
                            .markdownTheme(.fancy)
                    } else {
                        Text(message.content.trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.manrope(size: 16, weight: .regular))
                            .foregroundColor(.whiteText)
                    }
                }
                .padding(EdgeInsets.init(top: 10, leading: 16, bottom: 10, trailing: 16))
                .background(
                    LinearGradient(
                        colors: [.primary.opacity(0.8), .primary.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                )
                .clipShape(CornerRadiusShape(radius: 4, corners: .topRight))
                .clipShape(CornerRadiusShape(radius: 20, corners: [.bottomLeft, .bottomRight, .topLeft]))
                .padding(.trailing, 20)
            }
        }
    }
}

struct AICatMessageView: View {
    let message: ChatMessage
    var body: some View {
        if containsCodeBlock(content: message.content) {
            Markdown(message.content.trimmingCharacters(in: .whitespacesAndNewlines))
               .textSelection(.enabled)
               .markdownCodeSyntaxHighlighter(.splash(theme: .sundellsColors(withFont: .init(size: 16))))
               .markdownTheme(.gitHub)
               .padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
        } else {
            ZStack {
                if isMarkdown(message.content) {
                    Markdown(message.content.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    Text(message.content.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.manrope(size: 16, weight: .regular))
                        .foregroundColor(.blackText)
                }
            }
            .padding(EdgeInsets.init(top: 10, leading: 16, bottom: 10, trailing: 16))
            .background(Color.aiBubbleBg)
            .clipShape(CornerRadiusShape(radius: 4, corners: .topLeft))
            .clipShape(CornerRadiusShape(radius: 20, corners: [.bottomLeft, .bottomRight, .topRight]))
            .padding(.init(top: 0, leading: 20, bottom: 0, trailing: 36))

        }
    }

    func containsCodeBlock(content: String) -> Bool {
        let regextPattern = "```[\\w\\W]*?```"
        if let regex = try? NSRegularExpression(pattern: regextPattern) {
            let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            return !matches.isEmpty
        }
        return false
    }
}

struct MessageView: View {
    let message: ChatMessage
    var body: some View {
        if message.role == "user" {
            MineMessageView(message: message)
        } else {
            AICatMessageView(message: message)
        }
    }
}

struct RectCorner: OptionSet {

    let rawValue: Int

    static let topLeft = RectCorner(rawValue: 1 << 0)
    static let topRight = RectCorner(rawValue: 1 << 1)
    static let bottomRight = RectCorner(rawValue: 1 << 2)
    static let bottomLeft = RectCorner(rawValue: 1 << 3)

    static let allCorners: RectCorner = [.topLeft, topRight, .bottomLeft, .bottomRight]
}


// draws shape with specified rounded corners applying corner radius
struct CornerRadiusShape: Shape {

    var radius: CGFloat = .zero
    var corners: RectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let p1 = CGPoint(x: rect.minX, y: corners.contains(.topLeft) ? rect.minY + radius  : rect.minY )
        let p2 = CGPoint(x: corners.contains(.topLeft) ? rect.minX + radius : rect.minX, y: rect.minY )

        let p3 = CGPoint(x: corners.contains(.topRight) ? rect.maxX - radius : rect.maxX, y: rect.minY )
        let p4 = CGPoint(x: rect.maxX, y: corners.contains(.topRight) ? rect.minY + radius  : rect.minY )

        let p5 = CGPoint(x: rect.maxX, y: corners.contains(.bottomRight) ? rect.maxY - radius : rect.maxY )
        let p6 = CGPoint(x: corners.contains(.bottomRight) ? rect.maxX - radius : rect.maxX, y: rect.maxY )

        let p7 = CGPoint(x: corners.contains(.bottomLeft) ? rect.minX + radius : rect.minX, y: rect.maxY )
        let p8 = CGPoint(x: rect.minX, y: corners.contains(.bottomLeft) ? rect.maxY - radius : rect.maxY )


        path.move(to: p1)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                    tangent2End: p2,
                    radius: radius)
        path.addLine(to: p3)
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                    tangent2End: p4,
                    radius: radius)
        path.addLine(to: p5)
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
                    tangent2End: p6,
                    radius: radius)
        path.addLine(to: p7)
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
                    tangent2End: p8,
                    radius: radius)
        path.closeSubpath()

        return path
    }
}

struct ErrorMessageView: View {
    let errorMessage: String
    let retry: () -> Void
    let clear: () -> Void
    var body: some View {
        ZStack {
            HStack {
                Text(errorMessage)
                    .foregroundColor(.white)
                    .font(.manrope(size: 16, weight: .medium))
                    .padding(EdgeInsets.init(top: 10, leading: 16, bottom: 10, trailing: 16))
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Button(
                    action: retry
                ) {
                    if #available(iOS 16.0, *) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .tint(
                                LinearGradient(
                                    colors: [.primary.opacity(0.9), .primary.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing)
                            )
                    } else {
                        // Fallback on earlier versions
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .tint(.primary.opacity(0.8))
                    }
                }
                Button(
                    action: clear
                ) {
                    if #available(iOS 16.0, *) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .tint(
                                LinearGradient(
                                    colors: [.primary.opacity(0.9), .primary.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing)
                            )
                    } else {
                        // Fallback on earlier versions
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .tint(.primary.opacity(0.8))
                    }
                }
            }.padding(.horizontal, 20)
        }
    }
}

struct InputingMessageView: View {
    @State private var shouldAnimate = false

    let circleSize: CGFloat = 6

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.primary.opacity(0.8))
                .frame(width: circleSize, height: circleSize)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever(), value: shouldAnimate)
            Circle()
                .fill(Color.primary.opacity(0.8))
                .frame(width: circleSize, height: circleSize)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.3), value: shouldAnimate)
            Circle()
                .fill(Color.primary.opacity(0.8))
                .frame(width: circleSize, height: circleSize)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.6), value: shouldAnimate)
        }
        .padding(EdgeInsets.init(top: 10, leading: 20, bottom: 10, trailing: 20))
        .frame(height: 40)
        .background(Color.aiBubbleBg)
        .clipShape(CornerRadiusShape(radius: 4, corners: .topLeft))
        .clipShape(CornerRadiusShape(radius: 20, corners: [.bottomLeft, .bottomRight, .topRight]))
        .padding(.init(top: 0, leading: 20, bottom: 0, trailing: 36))
        .onAppear {
            self.shouldAnimate.toggle()
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AICatMessageView(message: ChatMessage(role: "user", content: "you are beautiful", conversationId: ""))
            MineMessageView(message: ChatMessage(role: "", content: "### title ```swift```", conversationId: ""))
            ErrorMessageView(errorMessage: "RequestTime out", retry: {}, clear: {})
        }
    }
}

