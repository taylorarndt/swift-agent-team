# Swift Agents — Copilot Instructions

Before proceeding with any task involving Swift code, SwiftUI views, UIKit views, async/await, actors, Sendable, @MainActor, Foundation Models, MLX, Core ML, coremltools, model conversion, MLXLLM, MLXVLM, MLXLMCommon, LLMModelFactory, ChatSession, GenerateParameters, LoRA, Hugging Face models, Keychain, CryptoKit, biometric auth, App Store submission, testing, SwiftData, @Model, ModelContainer, @Query, persistence, schema migration, visionOS, RealityKit, ARKit, immersive spaces, spatial computing, StoreKit, in-app purchases, subscriptions, Product, Transaction, performance profiling, Instruments, MetricKit, hang detection, launch time, memory optimization, Meta Wearables DAT, or any iOS/macOS/visionOS application code:

1. Switch to the **swift-lead** agent
2. The swift-lead will determine which specialist agents are needed
3. Do NOT write SwiftUI code without mobile-a11y-specialist review
4. Do NOT write concurrent code without concurrency-specialist review
5. Do NOT handle credentials or encryption without swift-security-specialist review
6. Do NOT submit to App Store without app-review-guardian review
7. Do NOT convert or optimize ML models without coreml-specialist review
8. Do NOT use MLX Swift, MLXLLM, or MLXVLM without mlx-specialist review
9. Do NOT write SwiftData models or queries without swiftdata-specialist review
10. Do NOT build visionOS or RealityKit features without visionos-specialist review
11. Do NOT implement in-app purchases without storekit-specialist review
12. Do NOT optimize performance without performance-specialist review

## Critical Rules

- For NEW projects or features: Enter plan mode FIRST. Design architecture before writing code.
- NEVER create mock, placeholder, or stub implementations. All code must be real and functional.
- Use built-in SwiftUI features instead of building custom replacements.
- Settings screens MUST use `Form { Section { Toggle/Picker/Stepper } }`. Not custom VStacks.
- macOS preferences MUST use the `Settings { }` scene. Not a custom window.
- Persistence MUST use `@AppStorage` for UserDefaults. Not manual `UserDefaults.standard` calls.
- Use `.searchable`, `.refreshable`, `PhotosPicker`, `ShareLink`, `SubscriptionStoreView`, `.confirmationDialog`.
- Use Swift compiler synthesis (`Codable`, `Equatable`, `Hashable`) instead of manual implementations.

If the task does not involve any Swift or Apple platform code, proceed normally.
