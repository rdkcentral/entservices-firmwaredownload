# Architecture Overview

The **FirmwareDownload** project is a plugin-based service built on the **WPEFramework** (Thunder) architecture, designed to provide firmware download and management capabilities for RDK (Reference Design Kit) devices. This document outlines the overall system architecture, component interactions, and design patterns employed.

## System Architecture

### Framework Integration
The project integrates with the **WPEFramework**, a modular C++ framework that provides:
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
The core business logic implementation that provides the actual firmware download services through the **Exchange::IFirmwareDownload** interface.

**Key Responsibilities:**
- Firmware search and discovery
- Download progress tracking
- State management
- Failure reason reporting
- Event dispatching to subscribers

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

### Build System Integration

#### CMake Integration
The project integrates with WPEFramework's build system:
- **Namespace Support:** `${NAMESPACE}` variable for framework version compatibility
- **Plugin Registration:** Automatic service discovery
- **Dependency Management:** Framework and plugin dependency resolution

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

## Extensibility Points

### Plugin Registration
New firmware download implementations can be registered through:
- **SERVICE_REGISTRATION macro:** Automatic service discovery
- **Interface Implementation:** Exchange::IFirmwareDownload compliance
- **Configuration Integration:** JSON-based service parameters

### Event System Extensions
Additional events can be integrated through:
- **Event Enumeration Extension:** New event type definitions
- **Notification Interface Extension:** Additional callback methods
- **Job System Integration:** Asynchronous event processing

This architecture provides a robust, extensible foundation for firmware download services while maintaining compatibility with the WPEFramework ecosystem and supporting future enhancements through well-defined extension points.