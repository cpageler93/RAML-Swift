import Foundation
import Yaml
import PathKit

public class RAML : HasTypes, HasAnnotationTypes, HasResources, HasTraitDefinitions, HasDocumentationEntries {
    
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
//    resourceTypes
    public var annotationTypes: [AnnotationType]?
//    securitySchemes
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
    
    // MARK: - Internal Methods
    
    internal func directoryOfInitialFilePath() throws -> Path {
        guard let initialFilePath = initialFilePath else {
            throw RAMLError.unknown
        }
        return initialFilePath.absolute().directory()
    }
    
    // MARK: - Public Methods
    
    public func baseURIWithParameter() -> String? {
        guard var baseURIValue = baseURI?.value else { return nil }
        if let version = version {
            baseURIValue = baseURIValue.replacingOccurrences(of: "{version}", with: version)
        }
        return baseURIValue
    }
    
}


// MARK: Parsing
extension RAML {
    
    internal func parseRoot(_ yaml: Yaml) throws {
        guard let yamlTitle = yaml["title"].string else {
            throw RAMLError.ramlParsingError(.missingValueFor(key: "title"))
        }
        
        self.title = yamlTitle
        self.description = yaml["description"].string
        self.version = yaml["version"].string
        
        if let baseURIString = yaml["baseUri"].string {
            self.baseURI = try parseBaseURI(string: baseURIString)
        } else if let baseURIDictionary = yaml["baseUri"].dictionary {
            self.baseURI = try parseBaseURI(yaml: baseURIDictionary)
        }
        
        
        if let baseURIParameters = yaml["baseUriParameters"].dictionary {
            self.baseURIParameters = try parseURIParameters(baseURIParameters)
        }
        
        if let protocolsYaml = yaml["protocols"].array {
            self.protocols = try parseProtocols(protocolsYaml)
        }
        
        if let mediaTypesYaml = yaml["mediaType"].array {
            self.mediaTypes = try parseMediaTypes(mediaTypesYaml)
        } else if let mediaTypeString = yaml["mediaType"].string {
            self.mediaTypes = [parseMediaType(mediaTypeString)]
        }
        
        if let documentationEntriesYaml = yaml["documentation"].array {
            self.documentation = try parseDocumentation(documentationEntriesYaml)
        }
        
        if let typesYaml = yaml["types"].dictionary {
            self.types = try parseTypes(typesYaml)
        }
        
        if let traitsYaml = yaml["traits"].dictionary {
            self.traitDefinitions = try parseTraitDefinitions(traitsYaml)
        } else if let traitIncludeString = yaml["traits"].string {
            let yaml = try parseTraitFromIncludeString(traitIncludeString)
            guard let traitsYaml = yaml.dictionary else {
                throw RAMLError.ramlParsingError(.invalidInclude)
            }
            self.traitDefinitions = try parseTraitDefinitions(traitsYaml)
        }
        
        if let annotationTypesYaml = yaml["annotationTypes"].dictionary {
            self.annotationTypes = try parseAnnotationTypes(annotationTypesYaml)
        }
        
        self.resources = try parseResources(yaml, parent: self)
    }
    
}


extension RAML: ResourceParent {
    
    public func absolutePath() -> String {
        return baseURI?.value ?? ""
    }
    
}
