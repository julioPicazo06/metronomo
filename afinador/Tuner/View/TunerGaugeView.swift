import SwiftUI

// MARK: - TunerGaugeView (View)
// Semicircle cents meter (−50…+50). Arc is inset so it is not clipped at the top.
// Debug: needle color — lime = inTune, cyan = hasSignal, gray = idle at 0 cents.
// Geometry: center sits on the diameter; radius fits inside width/2 and height minus label row.

struct TunerGaugeView: View {
    let cents: Double
    let isInTune: Bool
    let isActive: Bool

    var body: some View {
        Canvas { context, size in
            let stroke: CGFloat = 8
            let labelSpace: CGFloat = 20
            let horizontalInset: CGFloat = 12
            let availableHeight = max(0, size.height - labelSpace - stroke / 2)
            let availableWidth = max(0, size.width / 2 - horizontalInset)
            let radius = min(availableWidth, availableHeight)
            let center = CGPoint(x: size.width / 2, y: stroke / 2 + radius)

            var arc = Path()
            arc.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
            context.stroke(
                arc,
                with: .color(AppTheme.border.opacity(0.7)),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )

            var greenArc = Path()
            greenArc.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(96),
                endAngle: .degrees(84),
                clockwise: false
            )
            context.stroke(
                greenArc,
                with: .color(AppTheme.success),
                style: StrokeStyle(lineWidth: stroke, lineCap: .round)
            )

            for mark in stride(from: -50.0, through: 50.0, by: 5) {
                let angle = angle(for: mark)
                let isMajor = mark.truncatingRemainder(dividingBy: 25) == 0
                let outer = point(center: center, radius: radius, angle: angle)
                let inner = point(center: center, radius: radius - (isMajor ? 14 : 8), angle: angle)
                var tick = Path()
                tick.move(to: inner)
                tick.addLine(to: outer)
                context.stroke(tick, with: .color(AppTheme.border.opacity(0.85)), lineWidth: 1.5)
            }

            let needleAngle = angle(for: min(50, max(-50, cents)))
            let tip = point(center: center, radius: radius - 6, angle: needleAngle)
            var needle = Path()
            needle.move(to: center)
            needle.addLine(to: tip)
            let needleColor = isInTune ? AppTheme.success : (isActive ? AppTheme.info : AppTheme.border)
            context.stroke(
                needle,
                with: .color(needleColor),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            let hub = Path(ellipseIn: CGRect(x: center.x - 5, y: center.y - 5, width: 10, height: 10))
            context.fill(hub, with: .color(needleColor))
        }
        .overlay(alignment: .bottom) {
            HStack {
                Text(TunerCopy.Gauge.minus50)
                Spacer()
                Text(TunerCopy.Gauge.plus50)
            }
            .font(.caption2.monospaced())
            .foregroundStyle(AppTheme.textMuted)
            .padding(.horizontal, 4)
        }
        .accessibilityLabel(TunerCopy.Gauge.accessibilityNeedle)
    }

    private func angle(for cents: Double) -> Angle {
        .degrees(180 - (cents + 50) * 1.8)
    }

    private func point(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + radius * CGFloat(cos(angle.radians)),
            y: center.y - radius * CGFloat(sin(angle.radians))
        )
    }
}
