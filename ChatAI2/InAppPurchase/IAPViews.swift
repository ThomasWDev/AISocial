//
//  ContentView.swift
//  PromotionUI
//
//  Created by Thomas Woodfin on 2/6/23.
//
// swiftlint:disable line_length

import SwiftUI
import RevenueCat

struct IAPViews: View {
    @StateObject private var iapVM = InAppPurchaseViewModel.shared
    @Binding var show: Bool
    var body: some View {
        ScrollView {
            // Bleeds into NavigationView
            HStack {
                Button {
                    // action here
                    show = false
                } label: {
                    VStack {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(10)
                    }.background(Color("DarkGray"))
                        .clipShape(Circle())
                }
                Spacer()
                Button {
                    // action here
                    iapVM.restore()
                } label: {
                    Text("Restore")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(Color("DarkGray"))
                        .clipShape(Capsule())
                }
                .disabled(iapVM.isPurchasing)
            }
            Text("Unlock Unlimited Access")
                .foregroundColor(.white)
                .font(.title)
                .bold()
                .padding(.top, 30)
            MiddleView()
                .padding(.top)
            if let currentOffering = iapVM.currentOfferings {
                ForEach(currentOffering.availablePackages) { pkg in
                    Button {
                        // action here
                        iapVM.purchase(pkg: pkg)
                    } label: {
                        VStack {
                            VStack {
                                HStack {
                                    Text("3 days Free Trial, Auto Renewal")
                                        .bold()
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                HStack {
                                    Text("\(pkg.storeProduct.localizedPriceString) / \(pkg.storeProduct.subscriptionPeriod?.periodTitle ?? "No Product")")
                                        .bold()
                                        .foregroundColor(.white)
                                        .font(.title3)
                                    Spacer()
                                }
                            }
                        }.padding()
                            .background(Color("FadeGreen"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("DarkGreen"), lineWidth: 3)
                            )
                    }
                    .padding(.top)
                    .disabled(iapVM.isPurchasing)
                }
            }
            //                    Button {
            //                        // action here
            //                    } label: {
            //                        VStack {
            //                            VStack {
            //                                HStack {
            //                                    Text("3 days Free Trial, Auto Renewal")
            //                                        .bold()
            //                                        .foregroundColor(.gray)
            //                                    Spacer()
            //                                }
            //                                HStack {
            //                                    Text("4.99 / Week")
            //                                        .bold()
            //                                        .foregroundColor(.white)
            //                                        .font(.title3)
            //                                    Spacer()
            //                                }
            //                            }
            //                        }.padding()
            //                            .background(Color("FadeGreen"))
            //                            .cornerRadius(8)
            //                            .overlay(
            //                                RoundedRectangle(cornerRadius: 8)
            //                                    .stroke(Color("DarkGreen"), lineWidth: 3)
            //                            )
            //                    }.padding(.top)
            //                    Button {
            //                        // action here
            //                    } label: {
            //                        VStack {
            //                            HStack {
            //                                VStack {
            //                                    HStack {
            //                                        Text("Auto Renewal")
            //                                            .bold()
            //                                            .foregroundColor(.gray)
            //                                        Spacer()
            //                                    }
            //                                    HStack {
            //                                        Text("39.99 / Year")
            //                                            .bold()
            //                                            .foregroundColor(.white)
            //                                            .font(.title3)
            //                                        Spacer()
            //                                    }
            //                                }
            //                                Text("Save 70%")
            //                                    .bold()
            //                                    .foregroundColor(.black)
            //                                    .padding(10)
            //                                    .background(.white)
            //                                    .clipShape(Capsule())
            //                            }
            //                        }.padding()
            //                            .cornerRadius(8)
            //                            .overlay(
            //                                RoundedRectangle(cornerRadius: 8)
            //                                    .stroke(Color("DarkGray"), lineWidth: 3)
            //                            )
            //                    }
            Button {
                show = false
            } label: {
                HStack {
                    Spacer()
                    Text("Start Free Trial and Plan")
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }.background(Color("DarkGreen"))
                    .cornerRadius(8)
                    .clipShape(Rectangle())
            }.padding(.top)
            Spacer()
            FooterView()
                .padding(.bottom, 10)
        }
        .background(Color.black)
        .showLoadingView(iapVM.isPurchasing, isWhite: true)
        .onChange(of: iapVM.purchaseSuccess) { success in
            if success {
                show = false
            }
        }
        .alert(iapVM.message, isPresented: $iapVM.showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct IAPViews_Previews: PreviewProvider {
    static var previews: some View {
        IAPViews(show: .constant(true))
    }
}

struct FeatureView: View {
    var firstTxt: String
    var secondText: String
    var body: some View {
        VStack {
            HStack {
                Spacer()
                HStack {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding(10)
                        .bold()
                    VStack {
                        HStack {
                            Text(firstTxt)
                                .foregroundColor(.white)
                                .font(.title2)
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Text(secondText)
                                .foregroundColor(.white)
                                .font(.title3)
                            Spacer()
                        }
                    }.padding(.horizontal)
                }
            }
        }
    }
}

struct FooterView: View {
    var body: some View {
        VStack {
            HStack {
                Button {
                    // action here
                } label: {
                    Text("Privacy")
                        .foregroundColor(.gray)
                }
                Text("|").foregroundColor(.gray)
                Button {
                    // action here
                } label: {
                    Text("Terms")
                        .foregroundColor(.gray)
                }
                Spacer()
                Button {
                    // action here
                } label: {
                    Text("Cancel Anytime")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct MiddleView: View {
    var body: some View {
        FeatureView(firstTxt: "Answers from GPT3.5", secondText: "More accurate & detailed answers")
        FeatureView(firstTxt: "Higher word limit", secondText: "Type longer messages")
        FeatureView(firstTxt: "No Limits", secondText: "Have unlimited dialogues")
        FeatureView(firstTxt: "No Ads", secondText: "Enjoy Ask Al without any ads")
    }
}

import Foundation
import StoreKit

/* Some methods to make displaying subscription terms easier */

extension Package {
    func terms(for package: Package) -> String {
        if let intro = package.storeProduct.introductoryDiscount {
            if intro.price == 0 {
                return "\(intro.subscriptionPeriod.periodTitle) free trial"
            } else {
                return "\(package.localizedIntroductoryPriceString!) for \(intro.subscriptionPeriod.periodTitle)"
            }
        } else {
            return "Unlocks Premium"
        }
    }
}

extension SubscriptionPeriod {
    var durationTitle: String {
        switch self.unit {
        case .day: return "day"
        case .week: return "Weekly"
        case .month: return "month"
        case .year: return "Yearly"
        @unknown default: return "Unknown"
        }
    }

    var periodTitle: String {
        let periodString = "\(self.value) \(self.durationTitle)"
        let pluralized = self.value > 1 ?  periodString + "s" : periodString
        return pluralized
    }
}

// swiftlint:enable line_length
