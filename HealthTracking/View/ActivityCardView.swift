//
//  ActivityCardView.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/1/12.
//

import SwiftUI

struct ActivityCardView: View {

    @State var activity: ActivityModel

    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)

            VStack(spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(activity.title)
                            .font(.system(size: 16))

                        Text(activity.subTitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: activity.image)
                        .foregroundStyle(activity.tintColor)
                }

                Text(activity.amount)
                    .font(.system(size: 24))
                    .minimumScaleFactor(0.6)
                    .bold()
                    .padding(.bottom, 10)
            }
            .padding()
        }
    }
}

#Preview {
    ActivityCardView(activity: ActivityModel( id: 0, title: "Daily Steps", subTitle: "Goal: 10,000", image: "figure.walk", tintColor: .green, amount: "6,234"))
}
