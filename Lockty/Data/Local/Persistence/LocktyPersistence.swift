//
//  LocktyPersistence.swift
//  Lockty
//
//  Created by Gabrisp on 22/3/26.
//

import CoreData

// MARK: - Persistence Controller

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Lockty", managedObjectModel: Self.model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.persistentStoreDescriptions.forEach {
            $0.shouldMigrateStoreAutomatically = true
            $0.shouldInferMappingModelAutomatically = true
        }
        container.loadPersistentStores { _, error in
            if let error { fatalError("CoreData failed to load: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var context: NSManagedObjectContext { container.viewContext }
}

// MARK: - Model (programático, sin .xcdatamodeld)

extension PersistenceController {
    static let model: NSManagedObjectModel = {
        let model = NSManagedObjectModel()

        func attr(_ name: String, _ type: NSAttributeType, optional: Bool = false) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = type
            a.isOptional = optional
            return a
        }

        // MARK: LocalUserEntity
        let userEntity = NSEntityDescription()
        userEntity.name = "LocalUserEntity"
        userEntity.managedObjectClassName = NSStringFromClass(LocalUserEntity.self)
        userEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("displayName", .stringAttributeType),
            attr("createdAt", .dateAttributeType),
            attr("firebaseUserId", .stringAttributeType)
        ]

        // MARK: ModeEntity
        let modeEntity = NSEntityDescription()
        modeEntity.name = "ModeEntity"
        modeEntity.managedObjectClassName = NSStringFromClass(ModeEntity.self)
        modeEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("name", .stringAttributeType),
            attr("iconName", .stringAttributeType),
            attr("colorHex", .stringAttributeType),
            attr("state", .stringAttributeType),
            attr("createdAt", .dateAttributeType)
        ]

        // MARK: BlockedAppsEntity
        let blockedAppsEntity = NSEntityDescription()
        blockedAppsEntity.name = "BlockedAppsEntity"
        blockedAppsEntity.managedObjectClassName = NSStringFromClass(BlockedAppsEntity.self)
        blockedAppsEntity.properties = [
            attr("modeId", .UUIDAttributeType),
            attr("appGroupId", .UUIDAttributeType, optional: true),
            attr("selectionData", .binaryDataAttributeType, optional: true)
        ]

        // MARK: AppGroupEntity
        let appGroupEntity = NSEntityDescription()
        appGroupEntity.name = "AppGroupEntity"
        appGroupEntity.managedObjectClassName = NSStringFromClass(AppGroupEntity.self)
        appGroupEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("name", .stringAttributeType),
            attr("emoji", .stringAttributeType),
            attr("selectionData", .binaryDataAttributeType, optional: true),
            attr("createdAt", .dateAttributeType)
        ]

        // MARK: SessionEntity
        let sessionEntity = NSEntityDescription()
        sessionEntity.name = "SessionEntity"
        sessionEntity.managedObjectClassName = NSStringFromClass(SessionEntity.self)
        sessionEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("modeId", .UUIDAttributeType, optional: true),
            attr("startedAt", .dateAttributeType),
            attr("endedAt", .dateAttributeType, optional: true),
            attr("startTrigger", .stringAttributeType),
            attr("endTrigger", .stringAttributeType, optional: true),
            attr("totalBreakTime", .integer32AttributeType),
            attr("blockedCount", .integer32AttributeType),
            attr("payload", .binaryDataAttributeType, optional: true)
        ]

        // MARK: RuleEntity
        let ruleEntity = NSEntityDescription()
        ruleEntity.name = "RuleEntity"
        ruleEntity.managedObjectClassName = NSStringFromClass(RuleEntity.self)
        ruleEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("modeId", .UUIDAttributeType),
            attr("transition", .stringAttributeType),
            attr("conditionType", .stringAttributeType),
            attr("conditionConfig", .binaryDataAttributeType, optional: true),
            attr("guardLogic", .stringAttributeType),
            attr("onGuardFail", .stringAttributeType),
            attr("isActive", .booleanAttributeType)
        ]

        // MARK: NFCTagEntity
        let nfcTagEntity = NSEntityDescription()
        nfcTagEntity.name = "NFCTagEntity"
        nfcTagEntity.managedObjectClassName = NSStringFromClass(NFCTagEntity.self)
        nfcTagEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("modeId", .UUIDAttributeType, optional: true),
            attr("name", .stringAttributeType),
            attr("systemIdentifier", .stringAttributeType, optional: true),
            attr("technology", .stringAttributeType),
            attr("payload", .binaryDataAttributeType, optional: true),
            attr("createdAt", .dateAttributeType),
            attr("lastSeenAt", .dateAttributeType, optional: true)
        ]

        // MARK: LocationZoneEntity
        let locationZoneEntity = NSEntityDescription()
        locationZoneEntity.name = "LocationZoneEntity"
        locationZoneEntity.managedObjectClassName = NSStringFromClass(LocationZoneEntity.self)
        locationZoneEntity.properties = [
            attr("id", .UUIDAttributeType),
            attr("modeId", .UUIDAttributeType, optional: true),
            attr("name", .stringAttributeType),
            attr("latitude", .doubleAttributeType),
            attr("longitude", .doubleAttributeType),
            attr("radius", .doubleAttributeType),
            attr("trigger", .stringAttributeType),
            attr("allowsImmediateManualStopOnExit", .booleanAttributeType),
            attr("createdAt", .dateAttributeType)
        ]

        // MARK: SyncSettingsEntity
        let syncEntity = NSEntityDescription()
        syncEntity.name = "SyncSettingsEntity"
        syncEntity.managedObjectClassName = NSStringFromClass(SyncSettingsEntity.self)
        syncEntity.properties = [
            attr("syncModes", .booleanAttributeType),
            attr("syncSessions", .booleanAttributeType)
        ]

        model.entities = [
            userEntity,
            modeEntity,
            blockedAppsEntity,
            appGroupEntity,
            sessionEntity,
            ruleEntity,
            nfcTagEntity,
            locationZoneEntity,
            syncEntity
        ]
        return model
    }()
}

// MARK: - NSManagedObject subclasses

@objc(LocalUserEntity)
class LocalUserEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var displayName: String?
    @NSManaged var createdAt: Date?
    @NSManaged var firebaseUserId: String?

    static func fetchRequest() -> NSFetchRequest<LocalUserEntity> {
        NSFetchRequest<LocalUserEntity>(entityName: "LocalUserEntity")
    }
}

@objc(ModeEntity)
class ModeEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var iconName: String?
    @NSManaged var colorHex: String?
    @NSManaged var state: String?
    @NSManaged var createdAt: Date?

    static func fetchRequest() -> NSFetchRequest<ModeEntity> {
        NSFetchRequest<ModeEntity>(entityName: "ModeEntity")
    }
}

@objc(BlockedAppsEntity)
class BlockedAppsEntity: NSManagedObject {
    @NSManaged var modeId: UUID?
    @NSManaged var appGroupId: UUID?
    @NSManaged var selectionData: Data?

    static func fetchRequest() -> NSFetchRequest<BlockedAppsEntity> {
        NSFetchRequest<BlockedAppsEntity>(entityName: "BlockedAppsEntity")
    }
}

@objc(AppGroupEntity)
class AppGroupEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var emoji: String?
    @NSManaged var selectionData: Data?
    @NSManaged var createdAt: Date?

    static func fetchRequest() -> NSFetchRequest<AppGroupEntity> {
        NSFetchRequest<AppGroupEntity>(entityName: "AppGroupEntity")
    }
}

@objc(SessionEntity)
class SessionEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var modeId: UUID?
    @NSManaged var startedAt: Date?
    @NSManaged var endedAt: Date?
    @NSManaged var startTrigger: String?
    @NSManaged var endTrigger: String?
    @NSManaged var totalBreakTime: Int32
    @NSManaged var blockedCount: Int32
    @NSManaged var payload: Data?

    static func fetchRequest() -> NSFetchRequest<SessionEntity> {
        NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
    }
}

@objc(RuleEntity)
class RuleEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var modeId: UUID?
    @NSManaged var transition: String?
    @NSManaged var conditionType: String?
    @NSManaged var conditionConfig: Data?
    @NSManaged var guardLogic: String?
    @NSManaged var onGuardFail: String?
    @NSManaged var isActive: Bool

    static func fetchRequest() -> NSFetchRequest<RuleEntity> {
        NSFetchRequest<RuleEntity>(entityName: "RuleEntity")
    }
}

@objc(NFCTagEntity)
class NFCTagEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var modeId: UUID?
    @NSManaged var name: String?
    @NSManaged var systemIdentifier: String?
    @NSManaged var technology: String?
    @NSManaged var payload: Data?
    @NSManaged var createdAt: Date?
    @NSManaged var lastSeenAt: Date?

    static func fetchRequest() -> NSFetchRequest<NFCTagEntity> {
        NSFetchRequest<NFCTagEntity>(entityName: "NFCTagEntity")
    }
}

@objc(LocationZoneEntity)
class LocationZoneEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var modeId: UUID?
    @NSManaged var name: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var radius: Double
    @NSManaged var trigger: String?
    @NSManaged var allowsImmediateManualStopOnExit: Bool
    @NSManaged var createdAt: Date?

    static func fetchRequest() -> NSFetchRequest<LocationZoneEntity> {
        NSFetchRequest<LocationZoneEntity>(entityName: "LocationZoneEntity")
    }
}

@objc(SyncSettingsEntity)
class SyncSettingsEntity: NSManagedObject {
    @NSManaged var syncModes: Bool
    @NSManaged var syncSessions: Bool

    static func fetchRequest() -> NSFetchRequest<SyncSettingsEntity> {
        NSFetchRequest<SyncSettingsEntity>(entityName: "SyncSettingsEntity")
    }

    static func current(in context: NSManagedObjectContext) -> SyncSettingsEntity {
        let req = fetchRequest()
        req.fetchLimit = 1
        if let existing = try? context.fetch(req).first {
            return existing
        }
        let new = SyncSettingsEntity(context: context)
        new.syncModes = false
        new.syncSessions = false
        try? context.save()
        return new
    }
}
