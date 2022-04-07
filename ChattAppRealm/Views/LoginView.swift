//
//  LoginView.swift
//  ChattAppRealm
//
//  Created by Luca Salmi on 2022-04-07.
//

import SwiftUI

struct LoginView: View {
    
    @Binding var isLoggedIn: Bool
    
    @State var userName: String = ""
    @State var password: String = ""
    @State private var showRegisterAccount = false
    @State private var loginErrorAlert = false
    
    
    var body: some View {
        
        let userDao = UserDao()

            
            VStack{
                
                Text("LOGIN")
                    .font(.largeTitle)
                        
                    
                    TextField("Username", text: $userName)
                            .padding()
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                
                
                    
                    SecureInputView("Password", text: $password)
                            .padding()
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                
                HStack{
                    
                    Spacer()
                    
                    Button(action: {
                        
                        if userDao.getUser(userName: userName, password: password){
                            
                            isLoggedIn = true
                            
                        }else{
                            
                            loginErrorAlert = true
                        }
                        
                    }, label: {
                        
                        Text("Login")
                        
                    })
                    .alert("Error logging in, check userame and password", isPresented: $loginErrorAlert) {
                        Button("Ok", role: .cancel){}
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        
                        showRegisterAccount.toggle()
                        
                        
                    }, label: {
                        
                        Text("Register")
                        
                    })
                    .sheet(isPresented: $showRegisterAccount, content: {
                        registerView(userName: $userName, password: $password, userDao: userDao)
                    })
                    
                    Spacer()
                
                }
                .buttonStyle(.bordered)
                .padding(.top)
            }
    }
}


struct registerView: View{
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var userName: String
    @Binding var password: String
    var userDao: UserDao
    
    @State var firstName = ""
    @State var lastName = ""
    @State var mail = ""
    @State var repeatPassword = ""
    
    @State var showSuccessAlert = false
    @State var showFailureAlert = false
    
    
    var body: some View{
        
        VStack{
            
            TextField("username", text: $userName)
                .autocapitalization(.none)
            
            TextField("mail", text: $mail)
                .autocapitalization(.none)
            
            HStack{
                
                TextField("first name", text: $firstName)
                
                TextField("last name", text: $lastName)
                
            }
            
            SecureInputView("password", text: $password)
                .autocapitalization(.none)
            
            SecureInputView("repeat password", text: $repeatPassword)
                .autocapitalization(.none)
            
            HStack{
                
                Spacer()
                
                Button(action: {
                    
                    if password == repeatPassword && textFieldValidatorEmail(mail) && !userName.isEmpty && !mail.isEmpty && !firstName.isEmpty && !password.isEmpty{
                        
                        let user = User()
                        user.username = userName
                        user.email = mail
                        user.name = firstName
                        user.lastName = lastName
                        user.password = password
                        showSuccessAlert = true
                        userDao.saveUser(user: user)
                        
                    }else{
                        showFailureAlert = true
                    }
                    
                    
                    
                }, label: {
                    Text("Register")
                })
                .alert("Account created", isPresented: $showSuccessAlert) {
                    Button("Great!", role: .cancel){
                        dismiss()

                    }
                }
                .alert("Something went wrong, check again", isPresented: $showFailureAlert) {
                    Button("Ok", role: .cancel){}
                }
                
                
                Spacer()
                
                Button(action: {
                    
                    dismiss()
                    
                }, label: {
                    Text("Return")
                })
                
                Spacer()
                
            }
            .buttonStyle(.bordered)
            .padding(.top)
            
            
            
            
            
            
        }
        .textFieldStyle(.roundedBorder)
        .padding(.leading)
        .padding(.trailing)
        
    }
    
    func textFieldValidatorEmail(_ string: String) -> Bool {
        
        if string.count > 100 {
            return false
            
        }
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" // short format
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: string)
        
    }
    
    
}

struct SecureInputView: View {
    
    @Binding private var password: String
    @State private var isSecured: Bool = true
    
    private var title: String
    
    init(_ title: String, text: Binding<String>) {
        
        self.title = title
        self._password = text
        
    }
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(title, text: $password)
                    
                } else {
                    TextField(title, text: $password)
                    
                }
                
            }.padding(.trailing, 32)
            Button(action: {
                isSecured.toggle()
                
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                .accentColor(.gray)
                
            }
            
        }
        
    }
    
    
}