#!/usr/bin/env bash
set -euo pipefail

# 배달의민족 상점 검색 (웹 스크래핑 기반)
# 사용법: ./search.sh <검색어> [결과수]
#         ./search.sh --categories

CATEGORIES=(
  "치킨" "피자" "중식" "한식" "일식" "분식"
  "카페/디저트" "패스트푸드" "족발/보쌈" "찜/탕"
  "돈까스/회/일식" "샐러드" "야식" "도시락"
)

if [ "${1:-}" = "--categories" ]; then
  echo "🍽️ 배민 인기 카테고리"
  echo "---"
  for i in "${!CATEGORIES[@]}"; do
    echo "  $((i+1)). ${CATEGORIES[$i]}"
  done
  exit 0
fi

QUERY="${1:?검색어를 입력해주세요}"
LIMIT="${2:-10}"
LAT="${BAEMIN_LATITUDE:-37.5665}"
LNG="${BAEMIN_LONGITUDE:-126.9780}"

echo "🔍 \"${QUERY}\" 검색 중... (위치: ${LAT}, ${LNG})"
echo "---"

# 배민 웹에서 검색 (baemin.com)
# 참고: 배민 웹사이트 구조 변경 시 수정 필요
RESPONSE=$(curl -s "https://www.baemin.com/search?query=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${QUERY}'))")" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  -H "Accept: text/html,application/xhtml+xml" \
  -H "Accept-Language: ko-KR,ko;q=0.9" \
  2>/dev/null || true)

if [ -z "$RESPONSE" ]; then
  echo "⚠️ 배민 웹사이트에 접근할 수 없습니다."
  echo ""
  echo "대안: 네이버 지도에서 검색합니다..."
  echo ""
  
  # 네이버 지도 API 폴백
  NAVER_RESPONSE=$(curl -s "https://map.naver.com/v5/api/search?caller=pcweb&query=${QUERY}+배달&type=all&page=1&displayCount=${LIMIT}" \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)" \
    2>/dev/null || echo '{}')
  
  if echo "$NAVER_RESPONSE" | jq -e '.result.place.list' > /dev/null 2>&1; then
    echo "$NAVER_RESPONSE" | jq -r ".result.place.list[:${LIMIT}][] | \"🏪 \(.name)\n   📍 \(.address // .roadAddress)\n   ⭐ \(.reviewCount // 0)개 리뷰\n   📞 \(.tel // \"번호 없음\")\n\""
  else
    echo "검색 결과를 가져올 수 없습니다."
    echo "💡 팁: 배민 앱에서 직접 '${QUERY}'를 검색해보세요."
  fi
  exit 0
fi

# HTML에서 상점 정보 추출 시도
if command -v pup &> /dev/null; then
  echo "$RESPONSE" | pup 'div.shop-item text{}' | head -n "$((LIMIT * 3))"
else
  echo "⚠️ HTML 파싱을 위해 'pup'을 설치해주세요."
  echo "   go install github.com/ericchiang/pup@latest"
  echo ""
  echo "💡 팁: 배민 앱에서 직접 '${QUERY}'를 검색해보세요."
fi
