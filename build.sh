#!/bin/bash
set -e

TARGET=$1
PROTO_DIR="./protos"
BUILD_DIR="./gen"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 {cpp|dart|python}"
  exit 1
fi

mkdir -p "$BUILD_DIR"

case "$TARGET" in
  cpp)
    for f in $PROTO_DIR/*.proto; do
        protoc -I $PROTO_DIR --cpp_out=$BUILD_DIR/ $f
        protoc -I $PROTO_DIR --grpc_out=$BUILD_DIR/ --plugin=protoc-gen-grpc=`which grpc_cpp_plugin` $f
    done
    echo "C++ code generated in $BUILD_DIR/"
    ;;

  dart)
    export PATH="$PATH":"path/to/workspace-automation/.config/flutter_workspace/pub_cache/bin"
    protoc --dart_out=grpc:$BUILD_DIR/ -I$PROTO_DIR $PROTO_DIR/*.proto
    echo "Dart code generated in $BUILD_DIR/"
    ;;

  python)
    python3 -m grpc_tools.protoc -I$PROTO_DIR \
      --python_out=$BUILD_DIR/ \
      --grpc_python_out=$BUILD_DIR/ \
      $PROTO_DIR/*.proto
    echo "Python code generated in $BUILD_DIR/"
    ;;

  *)
    echo "Unknown target: $TARGET"
    echo "Usage: $0 {cpp|dart|python}"
    exit 1
    ;;
esac
