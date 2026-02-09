#!/usr/bin/env bash
set -euo pipefail

# 네이버 검색 API
# 사용법: ./search.sh <blog|news|kin|image> <검색어> [결과수] [시작위치]

if [ -z "${NAVER_CLIENT_ID:-}" ] || [ -z "${NAVER_CLIENT_SECRET:-}" ]; then
  echo "❌ NAVER_CLIENT_ID, NAVER_CLIENT_SECRET 환경변수를 설정해주세요." >&2
  exit 1
fi

TYPE="${1:?타입을 입력해주세요 (blog|news|kin|image)}"
QUERY="${2:?검색어를 입력해주세요}"
DISPLAY="${3:-10}"
START="${4:-1}"

case "$TYPE" in
  blog|news|kin|image) ;;
  *) echo "❌ 지원하지 않는 타입: $TYPE (blog|news|kin|image)" >&2; exit 1 ;;
esac

# URL 인코딩
ENCODED_QUERY=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$QUERY'))")

RESPONSE=$(curl -s -X GET \
  "https://openapi.naver.com/v1/search/${TYPE}?query=${ENCODED_QUERY}&display=${DISPLAY}&start=${START}" \
  -H "X-Naver-Client-Id: ${NAVER_CLIENT_ID}" \
  -H "X-Naver-Client-Secret: ${NAVER_CLIENT_SECRET}")

# 에러 체크
ERROR=$(echo "$RESPONSE" | jq -r '.errorCode // empty')
if [ -n "$ERROR" ]; then
  echo "❌ API 에러: $(echo "$RESPONSE" | jq -r '.errorMessage')" >&2
  exit 1
fi

TOTAL=$(echo "$RESPONSE" | jq -r '.total')
echo "🔍 검색결과: 총 ${TOTAL}건"
echo "---"

case "$TYPE" in
  blog)
    echo "$RESPONSE" | jq -r '.items[] | "📝 \(.title | gsub("<[^>]*>"; ""))\n   \(.description | gsub("<[^>]*>"; ""))\n   🔗 \(.link)\n"'
    ;;
  news)
    echo "$RESPONSE" | jq -r '.items[] | "📰 \(.title | gsub("<[^>]*>"; ""))\n   \(.description | gsub("<[^>]*>"; ""))\n   📅 \(.pubDate)\n   🔗 \(.link)\n"'
    ;;
  kin)
    echo "$RESPONSE" | jq -r '.items[] | "❓ \(.title | gsub("<[^>]*>"; ""))\n   \(.description | gsub("<[^>]*>"; ""))\n   🔗 \(.link)\n"'
    ;;
  image)
    echo "$RESPONSE" | jq -r '.items[] | "🖼️  \(.title | gsub("<[^>]*>"; ""))\n   🔗 \(.link)\n"'
    ;;
esac
