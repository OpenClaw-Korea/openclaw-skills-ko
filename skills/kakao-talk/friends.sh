#!/usr/bin/env bash
set -euo pipefail

# 카카오톡 친구 목록 조회
# 사용법: ./friends.sh [limit] [offset]

if [ -z "${KAKAO_ACCESS_TOKEN:-}" ]; then
  echo "❌ KAKAO_ACCESS_TOKEN 환경변수를 설정해주세요." >&2
  exit 1
fi

LIMIT="${1:-10}"
OFFSET="${2:-0}"

RESPONSE=$(curl -s -X GET "https://kapi.kakao.com/v1/api/talk/friends?limit=${LIMIT}&offset=${OFFSET}" \
  -H "Authorization: Bearer ${KAKAO_ACCESS_TOKEN}")

echo "$RESPONSE" | jq -r '
  .elements[]? | 
  "UUID: \(.uuid)\n닉네임: \(.profile_nickname)\n프로필: \(.profile_thumbnail_image // "없음")\n---"
'

TOTAL=$(echo "$RESPONSE" | jq -r '.total_count // 0')
echo "총 친구 수: ${TOTAL}"
