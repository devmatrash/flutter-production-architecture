# Engineering Production-Ready Flutter Apps 🚀

![Status](https://img.shields.io/badge/Status-Active_Development-yellow)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Architecture](https://img.shields.io/badge/Architecture-Clean-green)
![License](https://img.shields.io/badge/License-MIT-purple)

> **A living reference architecture for building fault-tolerant, secure, and scalable mobile applications.**

---

## 📖 About The Project

This repository is not just another "To-Do App" example. It is the practical implementation of my article series: **"Engineering Production-Ready Flutter Apps"**.

I am documenting the journey of solving real-world production nightmares—silent crashes, memory leaks, security vulnerabilities, and invisible user journeys—by engineering robust solutions from the ground up.

**My Philosophy:** I don't just "patch" bugs; I architect resilience.

### 🎯 The Mission
To provide the community with a battle-tested reference for:
* **Resilience:** Systems that degrade gracefully instead of crashing (Circuit Breakers).
* **Security:** Storing sensitive data using hardware-backed encryption, and sanitizing analytics strictly.
* **Performance:** Zero-overhead pipelines, isolate batching, and zero-copy operations.
* **Scale:** A Clean Architecture that survives team growth, library swaps, and feature bloat.

---

## 📚 The Article Series

This codebase evolves alongside the articles. Each part introduces a new, production-grade architectural layer.

### Core Infrastructure & Caching
| Part | Title | Focus | Status |
| :--- | :--- | :--- | :--- |
| **01** | **When SharedPreferences Fails** | Resilience, Circuit Breakers, LRU Eviction | [✅ **Published**](https://dev.to/devmatrash/when-sharedpreferences-fails-architecting-resilient-cache-infrastructure-for-production-flutter-3j3d) |
| **02** | **The JWT Token Incident** | Security, Keychain, Keystore, Encryption | [✅ **Published**](https://dev.to/devmatrash/the-jwt-token-incident-why-your-flutter-apps-cache-isnt-secure-and-how-to-fix-it-56i5) |
| **03** | **From 0.3% Crash Rate to Zero** | Performance, Batching, Concurrency | [✅ **Published**](https://dev.to/devmatrash/from-03-crash-rate-to-zero-scaling-flutter-cache-with-batching-locking-and-observable-state-24oi) |

### Navigation & Observability
| Part | Title | Focus | Status |
| :--- | :--- | :--- | :--- |
| **04** | **Building a Production-Ready Navigation Observability System** | Clean Architecture, Zero-Overhead, Privacy | [✅ **Published**](https://dev.to/devmatrash/deep-dive-building-a-production-ready-navigation-observability-system-in-flutter-2k24) |

*(Links are updated as articles go live)*

---

## 🚧 Project Status: Public Preview

**Current Version:** `v0.1.0-alpha` (Navigation Observability Merge)

⚠️ **Please Note:**
This repository is currently under **Active Development**.
* It serves as a **Reference Architecture**, not a drop-in package (yet).
* The code reflects the current state of the article series.
* Breaking changes may occur as new layers (Networking, State Management, etc.) are introduced.

I am sharing this early to build in public and learn together.

---

## 🛠️ Key Features (So Far)

* ✅ **Clean Architecture Core:** Strict separation of Domain, Data, Infrastructure, and Presentation.
* ✅ **Navigation Observability (NEW):**
    * **Zero-Overhead Event Bus:** O(1) event routing with early returns.
    * **Strict Privacy by Default:** Auto-redaction of PII/Sensitive data via zero-copy sanitization.
    * **Router-Agnostic:** Adapter pattern implementation (currently using `auto_route`).
* ✅ **Advanced Caching Strategy:**
    * **LRU Eviction Policy:** To manage memory usage efficiently.
    * **2-Layer Cache:** Memory (Fast) + Disk (Persistent).
* ✅ **Fault Tolerance & Security:**
    * **Circuit Breaker Pattern:** To isolate failures and prevent cascading crashes.
    * Abstracted wrappers for iOS Keychain and Android KeyStore.

---

## 🤝 Contributing & Feedback

I am building this for the community, and I'd love your input!

* **Found a bug?** Please open an [Issue](https://github.com/devmatrash/flutter-production-architecture/issues).
* **Have an architectural suggestion?** Discussions are open.
* **Want to contribute?** PRs are welcome! Please match the existing architectural style.

Let's build better Flutter apps, together. ❤️

---

**Author:** [Mahmoud Alatrash](https://www.linkedin.com/in/devmatrash/)
