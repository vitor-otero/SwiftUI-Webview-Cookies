//
//  MainView.swift
//  SwiftUI-Webview-Cookies
//
//  Created by Vítor Otero on 26/03/2023.
//

import SwiftUI
import WebKit

struct MainView: View {
    
    let webview = WebView(web: nil, req: URLRequest(url:URL(              string:"https://www.google.com")!))
    
    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
            ZStack{
                Rectangle()
                    .foregroundColor(.white)
                RoundedRectangle(cornerSize: CGSize(width: 4.2, height: 4.2))
                    .frame(width: 150,height: 70)
                    .foregroundColor(.white)
                ProgressView("Loading...")
            }
            webview
            
            ZStack{
                RoundedRectangle(cornerRadius: 30)
                    .frame(width:55, height: 130)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                VStack(spacing: 7){
                    Button(action: {
                        self.webview.goHome()
                    }){
                        Image(systemName: "house.fill")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Divider()
                        .foregroundColor(.black)
                        .frame(width: 35)
                    Spacer()
                    Button(action: {
                        self.webview.reload()
                    }){
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.gray)
                    }
                }.frame(height: 55)
            }.draggable()
                .offset(x:125,
                        y:300)
        }
    }
}

struct DraggableView: ViewModifier {
    @State var offset = CGPoint(x: 0, y: 0)
    
    func body(content: Content) -> some View {
        content
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    self.offset.x += value.location.x - value.startLocation.x
                    self.offset.y += value.location.y - value.startLocation.y
                })
            .offset(x: offset.x, y: offset.y)
    }
}

extension View {
    func draggable() -> some View {
        return modifier(DraggableView())
    }
}

struct WebViewUI_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
