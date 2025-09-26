//
//  InfoView.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 22.09.2025.
//

import SwiftUI

struct InfoView: View {
    @State private var showAchieving: Bool = true
    @State private var showRecommendations: Bool = false
    @State private var showHowItWorks: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                howToAchieveSection

                creatorRecomandationSection

                howNextDreamWorksSections
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Info")
    }
}

#Preview {
    InfoView()
}

extension InfoView {
    
    private var howNextDreamWorksSections: some View {
        DisclosureGroup(isExpanded: $showHowItWorks) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Next Dream is an app designed to help you achieve your dreams. It features three main pages:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Group {
                    (
                        Text("1. ")
                        + Text("Tasks & Statistics – ").fontWeight(.semibold)
                        + Text("Create tasks, track your progress, and view detailed statistics.")
                    )
                    (
                        Text("2. ")
                        + Text("Daily Dashboard – ").fontWeight(.semibold)
                        + Text("See your daily tasks at a glance, so you always know what needs to be done today.")
                    )
                    (
                        Text("3. ")
                        + Text("Calendar – ").fontWeight(.semibold)
                        + Text("Review a clear overview of what you’ve completed and when, helping you stay organized and motivated.")
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("In short: Next Dream keeps your goals, daily tasks, and progress all in one place, making it easier to stay focused and achieve your dreams.")
                    .font(.headline)
                    .padding(.top, 8)
            }
        } label: {
            HStack {
                Text("How NextDream Works & How to Get the Most Out of It")
                    .font(.headline)
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private var creatorRecomandationSection: some View {
        DisclosureGroup(isExpanded: $showRecommendations) {
            VStack(alignment: .leading, spacing: 12) {
                Text("A few simple principles to keep momentum:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Group {
                    (
                        Text("1. ")
                        + Text("Maintain a healthy body – ").fontWeight(.semibold)
                        + Text("prioritize sleep, nourish yourself with proper nutrition, and engage in regular exercise.")
                    )
                    (
                        Text("2. ")
                        + Text("Understand your “why” – ").fontWeight(.semibold)
                        + Text("clarity of purpose fuels every step you take.")
                    )
                    (
                        Text("3. ")
                        + Text("Cultivate a strong desire – ").fontWeight(.semibold)
                        + Text("let your ambition drive you relentlessly. (Chapter 2, Think and Grow Rich)")
                    )
                    (
                        Text("4. ")
                        + Text("Follow your path, even if it’s unconventional – ").fontWeight(.semibold)
                        + Text("trust your journey and embrace what makes it uniquely yours.")
                    )
                    (
                        Text("5. ")
                        + Text("Conduct a weekly review – ").fontWeight(.semibold)
                        + Text("reflect, adjust, and stay aligned with your goals.")
                    )
                    (
                        Text("6. ")
                        + Text("Learn from failures – ").fontWeight(.semibold)
                        + Text("analyze what went wrong, grow stronger, and keep moving forward.")
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 8)
        } label: {
            HStack {
                Text("Creator’s Recommendations")
                    .font(.headline)
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private var howToAchieveSection: some View {
        DisclosureGroup(isExpanded: $showAchieving) {
            achivingSection
                .padding(.top, 8)
        } label: {
            HStack {
                Text("How to Achieve a Dream")
                    .font(.headline)
                Spacer()
            }
        }
        .disclosureGroupStyle(.automatic)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private var achivingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achieving a Dream")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)

            Text("Achieving a dream usually requires a mix of mindset, strategy, and consistent effort.")
                .font(.body)
                .foregroundStyle(.secondary)

            Divider()

            Text("Here are the key elements:")
                .font(.title3.weight(.semibold))
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 12) {
                (
                    Text("1. ")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    + Text("Clarity – ")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    + Text("You need to clearly define what your dream is. Vague desires rarely become reality.")
                        .foregroundStyle(.primary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                (
                    Text("2. ")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    + Text("Belief – ")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    + Text("Believing it’s possible (and that you’re capable) fuels persistence through difficulties.")
                        .foregroundStyle(.primary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                (
                    Text("3. ")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    + Text("Planning – ")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    + Text("Breaking the dream into realistic, actionable steps creates a path forward.")
                        .foregroundStyle(.primary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                (
                    Text("4. ")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    + Text("Discipline & Consistency – ")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    + Text("Small, repeated actions often matter more than bursts of effort.")
                        .foregroundStyle(.primary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                (
                    Text("5. ")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    + Text("Resilience – ")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    + Text("Obstacles, failures, and setbacks are inevitable. The ability to adapt and keep going is crucial.")
                        .foregroundStyle(.primary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                (
                    Text("6. ")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    + Text("Learning & Growth – ")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    + Text("Skills, knowledge, and perspective must keep evolving to match the dream.")
                        .foregroundStyle(.primary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                (
                    Text("7. ")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    + Text("Support System – ")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    + Text("Mentors, peers, or a community can encourage, guide, and open opportunities.")
                        .foregroundStyle(.primary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                (
                    Text("8. ")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    + Text("Patience – ")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    + Text("Big dreams take time; staying committed over the long run is essential.")
                        .foregroundStyle(.primary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 4)

            VStack(alignment: .leading, spacing: 8) {
                Text("✨ In short: a dream needs clarity, belief, and relentless action fueled by resilience.")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
