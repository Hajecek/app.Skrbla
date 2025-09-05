//
//  Card.swift
//  InvitesIntroPage
//
//  Created by Balaji Venkatesh on 11/02/25.
//

import Foundation
import SwiftUI

struct Card: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var image: String
}

let cards: [Card] = [
    .init(image: "test"),
    .init(image: "distance"),
    .init(image: "edit"),
    .init(image: "set-homepage"),
    .init(image: "sports"),
]
