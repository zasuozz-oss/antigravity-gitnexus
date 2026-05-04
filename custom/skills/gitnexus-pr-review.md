---
name: gitnexus-pr-review
description: "Use when reviewing a pull request or diff — understanding what changed, tracing codebase impact, checking missing test coverage, or assessing merge risk. Also for review-mode findings. Mandatory before relying on raw `git diff`, `grep`, or file reads for PR risk when the repo has `.gitnexus/` or is indexed."
---

# PR Review with GitNexus

## When to Use

- Reviewing any pull request
- Understanding what a diff actually changes end-to-end
- Checking if tests cover the changed paths
- Assessing risk before merging

## Workflow

```
1. mcp__gitnexus__detect_changes({...})           → What symbols changed?
2. gitnexus_context({name: "<changed>"})          → Who uses each changed symbol?
3. mcp__gitnexus__impact({name: "<changed>"})     → Full blast radius of changes
4. READ gitnexus://repo/{name}/process/{name}      → Are affected flows tested?
```

## Checklist

```
- [ ] detect_changes — list all modified symbols
- [ ] gitnexus_context on each changed symbol
- [ ] Impact analysis for high-risk changes
- [ ] Verify test coverage for affected processes
- [ ] Flag untested or high-blast-radius changes
```

## Tools

**detect_changes** — diff-aware symbol changes:

```
gitnexus detect_changes
→ Modified: validatePayment, processRefund
→ Added: handleTimeout
→ Deleted: legacyCharge
```

**gitnexus_context** — who uses the changed symbols:

```
gitnexus_context({name: "validatePayment"})
→ Called by: checkoutHandler, webhookHandler
→ In processes: CheckoutFlow, RefundFlow
```

## Example: Reviewing a payment refactor PR

```
1. detect_changes
   → Modified: validatePayment (signature changed!)

2. gitnexus_context({name: "validatePayment"})
   → 2 callers — both pass old argument order

3. Impact: CheckoutFlow + RefundFlow both affected

4. Tests: checkout.test.ts covers CheckoutFlow ✓
          refund.test.ts missing RefundFlow path ✗

5. Review comment: missing test coverage for RefundFlow
```
