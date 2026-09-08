%dw 2.0
import modules::ValidationUtils
output application/json
---
ValidationUtils::validateAll(payload, {
  name: { required: true, minLength: 3 },
  age: { min: 18, max: 99 }
})
