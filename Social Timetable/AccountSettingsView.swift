//
//  AccountSettingsView.swift
//  Social Timetable
//
//  Created by Hugh Drummond on 7/1/2023.
//

import SwiftUI

struct AccountSettingsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var user: User?
    @State var displayName: String = ""
    @State var color: Color = .accentColor
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        List {
            if let user = user {
                Label(user.email, systemImage: "envelope")
                Label(title: {
                    TextField("Username", text: $displayName)
                        .padding(5)
                        .background(colorScheme == .light ? Color(0xD9D9D9) : Color(0x3c3c3c))
                        .containerShape(RoundedRectangle(cornerRadius: 5))
                        .onChange(of: displayName, perform: { newVal in
                            if displayName.count > 12 {
                                displayName = displayName.prefix(12).description
                            }
                        })
                        .onDisappear() {
                            if !displayName.isEmpty {
                                if user.displayName != displayName {
                                    user.displayName = displayName
                                    viewModel.setDisplayName(name: displayName)
                                }
                            }
                        }
                }, icon: {
                    Image(systemName: "person")
                })
                Label(title: {
                    ColorPicker("", selection: $color, supportsOpacity: false)
                        .onDisappear() {
                            if let hex = color.hex() {
                                if user.color != hex {
                                    user.color = hex
                                    viewModel.setUserColor(hex: hex)
                                }
                            }
                        }
                        .frame(width: 0)
                        .padding(.horizontal)
                }, icon: {
                    Image(systemName: "paintpalette")
                })
                .onAppear() {
                    displayName = user.displayName
                    color = Color(user.color)
                }
                Label(title: {
                    Text(user.tag)
                        .foregroundColor(.gray)
                }, icon: {
                    Image(systemName: "lanyardcard")
                })
            }
            Button(action: {
                viewModel.signOut()
            }) {
                Label("Logout", systemImage: "lock")
            }

        }

    }
}

struct AccountSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView(user: .constant(User.sampleData))
            .environmentObject(AppViewModel.sampleData)
        
    }
}
