---
name: gitnexus-impact-analysis
description: "Use before changing, moving, or deleting any code — to understand blast radius, find all dependents, and verify safety. Also use when asked about dependencies or ripple effects of a proposed change."
---

# Impact Analysis with GitNexus

## When to Use

- "Is it safe to change X?"
- "What depends on this function?"
- "What will break if I rename this?"
- Before any refactor, deletion, or API change
- Assessing risk before merging

## Workflow

```
1. gitnexus_context({name: "<target>"})           → See all callers and processes using it
2. mcp__gitnexus__impact({name: "<target>"})      → Full blast-radius report
3. READ gitnexus://repo/{name}/process/{name}      → Check affected flows
4. gitnexus_query({query: "<related concept>"})   → Find adjacent code that may be affected
```

## Checklist

```
- [ ] gitnexus_context on the target symbol — who calls it?
- [ ] gitnexus impact tool for full blast radius
- [ ] Review every affected process
- [ ] Check if any public API or test depends on target
- [ ] Read source files for any implicit coupling not in graph
```

## Tools

**gitnexus_context** — immediate callers and processes:

```
gitnexus_context({name: "processPayment"})
→ Incoming: checkoutHandler (3 calls), webhookHandler (1 call)
→ Processes: CheckoutFlow, RefundFlow, WebhookHandler
```

**impact** — full transitive blast radius:

```
gitnexus impact processPayment
→ Direct callers: 2
→ Indirect dependents: 14
→ Affected processes: CheckoutFlow, RefundFlow, AdminDashboard
```

## Example: "Is it safe to rename processPayment?"

```
1. gitnexus_context({name: "processPayment"})
   → Called by: checkoutHandler, webhookHandler, adminRefund
   → In processes: CheckoutFlow (step 4), RefundFlow (step 2)

2. impact analysis
   → 3 direct callers, 8 indirect dependents
   → Tests: checkout.test.ts, refund.test.ts

3. Verdict: safe if all 3 callers + 2 test files are updated
```
