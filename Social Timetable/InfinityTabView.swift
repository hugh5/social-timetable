//
//  InfinityTabView.swift
//  Social Timetable
//
//  Created by beader on 9/10/2022.
//  Credit: https://gist.github.com/beader/e1312aa5b88af30407bde407235fbe67
//  Adapted by Hugh Drummond on 20/2/2023
//

import SwiftUI

struct TabContentView: View {
    let colors: [Color] = [.red, .green, .blue]
    @State var page = 10
    var body: some View {
        GeometryReader { geometry in
            VStack {
                InfiniteTabPageView(currentPage: $page, width: geometry.size.width) { curr in
                    Text("\(curr.description)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.teal)
                }
                .frame(height: 300)
                Button("+", action: {
                    page += 1
                })
            }
        }
    }
}


struct InfiniteTabPageView<Content: View>: View {
    @GestureState private var translation: CGFloat = .zero
    @State private var offset: CGFloat = .zero

    var currentPage: Binding<Int>
    private let width: CGFloat
    private let animationDuration: CGFloat = 0.25
    let content: (_ page: Int) -> Content
    
    init(currentPage: Binding<Int>, width: CGFloat = 390, @ViewBuilder content: @escaping (_ page: Int) -> Content) {
        self.currentPage = currentPage
        self.width = width
        self.content = content
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($translation) { value, state, _ in
                let translation = min(width, max(-width, value.translation.width))
                state = translation
            }
            .onEnded { value in
                offset = min(width, max(-width, value.translation.width))
                let predictEndOffset = value.predictedEndTranslation.width * 2
                withAnimation(.easeOut(duration: animationDuration)) {
                    if offset < -width / 2 || predictEndOffset < -width {
                        offset = -width
                    } else if offset > width / 2 || predictEndOffset > width {
                        offset = width
                    } else {
                        offset = 0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    if offset < 0 {
                        currentPage.wrappedValue += 1
                    } else if offset > 0 {
                        currentPage.wrappedValue -= 1
                    }
                    offset = 0
                }
            }
    }
    
    var body: some View {
        ZStack {
            content(pageIndex(currentPage.wrappedValue + 2) - 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: CGFloat(1 - offsetIndex(currentPage.wrappedValue - 1)) * width)

            content(pageIndex(currentPage.wrappedValue + 1) + 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: CGFloat(1 - offsetIndex(currentPage.wrappedValue + 1)) * width)

            content(pageIndex(currentPage.wrappedValue + 0) + 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: CGFloat(1 - offsetIndex(currentPage.wrappedValue)) * width)
        }
        .contentShape(Rectangle())
        .offset(x: translation)
        .offset(x: offset)
        .gesture(dragGesture)
        .clipped()
    }
    
    private func pageIndex(_ x: Int) -> Int {
        // 0 0 0 3 3 3 6 6 6 . . . periodic function
        // used to decide 3 content pages which should be displayed respectively
        Int((CGFloat(x) / 3).rounded(.down)) * 3
    }
    
    
    private func offsetIndex(_ x: Int) -> Int {
        // 0 1 2 0 1 2 0 1 2 ... 周期函数
        // 用来决定静止状态 3 个 content 的摆放顺序
        if x >= 0 {
            return x % 3
        } else {
            return (x + 1) % 3 + 2
        }
    }
}

struct TabContentView_Previews: PreviewProvider {
    static var previews: some View {
        TabContentView()
    }
}
