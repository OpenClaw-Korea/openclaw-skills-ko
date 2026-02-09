---
name: kakao-talk
description: 카카오톡 메시지 보내기 (나에게 보내기, 친구에게 보내기, 친구 목록 조회)
---

# 카카오톡 메시지

카카오 REST API를 사용하여 카카오톡 메시지를 보내는 스킬입니다.

## 설치

```bash
# 필요: curl, jq
brew install jq  # macOS
```

카카오 개발자 앱 등록이 필요합니다:
1. https://developers.kakao.com 에서 앱 생성
2. **카카오 로그인** 활성화
3. 동의항목에서 `talk_message` 권한 설정
4. OAuth 인증으로 Access Token 발급

## 환경변수

| 변수 | 설명 | 필수 |
|------|------|------|
| `KAKAO_REST_API_KEY` | 카카오 REST API 키 | ✅ |
| `KAKAO_ACCESS_TOKEN` | 사용자 Access Token (OAuth로 발급) | ✅ |

## 사용법

### 나에게 메시지 보내기
```bash
./send.sh me "안녕하세요!"
```

### 친구에게 메시지 보내기
```bash
./send.sh friend <receiver_uuid> "안녕하세요!"
```

### 친구 목록 조회
```bash
./friends.sh
```

## 예시

```bash
# 나에게 보내기
./send.sh me "오늘 회의 3시입니다"

# 친구 목록 확인
./friends.sh

# 친구에게 보내기
./send.sh friend abc123-uuid "내일 점심 같이 먹자!"
```

## 참고

- Access Token은 주기적으로 갱신이 필요합니다 (기본 6시간)
- Refresh Token으로 자동 갱신 가능 (별도 구현 필요)
- API 문서: https://developers.kakao.com/docs/latest/ko/message/rest-api
