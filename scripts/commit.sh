#!/usr/bin/env bash

DIFF=$(git diff)
PAYLOAD=$(
  jq -n \
    --arg DIFF "$DIFF" \
    '{
    model: "PLACEHOLDER",
    messages: [
      {
        role: "user",
        content: (
            "Generate a git commit message in PLAIN TEXT.\n\n" +
            "RULES:\n" +
            "1. Output MUST be ONLY a single line.\n" +
            "2. Maximum 70 characters.\n" +
            "3. Use ONLY lowercase letters (no uppercase).\n" +
            "4. DO NOT use colons (:), symbols, or special characters.\n" +
            "5. DO NOT use markdown.\n" +
            "7. DO NOT use git flags or types (no feat, fix, chore, etc.).\n" +
            "8. The message must represent the core idea behind the code changes.\n" +
            "9. No explanations, just the message.\n\n" +
            "DIFF:\n" +
            $DIFF
        )
      }
    ]
  }'
)

echo

response=$(
  gum spin \
    --spinner line \
    --title "Generating..." \
    -- curl -s http://localhost:1234/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD"
) || {
  gum log --structured --level fatal "Failed to execute the cURL command."
  exit 1
}

message=$(echo "$response" | jq -r '.choices[0].message.content')

echo
echo "$message"
echo

gum confirm "Apply commit?" && {
  git add .
  git commit -m "$message"
} || {
  exit 0
}
