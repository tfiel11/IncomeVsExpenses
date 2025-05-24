//
//  ScaleView.swift
//  IncomeVsExpenses
//
//  Created by Tyler Fielding on 5/22/25.
//

import SwiftUI

struct ScaleView: View {
    let tiltAngle: Double
    let leftAmount: Double
    let rightAmount: Double
    let showAnimation: Bool
    let lastAddedItemIsIncome: Bool
    var onExpenseTapped: () -> Void
    var onIncomeTapped: () -> Void
    
    @State private var animatedTiltAngle: Double = 0
    
    // Constants for sizing calculations
    private let baseBallSize: CGFloat = 70
    private let maxBallSize: CGFloat = 140
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let centerX = width / 2
            let centerY = height * 0.6
            
            // Render the complete scale with balls
            renderScale(centerX: centerX, centerY: centerY, width: width, height: height)
                .onChange(of: tiltAngle) { _, newAngle in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        animatedTiltAngle = newAngle
                    }
                }
                .onAppear {
                    animatedTiltAngle = tiltAngle
                }
        }
    }
    
    // MARK: - Scale Rendering
    
    private func renderScale(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) -> some View {
        // Beam dimensions
        let beamLength = width * 0.82
        let beamHeight: CGFloat = 8
        
        // Triangle stand dimensions
        let triangleWidth = width * 0.22
        let triangleHeight = height * 0.16
        
        // Calculate ball sizes based on amounts
        let leftBallSize = calculateBallSize(amount: leftAmount, otherAmount: rightAmount)
        let rightBallSize = calculateBallSize(amount: rightAmount, otherAmount: leftAmount)
        
        // Ball positions (1/3 from each end)
        let ballDistanceFromCenter = beamLength * 0.32
        
        return ZStack {
            // Draw the triangle fulcrum first
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addLine(to: CGPoint(x: centerX - triangleWidth/2, y: centerY + triangleHeight))
                path.addLine(to: CGPoint(x: centerX + triangleWidth/2, y: centerY + triangleHeight))
                path.closeSubpath()
            }
            .fill(Color.gray.opacity(0.8))
            
            // Draw the beam with balls
            Group {
                // Beam
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray4))
                    .frame(width: beamLength, height: beamHeight)
                
                // Left ball (expenses)
                Circle()
                    .fill(Color.red.opacity(0.85))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .frame(width: leftBallSize, height: leftBallSize)
                    .overlay(
                        Text("$\(Int(leftAmount))")
                            .foregroundColor(.white)
                            .font(.system(size: min(24, leftBallSize * 0.28), weight: .bold))
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                    )
                    .offset(
                        x: -ballDistanceFromCenter,
                        y: -(leftBallSize/2 + beamHeight/2)
                    )
                    .onTapGesture {
                        onExpenseTapped()
                    }
                
                // Right ball (income)
                Circle()
                    .fill(Color.green.opacity(0.85))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .frame(width: rightBallSize, height: rightBallSize)
                    .overlay(
                        Text("$\(Int(rightAmount))")
                            .foregroundColor(.white)
                            .font(.system(size: min(24, rightBallSize * 0.28), weight: .bold))
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                    )
                    .offset(
                        x: ballDistanceFromCenter,
                        y: -(rightBallSize/2 + beamHeight/2)
                    )
                    .onTapGesture {
                        onIncomeTapped()
                    }
            }
            // Apply rotation to the beam and balls as a group
            .rotationEffect(.degrees(animatedTiltAngle), anchor: .center)
            .position(x: centerX, y: centerY)
        }
    }
    
    // Calculate ball size based on amount
    private func calculateBallSize(amount: Double, otherAmount: Double) -> CGFloat {
        guard amount > 0 else { return baseBallSize }
        
        let maxAmount = max(amount, otherAmount, 1) // Avoid division by zero
        let proportion = CGFloat(amount / maxAmount)
        
        // Scale between base size and max size
        return baseBallSize + (maxBallSize - baseBallSize) * proportion
    }
}

#Preview {
    ScaleView(
        tiltAngle: 15,
        leftAmount: 1600,
        rightAmount: 3500,
        showAnimation: false,
        lastAddedItemIsIncome: true,
        onExpenseTapped: {},
        onIncomeTapped: {}
    )
    .frame(height: 280)
    .padding()
} 