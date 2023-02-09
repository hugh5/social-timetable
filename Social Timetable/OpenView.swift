//
//  OpenView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 5/1/2023.
//

import SwiftUI
import GoogleSignInSwift
import AuthenticationServices
import FacebookLogin

import WebKit

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
    
    @State var isPresenting = false
    
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Spacer()
            Image(colorScheme == .light ? "social-timetable-black" : "social-timetable-white")
                .resizable()
                .scaledToFit()
            Spacer()
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: colorScheme == .light ? .dark : .light, style: .wide, state: .normal), action: {
                viewModel.authenticateWithGoogle()
            })
            .disabled(viewModel.isLoading)
            .frame(width: UIScreen.main.bounds.width / 2)
            .padding(.bottom)

            Button(action: {
                viewModel.authenticateWithFacebook()
            }, label: {
                HStack {
                    Text("f")
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                        .font(.title)
                        .bold(true)
                        .foregroundColor(colorScheme == .light ? Color(0x0165E1) : .white)
                        .background(Circle().foregroundColor(colorScheme == .light ? .white : Color(0x0165E1)))
                    Text("Sign in with Facebook")
                        .foregroundColor(colorScheme == .light ? .white : .black)
                        .font(.subheadline)
                }
                .foregroundColor(colorScheme == .light ? .white : Color(0x0165E1))
                .frame(width: UIScreen.main.bounds.width / 2, height: 45)
                .background(colorScheme == .light ? Color(0x0165E1) : .white)
                .cornerRadius(6)
            })
            .padding(.bottom)

            SignInWithAppleButton(onRequest: { request in
                
            }, onCompletion: { response in
                
            })
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
            .frame(width: UIScreen.main.bounds.width / 2, height: 45)
            .padding(.bottom)

            Button(action: {
                viewModel.authenticateAsTester()
            }, label: {
                HStack {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Sign in as Tester")
                }
                .frame(width: UIScreen.main.bounds.width / 2, height: 45)
                .foregroundColor(.black)
                .background(colorScheme == .light ? Color(0xC5C5C5) : .white)
                .cornerRadius(6)
            })
            .buttonStyle(.plain)

            
            if (viewModel.isLoading) {
                ProgressView()
                    .padding()
            } else {
                Text(viewModel.credentialError)
                    .foregroundColor(.red)
            }
            Spacer()
            Button(action: {
                isPresenting.toggle()
            }, label: {
                Text("Privacy policy")
            })
            .sheet(isPresented: $isPresenting) {
                ZStack {
                    WebView(url: URL(string:"https://www.freeprivacypolicy.com/live/fdd32691-0e63-4b44-ac7b-75a6fb78be9b")!)
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                isPresenting.toggle()
                            }, label: {
                                Image(systemName: "x.circle")
                                    .foregroundColor(.red)
                            })
                            .buttonStyle(.plain)
                        }
                        .padding()
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }
}
 
struct WebView: UIViewRepresentable {
 
    var url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        Task {
            let request = URLRequest(url: url)
            webView.load(request)
        }
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
