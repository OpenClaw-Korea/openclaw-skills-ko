#!/usr/bin/env bash
set -euo pipefail

# 카카오톡 메시지 보내기
# 사용법: ./send.sh me "메시지"
#         ./send.sh friend <receiver_uuid> "메시지"

if [ -z "${KAKAO_ACCESS_TOKEN:-}" ]; then
  echo "❌ KAKAO_ACCESS_TOKEN 환경변수를 설정해주세요." >&2
  exit 1
fi

MODE="${1:-}"
if [ -z "$MODE" ]; then
  echo "사용법: $0 me \"메시지\"" >&2
  echo "        $0 friend <receiver_uuid> \"메시지\"" >&2
  exit 1
fi

build_template() {
  local text="$1"
  cat <<EOF
{"object_type":"text","text":"${text}","link":{"web_url":"","mobile_web_url":""}}
EOF
}

case "$MODE" in
  me)
    MESSAGE="${2:?메시지를 입력해주세요}"
    TEMPLATE=$(build_template "$MESSAGE")
    
    curl -s -X POST "https://kapi.kakao.com/v2/api/talk/memo/default/send" \
      -H "Authorization: Bearer ${KAKAO_ACCESS_TOKEN}" \
      -d "template_object=${TEMPLATE}" | jq .
    ;;
  
  friend)
    RECEIVER_UUID="${2:?receiver_uuid를 입력해주세요}"
    MESSAGE="${3:?메시지를 입력해주세요}"
    TEMPLATE=$(build_template "$MESSAGE")
    
    curl -s -X POST "https://kapi.kakao.com/v1/api/talk/friends/message/default/send" \
      -H "Authorization: Bearer ${KAKAO_ACCESS_TOKEN}" \
      -d "receiver_uuids=[\"${RECEIVER_UUID}\"]" \
      -d "template_object=${TEMPLATE}" | jq .
    ;;
  
  *)
    echo "❌ 알 수 없는 모드: $MODE" >&2
    echo "사용법: $0 me|friend ..." >&2
    exit 1
    ;;
esac
