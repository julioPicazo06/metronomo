import SwiftUI

// MARK: - MetronomeSubdivisionRow (View)
// Extra clicks per beat (1/2/3/4). Dots still show measure beats; audio uses clicksPerBeat.

struct MetronomeSubdivisionRow: View {
    let modelView: MetronomeModelView

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(MetronomeCopy.Screen.subdivision)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
            HStack(spacing: 10) {
                ForEach(Subdivision.allCases, id: \.self) { subdivision in
                    Button {
                        modelView.selectSubdivision(subdivision)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: subdivision.symbolName)
                                .font(.title3)
                            if subdivision == .triplet {
                                Text(MetronomeCopy.SubdivisionLabel.tripletBadge)
                                    .font(.caption2.bold())
                            }
                        }
                        .foregroundStyle(modelView.subdivision == subdivision ? AppTheme.success : AppTheme.info)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    modelView.subdivision == subdivision ? AppTheme.success : AppTheme.border.opacity(0.35),
                                    lineWidth: modelView.subdivision == subdivision ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(subdivision.title)
                    
                }
            }
        }
    }
}
