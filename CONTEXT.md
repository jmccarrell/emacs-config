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
