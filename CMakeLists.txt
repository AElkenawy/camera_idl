
find_package(PkgConfig REQUIRED)

#
# GRPC
#
pkg_check_modules(GRPC IMPORTED_TARGET grpc++ protobuf REQUIRED)

find_program(GRPC_CPP_PLUGIN_EXE grpc_cpp_plugin REQUIRED)
find_program(PROTOC_EXE protoc REQUIRED)

# Define output paths with full paths
set(coordinator_proto_srcs "${CMAKE_CURRENT_SOURCE_DIR}/gen/coordinator.pb.cc")
set(coordinator_proto_hdrs "${CMAKE_CURRENT_SOURCE_DIR}/gen/coordinator.pb.h")
set(coordinator_grpc_srcs "${CMAKE_CURRENT_SOURCE_DIR}/gen/coordinator.grpc.pb.cc")
set(coordinator_grpc_hdrs "${CMAKE_CURRENT_SOURCE_DIR}/gen/coordinator.grpc.pb.h")

# Custom command to generate C++ proto files
add_custom_command(
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT ${coordinator_proto_srcs} ${coordinator_proto_hdrs}
    COMMAND ${PROTOC_EXE} -I ${CMAKE_CURRENT_SOURCE_DIR}/protos --cpp_out=${CMAKE_CURRENT_SOURCE_DIR}/gen/ ${CMAKE_CURRENT_SOURCE_DIR}/protos/coordinator.proto
    DEPENDS protos/coordinator.proto
)

add_custom_command(
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT ${coordinator_grpc_srcs} ${coordinator_grpc_hdrs}
    COMMAND ${PROTOC_EXE} -I ${CMAKE_CURRENT_SOURCE_DIR}/protos --grpc_out=${CMAKE_CURRENT_SOURCE_DIR}/gen/ --plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN_EXE} ${CMAKE_CURRENT_SOURCE_DIR}/protos/coordinator.proto
    DEPENDS protos/coordinator.proto
)

# gRPC proto library
add_library(coordinator_grpc_proto STATIC
    ${coordinator_grpc_srcs} ${coordinator_grpc_hdrs}
    ${coordinator_proto_srcs} ${coordinator_proto_hdrs}
)

target_include_directories(coordinator_grpc_proto PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/gen
)

target_link_libraries(coordinator_grpc_proto PUBLIC PkgConfig::GRPC)
