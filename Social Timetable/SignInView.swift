//
//  SignInView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 21/2/2023.
//

import SwiftUI
import GoogleSignInSwift
import AuthenticationServices
import FacebookLogin

import WebKit

struct SignInView: View {
    
    @State var isPresenting = false
    
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(colorScheme == .light ? "social-timetable-black" : "social-timetable-white")
                    .resizable()
                    .scaledToFit()
                Spacer()
                Button(action: {
                    viewModel.authenticateWithGoogle()
                }, label: {
                    HStack {
                        Image("Google-icon")
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("Continue with Google")
                            .foregroundColor(.black)
                            .bold()
                    }
                    .frame(width: UIScreen.main.bounds.width / 1.5, height: 45)
                    .background(.white)
                })
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black, lineWidth: 1)
                )
                .cornerRadius(6)
                .padding(.bottom)
                
                Button(action: {
                    viewModel.authenticateWithFacebook()
                }, label: {
                    HStack {
                        Image("Facebook-logo")
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("Continue with Facebook")
                            .foregroundColor(.black)
                            .bold()
                    }
                    .frame(width: UIScreen.main.bounds.width / 1.5, height: 45)
                    .background(.white)
                })
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black, lineWidth: 1)
                )
                .cornerRadius(6)
                .padding(.bottom)

                SignInWithAppleButton(.continue, onRequest: { request in
                    viewModel.handleSignInWithAppleRequest(request)
                }, onCompletion: { response in
                    viewModel.handleSignInWithAppleCompletion(response)
                })
                .signInWithAppleButtonStyle(.whiteOutline)
                .frame(width: UIScreen.main.bounds.width / 1.5, height: 45)
                .padding(.bottom)

                
                NavigationLink(destination: {
                    LoginView()
                }, label: {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Continue with Email")
                            .bold()
                    }
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width / 1.5, height: 45)
                    .background(.white)
                })
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black, lineWidth: 1)
                )
                .cornerRadius(6)
                
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
                                    Image(systemName: "x.circle.fill")
                                        .foregroundColor(.red)
                                        .imageScale(.large)
                                })
                                .buttonStyle(.bordered)
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

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignInView()
            SignInView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(AppViewModel())
    }
}
