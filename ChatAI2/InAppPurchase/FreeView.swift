//
//  FreeTrialView.swift
//  PromotionUI
//
//  Created by Thomas Woodfin on 2/6/23.
//

import SwiftUI

struct FreeTrialView: View {
    var body: some View {
        ScrollView {
            VStack {
                // Bleeds into NavigationView
                HStack {
                    Button {
                        // action here
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .padding(10)
                    }
                    Spacer()
                }
                VStack {
                    VStack {
                        HStack {
                            Text("Discover \nAlI\nPossibilities")
                                .lineLimit(nil)
                                .frame(height: 130)
                                .foregroundColor(.black)
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }.padding(.top, 30)
                            .padding(.horizontal, 30)
                    }
                    FreeTrialFeatureView(firstTxt: "Unlimited", secondText: "chat messages", emojies: "😱")
                    FreeTrialFeatureView(firstTxt: "More detailed", secondText: "answers", emojies: "🤓")
                    FreeTrialFeatureView(firstTxt: "Instant", secondText: "responses", emojies: "🎉")
                    FreeTrialFeatureView(firstTxt: "Chat", secondText: "history", emojies: "😎")
                    FreeTrialFeatureView(firstTxt:
                                            "Image to text (OCR)",
                                        secondText: "", emojies: "🔠")
                    .padding(.bottom, 40)
                }
                .background(Color("LiteGray"))
                .cornerRadius(8)
                .padding(.horizontal)
                FreeTrialFooterView()
                Spacer()
            }
        }
        .background(Color.white)
    }
}

struct FreeTrialView_Previews: PreviewProvider {
    static var previews: some View {
        FreeTrialView()
    }
}
struct FreeTrialFeatureView: View {
    var firstTxt: String
    var secondText: String
    var emojies: String
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Text(emojies)
                    VStack {
                        HStack {
                            if secondText == "history"{
                                Text(firstTxt)
                                    .foregroundColor(.black)
                                    .font(.title3)
                                Text(secondText)
                                    .foregroundColor(.black)
                                    .font(.title3)
                                    .bold()
                            } else if secondText == "" {
                                Text(firstTxt)
                                    .foregroundColor(.black)
                                    .font(.title3)
                            } else {
                                Text(firstTxt)
                                    .foregroundColor(.black)
                                    .font(.title3)
                                    .bold()
                                Text(secondText)
                                    .foregroundColor(.black)
                                    .font(.title3)
                            }
                            Spacer()
                        }
                    }.padding(.horizontal)
                }
            }.padding(.horizontal, 30)
                .padding(.top, 5)
        }
    }
}

struct FreeTrialFooterView: View {
    @State private var freeTrialEnable = true
    @State private var isTrialSelected: Bool = true
    var body: some View {
        VStack {

            Button {
                // action here
            } label: {
                VStack {
                    HStack {
                        VStack {
                            HStack {
                                Text("Free Trial Enabled")
                                    .bold()
                                    .foregroundColor(.black)
                                Spacer()
                                Toggle("", isOn: $freeTrialEnable)
                                    .toggleStyle(SwitchToggleStyle(tint: .mint))
                            }
                        }
                    }
                }.padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.gray), lineWidth: 2)
                    )
            }.padding(.top)
            Button {
                isTrialSelected = false
            } label: {
                VStack {
                    HStack {
                        VStack {
                            HStack {
                                Text("YEARLY ACCESS")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            HStack {
                                Text("$39.99/year")
                                    .bold()
                                    .foregroundColor(.black)
                                    .font(.body)
                                Spacer()
                            }
                        }
                        Image(systemName: isTrialSelected ? "circle" : "circle.inset.filled")
                            .foregroundColor(.black)
                    }
                }.padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.gray), lineWidth: 2)
                    )
            }.padding(.vertical)
            HStack {
                Spacer()
                VStack {
                    Text("SAVE %84")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(.mint)
                        .clipShape(Capsule())
                }.padding(.top, -110)
                    .padding(.trailing, 30)
            }
            Button {
                isTrialSelected = true
            } label: {
                VStack {
                    HStack {
                        VStack {
                            HStack {
                                Text("3-DAYS FREE TRIAL")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            HStack {
                                Text("then $4.99/week")
                                    .bold()
                                    .foregroundColor(.black)
                                    .font(.body)
                                Spacer()
                            }
                        }
                        Image(systemName: isTrialSelected ? "circle.inset.filled" : "circle")
                            .foregroundColor(.black)
                    }
                }.padding()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("DarkGray"), lineWidth: 2)
                    )
            }
            Button {
                // action here
            } label: {
                HStack {
                    Spacer()
                    Text("Try for Free")
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .padding(.trailing)

                }.background(Color.black)
                    .cornerRadius(8)
                    .clipShape(Rectangle())
            }.padding(.top)
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(Color("DarkGreen"))
                Text("NO PAYMENT NOW")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
            }.padding(.top)
            HStack {
                Button {
                    // action here
                } label: {
                    Text("Terms")
                        .foregroundColor(.gray)
                        .underline()
                }
                Button {
                    // action here
                } label: {
                    Text("Privacy Policy")
                        .foregroundColor(.gray)
                        .underline()
                        .padding(.horizontal)
                }
                Button {
                    // action here
                } label: {
                    Text("Restore")
                        .foregroundColor(.gray)
                        .underline()
                }
            }.padding(.top)
        }.padding(.horizontal)
    }
}
