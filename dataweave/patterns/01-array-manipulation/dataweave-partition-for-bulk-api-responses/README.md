## DataWeave partition() for bulk API responses
> The Arrays module must be imported to your DataWeave code by adding the line `import * from dw::core::Arrays` to the header of your DataWeave script

### When to Use
- I add `import * from dw::core::Arrays` to the DataWeave header before using `partition`.
- I map the `success` and `failure` keys to domain names like `accepted` and `rejected`.
- I calculate retry counts using `sizeOf` on the failure partition.
- The Arrays module must be imported to your DataWeave code by adding the line `import * from dw::core::Arrays` to the header of your DataWeave script.

### Configuration / Code

Input (`application/json`):

```json
{
  "records": [
    { "id": "ORD-1001", "email": "ana@example.com" },
    { "id": "ORD-1002", "email": "bad-address" },
    { "id": "ORD-1003", "email": "raj@example.org" },
    { "id": "ORD-1004" },
    { "id": "ORD-1005", "email": "mei@example.net" }
  ]
}
```

```dataweave
%dw 2.0
// partition() lives in dw::core::Arrays — not imported by default
import * from dw::core::Arrays
output application/json
// keys are ALWAYS success/failure — re-map them to domain names
var split = payload.records partition (r) ->
    (r.email default "") matches /.+@.+\..+/
---
{
  accepted: split.success map (r) -> r.id,
  rejected: split.failure map (r) -> {
    id: r.id,
    reason: "missing or invalid email"
  },
  retryCount: sizeOf(split.failure)
}
```

Output (`application/json`):

```json
{
  "accepted": [
    "ORD-1001",
    "ORD-1003",
    "ORD-1005"
  ],
  "rejected": [
    {
      "id": "ORD-1002",
      "reason": "missing or invalid email"
    },
    {
      "id": "ORD-1004",
      "reason": "missing or invalid email"
    }
  ],
  "retryCount": 2
}
```

### How It Works
1. partition() lives in dw::core::Arrays — not imported by default
2. keys are ALWAYS success/failure — re-map them to domain names
3. The `accepted` array contains IDs from records with valid emails, while the `rejected` array holds objects for records missing or invalidating email addresses.
4. The `retryCount` field reports the size of the failure partition as two.
5. Runs shown: DataWeave CLI 2.12.2

### Gotchas
- The trap is an unresolved reference error when calling `partition` without importing the Arrays module.
- My DataWeave script threw an unresolved reference error when calling `partition` without an explicit import.

### Related
- [Distinct By (Remove Duplicates)](../distinct-by.dwl) — Remove duplicate elements from an array based on a specific
- [Zip Arrays](../zip-arrays.dwl) — Combine two arrays element-wise into an array of pairs (or merged
