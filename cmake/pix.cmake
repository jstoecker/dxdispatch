FetchContent_Declare(
    nuget
    PREFIX nuget
    URL "https://dist.nuget.org/win-x86-commandline/v5.3.0/nuget.exe"
    DOWNLOAD_NO_EXTRACT 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    UPDATE_COMMAND ""
    INSTALL_COMMAND ""
)

if(NOT nuget_POPULATED)
    FetchContent_Populate(nuget)
endif()

set(pix_PACKAGE_ID WinPixEventRuntime)
set(pix_PACKAGE_VERSION 1.0.210209001)
set(pix_PACKAGE_DIR ${nuget_SOURCE_DIR}/packages/${pix_PACKAGE_ID}.${pix_PACKAGE_VERSION})

execute_process(
    COMMAND 
        ${nuget_SOURCE_DIR}/nuget.exe
        install 
        ${pix_PACKAGE_ID} 
        -Version ${pix_PACKAGE_VERSION} 
        -OutputDirectory ${nuget_SOURCE_DIR}/packages
)

add_library(pix SHARED IMPORTED)
add_library(Microsoft::PIX ALIAS pix)

target_include_directories(pix INTERFACE ${pix_PACKAGE_DIR}/include)

if (${CMAKE_SYSTEM_NAME} MATCHES Windows)
    set(pix_PLATFORM ${CMAKE_GENERATOR_PLATFORM})
    if(NOT pix_PLATFORM)
        set(pix_PLATFORM ${CMAKE_VS_PLATFORM_NAME})
    endif()
    if(NOT pix_PLATFORM)
        set(pix_PLATFORM x64)
    endif()

    if(${pix_PLATFORM} MATCHES x64)
        set(pix_BIN_PATH ${pix_PACKAGE_DIR}/bin/x64)
    elseif (${pix_PLATFORM} MATCHES ARM64)
        set(pix_BIN_PATH ${pix_PACKAGE_DIR}/bin/ARM64)
    endif()

    set_property(TARGET pix PROPERTY IMPORTED_LOCATION ${pix_BIN_PATH}/WinPixEventRuntime.dll)
    set_property(TARGET pix PROPERTY IMPORTED_IMPLIB ${pix_BIN_PATH}/WinPixEventRuntime.lib)

    install(FILES ${pix_BIN_PATH}/WinPixEventRuntime.dll DESTINATION bin)
endif()