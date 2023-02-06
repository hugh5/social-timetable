//
//  OpenView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 5/1/2023.
//

import SwiftUI
import GoogleSignInSwift

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

struct SignInView: View {
    
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Image(colorScheme == .light ? "social-timetable-black" : "social-timetable-white")
                .resizable()
                .scaledToFit()
                .padding(.vertical, 100)
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: colorScheme == .light ? .dark : .light, style: .wide, state: .normal), action: {
                viewModel.authenticatWithGoogle()
            })
            .disabled(viewModel.isLoading)
            .fixedSize()
            .padding(.vertical, 100)
            if (viewModel.isLoading) {
                ProgressView()
                    .padding()
            }
        }
        .padding()
    }
}

struct OpenView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignInView()
            SignInView()
                .preferredColorScheme(.dark)
        }
            .environmentObject(AppViewModel())
    }
}
