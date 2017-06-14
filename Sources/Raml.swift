import Foundation
import Yaml

enum RAMLError: Error {
    case yamlParsingError(message: String)
    case invalidRAMLVersion(message: String)
    case ramlParsingError(message: String)
}

public class RAML {
    
    public var version: String = ""
    public var title: String = ""
    
    public init(_ string: String) throws {
        // validate version
        let ramlVersion = try validateRamlVersion(string: string)
        self.version = ramlVersion
        
        // parse string to yaml
        let yaml = try parsedYAMLFromString(string)
        
        // parse root raml
        try parseRoot(yaml)
    }
}

// MARK: Parsing
extension RAML {
    
    fileprivate func validateRamlVersion(string: String) throws -> String {
        guard let firstLine = string.components(separatedBy: "\n").first else { throw RAMLError.invalidRAMLVersion(message: "string has no first line") }
        let ramlPrefix = "#%RAML "
        guard firstLine.hasPrefix(ramlPrefix) else { throw RAMLError.invalidRAMLVersion(message: "first line must look like this `#%RAML <version>`") }
        let ramlVersion = firstLine.substring(from: ramlPrefix.endIndex)
        guard ramlVersion == "1.0" else { throw RAMLError.invalidRAMLVersion(message: "only RAML Version 1.0 is supported") }
        return ramlVersion
    }
    
    fileprivate func parsedYAMLFromString(_ string: String) throws -> Yaml {
        do {
            let parsedYaml = try Yaml.load(string)
            return parsedYaml
        } catch {
            throw RAMLError.yamlParsingError(message: error.localizedDescription)
        }
    }
    
    fileprivate func parseRoot(_ yaml: Yaml) throws {
        guard let yamlTitle = yaml["title"].string else { throw RAMLError.yamlParsingError(message: "title is required") }
        
        self.title = yamlTitle
    }
}
