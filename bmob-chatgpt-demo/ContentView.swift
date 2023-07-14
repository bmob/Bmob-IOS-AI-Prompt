//
//  ContentView.swift
//  bmob-chatgpt-demo
//  fda2aa4220549f74
//  Created by magic on 2023/7/6.
//

import SwiftUI

import BmobChatAi

//struct Category {
//    let id: Int
//    let name: String
//}
//
//struct Item {
//    let id: Int
//    let name: String
//    let categoryId: Int
//}

struct ContentView: View {
    let categories = [
        Category(id: 1, name: "全能问题"),
        Category(id: 2, name: "娱乐"),
        Category(id: 3, name: "效率")
    ]
  
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.id) { category in
                    Section(header: Text(category.name)) {
                        ForEach(items.filter { $0.categoryId == category.id }, id: \.id) { item in
                            NavigationLink(destination: ChatView( info: item)) {
//                                #3493ff
                                Image(systemName: item.img).foregroundColor(Color(red: 52/255, green: 147/255, blue: 255/255))
                                Text(item.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("发现")
           
        }
    }
    
}
//The production process of water cup
struct ItemDetailView: View {
    let item: Item
    
    var body: some View {
        Text(item.name)
            .navigationTitle(item.name)
    }
}

func loadData() {
    // 在视图显示时调用的回调函数
    
    //    webSocketManager.connect()
    
    //    // 设置闭包属性，在接收到 WebSocket 文本消息时进行处理
    //    webSocketManager.onReceiveMessage = { message in
    //        print("接收到 WebSocket 文本消息：\(message)")
    //        // 在这里进行接收到 WebSocket 文本消息后的处理
    //    }
    //    // 设置错误处理闭包属性
    //    webSocketManager.onError = { error in
    //        print("WebSocket 出现错误：\(error.localizedDescription)")
    //    }
    // 发送消息
    //        webSocketManager.send(message: "ping")
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}
