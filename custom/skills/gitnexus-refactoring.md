---
name: gitnexus-refactoring
description: "Use whenever restructuring code — renaming symbols, extracting modules, moving files, splitting classes, or changing multiple call sites. Also during writing-plans refactor decomposition. Mandatory before manual search/replace, `mv`, broad `rg`, or raw call-site scans when the repo has `.gitnexus/` or is indexed."
---

# Refactoring with GitNexus

## When to Use

- Renaming a function, class, or variable
- Extracting logic into a new module
- Moving code to a different file or package
- Splitting a large class or service
- Any change that touches multiple call sites

## Workflow

```
1. gitnexus_context({name: "<target>"})           → Find all call sites
2. mcp__gitnexus__impact({name: "<target>"})      → Full blast radius
3. mcp__gitnexus__rename({...})                   → Safe rename across graph
4. Verify with gitnexus_context after change      → Confirm no dangling refs
```

## Checklist

```
- [ ] gitnexus_context — list all callers and processes
- [ ] Impact analysis — understand full blast radius
- [ ] Plan: which files need updating?
- [ ] Execute rename/move
- [ ] Re-run context to verify no orphaned references
- [ ] Run tests to confirm
```

## Tools

**gitnexus_context** — find every call site before touching anything:

```
gitnexus_context({name: "UserService"})
→ Incoming: AuthController, ProfileController, AdminService
→ Processes: LoginFlow, RegistrationFlow, AdminPanel
```

**rename** — update symbol name in graph:

```
gitnexus rename UserService → AccountService
→ Updated 3 callers, 2 processes
```

## Example: "Rename UserService to AccountService"

```
1. gitnexus_context({name: "UserService"})
   → 3 direct callers, referenced in 4 processes

2. Impact: AuthController.ts, ProfileController.ts, AdminService.ts
           + tests: auth.test.ts, profile.test.ts

3. Rename in graph → gitnexus rename

4. Update each file manually (or via find/replace)

5. Re-check context → 0 remaining references to UserService
```
