/**
 * Pattern: RFC 7807 error envelope in DataWeave
 * Category: Error Handling
 * Difficulty: Intermediate
 *
 * Description: The documentation describes `try` as a function that returns a Result object for handling errors. I always add `import try from dw::Runtime` at the top of every script that uses the function.
 *
 * Input (application/json):
 * {
 *   "order": { "id": "ORD-2001", "total": "12.5O" }
 * }
 *
 * Output (application/json):
 * {
 *   "type": "https://example.com/problems/invalid-total",
 *   "title": "Invalid order total",
 *   "status": 400,
 *   "detail": "Cannot coerce String (12.5O) to Number",
 *   "instance": "/orders/ORD-2001",
 *   "errorKind": "InvalidNumberException"
 * }
 */
%dw 2.0
// try() lives in dw::Runtime — not imported by default
import try from dw::Runtime
// RFC 7807 media type is accepted as-is by the JSON writer
output application/problem+json
var attempt = try(() -> payload.order.total as Number)
---
if (attempt.success) { total: attempt.result }
else {
  "type": "https://example.com/problems/invalid-total",
  "title": "Invalid order total",
  "status": 400,
  "detail": attempt.error.message,
  "instance": "/orders/" ++ payload.order.id,
  "errorKind": attempt.error.kind
}
