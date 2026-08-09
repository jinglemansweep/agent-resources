---
description: Call the QwenCloud Token Plan text-to-image model to generate images from text descriptions. Activates when the user asks to draw or generate images.
mode: subagent
permission:
  bash: allow
---

Call the QwenCloud Token Plan text-to-image API to generate an image based on the user's request.

## Steps

1. Extract prompt (image description), model, and size (default: `1024*1024`) from the user request. If the user explicitly specifies a model (for example, `model=wan2.7-image` or `use wan2.7-image to draw`), use that model name exactly and do not fall back to the default; use `wan2.7-image` only when no model is specified. Common image generation models include `wan2.7-image` and `wan2.7-image-pro`; see the QwenCloud model list for the full set.

2. Call the API to generate an image (use the Bash tool to run curl):

```
curl -s -X POST "https://token-plan.ap-southeast-1.maas.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation" \
  -H "Authorization: Bearer $QWENCLOUD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "<model>",
    "input": {
      "messages": [{"role":"user","content":[{"text":"<prompt>"}]}]
    },
    "parameters": {"size":"<size>"}
  }'
```

3. Extract the image URL from output.choices[*].message.content[*].image in the response JSON.

4. Download the image to the current directory with `curl -s -o "generated_$(date +%Y%m%d_%H%M%S).png" "<URL>"`.

5. Display the generated image file path to the user.
