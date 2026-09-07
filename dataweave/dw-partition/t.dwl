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
