//
//  ContentView.swift
//  Calculator_swiftui
//
//  Created by 香宁雨 on 2021/10/31.
//

import SwiftUI

struct ContentView: View {
    var VNumbers = [["AC","+/-","%","÷"],
                   ["7","8","9","×"],
                   ["4","5","6","-"],
                   ["1","2","3","+"],
                   ["0","π",".","="]]
    var HNumbers = [["(",")","AC","+/-","%","÷"],
                    ["sin","sinh","7","8","9","×"],
                    ["cos","cosh","4","5","6","-"],
                    ["tan","tanh","1","2","3","+"],
                    ["x!","e","0","π",".","="]]
    
    @State var orient = UIDevice.current.orientation
    
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    var body: some View {
        Group{
            if !orient.isLandscape{
            GeometryReader{ geo in
                VStack{
                    Spacer()
                    Text("1+1")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(width: geo.size.width, height: geo.size.height/3, alignment: .center)

                    ForEach((0...4),id:\.self){row in
                        HStack{
                            ForEach((0...3),id:\.self){col in
                                if col<3{
                                    if row == 0{
                                        ButtonView(color: Color(UIColor.lightGray),text: self.VNumbers[row][col],textColor: Color.black)
                                    }else{
                                        ButtonView(color: Color(UIColor.darkGray),text: self.VNumbers[row][col])
                                    }
                                } else {
                                    ButtonView(color: Color.orange,text: self.VNumbers[row][col])
                                }
                            }
                        }
                        .padding(3)
                    }
                }
            }
        } else {
            GeometryReader{ geo in
                    VStack{
                        Spacer()
                        Text("1+1")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: geo.size.width, height: geo.size.height/3, alignment: .center)
    
                        ForEach((0...4),id:\.self){row in
                            HStack{
                                ForEach((0...5),id:\.self){col in
                                    if col<4{
                                        if row == 0{
                                            RectangleButtonView(color: Color(UIColor.lightGray),text: self.HNumbers[row][col],textColor: Color.black)
                                        }else{
                                            RectangleButtonView(color: Color(UIColor.darkGray),text: self.HNumbers[row][col])
                                        }
                                    } else {
                                        RectangleButtonView(color: Color.orange,text: self.HNumbers[row][col])
                                    }
                                }
                            }
                            .padding(3)
                        }
                    }
                }
            }
        }.onReceive(orientationChanged){_ in
            self.orient = UIDevice.current.orientation
        }
    
    }
}

struct RectangleButtonView: View{
    var color: Color
    var text: String
    var textColor = Color.white
    
    
    var body : some View{
        
        GeometryReader{ geo in
            Button(action:{}){
                ZStack{
                    RoundedRectangle(cornerSize: CGSize(width:10,height:geo.size.height))
                        .foregroundColor(color)
                    Text(text).font(.title).fontWeight(.bold).foregroundColor(textColor)
                }
            }
        }
    }
}

struct ButtonView:View{
    var color: Color
    var text: String
    var textColor = Color.white
    
    var body: some View {
        GeometryReader{ geo in
            Button(action:{}){
                ZStack{
                    Circle()
                        .frame(width: geo.size.width,height:geo.size.height).foregroundColor(color)
                    Text(text).font(.title).fontWeight(.bold).foregroundColor(textColor)
                }
            }
        }
    }
}
        

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.light).previewInterfaceOrientation(.portrait)
//        ContentView().preferredColorScheme(.dark).previewInterfaceOrientation(.portrait)
    }
}

