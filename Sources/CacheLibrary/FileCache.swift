import Foundation

@available(macOS 16.0, *)
public protocol CacheData {
    var tasks: [String: ToDoItem] { get }
    func add(_ task: ToDoItem)
    @discardableResult func remove(id: String) -> ToDoItem?
    func save(title: String, format: FileCache.FileCacheFormat) throws
    func load(title: String, format: FileCache.FileCacheFormat) throws
}

@available(macOS 16.0, *)
public class FileCache: CacheData {
    public private(set) var tasks = [String: ToDoItem]()

    public func add(_ task: ToDoItem) {
        tasks[task.id] = task
    }

    @discardableResult
    public func remove(id: String) -> ToDoItem? {
        defer { tasks[id] = nil }
        return tasks[id]
    }

    public func save(title: String, format: FileCacheFormat) throws {
        let dir = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        switch format {
        case .json:
            let url = dir.appending(path: title + ".json")
            let tasksJSON = tasks.map(\.value.json)
            let jsonData = try JSONSerialization.data(withJSONObject: tasksJSON, options: .prettyPrinted)
            try jsonData.write(to: url, options: .atomic)
        case .csv:
            let url = dir.appending(path: title + ".csv")
            var tasksCsv = tasks.map(\.value.csv).joined(separator: "\n")
            tasksCsv = ToDoItem.csvHeader.joined(separator: ",") + "\n" + tasksCsv
            try tasksCsv.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    public func load(title: String, format: FileCacheFormat) throws {
        let dir = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        var toDoItems = [ToDoItem]()
        switch format {
        case .json:
            let url = dir.appending(path: title + ".json")
            let data = try Data(contentsOf: url)
            let jsonData = try JSONSerialization.jsonObject(with: data)
            guard let jsonArray = jsonData as? [Any] else { throw FileCacheErrors.LoadInvalidJson }
            toDoItems = jsonArray.compactMap { ToDoItem.parse(json: $0) }
        case .csv:
            let url = dir.appending(path: title + ".csv")
            let data = try String(contentsOf: url).split(separator: "\n").map(String.init)

            toDoItems = data.compactMap { ToDoItem.parse(csv: $0) }
        }
        for toDoItem in toDoItems {
            add(toDoItem)
        }
    }
}

@available(macOS 16.0, *)
extension FileCache {
    public enum FileCacheFormat {
        case json
        case csv
    }

    public enum FileCacheErrors: Error {
        case LoadInvalidJson
    }
}
