# RAML-Swift
A RAML parser based on Yams written in Swift


## Run Script to copy test data

```shell
export SOURCE="$PROJECT_DIR/Tests/RAMLTests/TestData"
export DESTINATION=${BUILT_PRODUCTS_DIR}/${EXECUTABLE_NAME}.xctest/Contents/Resources/
echo "Copy from $SOURCE to $DESTINATION"
cp -r $SOURCE $DESTINATION
```