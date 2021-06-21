cmake_minimum_required(VERSION 3.18)

project(dxdispatch VERSION 0.1.0 LANGUAGES CXX)

# ==============================================================================
# External Libraries
# ==============================================================================
include(FetchContent)
include(cmake/gsl.cmake)
include(cmake/rapidjson.cmake)
include(cmake/fmt.cmake)
include(cmake/wil.cmake)
include(cmake/directml.cmake)
include(cmake/directmlx.cmake)
include(cmake/direct3d.cmake)
include(cmake/dxheaders.cmake)
include(cmake/pix.cmake)
include(cmake/gtest.cmake)
include(cmake/dxc.cmake)
include(cmake/half.cmake)
include(cmake/cxxopts.cmake)

# ==============================================================================
# Model Library
# ==============================================================================
add_library(
    model STATIC 
    src/model/JsonParsers.cpp 
    src/model/Model.cpp
)

target_link_libraries(
    model 
    PRIVATE 
    fmt::fmt-header-only
    Microsoft::DirectMLX
    PUBLIC
    Microsoft.GSL::GSL
    rapidjson::rapidjson
    Microsoft::DirectML
    Microsoft::WIL
    Half::Half
)

target_compile_features(model PRIVATE cxx_std_17)
target_precompile_headers(model PRIVATE src/model/pch.h)
target_include_directories(model INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/src/model)

# ==============================================================================
# Main Executable
# ==============================================================================
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/dxdispatch/config.h.in config.h)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/dxdispatch/dxdispatch.rc.in dxdispatch.rc)

add_executable(
    dxdispatch
    src/dxdispatch/Adapter.cpp
    src/dxdispatch/Device.cpp
    src/dxdispatch/main.cpp
    src/dxdispatch/DmlDispatchable.cpp
    src/dxdispatch/HlslDispatchable.cpp
    src/dxdispatch/Executor.cpp
    src/dxdispatch/CommandLineArgs.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
    ${CMAKE_CURRENT_BINARY_DIR}/dxdispatch.rc
)

target_include_directories(dxdispatch PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_link_libraries(
    dxdispatch 
    PRIVATE 
    Microsoft.GSL::GSL
    fmt::fmt-header-only
    Microsoft::WIL
    Microsoft::DirectML
    Microsoft::Direct3D12
    Microsoft::PIX
    Microsoft::DirectMLX
    Microsoft::DirectX-Headers
    Microsoft::DirectX-Guids
    Microsoft::DXC
    dxcore
    model
    cxxopts
)

target_compile_features(dxdispatch PRIVATE cxx_std_17)
target_precompile_headers(dxdispatch PRIVATE src/dxdispatch/pch.h)

# Copy DLLs into executable's build output directory for debugging purposes.
add_custom_command(
    TARGET dxdispatch 
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:Microsoft::DirectML> $<TARGET_FILE_DIR:dxdispatch>
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_PROPERTY:Microsoft::DirectML,DEBUG_DLL_PATH> $<TARGET_FILE_DIR:dxdispatch>
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:Microsoft::PIX> $<TARGET_FILE_DIR:dxdispatch>
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:Microsoft::DXC> $<TARGET_FILE_DIR:dxdispatch>
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_PROPERTY:Microsoft::DXC,DXIL_PATH> $<TARGET_FILE_DIR:dxdispatch>
    COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:dxdispatch>/$<TARGET_PROPERTY:Microsoft::Direct3D12,SUBDIR_PATH>
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_PROPERTY:Microsoft::Direct3D12,CORE_DLL_PATH> $<TARGET_FILE_DIR:dxdispatch>/$<TARGET_PROPERTY:Microsoft::Direct3D12,SUBDIR_PATH>
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_PROPERTY:Microsoft::Direct3D12,DEBUG_DLL_PATH> $<TARGET_FILE_DIR:dxdispatch>/$<TARGET_PROPERTY:Microsoft::Direct3D12,SUBDIR_PATH>
)

# TODO: improve this installation
install(
    FILES 
    $<TARGET_FILE:dxdispatch> 
    ${CMAKE_CURRENT_SOURCE_DIR}/ThirdPartyNotices.txt
    ${CMAKE_CURRENT_SOURCE_DIR}/doc/Guide.md
    DESTINATION bin
)

install(
    DIRECTORY 
    ${CMAKE_CURRENT_SOURCE_DIR}/models
    DESTINATION bin
)

# ==============================================================================
# Tests
# ==============================================================================
enable_testing()
include(GoogleTest)

add_executable(
    jsontests 
    src/test/JsonParserTests.cpp
)

target_compile_features(jsontests PRIVATE cxx_std_17)
target_link_libraries(
    jsontests 
    PRIVATE 
    gtest_main 
    fmt::fmt-header-only
    Microsoft::DirectMLX
    model
)
target_include_directories(jsontests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/dxdispatch)
gtest_discover_tests(jsontests)