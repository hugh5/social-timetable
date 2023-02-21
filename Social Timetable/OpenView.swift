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
                ContentView(user: $viewModel.user)
            } else {
                SignInView()
            }
        }
        .onAppear {
            viewModel.signedIn = viewModel.isSignedIn
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct OpenView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AppViewModel())
    }
}
