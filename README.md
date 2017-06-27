# RAML-Swift

[![Twitter: @cpageler93](https://img.shields.io/badge/contact-@cpageler93-lightgrey.svg?style=flat)](https://twitter.com/cpageler93)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/cpageler93/RAML-Swift/blob/master/LICENSE)

A [RAML](http://raml.org) parser based on [YamlSwift](https://github.com/behrang/YamlSwift) written in **Swift 4**.


## Test

### Run Script to copy test data

```shell
export SOURCE="$PROJECT_DIR/Tests/RAMLTests/TestData"
export DESTINATION=${BUILT_PRODUCTS_DIR}/${EXECUTABLE_NAME}.xctest/Contents/Resources/
echo "Copy from $SOURCE to $DESTINATION"
cp -r $SOURCE $DESTINATION
```

## Links

[Spec](https://github.com/raml-org/raml-spec/blob/master/versions/raml-10/raml-10.md/)
