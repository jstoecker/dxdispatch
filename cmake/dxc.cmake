FetchContent_Declare(
    dxc
    PREFIX dxc
    URL "https://github.com/microsoft/DirectXShaderCompiler/releases/download/v1.6.2104/dxc_2021_04-20.zip"
)

if(NOT dxc_POPULATED)
    FetchContent_Populate(dxc)
endif()

add_library(dxc SHARED IMPORTED)
add_library(Microsoft::DXC ALIAS dxc)

target_include_directories(dxc INTERFACE ${dxc_SOURCE_DIR}/inc)
if(${CMAKE_SYSTEM_NAME} MATCHES Windows)
    set_property(TARGET dxc PROPERTY IMPORTED_LOCATION ${dxc_SOURCE_DIR}/bin/x64/dxcompiler.dll)
    set_property(TARGET dxc PROPERTY IMPORTED_IMPLIB ${dxc_SOURCE_DIR}/lib/x64/dxcompiler.lib)
    set_property(TARGET dxc PROPERTY DXIL_PATH ${dxc_SOURCE_DIR}/bin/x64/dxil.dll)

    install(
        FILES 
            ${dxc_SOURCE_DIR}/bin/x64/dxcompiler.dll
            ${dxc_SOURCE_DIR}/bin/x64/dxil.dll
        DESTINATION bin
    )
endif()

