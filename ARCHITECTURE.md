# Architecture Overview

The **FirmwareDownload** project is a **template/skeleton implementation** of a plugin-based service built on the **WPEFramework** (Thunder) architecture. It provides the architectural foundation and framework integration for firmware download and management capabilities on RDK (Reference Design Kit) devices. This document outlines the overall system architecture, component interactions, and design patterns that will be employed when the implementation is completed.

> **Current Status:** This is a skeleton implementation created from RDKEMW-7762. The core business logic methods currently return `Core::ERROR_NONE` without actual functionality and serve as placeholders for future implementation.

## System Architecture

### Framework Integration
The project integrates with the **WPEFramework** (Thunder 4.x), a modular C++ framework that provides:
- Plugin lifecycle management
- JSON-RPC communication interface
- Remote procedure call (RPC) mechanisms
- Configuration management
- Service registration and discovery

### Core Components

#### 1. Plugin Layer (`FirmwareDownload.h/.cpp`)
The main plugin component implements the **PluginHost::IPlugin** interface, serving as the bridge between the WPEFramework and the firmware download functionality.

**Key Responsibilities:**
- Plugin lifecycle management (Initialize/Deinitialize)
- Service registration with the framework
- JSON-RPC interface exposure
- Event notification management
- Connection handling with remote services

**Design Pattern:** Facade Pattern - Provides a simplified interface to the complex firmware download subsystem.

#### 2. Implementation Layer (`FirmwareDownloadImplementation.h/.cpp`)
The skeleton business logic implementation that defines the interface structure for firmware download services through the **Exchange::IFirmwareDownload** interface. Currently contains placeholder methods that return `Core::ERROR_NONE`.

**Planned Responsibilities:**
- Firmware search and discovery (placeholder: `SearchFirmware()`)
- Download progress tracking (placeholder: `GetFirmwareDownloadPercent()`)
- State management (placeholder: `GetDownloadState()`)
- Failure reason reporting (placeholder: `GetDownloadFailureReason()`)
- Downloaded firmware info retrieval (placeholder: `GetDownloadedFirmwareInfo()`)
- Event dispatching to subscribers (framework implemented)

**Design Pattern:** Observer Pattern - Implements notification mechanisms for firmware events.

### Interface Architecture

#### COM-Style Interface System
The system uses a COM-style interface architecture with:
- **Interface Maps:** Define supported interfaces for each component
- **Reference Counting:** Automatic memory management through AddRef()/Release()
- **Interface Aggregation:** Composition of multiple interfaces

#### Key Interfaces
- **Exchange::IFirmwareDownload:** Primary service interface
- **Exchange::IFirmwareDownload::INotification:** Event notification interface
- **PluginHost::IPlugin:** Framework plugin interface
- **PluginHost::JSONRPC:** JSON-RPC communication interface

### Event-Driven Architecture

#### Notification System
```cpp
class Notification : public RPC::IRemoteConnection::INotification, 
                    public Exchange::IFirmwareDownload::INotification
```

The notification system provides:
- **Asynchronous Event Delivery:** Non-blocking event propagation
- **Multiple Subscriber Support:** One-to-many event distribution
- **Type-Safe Callbacks:** Strongly typed event interfaces

#### Event Processing Pipeline
1. **Event Generation:** Firmware operations trigger events
2. **Event Dispatching:** Job-based asynchronous processing
3. **Notification Delivery:** Observer pattern implementation
4. **JSON-RPC Forwarding:** Framework-level event broadcasting

### Threading Model

#### Worker Pool Integration
The system integrates with WPEFramework's worker pool for:
- **Asynchronous Processing:** Non-blocking operation execution
- **Thread Safety:** Critical section protection for shared resources
- **Resource Management:** Efficient thread utilization

#### Critical Sections
```cpp
mutable Core::CriticalSection _adminLock;
```
Thread safety is ensured through:
- Administrative lock for notification list management
- Atomic operations for state transitions
- Protected resource access patterns

### Configuration Architecture

#### Template-Based Configuration
```cmake
configuration = JSON()
rootobject.add("mode", "@PLUGIN_FIRMWAREDOWNLOAD_MODE@")
rootobject.add("locator", "lib@PLUGIN_IMPLEMENTATION@.so")
```

The configuration system provides:
- **Build-Time Customization:** CMake template variable substitution
- **JSON-Based Settings:** Structured configuration format
- **Runtime Flexibility:** Dynamic service loading

### Current Implementation Status

#### Skeleton Structure
The current implementation provides:
```cpp
// All core methods currently return Core::ERROR_NONE
Core::hresult SearchFirmware() override { return Core::ERROR_NONE; }
Core::hresult GetDownloadState(FirmwareDownloadState& downloadState) override { return Core::ERROR_NONE; }
Core::hresult GetFirmwareDownloadPercent(FirmwareDownloadPercent& firmwareDownloadPercent) override { return Core::ERROR_NONE; }
```

#### Ready Framework Components
- **Plugin Registration:** `SERVICE_REGISTRATION` macros properly configured
- **JSON-RPC Integration:** `Exchange::JFirmwareDownload` stub registration
- **Event System:** Complete notification/observer pattern implementation
- **Module Definition:** Proper WPEFramework module structure (`Module.h/cpp`)
- **Configuration Templates:** Build-time configuration file generation

### Build System Integration

#### CMake Integration
The project integrates with WPEFramework's build system:
- **Dual Library Build:** Plugin and Implementation as separate shared libraries
- **Namespace Support:** `${NAMESPACE}` variable for Thunder version compatibility
- **Plugin Registration:** Automatic service discovery through `SERVICE_REGISTRATION`
- **Dependency Management:** Proper linking with Thunder framework components
- **Helper Integration:** Access to shared utility headers in `../helpers`

#### Quality Assurance Integration
- **Coverity Static Analysis:** Build script integration for code quality
- **Test Framework Integration:** L1/L2 test workflow support
- **CI/CD Pipeline Support:** GitHub Actions workflow integration

### Error Handling Strategy

#### Result Code System
```cpp
Core::hresult // Standardized error reporting
```

Error handling follows WPEFramework conventions:
- **HRESULT-style return codes:** Standard error propagation
- **Exception Safety:** RAII and smart pointer usage
- **Logging Integration:** Structured logging for diagnostics

### Security Considerations

#### Token-Based Security
```cmake
option(DISABLE_SECURITY_TOKEN "Disable security token" OFF)
```

Security features include:
- **Optional Token Authentication:** Build-time security configuration
- **Interface Isolation:** COM-style interface boundaries
- **Resource Protection:** Reference counting prevents use-after-free

## Implementation Roadmap

### Core Functionality Implementation
The skeleton provides clear extension points for implementing:

**Firmware Discovery:**
```cpp
Core::hresult SearchFirmware() override {
    // TODO: Implement server communication
    // TODO: Version comparison logic
    // TODO: Trigger OnFirmwareAvailable event
    return Core::ERROR_NONE;
}
```

**Download Management:**
```cpp
Core::hresult GetDownloadState(FirmwareDownloadState& downloadState) override {
    // TODO: Track download states (IDLE, DOWNLOADING, COMPLETED, FAILED)
    return Core::ERROR_NONE;
}
```

**Progress Monitoring:**
```cpp
Core::hresult GetFirmwareDownloadPercent(FirmwareDownloadPercent& firmwareDownloadPercent) override {
    // TODO: Real-time download progress calculation
    return Core::ERROR_NONE;
}
```

### Ready Extension Points

**Event System (Fully Implemented):**
- Complete Observer pattern with thread-safe notification delivery
- Job-based asynchronous event processing via `Core::IWorkerPool`
- JSON-RPC event forwarding through `Exchange::JFirmwareDownload::Event`

**Configuration System (Template Ready):**
- CMake variable substitution for deployment customization
- JSON-based runtime configuration loading
- Service startup order and dependency management

**Logging and Diagnostics (Integrated):**
- Thread-safe logging via custom `UtilsLogging.h` macros
- JSON-RPC parameter tracing via `UtilsJsonRpc.h` utilities
- WPEFramework SYSLOG integration for system events

This template provides a production-ready architectural foundation that requires only the core business logic implementation to become a fully functional firmware download service compatible with the WPEFramework ecosystem.