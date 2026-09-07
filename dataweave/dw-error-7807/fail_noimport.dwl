%dw 2.0
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
