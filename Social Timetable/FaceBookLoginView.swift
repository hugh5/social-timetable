//
//  FaceBookLoginView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 7/2/2023.
//

import SwiftUI
import FBSDKLoginKit
import Firebase

struct FaceBookLoginView: UIViewRepresentable {
    
    func makeCoordinator() -> FaceBookLoginView.Coordinator {
            return FaceBookLoginView.Coordinator()
        }
        
        class Coordinator: NSObject, LoginButtonDelegate {
            func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
                if let error = error {
                  print(error.localizedDescription)
                  return
                }
                
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                
            }
            
            func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
                try! Auth.auth().signOut()
            }
        }
        
        func makeUIView(context: UIViewRepresentableContext<FaceBookLoginView>) -> FBLoginButton {
            let view = FBLoginButton()
            view.permissions = ["email"]
            view.delegate = context.coordinator
            return view
        }
        
        func updateUIView(_ uiView: FBLoginButton, context: UIViewRepresentableContext<FaceBookLoginView>) { }
}

struct FaceBookLoginView_Previews: PreviewProvider {
    static var previews: some View {
        FaceBookLoginView()
    }
}
