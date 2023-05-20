//
//  InstructionsView.swift
//  RestaurantMatcher
//
//  Created by James Bailey on 20/05/2023.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        Text("Navigate to where you want to search for restaurants and press Search. \n Then select the glowing orange circle and check reviews if you like. If happy with it you can select whether you like it or not. You can see what you liked or disliked in the map as green or red glwing circles. When you are finished press Done and give your phone to your partner for them to try. When they are finished and they press Done you will see where you match!")
            .font(.title2)
            .fontWeight(.regular)
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
