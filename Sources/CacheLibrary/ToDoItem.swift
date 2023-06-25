import Foundation

public struct ToDoItem {
    public let id: String
    public let text: String
    public let importance: Required
    public let deadline: Date?
    public let done: Bool
    public let created: Date
    public let changed: Date?
    public init(id: String = UUID().uuidString,
         text: String,
         importance: Required = .common,
         deadline: Date? = nil,
         done: Bool = false,
         created: Date = Date(),
         changed: Date? = nil)
    {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.created = created
        self.changed = changed
    }
}

extension ToDoItem {
    public enum Required: String {
        case unimportant
        case common
        case important
    }
}

extension ToDoItem {
    public static func parse(json: Any) -> ToDoItem? {
        guard let json = json as? [String: Any] else { return nil }

        guard let id = json["id"] as? String,
              let text = json["text"] as? String,
              let createdTimeInterval = json["created"] as? TimeInterval
        else { return nil }

        let importanceStr = json["importance"] as? String ?? "common"
        let importance = Required(rawValue: importanceStr) ?? .common
        let done = json["done"] as? Bool ?? false
        var deadline: Date?
        if let deadlineTimeInterval = json["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSinceReferenceDate: deadlineTimeInterval)
        }
        var changed: Date?
        if let changedTimeInterval = json["changed"] as? TimeInterval {
            changed = Date(timeIntervalSinceReferenceDate: changedTimeInterval)
        }
        let created = Date(timeIntervalSinceReferenceDate: createdTimeInterval)
        return ToDoItem(id: id, text: text, importance: importance, deadline: deadline, done: done, created: created, changed: changed)
    }

    public var json: Any {
        var data = [String: Any]()
        data["id"] = id
        data["text"] = text
        if importance != .common {
            data["importance"] = importance.rawValue
        }
        if let deadline {
            data["deadline"] = deadline.timeIntervalSinceReferenceDate
        }
        data["done"] = done
        data["created"] = created.timeIntervalSinceReferenceDate
        if let changed {
            data["changed"] = changed.timeIntervalSinceReferenceDate
        }
        return data
    }
}

extension ToDoItem {
    public static let csvHeader = ["id", "text", "importance", "deadline", "done", "created", "changed"]

    public static func parse(csv: String) -> ToDoItem? {
        let dataCsv = csv.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
        guard dataCsv.count >= csvHeader.count else { return nil }
        let (id, text, importanceStr, deadlineStr, doneStr, createdStr, changedStr) = (dataCsv[0],
                                                                                       dataCsv[1],
                                                                                       dataCsv[2],
                                                                                       dataCsv[3],
                                                                                       dataCsv[4],
                                                                                       dataCsv[5],
                                                                                       dataCsv[6])
        guard !id.isEmpty,
              !text.isEmpty,
              !createdStr.isEmpty,
              let createdTimeInterval = TimeInterval(createdStr) else { return nil }
        let importance = Required(rawValue: importanceStr) ?? .common
        let done = Bool(doneStr) ?? false
        var deadline: Date?
        if let deadlineTimeInterval = TimeInterval(deadlineStr) {
            deadline = Date(timeIntervalSinceReferenceDate: deadlineTimeInterval)
        }
        var changed: Date?
        if let changedTimeInterval = TimeInterval(changedStr) {
            changed = Date(timeIntervalSinceReferenceDate: changedTimeInterval)
        }
        let created = Date(timeIntervalSinceReferenceDate: createdTimeInterval)
        return ToDoItem(id: id, text: text, importance: importance, deadline: deadline, done: done, created: created, changed: changed)
    }

    public var csv: String {
        var data = [String]()
        data.append(id)
        data.append(text)
        if importance != .common {
            data.append(importance.rawValue)
        } else {
            data.append("")
        }
        if let deadline {
            data.append("\(deadline.timeIntervalSinceReferenceDate)")
        } else {
            data.append("")
        }
        data.append("\(done)")
        data.append("\(created.timeIntervalSinceReferenceDate)")
        if let changed {
            data.append("\(changed.timeIntervalSinceReferenceDate)")
        } else {
            data.append("")
        }
        return data.joined(separator: ",")
    }
}
