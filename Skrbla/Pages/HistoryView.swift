//
//  HistoryView.swift
//  Skrbla
//
//  Created by Michal Hájek on 26.08.2025.
//

import SwiftUI

// MARK: - History View
struct HistoryView: View {
    @State private var selectedFilter = 0
    private let filters = ["Vše", "Dnes", "Tento týden", "Tento měsíc"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Historie")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Filter tabs (horizontální scroll uvnitř hlavního svislého scrollu je OK)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(filters.enumerated()), id: \.offset) { index, filter in
                            FilterChip(
                                title: filter,
                                isSelected: selectedFilter == index
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedFilter = index
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // History list
                LazyVStack(spacing: 12) {
                    ForEach(0..<30) { index in
                        HistoryItemCard(index: index)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .scrollIndicators(.automatic)
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.white.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - History Item Card
struct HistoryItemCard: View {
    let index: Int
    
    private let colors: [Color] = [.blue, .green, .orange, .purple, .red]
    private let titles = ["Položka A", "Položka B", "Položka C", "Položka D", "Položka E"]
    private let dates = ["2 hodiny", "1 den", "3 dny", "1 týden", "2 týdny"]
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(colors[index % colors.count].opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(colors[index % colors.count])
                        .font(.system(size: 20))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(titles[index % titles.count])
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Přidáno před \(dates[index % dates.count])")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("+50 Kč")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.green)
                
                Text("Příjem")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                )
        )
    }
}

#Preview {
    HistoryView()
}
