import Foundation
import Yaml
import PathKit

public class RAML : HasBaseURIParameters, HasProtocols, HasMediaTypes, HasDocumentationEntries, HasTypes, HasTraitDefinitions, HasResourceTypes, HasAnnotationTypes, HasSecuritySchemes, /* HasUses, */ HasResources {
    
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
    public var baseURI: BaseURI?
    
    public var baseURIParameters: [URIParameter]?
    public var protocols: Protocols?
    public var mediaTypes: [MediaType]?
    public var documentation: [DocumentationEntry]?
    public var types: [Type]?
    public var traitDefinitions: [TraitDefinition]?
    public var resourceTypes: [ResourceType]?
    public var annotationTypes: [AnnotationType]?
    public var securitySchemes: [SecurityScheme]?
//    securedBy
//    uses
    public var resources: [Resource]?
    
    // we need this static constant because our yaml parser doesnt work well
    // the value from `keyWithEmptyValueFix` will be inserted in the yaml string
    // where no value is given and the node has no children
    // after the parsing the value will be removed recursively
    static let keyWithEmptyValueFix = "RAMLEMPTYVALUEFIX"
    
    // MARK: - Initializer
    
    public init(file: String) throws {
        includesAvailable = true
        initialFilePath = Path(file)
        guard let filePath = initialFilePath else { throw RAMLError.invalidFile(atPath: file) }
        let content = try contentFromFile(path: filePath)
        try loadRamlRootFromString(content)
    }
    
    public init(string: String) throws {
        includesAvailable = false
        try loadRamlRootFromString(string)
    }
    
    internal init() {
        title = ""
        includesAvailable = false
    }
    
    // MARK: - Internal Methods
    
    internal func directoryOfInitialFilePath() throws -> Path {
        guard let initialFilePath = initialFilePath else {
            throw RAMLError.unknown
        }
        return initialFilePath.absolute().directory()
    }
}


// MARK: Parsing
extension RAML {
    
    internal func parseRoot(_ yaml: Yaml) throws {
        guard let yamlTitle = yaml["title"].string else {
            throw RAMLError.ramlParsingError(.missingValueFor(key: "title"))
        }
        
        self.title              = yamlTitle
        self.description        = yaml["description"].string
        self.version            = yaml["version"].string
        self.baseURI            = try parseBaseURI(yaml: yaml["baseUri"])
        self.baseURIParameters  = try parseURIParameters(yaml: yaml["baseUriParameters"])
        self.protocols          = try parseProtocols(yaml: yaml["protocols"])
        self.mediaTypes         = try parseMediaTypes(yaml: yaml["mediaType"])
        self.documentation      = try parseDocumentation(yaml: yaml["documentation"])
        self.types              = try parseTypes(yaml: yaml["types"])
        self.traitDefinitions   = try parseTraitDefinitions(yaml: yaml["traits"])
        self.resourceTypes      = try parseResourceTypes(yaml: yaml["resourceTypes"])
        self.annotationTypes    = try parseAnnotationTypes(yaml: yaml["annotationTypes"])
        self.securitySchemes    = try parseSecuritySchemes(yaml: yaml["securitySchemes"])
        // securedBy
        // uses
        self.resources          = try parseResources(yaml: yaml)
    }
    
}


// MARK: Default Values
public extension RAML {
    
    public convenience init(initWithDefaultsBasedOn raml: RAML) {
        self.init()
        
        self.ramlVersion = raml.ramlVersion
        self.includesAvailable = raml.includesAvailable
        self.initialFilePath = raml.initialFilePath
        
        self.title = raml.title
        self.description = raml.description ?? nil // no default value
        self.version = raml.version ?? nil // no default value
    }
    
    public func applyDefaults() -> RAML {
        return RAML(initWithDefaultsBasedOn: self)
    }
    
}
