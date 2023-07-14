import SwiftUI
import BmobChatAi

struct ChatMessage: Identifiable, Equatable { // 添加 Equatable 协议
    var id = UUID()
    var message: String
    var isMe: Bool
    var typing: Bool = false
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool { // 实现 == 函数
        lhs.id == rhs.id && lhs.message == rhs.message && lhs.isMe == rhs.isMe
    }
    
    init(message: String?, isMe: Bool, typing: Bool = false) {
        self.message = message!
        self.isMe = isMe
        self.typing = typing
    }
}

class ChatViewModel: ObservableObject {
    // 聊天记录列表
    @Published var messages: [ChatMessage] = [
        ChatMessage(message: "你好，有什么我可以为你提供的帮助吗？", isMe: false)
    ]
    
    // 实例化AI类
    let chatAI = BmobChatAiTest(SecretKey: "fda2aa4220549f74")
    //    let chatAI = BmobChatAi(SecretKey: "fda2aa4220549f74")
    
    func setPrompt(message:String) {
        print(message)
        chatAI.setPrompt(message:message)
    }
    
    init() {
        // 连接websock 域名参数可不传
        chatAI.connect("https://api.bmobcloud.com")
        
        chatAI.onError = { error in
            // 处理 WebSocket 连接中的错误
            print("WebSocket \(error) 连接出现错误：\(error.localizedDescription)")
            self.chatAI.connect()
        }
        
        chatAI.onReceiveMessage = { [weak self] message in
            DispatchQueue.main.async {
                if self?.messages[self!.messages.count - 1].typing == false{
                    DispatchQueue.main.async {
                        self?.messages[self!.messages.count - 1].message = ""
                    }
                }
                
                self?.messages[self!.messages.count - 1].typing = true
                // 检查消息是否包含 chatgpt ai 的最终响应
                if message == "done" {
                    // 将 typing 属性设置为 false，表示打字效果已完成
                    DispatchQueue.main.async {
                        self?.messages[self!.messages.count - 1].typing = false
                    }
                } else {
                    // 使用延迟操作来模拟打字效果
                    DispatchQueue.main.async {
                        self?.messages[self!.messages.count - 1].message.append(message)
                    }
                }
                
                
            }
        }
    }
    
    func sendMessage(_ text: String) {
        
        // 发送一条消息给 chatgpt ai
        let dictionary: [String: Any] = [
            "messages": [
                [
                    "content": text,
                    "role": "user"
                ]
            ],
            "session": "b1"
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            // use jsonString as you want
            chatAI.send(message: jsonString)
            // 添加新的聊天记录
            DispatchQueue.main.async {
                self.messages.append(ChatMessage(message: text, isMe: true))
            }
            print("发送ok")
            
            //        插入一条空消息
            DispatchQueue.main.async {
                self.messages.append(ChatMessage(message: "", isMe: false, typing: false))
            }
            
        }
    }
}


struct ChatView: View {
    //    实例化连接
    @StateObject private var viewModel = ChatViewModel()
    
    @State private var newMessage = ""
    
    @State private var showingAlert = false
    
    let info:Item
    
    var body: some View {
        VStack {
            // 聊天记录列表
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message.message, isMe: message.isMe)
                                .id(message.id)
                        }
                    }
                }
                .onAppear {
                    // 在视图出现时自动滚动到底部
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                    print("OK.\(info.prompt)")
                    
                    //                    设置setPrompt
                    viewModel.setPrompt(message: info.prompt)
                }
                .onChange(of: viewModel.messages) { _ in
                    // 在聊天记录列表发生变化时自动滚动到底部
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .padding()
            
            // 文本输入框和发送按钮
            HStack {
                TextField("请输入...", text: $newMessage, onCommit:{
                    // 添加新的聊天记录
                    //                    viewModel.messages.append(ChatMessage(message: newMessage, isMe: true))
                    //                    newMessage = ""
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                
                Button(action: {
                    
                    if newMessage == ""{
                        print("不允许为空")
                        showAlert(title: "温馨提醒", message: "发送内容不能为空！", buttonTitle: "OK")
                        return
                    }
                    
                    // 发送新的聊天消息
                    viewModel.sendMessage(newMessage)
                    newMessage = ""
                }) {
                    Text("发送")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .padding(.trailing)
            }
        }
        .navigationBarTitle(info.name)
        .background(Color(UIColor.systemGray6))
    }
    
    
}


func showAlert(title: String, message: String, buttonTitle: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
    
    if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
        topViewController.present(alert, animated: true, completion: nil)
    }
}

struct ChatBubble: View {
    var message: String
    var isMe: Bool
    
    var body: some View {
        
        
        HStack {
            if isMe {
                Spacer()
                Text(message)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = message
                        }) {
                            Text("复制")
                            Image(systemName: "doc.on.doc")
                        }
                    }
            } else {
                Text(message)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = message
                        }) {
                            Text("复制")
                            Image(systemName: "doc.on.doc")
                        }
                    }
                Spacer()
            }
        }
        
        .edgesIgnoringSafeArea(.all) // 忽略安全区域边缘
        .padding(.vertical, 4)
        .onTapGesture {
            hideKeyboard()
        }
        
        
        
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let item = Item(id: 1, name: "全知全能", categoryId: 1,prompt: "",img: "")
        ChatView(info: item)
    }
}
