# Task Manager

A board-based task management app. Organise your work into custom boards, track tasks by priority and status, and stay on top of everything — with full dark mode support.

---

## 📱 Screenshots

<p align="center">
  <img src="TaskManager/ScreenShots/login_light.png" alt="Login screen" width="23%" />
  <img src="TaskManager/ScreenShots/boards_light.png" alt="Boards list" width="23%" />
  <img src="TaskManager/ScreenShots/tasks_light.png" alt="Tasks grouped by status" width="23%" />
  <img src="TaskManager/ScreenShots/profile_dark.png" alt="User profile in dark mode" width="23%" />
</p>
<p align="center">
  <img src="TaskManager/ScreenShots/boards_dark.png" alt="Boards list in dark mode" width="23%" />
  <img src="TaskManager/ScreenShots/tasks_dark.png" alt="Tasks grouped by status in dark mode" width="23%" />
</p>

---

## ✨ Features

- 📋 **Boards** — Create boards with custom colours and see task counts at a glance
- ✅ **Tasks** — Add tasks with priorities (High, Medium, Low) and statuses (To Do, In Progress, Done)
- 🌙 **Dark mode** — Automatic dark/light mode based on system settings
- 👤 **Profile** — Edit name, manage notifications, switch language and appearance
- 🌍 **Multilingual** — English and Spanish support

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift (Xcode 26) |
| UI Framework | SwiftUI |
| State Management | `@Observable` + `@State` |
| Authentication | Firebase Auth (Email + Google) |
| Backend | .NET 10 REST API (Clean Architecture) |
| Database | Cloud Firestore |
| Infrastructure | Google Cloud Run |
| Logging | swift-log |
| Testing | Swift Testing |
| Dependency Management | Swift Package Manager |

---

## 🏗️ Architecture

The app follows **Clean Architecture** per feature. Views depend on ViewModels and domain abstractions only; the concrete implementations are the default arguments of each ViewModel.

```
TaskManager/
├── Core/
│   ├── Config/          # API and app configuration
│   ├── Errors/          # Failure types
│   ├── Logging/         # AppLogger (swift-log)
│   └── Network/         # API client with Firebase auth
└── Features/
    ├── Auth/            # Login, register, Google Sign-In
    ├── Boards/          # CRUD boards
    ├── Tasks/           # CRUD tasks, priorities, statuses
    └── Profile/         # Settings, notifications, language
```

Each feature follows the pattern:

```
Feature/
├── Data/
│   ├── DataSources/     # Remote API calls
│   ├── Models/          # DTO models
│   └── Repositories/    # Repository implementations
├── Domain/
│   ├── Entities/        # Domain entities
│   ├── Repositories/    # Abstract repository interfaces
│   └── UseCases/        # One use case per operation
└── Presentation/
    ├── Views/           # SwiftUI screens
    ├── ViewModels/      # @Observable ViewModels
    └── Components/      # Reusable UI components
```

---

## 🧭 Technical Decisions

- **Clean Architecture per feature.** Each feature has its own `Data / Domain / Presentation`. The domain layer only imports Foundation, so business rules can be tested without a device or Firebase.
- **`@Observable` ViewModels with an enum for each screen state.** `loading`, `loaded` and `error` are explicit cases, so a view cannot read data that is not there. No `ObservableObject` and no Combine.
- **`async/await` with typed errors.** Repositories and data sources `throw` a `Failure`; the ViewModels catch it, log it through `AppLogger` (swift-log) and turn it into screen state. Each `Failure` has a technical description for the log and a separate localised `userMessage` (English and Spanish) for the screen, so technical detail goes to the log, not to the user. Any error that is not a `Failure` falls back to a generic message.
- **Validation in the use cases.** Input rules (empty board name, empty task title, ignoring surrounding spaces) live in the domain as `Failure.validation` with a localised message, so they are tested once and never reach the network.
- **Failed writes never lose what the user has.** Creating, editing and deleting boards and tasks return the user message on failure (`nil` on success). The add and edit sheets only close on success and show an alert otherwise, keeping what was typed; a failed delete shows an alert and keeps the loaded list. The profile switches and a failed sign-out work the same way: the screen stays as it was and an alert explains what happened.
- **Firebase errors are translated, not shown.** `FirebaseAuthErrorMapper` is a pure function that turns Firebase Auth error codes into `Failure` cases (wrong credentials, email already in use, weak password, too many requests, no network). During sign-in the login screen stays on screen with its fields, so a wrong password shows an alert instead of clearing the form.
- **Cancellation is not an error.** Cancelling a request or closing the Google sign-in window restores the previous state instead of showing an error.
- **One use case per operation.** Every feature goes through use cases, so the rule is uniform. The trade-off is some thin classes that only forward the call.
- **Dependencies behind protocols, wired with default arguments.** Production code builds the real implementations through the ViewModel initialisers, and tests inject fakes. There is no DI container, which keeps the project small; the cost is that wiring lives in the initialisers.
- **Profile name saved API first, Firebase second.** Editing the name touches two systems that cannot be updated atomically. The API is saved first; if the Firebase update then fails, the previous name is restored in the API, so the user never ends up with two different names. The view does not import Firebase: it only calls ViewModels.
- **A network client that can be tested.** `NetworkClient` receives its `URLSession` and a token provider, so the tests run it against a stubbed `URLProtocol` and check the bearer header, status mapping and decoding without touching the network.
- **App Transport Security stays on.** The only exception is local networking, for development against `localhost`.
- **Shared .NET 10 API.** Business rules live on the server; the app sends the Firebase ID token. One backend serves all the apps in this portfolio.
- **Tests with Swift Testing and hand-written fakes.** ViewModels, repository mappings, the network client, the Firebase error mapper and the user-facing messages are covered with fakes of the domain protocols, with no mocking library. The alerts and sheets themselves are not covered by automated UI tests.

### Known limitations

Deliberate technical debt, documented rather than hidden:

- **Expired session.** The network client treats every non-2xx response as a generic server error: a 401 is not told apart from a 500, and the app does not sign the user out or retry on its own. Firebase renews the ID token when the app asks for it, so the case is rare, but a server-side 401 ends in an error alert. Timeouts are the `URLSession` defaults rather than explicit values.
- **Profile name across two systems.** The name is saved in the API first and then in Firebase; if the Firebase step fails, the app restores the previous name in the API. If that restore also fails, it is only logged, so the two names could differ until the next successful edit.
- **No automated UI tests.** Alerts and sheets are checked by hand; the automated tests cover ViewModels, repositories, the network client and the user-facing messages.
- **No DI container.** Dependencies are wired with default arguments in each ViewModel initialiser. That is simple at this size; if the project grew, a container would centralise the wiring.

### Other projects in this portfolio

| Project | Platform | Language |
|---|---|---|
| [finance-tracker](https://github.com/gcalvarez93/finance-tracker) | Flutter (iOS + Android) | Dart |
| [habit-tracker](https://github.com/gcalvarez93/habit-tracker) | Flutter (iOS + Android) | Dart |
| [task-manager](https://github.com/gcalvarez93/task-manager) | iOS | Swift |
| [task-manager-kmp](https://github.com/gcalvarez93/task-manager-kmp) | Android + iOS | Kotlin Multiplatform + Swift |
| [budget-scanner](https://github.com/gcalvarez93/budget-scanner) | iOS | Swift |
| [recipe-manager](https://github.com/gcalvarez93/recipe-manager) | Android | Kotlin |
| [workout-tracker](https://github.com/gcalvarez93/workout-tracker) | Android | Kotlin |
| [castrodev-api](https://github.com/gcalvarez93/castrodev-api) | Shared backend | C# (.NET 10) |

---

## 🚀 Getting Started

### Prerequisites

- Xcode 26+
- iOS 26+ (simulator or device)
- Firebase project configured
- API running at `api.castrodev.com` or locally

### Installation

```bash
# Clone the repository
git clone https://github.com/gcalvarez93/task-manager.git

# Open in Xcode
open TaskManager.xcodeproj
```

Then:

1. Add your `GoogleService-Info.plist` to the main target in Xcode
2. Set the API URL in the `API_URL` key of `Info.plist` (defaults to `https://api.castrodev.com`; if the key is missing the app falls back to `http://localhost:5166`)
3. Swift Package Manager dependencies resolve automatically on first open
4. Build and run with `⌘R`

### Running Tests

```bash
xcodebuild test \
  -scheme TaskManager \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

---

## 🔗 Related

- [CastroDev API](https://github.com/gcalvarez93/castrodev-api) — Shared .NET 10 backend

---

## 📄 License

MIT © Gabriel Castro

---

---

# Task Manager

App de gestión de tareas por tableros. Organiza tu trabajo en tableros personalizados, controla tus tareas por prioridad y estado, y mantén todo bajo control — con soporte completo de modo oscuro.

---

## ✨ Funcionalidades

- 📋 **Tableros** — Crea tableros con colores personalizados y consulta el número de tareas de un vistazo
- ✅ **Tareas** — Añade tareas con prioridades (Alta, Media, Baja) y estados (Por Hacer, En Progreso, Completado)
- 🌙 **Modo oscuro** — Modo oscuro/claro automático según el sistema
- 👤 **Perfil** — Edita tu nombre, gestiona notificaciones, cambia el idioma y la apariencia
- 🌍 **Multiidioma** — Soporte para español e inglés

---

## 🛠️ Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Lenguaje | Swift (Xcode 26) |
| UI Framework | SwiftUI |
| Estado | `@Observable` + `@State` |
| Autenticación | Firebase Auth (Email + Google) |
| Backend | API REST .NET 10 (Clean Architecture) |
| Base de datos | Cloud Firestore |
| Infraestructura | Google Cloud Run |
| Logging | swift-log |
| Tests | Swift Testing |
| Gestión de dependencias | Swift Package Manager |

---

## 🧭 Decisiones Técnicas

- **Clean Architecture por feature.** Cada feature tiene su propio `Data / Domain / Presentation`. La capa de dominio solo importa Foundation, así que las reglas de negocio se prueban sin dispositivo ni Firebase.
- **ViewModels `@Observable` con un enum por estado de pantalla.** `loading`, `loaded` y `error` son casos explícitos, y la vista no puede leer datos que no existen. Sin `ObservableObject` ni Combine.
- **`async/await` con errores tipados.** Los repositorios y data sources lanzan un `Failure`; los ViewModels lo capturan, lo registran con `AppLogger` (swift-log) y lo convierten en estado de pantalla. Cada `Failure` tiene una descripción técnica para el log y un `userMessage` localizado aparte (español e inglés) para la pantalla, así que el detalle técnico va al log, no al usuario. Cualquier error que no sea un `Failure` usa un mensaje genérico.
- **Validación en los casos de uso.** Las reglas de entrada (nombre de tablero vacío, título de tarea vacío, ignorando los espacios de los extremos) viven en el dominio como `Failure.validation` con un mensaje localizado, así que se prueban una vez y nunca llegan a la red.
- **Una escritura fallida no hace perder lo que el usuario tiene.** Crear, editar y borrar tableros y tareas devuelven el mensaje para el usuario si fallan (`nil` si salen bien). Las hojas de crear y editar solo se cierran si tiene éxito y, si no, muestran una alerta conservando lo escrito; un borrado fallido muestra una alerta y mantiene la lista cargada. Los interruptores del perfil y un cierre de sesión fallido funcionan igual: la pantalla se queda como estaba y una alerta explica qué pasó.
- **Los errores de Firebase se traducen, no se muestran.** `FirebaseAuthErrorMapper` es una función pura que convierte los códigos de error de Firebase Auth en casos de `Failure` (credenciales incorrectas, email ya en uso, contraseña débil, demasiados intentos, sin red). Durante el inicio de sesión la pantalla de login sigue visible con sus campos, así que una contraseña incorrecta muestra una alerta en lugar de vaciar el formulario.
- **Cancelar no es un error.** Cancelar una petición o cerrar la ventana de Google restaura el estado anterior en lugar de mostrar un error.
- **Un caso de uso por operación.** Todas las features pasan por casos de uso, así que la regla es uniforme. El inconveniente son algunas clases finas que solo reenvían la llamada.
- **Dependencias tras protocolos, enlazadas con argumentos por defecto.** El código de producción construye las implementaciones reales en los inicializadores de los ViewModels, y los tests inyectan fakes. No hay contenedor de DI, lo que mantiene el proyecto pequeño; el coste es que el enlazado vive en los inicializadores.
- **Nombre de perfil: primero API, después Firebase.** Editar el nombre toca dos sistemas que no se pueden actualizar de forma atómica. Se guarda primero en la API; si después falla Firebase, se restaura el nombre anterior en la API, de modo que el usuario nunca acaba con dos nombres distintos. La vista no importa Firebase: solo llama a ViewModels.
- **Un cliente de red que se puede probar.** `NetworkClient` recibe su `URLSession` y un proveedor de token, así que los tests lo ejecutan contra un `URLProtocol` simulado y comprueban la cabecera bearer, el mapeo de códigos HTTP y la decodificación sin tocar la red.
- **App Transport Security activado.** La única excepción es la red local, para desarrollar contra `localhost`.
- **API compartida en .NET 10.** Las reglas de negocio viven en el servidor; la app envía el token de Firebase. Un solo backend sirve a todas las apps de este portfolio.
- **Tests con Swift Testing y fakes escritos a mano.** Los ViewModels, los mapeos de repositorios, el cliente de red, el traductor de errores de Firebase y los mensajes para el usuario están cubiertos con fakes de los protocolos del dominio, sin librería de mocks. Las alertas y las hojas en sí no tienen tests de UI automáticos.

### Limitaciones conocidas

Deuda técnica asumida a propósito, documentada en lugar de ocultada:

- **Sesión caducada.** El cliente de red trata cualquier respuesta no 2xx como un error genérico de servidor: un 401 no se distingue de un 500, y la app no cierra la sesión ni reintenta por sí sola. Firebase renueva el token de ID cuando la app lo pide, así que el caso es raro, pero un 401 del servidor acaba en una alerta de error. Los timeouts son los de `URLSession` por defecto, no valores explícitos.
- **Nombre de perfil en dos sistemas.** El nombre se guarda primero en la API y luego en Firebase; si falla el paso de Firebase, la app restaura el nombre anterior en la API. Si esa restauración también falla, solo se registra en el log, así que los dos nombres podrían diferir hasta la próxima edición correcta.
- **Sin tests de UI automáticos.** Las alertas y las hojas se comprueban a mano; los tests automáticos cubren ViewModels, repositorios, el cliente de red y los mensajes para el usuario.
- **Sin contenedor de DI.** Las dependencias se enlazan con argumentos por defecto en el inicializador de cada ViewModel. Es sencillo a este tamaño; si el proyecto creciera, un contenedor centralizaría el enlazado.

### Otros proyectos del portfolio

| Proyecto | Plataforma | Lenguaje |
|---|---|---|
| [finance-tracker](https://github.com/gcalvarez93/finance-tracker) | Flutter (iOS + Android) | Dart |
| [habit-tracker](https://github.com/gcalvarez93/habit-tracker) | Flutter (iOS + Android) | Dart |
| [task-manager](https://github.com/gcalvarez93/task-manager) | iOS | Swift |
| [task-manager-kmp](https://github.com/gcalvarez93/task-manager-kmp) | Android + iOS | Kotlin Multiplatform + Swift |
| [budget-scanner](https://github.com/gcalvarez93/budget-scanner) | iOS | Swift |
| [recipe-manager](https://github.com/gcalvarez93/recipe-manager) | Android | Kotlin |
| [workout-tracker](https://github.com/gcalvarez93/workout-tracker) | Android | Kotlin |
| [castrodev-api](https://github.com/gcalvarez93/castrodev-api) | Backend compartido | C# (.NET 10) |

---

## 🚀 Instalación

### Requisitos previos

- Xcode 26+
- iOS 26+ (simulador o dispositivo)
- Proyecto Firebase configurado
- API disponible en `api.castrodev.com` o en local

### Pasos

```bash
# Clonar el repositorio
git clone https://github.com/gcalvarez93/task-manager.git

# Abrir en Xcode
open TaskManager.xcodeproj
```

A continuación:

1. Añade tu `GoogleService-Info.plist` al target principal en Xcode
2. Indica la URL de la API en la clave `API_URL` de `Info.plist` (por defecto `https://api.castrodev.com`; si la clave no existe, la app usa `http://localhost:5166`)
3. Las dependencias de Swift Package Manager se resuelven automáticamente al abrir el proyecto
4. Compila y ejecuta con `⌘R`

### Tests

```bash
xcodebuild test \
  -scheme TaskManager \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

---

## 🔗 Relacionado

- [CastroDev API](https://github.com/gcalvarez93/castrodev-api) — Backend compartido en .NET 10

---

## 📄 Licencia

MIT © Gabriel Castro
