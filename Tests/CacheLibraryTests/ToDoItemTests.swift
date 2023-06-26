@testable import CacheLibrary
import XCTest

final class ToDoItemTests: XCTestCase {
    private let json: [String: Any] = ["id": "CC2400E1-5F05-4A8B-B753-96F3F96434F1",
                                       "text": "Task",
                                       "importance": "important",
                                       "deadline": 708_465_945.770851,
                                       "done": true,
                                       "created": 708_465_945.770851,
                                       "changed": 708_465_945.770851]
    private let toDoItem = ToDoItem(text: "Task")

    // MARK: Test var json

    func testJsonCreatedValid() throws {
        let toDo = ToDoItem(id: "id",
                            text: "text",
                            importance: .important,
                            deadline: Date(timeIntervalSinceReferenceDate: 708_553_585.42902195),
                            done: true,
                            created: Date(timeIntervalSinceReferenceDate: 708_553_585.42902195),
                            changed: Date(timeIntervalSinceReferenceDate: 708_553_585.42902195))
        let json = try XCTUnwrap(toDo.json as? [String: Any])
        let id = try XCTUnwrap(json["id"] as? String)
        let text = try XCTUnwrap(json["text"] as? String)
        let importanceStr = try XCTUnwrap(json["importance"] as? String)
        let importance = try XCTUnwrap(ToDoItem.Required(rawValue: importanceStr))
        let deadline = try XCTUnwrap(json["deadline"] as? TimeInterval)
        let done = try XCTUnwrap(json["done"] as? Bool)
        let created = try XCTUnwrap(json["created"] as? TimeInterval)
        let changed = try XCTUnwrap(json["changed"] as? TimeInterval)
        XCTAssertEqual(id, "id")
        XCTAssertEqual(text, "text")
        XCTAssertEqual(importance, .important)
        XCTAssertEqual(deadline, 708_553_585.42902195)
        XCTAssertEqual(done, true)
        XCTAssertEqual(created, 708_553_585.42902195)
        XCTAssertEqual(changed, 708_553_585.42902195)
    }

    func testJsonDontSaveImportanceIfItIsCommon() throws {
        let data = try XCTUnwrap(toDoItem.json as? [String: Any])
        XCTAssertNil(data["importance"], "Dont save importance if It is common")
    }

    func testJsonDontSaveDeadlineIfItIsNotExist() throws {
        let data = try XCTUnwrap(toDoItem.json as? [String: Any])
        XCTAssertNil(data["deadline"], "Dont save deadline if It is not exist")
    }

    func testJsonDontSaveChangedDateIfItIsNotExist() throws {
        let data = try XCTUnwrap(toDoItem.json as? [String: Any])
        XCTAssertNil(data["changed"], "Dont save changed date if It is not exist")
    }

    func testJsonIsValidJSONObject() {
        XCTAssertTrue(JSONSerialization.isValidJSONObject(toDoItem.json), "JSON should be valid")
    }

    // MARK: Test parse json

    func testParseJSON() throws {
        let json: [String: Any] = ["id": "D364F14E-EFF3-4C59-BA98-F01FB55F91F8",
                                   "text": "Task",
                                   "importance": "unimportant",
                                   "deadline": 708_644_816.9570181,
                                   "done": true,
                                   "created": 708_644_816.9570181,
                                   "changed": 708_644_816.9570181]
        let toDo = try XCTUnwrap(ToDoItem.parse(json: json))
        XCTAssertEqual(toDo.id, "D364F14E-EFF3-4C59-BA98-F01FB55F91F8")
        XCTAssertEqual(toDo.text, "Task")
        XCTAssertEqual(toDo.importance, .unimportant)
        XCTAssertEqual(toDo.deadline, Date(timeIntervalSinceReferenceDate: 708_644_816.9570181))
        XCTAssertEqual(toDo.done, true)
        XCTAssertEqual(toDo.created, Date(timeIntervalSinceReferenceDate: 708_644_816.9570181))
        XCTAssertEqual(toDo.changed, Date(timeIntervalSinceReferenceDate: 708_644_816.9570181))
    }

    func testParseJSONWrongTypeShouldBeNil() {
        let json = [AnyHashable: Any]()
        XCTAssertNil(ToDoItem.parse(json: json), "JSON should be [String: Any]")
    }

    func testParseJSONIdNotExists() {
        var json = json
        json["id"] = nil
        XCTAssertNil(ToDoItem.parse(json: json), "Id not exists")
    }

    func testParseJSONTextNotExists() {
        var json = json
        json["text"] = nil
        XCTAssertNil(ToDoItem.parse(json: json), "Text not exists")
    }

    func testParseJSONCreatedDateNotExists() {
        var json = json
        json["created"] = nil
        XCTAssertNil(ToDoItem.parse(json: json), "Created date not exists")
    }

    func testParseJSONImportanceNotExists() throws {
        var json = json
        json["importance"] = nil
        let importance = try XCTUnwrap(ToDoItem.parse(json: json)?.importance)
        XCTAssert(importance == ToDoItem.Required.common, "Importance not exists")
    }

    func testParseJSONDoneFlagNotExists() throws {
        var json = json
        json["done"] = nil
        let done = try XCTUnwrap(ToDoItem.parse(json: json)?.done)
        XCTAssertFalse(done, "Done flag not exists")
    }

    func testParseJSONDeadlineNotExists() throws {
        var json = json
        json["deadline"] = nil
        let toDoItem = try XCTUnwrap(ToDoItem.parse(json: json))
        XCTAssertNil(toDoItem.deadline, "Deadline not exists")
    }

    func testParseJSONChangedDateNotExists() throws {
        var json = json
        json["changed"] = nil
        let toDoItem = try XCTUnwrap(ToDoItem.parse(json: json))
        XCTAssertNil(toDoItem.changed, "Changed date not exists")
    }

    // MARK: Test var csv

    func testCsvCreatedValid() throws {
        let toDo = ToDoItem(id: "id",
                            text: "text",
                            importance: .important,
                            deadline: Date(timeIntervalSinceReferenceDate: 708_644_816.9570181),
                            done: true,
                            created: Date(timeIntervalSinceReferenceDate: 708_644_816.9570181),
                            changed: Date(timeIntervalSinceReferenceDate: 708_644_816.9570181))
        XCTAssertEqual(toDo.csv, "id,text,important,708644816.9570181,true,708644816.9570181,708644816.9570181")
    }

    func testCsvDontSaveImportanceIfItIsCommon() {
        let csv = toDoItem.csv.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
        XCTAssert(csv[2] == "", "Dont save importance if It is common")
    }

    func testCsvDontSaveDeadlineIfItIsNotExist() {
        let csv = toDoItem.csv.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
        XCTAssert(csv[3] == "", "Dont save deadline if It is not exist")
    }

    func testCsvDontSaveChangedDateIfItIsNotExist() {
        let csv = toDoItem.csv.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
        XCTAssert(csv[6] == "", "Dont save changed date if It is not exist")
    }

    // MARK: Test parse csv

    func testParseCsv() throws {
        let csv = "id,text,important,708644816.9570181,true,708644816.9570181,708644816.9570181"
        let toDo = try XCTUnwrap(ToDoItem.parse(csv: csv))

        XCTAssertEqual(toDo.id, "id")
        XCTAssertEqual(toDo.text, "text")
        XCTAssertEqual(toDo.importance, .important)
        XCTAssertEqual(toDo.deadline, Date(timeIntervalSinceReferenceDate: 708_644_816.9570181))
        XCTAssertEqual(toDo.done, true)
        XCTAssertEqual(toDo.created, Date(timeIntervalSinceReferenceDate: 708_644_816.9570181))
        XCTAssertEqual(toDo.changed, Date(timeIntervalSinceReferenceDate: 708_644_816.9570181))
    }

    func testParseCsvWrongType() {
        let csv = ""
        let toDo = ToDoItem.parse(csv: csv)
        XCTAssertNil(toDo)
    }

    func testParseCsvIdOrTextOrCreatedDateNotExists() {
        let csvId = ",text,important,708644816.9570181,true,708644816.9570181,708644816.9570181"
        let toDoId = ToDoItem.parse(csv: csvId)
        XCTAssertNil(toDoId)

        let csvText = "id,,important,708644816.9570181,true,708644816.9570181,708644816.9570181"
        let toDoText = ToDoItem.parse(csv: csvText)
        XCTAssertNil(toDoText)

        let csvCreated = "id,text,important,708644816.9570181,true,,708644816.9570181"
        let toDoCreated = ToDoItem.parse(csv: csvCreated)
        XCTAssertNil(toDoCreated)
    }

    func testParseCsvChangedDateOrDeadlineOrImportanceOrDoneNotExists() throws {
        let csvImportance = "id,text,,708644816.9570181,true,708644816.9570181,708644816.9570181"
        let toDoImportance = try XCTUnwrap(ToDoItem.parse(csv: csvImportance))
        XCTAssertEqual(toDoImportance.importance, .common)

        let csvChanged = "id,text,important,708644816.9570181,true,708644816.9570181,"
        let toDoChanged = try XCTUnwrap(ToDoItem.parse(csv: csvChanged))
        XCTAssertEqual(toDoChanged.changed, nil)

        let csvDeadline = "id,text,important,,true,708644816.9570181,708644816.9570181"
        let toDoDeadline = try XCTUnwrap(ToDoItem.parse(csv: csvDeadline))
        XCTAssertEqual(toDoDeadline.deadline, nil)

        let csvDone = "id,text,important,708644816.9570181,,708644816.9570181,708644816.9570181"
        let toDoDone = try XCTUnwrap(ToDoItem.parse(csv: csvDone))
        XCTAssertEqual(toDoDone.done, false)
    }
}
