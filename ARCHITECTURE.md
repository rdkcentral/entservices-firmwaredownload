# FirmwareDownload Plugin Architecture

## Overview

The FirmwareDownload plugin is a **Thunder/WPEFramework-based service** designed for RDK (Reference Design Kit) devices to provide firmware update capabilities. It implements a **plugin architecture pattern** where the main plugin acts as a bridge between client applications and the underlying firmware download implementation.

## Architecture Components

### 1. Core Plugin Layer (`FirmwareDownload`)
- **Purpose**: Primary plugin entry point and JSON-RPC interface management
- **Key Responsibilities**:
  - Plugin lifecycle management (Initialize/Deinitialize)
  - JSON-RPC method dispatch and event handling
  - Client notification management via Thunder framework
  - Service registration with Thunder/WPEFramework

### 2. Implementation Layer (`FirmwareDownloadImplementation`) 
- **Purpose**: Core business logic for firmware operations
- **Design Pattern**: Singleton pattern with thread-safe operations
- **Key Responsibilities**:
  - Firmware search and download orchestration
  - State management for download operations
  - Event notification dispatch to registered clients
  - Interface compliance with `Exchange::IFirmwareDownload`

### 3. Interface Layer (`Exchange::IFirmwareDownload`)
- **Purpose**: Abstract interface defining firmware download contract
- **Key Methods**:
  - `SearchFirmware()`: Initiate firmware availability check
  - `GetDownloadedFirmwareInfo()`: Retrieve firmware version details
  - `GetFirmwareDownloadPercent()`: Monitor download progress
  - `GetDownloadState()`: Query current download status
  - `Register/Unregister()`: Client notification management

### 4. Notification System
- **Design Pattern**: Observer pattern with asynchronous event dispatch
- **Event Types**:
  - `OnFirmwareAvailable`: Notifies clients about firmware availability
- **Threading**: Uses Thunder's `Core::IWorkerPool` for thread-safe event dispatch

### 5. Helper Utilities
- **UtilsLogging**: Standardized logging framework with thread ID tracking
- **UtilsJsonRpc**: JSON-RPC response formatting and parameter validation macros

## Communication Flow

```
Client Application
        ↓ JSON-RPC
Thunder Framework
        ↓ IPlugin Interface
FirmwareDownload Plugin
        ↓ Exchange::IFirmwareDownload
FirmwareDownloadImplementation
        ↓ Platform-specific calls
Underlying Firmware Service
```

## Threading Model

- **Main Thread**: Plugin initialization and JSON-RPC handling
- **Worker Pool**: Asynchronous event notification dispatch
- **Thread Safety**: 
  - `Core::CriticalSection _adminLock` protects notification list
  - Reference counting for notification objects
  - Thread-safe singleton implementation

## Memory Management

- **RAII Pattern**: Automatic resource cleanup using Thunder's smart pointers
- **Reference Counting**: COM-style AddRef/Release for interface objects
- **Proxy Objects**: Thunder's `Core::ProxyType` for type-safe object management

## Plugin Configuration

- **Configuration File**: `FirmwareDownload.config` defines startup parameters
- **Service Registration**: Automatic registration with Thunder framework
- **Versioning**: Semantic versioning (Major.Minor.Patch = 1.0.0)

## Error Handling Strategy

- **Return Codes**: `Core::hresult` for standardized error reporting
- **Exception Safety**: RAII ensures resource cleanup on exceptions
- **Validation**: Input parameter validation with early returns
- **Logging**: Comprehensive logging at all architectural layers

## Scalability Considerations

- **Asynchronous Operations**: Non-blocking firmware operations
- **Event-driven Architecture**: Loosely coupled notification system
- **Resource Pooling**: Efficient thread and memory management via Thunder framework
- **Interface Separation**: Clear separation between plugin and implementation layers