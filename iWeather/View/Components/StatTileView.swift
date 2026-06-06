//
//  StatTileView.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import SwiftUI

struct StatTileView: View {
    let label: String
    let value: String
    let textColor: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(textColor.opacity(0.7))
                .tracking(1)

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.15))
        .cornerRadius(14)
    }
}

struct StatTileView_Previews: PreviewProvider {
    static var previews: some View {
        StatTileView(
            label: "Humidity",
            value: "65%",
            textColor: .white
        )
        .padding()
        .background(Color.blue)
        .previewLayout(.sizeThatFits)
    }
}
