# Engineering Production-Ready Flutter Apps

![Status](https://img.shields.io/badge/Status-Active_Development-yellow)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Architecture](https://img.shields.io/badge/Architecture-Clean-green)
![License](https://img.shields.io/badge/License-MIT-purple)

> A reference architecture for building Flutter apps that hold up in production.

## About

This is the working code behind my article series, "Engineering Production-Ready Flutter Apps". Each part takes a real production problem (silent crashes, memory leaks, insecure storage, navigation you can't observe) and works through a solution you can ship, not a toy example.

## The article series

The code evolves with the articles. Each part adds a production-grade layer.

| Part | Article | Focus |
| :--- | :--- | :--- |
| 01 | [When SharedPreferences Fails](https://dev.to/devmatrash/when-sharedpreferences-fails-architecting-resilient-cache-infrastructure-for-production-flutter-3j3d) | Resilient caching, circuit breakers, LRU eviction |
| 02 | [The JWT Token Incident](https://dev.to/devmatrash/the-jwt-token-incident-why-your-flutter-apps-cache-isnt-secure-and-how-to-fix-it-56i5) | Secure storage: Keychain, Keystore, encryption |
| 03 | [From 0.3% Crash Rate to Zero](https://dev.to/devmatrash/from-03-crash-rate-to-zero-scaling-flutter-cache-with-batching-locking-and-observable-state-24oi) | Batching, locking, observable state |
| 04 | [A Production Navigation Observability System](https://dev.to/devmatrash/deep-dive-building-a-production-ready-navigation-observability-system-in-flutter-2k24) | Clean architecture, low overhead, privacy |

## Status

`v0.1.0-alpha`. This is a reference architecture, not a drop-in package yet. The code tracks the article series, so expect breaking changes as new layers (networking, state management) land. I'm sharing it early to build in the open.

## What's inside so far

- **Clean architecture core:** separation of domain, data, infrastructure, and presentation.
- **Navigation observability:** an event bus with O(1) routing, PII auto-redaction by default, and a router-agnostic adapter (currently `auto_route`).
- **Caching:** a two-layer cache (memory and disk) with LRU eviction.
- **Fault tolerance and security:** circuit breakers to stop cascading failures, and wrappers over the iOS Keychain and Android Keystore.

## Feedback

Issues and suggestions are welcome. If you want to contribute, open an issue or a PR and match the existing structure.

---

**Author:** [Mahmoud Alatrash](https://www.linkedin.com/in/devmatrash/)
