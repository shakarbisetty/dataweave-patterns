## DataWeave partition() for bulk API responses
> The Arrays module must be imported to your DataWeave code by adding the line `import * from dw::core::Arrays` to the header of your DataWeave script

### When to Use
- I add the explicit import statement to every DataWeave script that uses array functions before writing any logic.
- I map the `success` and `failure` keys from the partition result to domain-specific names immediately after the split operation.
- I verify the output structure against the expected schema to ensure downstream systems receive the correct payload format.
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
3. The `accepted` array lists the IDs of records that passed validation, while the `rejected` array contains objects with IDs and reasons for failure.
4. The `retryCount` field reports the total number of rejected items as an integer value.
5. Runs shown: DataWeave CLI 2.12.2

### Gotchas
- Readers hit a missing import error that prevents resolution of the `partition` function reference.
- I lost a batch of orders because the partition function threw an unresolved reference error during execution.
- The import statement for `dw::core::Arrays` was missing from the script header, causing the flow to abort before processing any records.

### Related
- [Distinct By (Remove Duplicates)](../distinct-by.dwl) — Remove duplicate elements from an array based on a specific
- [Zip Arrays](../zip-arrays.dwl) — Combine two arrays element-wise into an array of pairs (or merged
