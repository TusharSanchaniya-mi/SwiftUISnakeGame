//
//  ContentView.swift
//  SnakeGameExample
//
//  Created by Mindinventory on 05/07/24.
//

import SwiftUI


enum SnakeDirection: CaseIterable {
    case up
    case left
    case right
    case down
}

struct ContentView: View {
    
    @State private var startPosition: CGPoint = .zero     //start position of swipe
    @State private var positions = [CGPoint(x: 0, y: 0)]  //array of snake's body position
    @State private var foodPosition = CGPoint(x: 0, y: 0)  //array of snake's body position
    @State private var iScore: Int = 0
    
    let snakeSize: CGFloat = 12                           //snake size
    
    @State private var isStarted = false                   //started swipe?
    @State private var gameOver = false                   //game over?
    @State private var direction: SnakeDirection = SnakeDirection.allCases.randomElement() ?? .left
    
    
    private let minX = UIScreen.main.bounds.minX // Boundry of points to set
    private let maxX = UIScreen.main.bounds.maxX // Boundry of points to set
    private let minY = UIScreen.main.bounds.minY // Boundry of points to set
    private let maxY = UIScreen.main.bounds.maxY // Boundry of points to set
    
    
    
    //MARK: - Random Positions
    func changePosition() -> CGPoint {
        let rows = Int(maxX / snakeSize)
        let columns = Int(maxY / snakeSize)
        
        let randomX = Int.random(in: 1..<rows) * Int(snakeSize)
        let randomY = Int.random(in: 1..<columns) * Int(snakeSize)
        
        let randomPosition = CGPoint(x: randomX, y: randomY)
        return randomPosition
    }
    
    func changeDirection() {
        if positions[0].x < minX || positions[0].x > maxX && !gameOver {
            gameOver.toggle()
        } else if positions[0].y < minY || positions[0].y > maxY && !gameOver {
            gameOver.toggle()
        }
        
        var prev = positions[0]
        
        if direction == .down {
            positions[0].y += snakeSize
            
        } else if direction == .up {
            positions[0].y -= snakeSize
            
        } else if direction == .left {
            positions[0].x += snakeSize
            
        } else {
            positions[0].x -= snakeSize
        }
        
        
        for index in 1..<positions.count {
            let current = positions[index]
            positions[index] = prev
            
            prev = current
            
        }
    }
    
    //MARK: - Start Game
    func startGame() {
        withAnimation(.easeInOut) {
            iScore = 0
            positions = [CGPoint(x: 0, y: 0)]
            
            gameOver = false
            isStarted = true
            foodPosition = changePosition()
            positions.insert(foodPosition, at: 0)
            positions[0] = changePosition()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.changeDirection()
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            ZStack {
                
                VStack {
                    HStack {
                        Text("Score: \(iScore)")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                        
                        Button(action: {
                            startGame()
                        }, label: {
                            HStack {
                                Image(systemName: "arrow.uturn.left.circle")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 10)
                                Text("Restart")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.secondary)
                            .cornerRadius(30)
                        })
                    }
                    .padding(.horizontal, 15)
                    
                    Spacer()
                }
                
                //MARK: - Snake
                ForEach(0..<positions.count, id: \.self) { index in
                    if index == 0 && positions.count > 2 {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: snakeSize * 1.2, height: snakeSize * 1.2)
                            .position(positions[index])
                    }
                    else {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: snakeSize * 1.08, height: snakeSize * 1.08)
                            .position(positions[index])
                    }
                }
                
            // MARK: 
                Circle()
                    .fill(Color.green)
                    .overlay(Capsule().stroke(Color.green, lineWidth: 1))
                    .frame(width: snakeSize * 1.08, height: snakeSize * 1.08)
                    .position(foodPosition)
                    
                
                
            }
        }
        //MARK: - Alert
        .alert(isPresented: $gameOver) {
            Alert(title: Text("Game Over"), message: Text("Your Score is: \(iScore)"), primaryButton: .default(Text("Dismiss"), action: {
                gameOver.toggle()
                isStarted.toggle()
                
            }), secondaryButton: .default(Text("Restart"), action: {
                startGame()
            }))
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if isStarted {
                        withAnimation {
                            startPosition = gesture.location
                            isStarted.toggle()
                        }
                    }
                }
                .onEnded { gesture in
                    
                    let xDist =  abs(gesture.location.x - startPosition.x)
                    let yDist =  abs(gesture.location.y - startPosition.y)
                    if startPosition.y <  gesture.location.y && yDist > xDist {
                        direction = SnakeDirection.down
                    }
                    else if startPosition.y >  gesture.location.y && yDist > xDist {
                        direction = SnakeDirection.up
                    }
                    else if startPosition.x > gesture.location.x && yDist < xDist {
                        direction = SnakeDirection.right
                    }
                    else if startPosition.x < gesture.location.x && yDist < xDist {
                        direction = SnakeDirection.left
                    }
                    isStarted.toggle()
                    
                }
        )
        //MARK: - Time frequency
        .onReceive(Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()) { _ in
            if !gameOver && isStarted {
                withAnimation(.linear(duration: 0.08)) {
                    changeDirection()
                }
                if positions[0] == foodPosition {
                    withAnimation(.spring()) {
                        positions.append(positions[0])
                    }
                    foodPosition = changePosition()
                    iScore += 1
                    
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
