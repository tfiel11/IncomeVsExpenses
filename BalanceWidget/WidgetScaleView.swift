import SwiftUI

struct WidgetScaleView: View {
    let tiltAngle: Double
    let leftAmount: Double
    let rightAmount: Double
    
    // Constants for sizing calculations
    private let baseBallSize: CGFloat = 24
    private let maxBallSize: CGFloat = 40
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let centerX = width / 2
            let centerY = height * 0.6
            
            // Render the complete scale with balls
            ZStack {
                // Draw the triangle fulcrum
                Path { path in
                    let triangleWidth = width * 0.22
                    let triangleHeight = height * 0.16
                    
                    path.move(to: CGPoint(x: centerX, y: centerY))
                    path.addLine(to: CGPoint(x: centerX - triangleWidth/2, y: centerY + triangleHeight))
                    path.addLine(to: CGPoint(x: centerX + triangleWidth/2, y: centerY + triangleHeight))
                    path.closeSubpath()
                }
                .fill(Color.gray.opacity(0.8))
                
                // Draw the beam with balls
                Group {
                    // Beam
                    let beamLength = width * 0.82
                    let beamHeight: CGFloat = 4
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray4))
                        .frame(width: beamLength, height: beamHeight)
                    
                    // Ball positions (1/3 from each end)
                    let ballDistanceFromCenter = beamLength * 0.32
                    
                    // Left ball (expenses)
                    let leftBallSize = calculateBallSize(amount: leftAmount, otherAmount: rightAmount)
                    Circle()
                        .fill(Color.red.opacity(0.85))
                        .frame(width: leftBallSize, height: leftBallSize)
                        .overlay(
                            Text("$\(Int(leftAmount))")
                                .foregroundColor(.white)
                                .font(.system(size: min(12, leftBallSize * 0.4), weight: .bold))
                                .minimumScaleFactor(0.5)
                        )
                        .offset(
                            x: -ballDistanceFromCenter,
                            y: -(leftBallSize/2 + beamHeight/2)
                        )
                    
                    // Right ball (income)
                    let rightBallSize = calculateBallSize(amount: rightAmount, otherAmount: leftAmount)
                    Circle()
                        .fill(Color.green.opacity(0.85))
                        .frame(width: rightBallSize, height: rightBallSize)
                        .overlay(
                            Text("$\(Int(rightAmount))")
                                .foregroundColor(.white)
                                .font(.system(size: min(12, rightBallSize * 0.4), weight: .bold))
                                .minimumScaleFactor(0.5)
                        )
                        .offset(
                            x: ballDistanceFromCenter,
                            y: -(rightBallSize/2 + beamHeight/2)
                        )
                }
                // Apply rotation to the beam and balls as a group
                .rotationEffect(.degrees(tiltAngle), anchor: .center)
                .position(x: centerX, y: centerY)
            }
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