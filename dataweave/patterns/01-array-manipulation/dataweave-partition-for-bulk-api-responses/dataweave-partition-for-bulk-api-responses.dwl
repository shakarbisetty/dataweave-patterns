/**
 * Pattern: DataWeave partition() for bulk API responses
 * Category: Array Manipulation
 * Difficulty: Intermediate
 *
 * Description: The Arrays module must be imported to your DataWeave code by adding the line `import * from dw::core::Arrays` to the header of your DataWeave script. I add `import * from dw::core::Arrays` to the DataWeave header before using `partition`.
 *
 * Input (application/json):
 * {
 *   "records": [
 *     { "id": "ORD-1001", "email": "ana@example.com" },
 *     { "id": "ORD-1002", "email": "bad-address" },
 *     { "id": "ORD-1003", "email": "raj@example.org" },
 *     { "id": "ORD-1004" },
 *     { "id": "ORD-1005", "email": "mei@example.net" }
 *   ]
 * }
 *
 * Output (application/json):
 * {
 *   "accepted": [
 *     "ORD-1001",
 *     "ORD-1003",
 *     "ORD-1005"
 *   ],
 *   "rejected": [
 *     {
 *       "id": "ORD-1002",
 *       "reason": "missing or invalid email"
 *     },
 *     {
 *       "id": "ORD-1004",
 *       "reason": "missing or invalid email"
 *     }
 *   ],
 *   "retryCount": 2
 * }
 */
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
