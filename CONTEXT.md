# Emacs Configuration Workspace

This workspace coordinates Jeff's Emacs configuration work: durable intent,
reference intelligence, and the roadmap for improving the active configuration.

## Language

**Spec**:
A durable, numbered statement of intent in `specs/`. A spec is the source of
scope for work and persists as project history.
_Avoid_: Ticket, task

**Spec Shape**:
The classification of a Spec that determines how it is investigated and
decomposed: broad exploratory, narrow directive, pushback/redesign, or
extension/refinement.
_Avoid_: Spec type, request type

**Reference-Repository Inventory**:
The complete registry of external Emacs-configuration repositories and their
last-known commits. It preserves which references are available for analysis.
_Avoid_: Reference synthesis, reference cache

**Reference Cache**:
The per-machine, regenerable local clones of repositories in the
Reference-Repository Inventory.
_Avoid_: Reference repository, reference synthesis

**Reference Synthesis**:
The tracked analysis of the Active References and the signals extracted from
them for this project.
_Avoid_: Reference-repository inventory, reference cache

**Active Reference**:
A Reference-Repository Inventory entry currently analyzed in the Reference
Synthesis at HIGH or MEDIUM tier.
_Avoid_: Cached repository

**Landscape**:
The active Emacs configuration's modernization roadmap. It consumes relevant
signals from the Reference Synthesis without duplicating repository analysis.
_Avoid_: Reference synthesis, inventory

**Rust Development Workflow**:
The Rust-focused editing and feedback experience in the active Emacs
configuration: navigation, diagnostics, formatting, testing, debugging,
project tooling, and explicitly scoped AI assistance. It supports both daily
project work and Rust course exercises. Its AI assistance extends a validated
Core Rust Loop.
_Avoid_: Rust setup, Rust support

**Review-First AI Assistance**:
AI support that works from explicitly selected context and requires review
before changing code. Inline completion and autonomous editing are separate,
opt-in capabilities.
_Avoid_: AI coding assistant, autonomous agent

**Cargo Project**:
A Rust project described by Cargo, either as a single crate or as a workspace
of related crates.
_Avoid_: Rust project, crate repository

**Core Rust Loop**:
The first usable Rust Development Workflow: editing, navigation, diagnostics,
formatting, and test execution. Debugging is a later capability, not a
prerequisite for adoption.
_Avoid_: Complete IDE, debugger workflow

**Low-Surface-Area Rust Stack**:
The Rust Development Workflow built first from Emacs 30 capabilities, with
additional packages adopted only to fill a demonstrated gap.
_Avoid_: Full Rust IDE distribution, package bundle
