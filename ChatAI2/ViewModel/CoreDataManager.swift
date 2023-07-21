//
//  CoreDataManager.swift
//  ChatAI2
//
//  Created by Thomas Woodfinon 12/5/23.
//

import Foundation
import CoreData

final class CoreDataManager {
    let container: NSPersistentContainer
    static var shared = CoreDataManager()
    private init() {
        container = NSPersistentContainer(name: "ChatHistoryContainer")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("debug: Error Loading CoreData ", error)
            }
        }
    }
    // MARK: - Chats
    func saveChat(chatId: String, chat: String, isItChatGPT: Bool) {
        guard !chatId.isEmpty, !chat.isEmpty else {
            return
        }
        let chatEntity = ChatHistoryEntity(context: container.viewContext)
        chatEntity.chat = chat
        chatEntity.chatId = chatId
        chatEntity.createdAt = Date()
        chatEntity.isItChatGPT = isItChatGPT
        saveContext()
    }
    func saveChatId(chatId: String, chatName: String) {
        guard !chatId.isEmpty else {
            return
        }
        let chatEntity = ChatIdEntity(context: container.viewContext)
        chatEntity.chatId = chatId
        chatEntity.chatName = chatName
        chatEntity.createdAt = Date()
        saveContext()
    }
    func deleteId(id: String) {
        let idEntities = self.fetchChatId(id: id)
        if let idEntities = idEntities {
            for idEntity in idEntities {
                container.viewContext.delete(idEntity)
            }
            saveContext()
        }
    }
    func fetchChatId(id: String) -> [ChatIdEntity]? {
        let request = NSFetchRequest<ChatIdEntity>(entityName: "ChatIdEntity")
        request.predicate = NSPredicate(format: "chatId == %@", id)
        do {
            let ids = try container.viewContext.fetch(request)
            return ids} catch {
            print("debug: Error fetching coreData chat with id")
            return nil
        }
    }
    func fetchChat(chatId: String, fetchLimit: Int? = nil) -> [ChatHistoryEntity] {
        let request = NSFetchRequest<ChatHistoryEntity>(entityName: "ChatHistoryEntity")
        let sort = NSSortDescriptor(key: #keyPath(ChatHistoryEntity.createdAt), ascending: true)
        request.sortDescriptors = [sort]
        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }
        // create a predicate to filter between start date and end date
        request.predicate = NSPredicate(format: "chatId == %@", chatId)
        do {
            let chats = try container.viewContext.fetch(request)
            return chats.count > 0 ? chats : [ChatHistoryEntity]()} catch {
            print("debug: Error fetching coreData chat with id")
            return []
        }
    }
    func fetchChatIds(fetchOffset: Int = 0, fetchLimit: Int = 100) -> [ChatIdEntity] {
        let request = NSFetchRequest<ChatIdEntity>(entityName: "ChatIdEntity")
        let sort = NSSortDescriptor(key: #keyPath(ChatIdEntity.createdAt), ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = fetchLimit
        // request.fetchOffset = fetchOffset
        do {
            let chatIds = try container.viewContext.fetch(request)
            return chatIds.count > 0 ? chatIds : [ChatIdEntity]()} catch {
            print("debug: Error fetching coreData chatIds")
            return []
        }
    }
    func editChatName(chatIdEntity: ChatIdEntity, chatName: String) {
        chatIdEntity.chatName = chatName
        saveContext()
        print("debug: chatName edited")
    }
    func saveContext() {
       do {
           try container.viewContext.save()
           print("debug: context saved")} catch {
           print("debug: Error to Coredata saving context")
       }
   }
}
