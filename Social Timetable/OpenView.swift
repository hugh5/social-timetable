//
//  OpenView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 5/1/2023.
//

import SwiftUI

struct OpenView: View {
    
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            if (viewModel.signedIn) {
                MonthView(date: .now)
            } else {
                AuthView()
            }
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.signedIn = viewModel.isSignedIn
        }
    }
}

struct OpenView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
