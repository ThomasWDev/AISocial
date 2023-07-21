//
//  ProfileView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 5/6/23.
//
// swiftlint:disable file_length
import SwiftUI
import PhotosUI
import Firebase

struct ProfileView: View {
    var threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let width = (UIScreen.main.bounds.width - 2*5 - 32) / 3
    @State var user: UserModel
    @State private var bio = ""
    @State private var editBio = false
    @FocusState var focusedBio
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var showLastNameAlert = false
    @State private var showFirstNameAlert = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var imageURLs = [String]()
    @State private var itIsLoading = false
    @State private var showFullScreenCover = false
    @State private var currentImage: Image?
    @State private var currentImageURL = ""
    @State private var city = ""
    @State private var showCityNameAlert = false
    @State private var selectedProfilePhoto: PhotosPickerItem?
    @State private var forTheFirstTime = true
    @StateObject private var network = NetworkMonitor.shared

    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .leading, spacing: 12) {

                    profilePic

                    bioView

                    name

                    cityName

                    photos

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .showLoadingView(itIsLoading)
                .onAppear {
                    fetchBio()
                    fetchPhotosURLs()
                }
            }
            .padding(.horizontal, 16)
            imageModalView
                .offset(y: showFullScreenCover ? 0 : 1000)
        }
        .noInternetView(isConnected: $network.isConnected)
    }
}

extension ProfileView {
    private func updateCity() {
        itIsLoading = true
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            itIsLoading = false
            return
        }

        guard !city.isEmpty else {
            itIsLoading = false
            return
        }

        FirebaseManager.shared.firestore.collection("users").document(userId).updateData([
            "cityName": city
        ]) { err in
            if let err = err {
                print(err, "Error")
            } else {
                user.cityName = city
            }
            itIsLoading = false
        }
    }

    private func updateFirstandLastName() {
        itIsLoading = true
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }

        var data = [String: String]()

        if !firstName.isEmpty && !lastName.isEmpty {
            data["firstName"] = firstName
            data["lastName"] = lastName
        } else if firstName.isEmpty {
            data["lastName"] = lastName
        } else if lastName.isEmpty {
            data["firstName"] = firstName
        } else {
            return
        }

        FirebaseManager.shared.firestore.collection("users").document(userId).updateData(data) { err in
            if let err = err {
                print(err, "Error")
            } else {
                UserDefaults.standard.removeObject(forKey: "username")
                if !firstName.isEmpty && !lastName.isEmpty {
                    user.firstName = firstName
                    user.lastName = lastName
                } else if firstName.isEmpty {
                    user.lastName = lastName
                } else if lastName.isEmpty {
                    user.firstName = firstName
                }
            }
            itIsLoading = false
        }
    }

    @ViewBuilder
    private var photos: some View {
        Divider()
            .alert("Change First Or Last Name Or Both.", isPresented: $showFirstNameAlert, actions: {
                TextField("First name: ", text: $firstName)
                TextField("Last name: ", text: $lastName)
                Button("Update", action: {
                    self.updateFirstandLastName()
                })
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("")
            })

        HStack {
            Text("Photos")
                .font(.system(size: 25))
                .bold()

            if user.id == FirebaseManager.shared.auth.currentUser?.uid ?? "" {
                PhotosPicker(selection: $selectedPhoto) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(AppColors.themeColor)
                        .scaleEffect(1.5)
                }
                .onChange(of: selectedPhoto) { _ in
                    Task {
                        if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                itIsLoading = true
                                uploadImage(image: uiImage)
                                return
                            }
                        }
                        print("Failed")
                    }
                }
            }
        }

        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: threeColumnGrid) {
                ForEach(imageURLs, id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .frame(width: width, height: width)
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture {
                                self.currentImage = image
                                self.currentImageURL = url
                                if currentImage != nil {
                                    showFullScreenCover = true
                                }
                            }
                    } placeholder: {
                        Color.gray
                            .frame(width: width, height: width)
                    }
                }
            }
        }
    }

    var imageModalView: some View {
        VStack {
            HStack {
                if user.id == FirebaseManager.shared.auth.currentUser?.uid {
                    Text("Delete Photo")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(20)
                        .onTapGesture {
                            itIsLoading = true
                            deletePhoto(url: currentImageURL)
                            showFullScreenCover = false
                        }
                }
                Spacer()
                Image(systemName: "xmark")
                    .padding(20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showFullScreenCover = false
                    }
            }

            if let image = currentImage {
                image
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width - 32)
                    .aspectRatio(contentMode: .fit)
                    .onAppear {
                        print(currentImageURL, "IMAGE URL")
                    }
            } else {
                Text("Something is wrong, please try again!")
            }
            Spacer()
        }
        .background(.white)
    }

    private func uploadImage(image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.2) {
            let fileName = UUID().uuidString
            let storageRef = FirebaseManager.shared.storage.reference(withPath: "/other_images/\(fileName)")
            storageRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    print("Error uploading image to Firebase: \(error.localizedDescription)")
                    return
                }
                print("Image successfully uploaded to Firebase!")
                storageRef.downloadURL { url, _ in
                    guard let imageUrl = url?.absoluteString else { return }
                    storeImageUrltoFireStore(url: imageUrl)
                }
            }
        }
    }

    private func updateProfile(image: UIImage) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        itIsLoading = true
        if let imageData = image.jpegData(compressionQuality: 0.2) {
            let fileName = user.profileImage
            let storageRef = FirebaseManager.shared.storage.reference(withPath: "/profile_images/\(fileName)")
            storageRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    print("Error uploading image to Firebase: \(error.localizedDescription)")
                    itIsLoading = false
                    return
                }
                print("Image successfully uploaded to Firebase!")
                storageRef.downloadURL { url, _ in
                    guard let imageUrl = url?.absoluteString else { return }
                    FirebaseManager.shared.firestore.collection("users")
                        .document(userId)
                        .updateData(["profileImage": imageUrl]) { err in
                            if let err = err {
                                print(err, "Error")
                            } else {
                                user.profileImage = imageUrl
                            }
                            itIsLoading = false
                    }
                }
            }
        }
    }

    private func storeImageUrltoFireStore(url: String) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let photoRef = FirebaseManager.shared.firestore.collection("userPhotos").document(userId)

        photoRef.setData([
            "photos": FieldValue.arrayUnion([url])
        ], merge: true) { err in
            if let err = err {
                print("debug: ", err.localizedDescription)
            } else {
                print("debug: SUCCESS saving urls")
                fetchPhotosURLs()
            }
        }
    }

    private func deletePhoto(url: String) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }

        let photoRef = FirebaseManager.shared.firestore.collection("userPhotos").document(userId)

        photoRef.updateData([
            "photos": FieldValue.arrayRemove([url])
        ]) { err in
            if let err = err {
                print("debug: ", err.localizedDescription)
            } else {
                print("debug: SUCCESS deleting photo")
                fetchPhotosURLs()
            }
            itIsLoading = false
        }
        // Create a reference to the file to delete
        let storageRef = FirebaseManager.shared.storage.reference(forURL: url)

        // Delete the file
        storageRef.delete { error in
          if let error = error {
            print(error, "DELETE ERROR")
          }
        }
    }

    private var cityName: some View {
        HStack {
            Text(user.cityName)
                .bold()
                .font(.system(size: 18))
                .offset(x: 0, y: -8)
                .alert("Change Location Name.", isPresented: $showCityNameAlert, actions: {
                    TextField("Ex: Cityname ", text: $city)
                    Button("Update", action: {
                        self.updateCity()
                    })
                    Button("Cancel", role: .cancel, action: {})
                }, message: {
                    Text("")
                })

            if user.id == FirebaseManager.shared.auth.currentUser?.uid ?? "" {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(AppColors.themeColor)
                    .scaleEffect(1.2)
                    .offset(x: 0, y: -10)
                    .onTapGesture {
                        showCityNameAlert = true
                    }
            }
        }
    }

    private var name: some View {
        HStack {
            Text("\(user.firstName)")
                .bold()
                .font(.system(size: 30))
            + Text(" \(user.lastName)")
                .bold()
                .font(.system(size: 30))

            if user.id == FirebaseManager.shared.auth.currentUser?.uid ?? "" {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(AppColors.themeColor)
                    .scaleEffect(1.5)
                    .onTapGesture {
                        showFirstNameAlert = true
                    }
            }
        }
    }

    private var bioView: some View {
        HStack {
            if bio.isEmpty || editBio {
                if user.id == FirebaseManager.shared.auth.currentUser?.uid ?? "" {
                    HStack {
                        TextField("Write bio!", text: $bio)
                            .focused($focusedBio)
                            .onAppear {
                                editBio = true
                            }
                        if focusedBio {
                            Text("Done")
                                .foregroundColor(AppColors.themeColor)
                                .onTapGesture {
                                    addOrEditBio()
                                    focusedBio = false
                                    editBio = false
                                }
                        } else {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(AppColors.themeColor)
                                .scaleEffect(1.5)
                                .onTapGesture {
                                    editBio = true
                                    focusedBio = true
                                }
                        }
                    }
                }
            } else if !editBio {
                Text(bio)
                    .bold()
                    .opacity(0.7)
                    .font(.system(size: 17))

                if user.id == FirebaseManager.shared.auth.currentUser?.uid ?? "" {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(AppColors.themeColor)
                        .scaleEffect(1.5)
                        .onTapGesture {
                            editBio = true
                            focusedBio = true
                        }
                }
            }
        }
    }

    private var profilePic: some View {
        AsyncImage(url: URL(string: user.profileImage)) { image in
            image
                .resizable()
                .frame(width: 100, height: 100)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(50)
        } placeholder: {
            Color.gray
                .frame(width: 100, height: 100)
                .cornerRadius(50)
        }.overlay(alignment: .topTrailing) {
            if user.id == FirebaseManager.shared.auth.currentUser?.uid ?? "" {
                PhotosPicker(selection: $selectedProfilePhoto) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(AppColors.themeColor)
                        .scaleEffect(1.5)
                }
                .onChange(of: selectedProfilePhoto) { _ in
                    Task {
                        if let data = try? await selectedProfilePhoto?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                updateProfile(image: uiImage)
                                return
                            }
                        }
                        print("Failed")
                    }
                }
            }
        }
    }

    func addOrEditBio() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }

        FirebaseManager.shared.firestore.collection("bio").document(userId).setData([
            "bio": bio
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }

    func fetchBio() {
        guard let userId = user.id, bio.isEmpty else {
            return
        }

        FirebaseManager.shared.firestore
            .collection("bio")
            .document(userId)
            .getDocument { doc, err in
                if let err = err {
                    print(err, "Error")
                } else if let doc = doc {
                    self.bio = doc.data()?["bio"] as? String ?? ""
                    print(self.bio, "BIO")
                    if !bio.isEmpty {
                        editBio = false
                    }
                }
            }
    }

    func fetchPhotosURLs() {
        guard let userId = user.id else {
            return
        }

        FirebaseManager.shared.firestore
            .collection("userPhotos")
            .document(userId)
            .getDocument { document, err in
                if let err = err {
                    print(err, "Error")
                }
                itIsLoading = false
                guard let document = document, document.exists,
                        let urls = document.get("photos") as? [String] else { return }
                self.imageURLs = urls
            }
    }
}
// swiftlint:enable file_length
