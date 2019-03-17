import ID3TagEditor
import CommandLineKit
import TOMLDecoder
import Foundation

struct Config: Codable {
    let imagePath: String
    let year: Int
    let album: String
    let artist: String
}

func usageDescription(flags: Flags, message: String?, payload: String?) -> Never {
    if let message = message {
        print("Error: \(message)\n")
        if let payload = payload {
            print("\t \(payload)\n")
        }
    }
    print(flags.usageDescription(usageName: TextStyle.bold.properties.apply(to: "usage:"),
                                 synopsis: "[<option> ...] [---] [<program> <arg> ...]",
                                 usageStyle: TextProperties.none,
                                 optionsName: TextStyle.bold.properties.apply(to: "options:"),
                                 flagStyle: TextStyle.italic.properties),
          terminator: "")
    exit(0)
}

enum ProcessError: Error {
    case usage(message: String?)
    case configNotFound(path: String?)
    case mp3NotFound(path: String?)
    case invalidTitle(String?)
    case invalidMp3(String?)
    case invalidImageType(String?)
}

func process(flags: inout Flags) throws {
    let help = flags.option("h", "help", description: "Show description of usage and options of this tools.")

    let filePathValue  = flags.string("f", "filepath", description: "The mp3 file to update")
    let titleValue = flags.string("t", "title", description: "The title of the episode")
    let configPathValue = flags.string("c", "configpath", description: "The yaml configuration path")
    
    if help.wasSet {
        throw ProcessError.usage(message: nil)
    }
    
    if let parsingFailure = flags.parsingFailure() {
        throw ProcessError.usage(message: parsingFailure)
    }

    guard let filePath = filePathValue.value else {
        throw ProcessError.mp3NotFound(path: nil)
    }

    guard let title = titleValue.value else {
        throw ProcessError.invalidTitle(nil)
    }
    
    guard let configPath = configPathValue.value else {
        throw ProcessError.configNotFound(path: nil)
    }
    
    guard let toml = try? String(contentsOfFile: configPath) else {
        throw ProcessError.configNotFound(path: configPath)
    }
    
    guard FileManager.default.fileExists(atPath: filePath) else {
        throw ProcessError.mp3NotFound(path: filePath)
    }
    
    let decoder = TOMLDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let config = try decoder.decode(Config.self, from: toml)
    
    let allowedImages = ["jpg", "jpeg"]
    guard allowedImages.contains(String(NSString(string: config.imagePath.lowercased()).pathExtension)) else {
        throw ProcessError.invalidImageType("Image \(config.imagePath) is not of type \(allowedImages.joined(separator: ", "))")
    }
    
    guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: config.imagePath)) else {
        throw ProcessError.invalidImageType("Could not read image \(config.imagePath)")
    }
    
    let id3TagEditor = ID3TagEditor()
    do {
        let id3Tag = ID3Tag(
            version: .version3,
            artist: config.artist,
            albumArtist: config.artist,
            album: config.album,
            title: title,
            recordingDateTime: RecordingDateTime(date: RecordingDate(day: nil, month: nil, year: config.year), time: nil),
            genre: Genre(genre: ID3Genre.Other, description: "Podcast"),
            attachedPictures: [AttachedPicture(picture: imageData, type: .FrontCover, format: .Jpeg)],
            trackPosition: nil
        )
        try id3TagEditor.write(tag: id3Tag, to: filePath)
    } catch let error {
        throw ProcessError.invalidMp3(error.localizedDescription)
    }
}

func main() {
    var flags = Flags()
    do {
        try process(flags: &flags)
    } catch let error as ProcessError {
        switch error {
        case .usage(message: let message):
            usageDescription(flags: flags, message: message, payload: nil)
            
        case .configNotFound(path: let config):
            usageDescription(flags: flags,
                             message: "Config not found", payload: config)
            
        case .invalidImageType(let imageType):
            usageDescription(flags: flags,
                             message: "Invalid Image", payload: imageType)
            
        case .invalidMp3(let path):
            usageDescription(flags: flags,
                             message: "Invalid MP3", payload: path)
            
        case .invalidTitle(let title):
            usageDescription(flags: flags,
                             message: "Invalid Title", payload: title)
            
        case .mp3NotFound(path: let path):
            usageDescription(flags: flags,
                             message: "Mp3 path", payload: path)
        }
    } catch {
        fatalError("Invalid Error Type: \(error)")
    }
}
main()
