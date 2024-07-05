//
//  SnakeFeedItem.swift
//  SnakeGameExample
//
//  Created by Mindinventory on 05/07/24.

import SwiftUI


protocol AnnonymusType {
    associatedtype Item
    var itemType: [Item] { get set }
    mutating func addValue(item: Item)
}



struct RippleEffect: GeometryEffect {
    var amount: CGFloat
    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let scale = 1 + amount
        let translation = CGAffineTransform(translationX: size.width * (scale - 1) / 2, y: size.height * (scale - 1) / 2)
        return ProjectionTransform(CGAffineTransform(scaleX: scale, y: scale).concatenating(translation))
    }
}

struct SnakeFeedItem: View {
    @State private var animate = false
    let snakeSize: CGFloat = 12
        var body: some View {
            ZStack {
                ForEach(0..<1) { index in
                    Circle()
                        .fill(Color.pink.opacity(0.6))
                        .frame(width: snakeSize, height: snakeSize)
                        .scaleEffect(animate ? 1.5 : 0)
                        .opacity(animate ? 0 : 1)
                        .animation(
                            Animation.easeOut(duration: 5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.75),
                            value: animate
                        )
                }
            }
            .onAppear {
                animate = true
            }
        }
}

#Preview {
    SnakeFeedItem()
}
