//
//  InAppPurchaseView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 19/7/23.
//

import SwiftUI

struct InAppPurchaseView: View {
    @StateObject private var iapVM = InAppPurchaseViewModel.shared
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
           nav
            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 12) {
                        IAPCardComponent(imageIcon: "handIcon",
                                         boldText: "Powered by GPT 4",
                                         normalText: "Latest ChatGPT AI Model")
                        IAPCardComponent(imageIcon: "higher",
                                         boldText: "Higher Word Limit",
                                         normalText: "Type Longer Messages")
                        IAPCardComponent(imageIcon: "noLimits",
                                         boldText: "No Limits",
                                         normalText: "Have Unlimited Dialogues")
                        IAPCardComponent(imageIcon: "NoAdds",
                                         boldText: "No Ads",
                                         normalText: "Enjoy AISocial Without Ads")
                        ZStack {
                            VStack(spacing: 12) {
                                purchaseButtons
                                colorButton
                                HStack(spacing: 20) {
                                  term
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 10, height: 10)
                                    privacyPolicy
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 10, height: 10)
                                    cancelAnyTime
                                }
                                .padding(.top, 20)
                            }
                            .padding(.bottom, 50)
                        }
                        .frame(width: UIScreen.main.bounds.width-32, height: 350)
                        .background(AppColors.themeColor)
                        .cornerRadius(10)
                    }
                }
                .frame(height: geo.size.height)
                .background(.white)
                .cornerRadius(12)
                .padding(.top)
                .offset(y: -30)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }

    @ViewBuilder
    private var purchaseButtons: some View {
        if let currentOffering = iapVM.currentOfferings {
            ForEach(currentOffering.availablePackages) { pkg in
                Button {
                    // action here
                    iapVM.purchase(pkg: pkg)
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                        .foregroundColor(.white)
                        .background(.white)
                        .cornerRadius(10)
                        .frame(width: UIScreen.main.bounds.width/1.2, height: 70)
                        .overlay {
                            HStack {
                                Circle()
                                    .stroke()
                                    .fill(.gray)
                                    .frame(width: 20, height: 20)
                                VStack(alignment: .leading) {
                                    Text("\(pkg.storeProduct.subscriptionPeriod?.durationTitle ?? "")")
                                        .bold()
                                        .foregroundColor(AppColors.themeColor)
                                    Text("3 Days free then, \(pkg.storeProduct.localizedPriceString)")
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                Rectangle()
                                    .frame(width: 80, height: 70)
                                    .foregroundColor(AppColors.buttonColor)
                                    .cornerRadius(10)
                                    .offset(x: 8)
                                    .overlay {
                                        if pkg.storeProduct.subscriptionPeriod?.unit == .year {
                                            Text("Save 84%")
                                                .bold()
                                                .foregroundColor(AppColors.themeColor)
                                                .lineLimit(2)
                                        }
                                    }
                            }
                            .padding(8)
                        }
                }
                .padding(.top)
                .disabled(iapVM.isPurchasing)
            }
        }
    }

    private var cancelAnyTime: some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel Anytime")
                .font(.system(size: 12))
                .bold()
                .foregroundColor(.white)
        }
    }
    private var privacyPolicy: some View {
        Button {
        } label: {
            Text("Privacy Policy")
                .font(.system(size: 12))
                .bold()
                .foregroundColor(.white)
        }
    }
    private var term: some View {
        Button {
        } label: {
            Text("Terms")
                .font(.system(size: 12))
                .bold()
                .foregroundColor(.white)
        }

    }
    private var colorButton: some View {
        Button {
        } label: {
            Text("Start Free Trial and Plan")
                .font(.system(size: 25))
                .bold()
                .padding(16)
                .frame(width: UIScreen.main.bounds.width/1.2, height: 70)
                .background(AppColors.buttonColor)
                .cornerRadius(10)
        }
    }
    private var yearlyButton: some View {
        Button {
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .stroke()
                .foregroundColor(.white)
                .background(.white)
                .cornerRadius(10)
                .frame(width: UIScreen.main.bounds.width/1.2, height: 70)
                .overlay {
                    HStack {
                        Circle()
                            .stroke()
                            .fill(.gray)
                            .frame(width: 20, height: 20)
                        VStack(alignment: .leading) {
                            Text("Yearly")
                                .bold()
                                .foregroundColor(AppColors.themeColor)
                            Text("$39.99/year")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Rectangle()
                            .frame(width: 80, height: 70)
                            .foregroundColor(AppColors.buttonColor)
                            .cornerRadius(10)
                            .offset(x: 8)
                            .overlay {
                                Text("Save 84%")
                                    .bold()
                                    .foregroundColor(AppColors.themeColor)
                                    .lineLimit(2)
                            }
                    }
                    .padding(8)
                }
        }
    }

    private var weeklyButton: some View {
        Button {
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .stroke()
                .foregroundColor(.white)
                .background(.white)
                .cornerRadius(10)
                .frame(width: UIScreen.main.bounds.width/1.2, height: 70)
                .overlay {
                    HStack {
                        Circle()
                            .stroke()
                            .fill(.gray)
                            .frame(width: 20, height: 20)
                        VStack(alignment: .leading) {
                            Text("Weekly")
                                .bold()
                                .foregroundColor(AppColors.themeColor)
                            Text("3 Days free, then $4.99/week")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(8)
                }
        }

    }
    var nav: some View {
        ZStack(alignment: .top) {
            Image("topShape")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: 150)
            HStack(alignment: .center) {
                Image(systemName: "chevron.left")
                     .padding(.leading, 16)
                    .onTapGesture {
                        dismiss()
                    }
                Spacer()
                Text("Unlock Unlimited Access")
                    .font(.system(size: 25))
                  .padding(.trailing, 32)
                Spacer()
            }
            .bold()
            .font(.system(size: 30))
            .padding(.top, 60)
            .foregroundColor(.white)
            .background(AppColors.themeColor)
        }
    }
}
    struct InAppPurchaseView_Previews: PreviewProvider {
        static var previews: some View {
            InAppPurchaseView()
        }
    }
