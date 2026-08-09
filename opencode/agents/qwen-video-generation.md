---
description: Call the QwenCloud Token Plan video generation models to generate videos from text descriptions, first-frame images, or reference images. Activates when the user asks to generate a video.
mode: subagent
permission:
  bash: allow
---

Call the QwenCloud Token Plan video generation API to generate a video based on the user's request.

## Steps

1. Extract prompt (video description) and optional parameters from the user request:
   - model: default happyhorse-1.1-t2v, or happyhorse-1.1-i2v (image-to-video), happyhorse-1.1-r2v (reference-to-video). If the user explicitly specifies a model, use that model name exactly and do not fall back to the default.
   - duration: video length in seconds, default 5
   - resolution: default 720P, or 1080P
   - ratio: aspect ratio, default 16:9 (text-to-video and reference-to-video only)
   - For image-to-video (happyhorse-1.1-i2v), include the first-frame image URL alongside the description in the prompt. For reference-to-video (happyhorse-1.1-r2v), include the reference image URLs.

2. Submit a video generation task (use the Bash tool to run curl):

```
curl -s -X POST "https://token-plan.ap-southeast-1.maas.aliyuncs.com/api/v1/services/aigc/video-generation/video-synthesis" \
  -H "X-DashScope-Async: enable" \
  -H "Authorization: Bearer $QWENCLOUD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "<model>",
    "input": {
      "prompt": "<prompt>"
    },
    "parameters": {
      "resolution": "<resolution>",
      "ratio": "<ratio>",
      "duration": <duration>
    }
  }'
```

3. Extract the task ID from output.task_id in the response JSON.

4. Poll the task status every 15 seconds:

```
curl -s -X GET "https://token-plan.ap-southeast-1.maas.aliyuncs.com/api/v1/tasks/<task_id>" \
  -H "Authorization: Bearer $QWENCLOUD_API_KEY"
```

5. When output.task_status is SUCCEEDED, extract the video URL from output.video_url. When task_status is FAILED, show the error message to the user.

6. Download the video to the current directory with `curl -s -o "generated_$(date +%Y%m%d_%H%M%S).mp4" "<video_url>"`.

7. Display the generated video file path to the user.
