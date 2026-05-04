---
name: gitnexus-guide
description: "Use when asking about GitNexus itself — available tools, knowledge graph behavior, MCP resources, Cypher/schema queries, or which GitNexus skill to use. Also when deciding between GitNexus skills or writing trigger guidance for GitNexus workflows."
---

# GitNexus Guide

## When to Use

- "What GitNexus tools are available?"
- "How do I query the knowledge graph?"
- "What MCP resources does GitNexus expose?"
- "Which skill should I use for X?"
- Reference for graph schema, Cypher queries, or MCP tool signatures

## MCP Tools

| Tool | What it does |
|------|-------------|
| `gitnexus_query` | Find execution flows related to a concept |
| `gitnexus_context` | 360° view of a symbol (callers, callees, processes) |
| `gitnexus_cypher` | Raw Cypher query against the knowledge graph |
| `gitnexus_impact` | Full blast-radius report for a symbol |
| `gitnexus_rename` | Update symbol name in the graph |
| `gitnexus_detect_changes` | Find which symbols changed in recent commits |
| `gitnexus_route_map` | API route → handler mapping |
| `gitnexus_shape_check` | Validate data shape at a symbol |

## MCP Resources

| Resource | What you get |
|----------|-------------|
| `gitnexus://repos` | All indexed repos |
| `gitnexus://repo/{name}/context` | Stats + staleness check |
| `gitnexus://repo/{name}/clusters` | Functional areas with cohesion scores |
| `gitnexus://repo/{name}/cluster/{name}` | Members of a functional area |
| `gitnexus://repo/{name}/process/{name}` | Step-by-step execution trace |

## Skill Map

| Task | Skill |
|------|-------|
| Read/understand code, architecture | `gitnexus-exploring` |
| Debug bugs, trace errors | `gitnexus-debugging` |
| Safety check before changes | `gitnexus-impact-analysis` |
| Rename, extract, move, restructure | `gitnexus-refactoring` |
| Review a PR | `gitnexus-pr-review` |
| Index, reindex, CLI operations | `gitnexus-cli` |
| This reference | `gitnexus-guide` |

## Graph Schema (key node types)

| Node | Properties |
|------|-----------|
| `Function` | name, file, line, signature |
| `Class` | name, file |
| `Process` | name, steps |
| `Module` | name, path |

## Key Relationships

| Relation | Meaning |
|----------|---------|
| `CALLS` | Function A calls Function B |
| `MEMBER_OF` | Symbol belongs to class/module |
| `PART_OF` | Symbol is a step in a process |
