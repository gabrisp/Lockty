//
//  AppGroupStore.swift
//  Lockty
//

import CoreData
import FamilyControls

@MainActor
struct AppGroupStore {
    static let shared = AppGroupStore()

    private var context: NSManagedObjectContext {
        PersistenceController.shared.context
    }

    func fetchAll() -> [AppGroup] {
        let request = AppGroupEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: true),
            NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        ]

        return ((try? context.fetch(request)) ?? []).compactMap(makeModel(from:))
    }

    func fetch(id: UUID) -> AppGroup? {
        let request = AppGroupEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return (try? context.fetch(request).first).flatMap(makeModel(from:))
    }

    @discardableResult
    func save(
        id: UUID? = nil,
        name: String,
        emoji: String,
        selection: FamilyActivitySelection
    ) throws -> AppGroup {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        let entity: AppGroupEntity
        if let id {
            let request = AppGroupEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            entity = (try? context.fetch(request).first) ?? AppGroupEntity(context: context)
        } else {
            let request = AppGroupEntity.fetchRequest()
            request.predicate = NSPredicate(format: "name ==[c] %@", normalizedName)
            request.fetchLimit = 1
            entity = (try? context.fetch(request).first) ?? AppGroupEntity(context: context)
        }

        if entity.id == nil {
            entity.id = UUID()
            entity.createdAt = .now
        }

        entity.name = normalizedName
        entity.emoji = emoji
        entity.selectionData = try JSONEncoder().encode(selection)

        try context.save()

        guard let model = makeModel(from: entity) else {
            throw NSError(domain: "AppGroupStore", code: 1)
        }
        return model
    }

    func delete(id: UUID) throws {
        let request = AppGroupEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        guard let entity = try context.fetch(request).first else { return }
        context.delete(entity)
        try context.save()
    }

    private func makeModel(from entity: AppGroupEntity) -> AppGroup? {
        guard
            let id = entity.id,
            let name = entity.name,
            let emoji = entity.emoji,
            let selectionData = entity.selectionData,
            let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: selectionData)
        else { return nil }

        return AppGroup(
            id: id,
            name: name,
            emoji: emoji,
            selection: selection,
            createdAt: entity.createdAt ?? .now
        )
    }
}
