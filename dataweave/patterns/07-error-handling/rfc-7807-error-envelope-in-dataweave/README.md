## RFC 7807 error envelope in DataWeave
> The documentation describes `try` as a function that returns a Result object for handling errors

### When to Use
- I always add `import try from dw::Runtime` at the top of every script that uses the function.
- I verify the import exists before running the transformation to prevent resolution errors.
- The documentation describes `try` as a function that returns a Result object for handling errors.

### Configuration / Code

Input (`application/json`):

```json
{
  "order": { "id": "ORD-2001", "total": "12.5O" }
}
```

```dataweave
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
```

Output (`application/json`):

```json
{
  "type": "https://example.com/problems/invalid-total",
  "title": "Invalid order total",
  "status": 400,
  "detail": "Cannot coerce String (12.5O) to Number",
  "instance": "/orders/ORD-2001",
  "errorKind": "InvalidNumberException"
}
```

### How It Works
1. try() lives in dw::Runtime — not imported by default
2. RFC 7807 media type is accepted as-is by the JSON writer
3. The `detail` field contains the string `Cannot coerce String (12.5O) to Number`.
4. The `errorKind` field holds the value `InvalidNumberException`.
5. Runs shown: DataWeave CLI 2.12.2

### Gotchas
- The missing import causes a resolution failure when the script executes.
- Running `fail_noimport.dwl` produces an exit code of 255 and reports `Unable to resolve reference of: try`.
- My script failed when `try` lacked an explicit import from `dw::Runtime`.
- The runtime reported `Unable to resolve reference of: try` during execution.

### Related
- [Try Pattern](../try-pattern.dwl) — Use the try function to attempt an operation that might fail
- [Batch Error Record Analysis](../batch-error-handler.dwl) — Analyze per-record batch failures using Mule 4.11's BatchError
