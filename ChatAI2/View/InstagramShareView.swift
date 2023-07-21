//
//  InstagramShareView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 14/4/23.
//

import SwiftUI

struct InstagramShareView: View {
    let image: UIImage = UIImage(named: "label")!
    private let photo = Image("label")
    var imageToShare: UIImage {
        // An image defined in your app's asset catalogue.
        return UIImage(imageLiteralResourceName: "label")
    }
    var body: some View {
        VStack {
            // Display the image that will be shared to Instagram.
            VStack(alignment: .leading, spacing: 10) {
                photo
                    .resizable()
                    .scaledToFit()
                ShareLink(item: photo, preview: SharePreview("label", image: photo))
            }
            .padding(.horizontal)
            if InstagramSharingUtils.canOpenInstagramStories {
                Button(action: {
                    InstagramSharingUtils.shareToInstagramStories(imageToShare)
                }, label: {
                    Text("Share to Instagram Stories")
                })
            } else {
                Text("Instagram is not available.")
            }
        }
    }
}
