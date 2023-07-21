//
//  FavoritePeopleView.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 31/5/23.
//

import SwiftUI

struct FavoritePeopleView: View {
    @StateObject private var viewModel = FavoritePeopleViewModel()
    @StateObject private var network = NetworkMonitor.shared
    var body: some View {
        List {
            Text("People I Chattted With")
                .textGreen()
            ForEach(viewModel.favoriteChatHistoryMessages) { chatHistoryMessage in
                RecentMessageCard( message: chatHistoryMessage.message,
                                   toId: chatHistoryMessage.to,
                                   fromId: chatHistoryMessage.from,
                                   seen: chatHistoryMessage.seen,
                                   fromFavorite: true)
            }

            Button {
                viewModel.loadMoreChatHistoryClicked = true
                viewModel.loadNextChatHistories()
            } label: {
                Text( (viewModel.endReachedChatHistory ||
                       viewModel.favoriteChatHistoryMessages.isEmpty) ? "No more chats" : "Load More")
                    .textGreen()
            }.disabled(viewModel.endReachedChatHistory)
        }
        .noInternetView(isConnected: $network.isConnected)
        .onAppear {
            viewModel.firstBatch = true
            viewModel.loadFirstBatchChatHistoryWithListener()
        }
    }
}

struct FavoritePeopleView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritePeopleView()
    }
}
