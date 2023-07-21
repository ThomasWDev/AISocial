//
//  CustomTabBar.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 15/6/23.
//

//
//  ContentView.swift
//  CustomTabbarSwiftUI
//
//  Created by Zeeshan Suleman on 03/03/2023.
//

import SwiftUI

enum TabbedItems: Int, CaseIterable {
    case chat = 0
    case imageArt
    case pdfUpload
    case social
    var title: String {
        switch self {
        case .chat:
            return "Chat"
        case .imageArt:
            return "Image Art"
        case .pdfUpload:
            return "Pdf Upload"
        case .social:
            return "Social"
        }
    }
    var iconName: String {
        switch self {
        case .chat:
            return "chat"
        case .imageArt:
            return "imageArt"
        case .pdfUpload:
            return "pdfImage"
        case .social:
            return "social"
        }
    }
}

struct MainTabbedView: View {
    @State var selectedTab = 0
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ContentView()
                    .tag(0)

                ImageGeneratorView()
                    .tag(1)

                PdfView()
                    .tag(2)
                NavigationStack {
                    AuthView()
                }
                .tag(3)
            }

            ZStack {
                HStack {
                    ForEach((TabbedItems.allCases), id: \.self) { item in
                        Button {
                            selectedTab = item.rawValue
                        } label: {
                            customTabItem(imageName:
                                            item.iconName,
                                          title: item.title,
                                          isActive:
                                        (selectedTab == item.rawValue))
                        }
                    }
                }
                .padding(6)
            }
            .frame(height: 85)
            .background(AppColors.themeColor)
           // .cornerRadius(10)
           // .padding(.horizontal,)
        }
        .ignoresSafeArea()
    }
}

extension MainTabbedView {
    func customTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            Image(imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .white : .white)
                .frame(width: 25, height: 25)
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .white : .white)
            }
            Spacer()
        }
        .frame(width: isActive ? .infinity : 70, height: 70)
        .background(isActive ? AppColors.shapeColor : .clear)
        .cornerRadius(30)
    }
}

struct MainTabbedView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabbedView().environmentObject(LaunchScreenStateManager())
    }
}
