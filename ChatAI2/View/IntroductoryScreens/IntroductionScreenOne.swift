//
//  IntroductionScreenOne.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 10/7/23.
//
// swiftlint:disable line_length
import SwiftUI

struct IntroductionScreenOne: View {
    @StateObject var deviceVM = DeviceDetectViewModel.shared
    var label = ""
    var maximumRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    @State var rating: Int  = 5

    var body: some View {
        ZStack {
            topShape
            ScrollView {
                VStack {
                    Spacer()
                    feedBack
                    text
                    Spacer()
                    Spacer()
                    button
                        .padding(.bottom, 16)
                }
                .padding(.top, 130)
                .frame(height: UIScreen.main.bounds.height)
                .offset(y: deviceVM.currentDevice == .iPhone8 ? -60 : 0)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    private var button: some View {
        NavigationLink {
            IntroductionScreenTwo()
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .frame(width: UIScreen.main.bounds.width/1.25, height: 70)
                .padding(16)
                .overlay {
                    Text("Continue")
                        .bold()
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                }
        }
    }
    private var topShape: some View {
        VStack {
            Image("topCurve")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: 250)
                .overlay(alignment: .trailing) {
                    Image("cartoon")
                        .resizable()
                        .frame(width: 150, height: 200)
                }
            Spacer()
            bottomCurve
        }
    }

    private var bottomCurve: some View {
        Image("bottomCurve")
            .resizable()
            .frame(width: UIScreen.main.bounds.width, height: 200)
            .ignoresSafeArea(.all)
    }
    private var text: some View {
        VStack(spacing: 12) {
            Text("We Love your")
                .foregroundColor(AppColors.shapeColor)
                .bold()
                .font(.system(size: 35))
            Text("feedback")
                .foregroundColor(.black)
                .bold()
                .font(.system(size: 35))
            Image("emoji")
                .resizable()
                .frame(width: 120, height: 60)
            Text("We’re excited to see that our users love our app ")
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(AppColors.shapeColor)
        }
        .padding(16)
    }
    private var feedBack: some View {
        VStack(alignment: .leading, spacing: 5) {
            starView
                .overlay(
                    overlayView.mask((starView))
                )
            Text("This app is beautiful, fast, and efficient The app answers all my questions and provide suggestions too. I got everything that I need quickly and accurately")
                .lineLimit(5)
            // .lineSpacing(5)
                .foregroundColor(.white)
        }
        .frame(width: 350, height: 150)
        .background(.black)
        .cornerRadius(10)
    }
    private var overlayView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.yellow)
                    .frame(width: CGFloat(rating)/5*geometry.size.width)
            }
        }
        .allowsHitTesting(false)
    }
    private var starView: some View {
        HStack {
            if label.isEmpty == false {
                Text(label)
            }

            ForEach(1..<maximumRating + 1, id: \.self) { number in
                image(for: number)
                    .foregroundColor(number > rating ? offColor : onColor)
            }
        }
    }

    func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}

struct IntroductionScreenOne_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionScreenOne()
    }
}
// swiftlint:enable line_length
