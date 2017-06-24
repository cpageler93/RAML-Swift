import Foundation
import Yaml
import PathKit

public class RAML {
    
    // MARK: meta (not raml related)
    
    /// Version of RAML file
    internal var ramlVersion: String = ""
    
    /// indicates whether includes are available in raml file
    internal var includesAvailable: Bool
    
    /// initial file path, when loaded from file
    internal var initialFilePath: Path?
    
    
    
    // MARK: RAML related
    
    public var title: String = ""
    public var description: String?
    public var version: String?
    public var baseURI: String?
    public var baseURIParameters: [URIParameter]?
    public var protocols: Protocols?
//    mediaType
    public var documentation: [DocumentationEntry]?
//    schemas
//    types
//    traits
//    resourceTypes
//    annotationTypes
//    securitySchemes
//    securedBy
//    uses
    
    // we need this static constant because our yaml parser doesnt work well
    // the value from `keyWithEmptyValueFix` will be inserted in the yaml string
    // where no value is given and the node has no children
    // after the parsing the value will be removed recursively
    static let keyWithEmptyValueFix = "RAMLEMPTYVALUEFIX"
    
    // MARK: Initializer
    
    public init(file: String) throws {
        includesAvailable = true
        initialFilePath = Path(file)
        guard let filePath = initialFilePath else { throw RAMLError.yamlParsingError(message: "invalid file") }
        if !filePath.exists { throw RAMLError.yamlParsingError(message: "invalid file") }
        
        let content = try filePath.read(String.Encoding.utf8)
        try loadRamlFromString(content)
    }
    
    public init(string: String) throws {
        includesAvailable = false
        try loadRamlFromString(string)
    }
    
    // MARK: Public Methods
    
    public func baseURIWithParameter() -> String? {
        guard var baseURI = baseURI else { return nil }
        if let version = version {
            baseURI = baseURI.replacingOccurrences(of: "{version}", with: version)
        }
        return baseURI
    }
}

// MARK: Parsing
extension RAML {
    
    internal func parseRoot(_ yaml: Yaml) throws {
        guard let yamlTitle = yaml["title"].string else { throw RAMLError.ramlParsingError(message: "title is required") }
        
        self.title = yamlTitle
        self.description = yaml["description"].string
        self.version = yaml["version"].string
        self.baseURI = yaml["baseUri"].string
        
        if let baseURIParameters = yaml["baseUriParameters"].dictionary {
            self.baseURIParameters = try parseURIParameters(baseURIParameters)
        }
        
        if let protocolsYaml = yaml["protocols"].array {
            self.protocols = try parseProtocols(protocolsYaml)
        }
        
        if let yamlDocumentationEntries = yaml["documentation"].array {
            self.documentation = try parseDocumentation(yamlDocumentationEntries)
        }
    }
}
