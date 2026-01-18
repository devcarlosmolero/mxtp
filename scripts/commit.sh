#!/usr/bin/env bash

DIFF=$(git diff)
PAYLOAD=$(
  jq -n \
    --arg DIFF "$DIFF" \
    '{
    model: "qwen2.5-coder-7b-instruct",
    messages: [
      {
        role: "user",
        content: (
            "Generate a git commit message in PLAIN TEXT.\n\n" +
            "FORMAT (DO NOT DEVIATE):\n" +
            "<type>: <title>\n" +
            "\n" +
            "<description>\n\n" +
            "RULES:\n" +
            "1. Output MUST be ONLY the commit message. No explanations.\n" +
            "2. <type> MUST be one of: feat, fix, refactor, docs, test, chore.\n" +
            "3. The title MUST summarize the OVERALL IMPACT or SYSTEM-WIDE CHANGE.\n" +
            "4. The title MUST be abstract and general (focus on behavior, reliability, or architecture).\n" +
            "5. The title MUST NOT mention files, functions, or tools.\n" +
            "6. The title MUST NOT describe low-level implementation actions (e.g., update, refactor, replace).\n" +
            "7. DO NOT include parentheses, scopes, or filenames in the title.\n" +
            "8. The title MUST be a single line and 50 characters or fewer.\n" +
            "9. After the title there MUST be exactly one blank line.\n" +
            "10. The description MUST exist and explain ALL significant changes.\n" +
            "11. Each description line MUST wrap at 72 characters.\n" +
            "12. Use bullet points if necessary.\n" +
            "13. Use imperative mood.\n" +
            "14. If ANY rule is violated, rewrite until ALL rules are satisfied.\n\n" +
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
