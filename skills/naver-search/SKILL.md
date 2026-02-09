---
name: naver-search
description: 네이버 검색 API (블로그, 뉴스, 지식iN, 이미지)
---

# 네이버 검색

네이버 검색 API를 사용하여 블로그, 뉴스, 지식iN, 이미지를 검색하는 스킬입니다.

## 설치

```bash
# 필요: curl, jq
brew install jq  # macOS
```

네이버 개발자 앱 등록:
1. https://developers.naver.com/apps/ 에서 앱 등록
2. **검색** API 사용 신청

## 환경변수

| 변수 | 설명 | 필수 |
|------|------|------|
| `NAVER_CLIENT_ID` | 네이버 API Client ID | ✅ |
| `NAVER_CLIENT_SECRET` | 네이버 API Client Secret | ✅ |

## 사용법

```bash
./search.sh <타입> <검색어> [결과수] [시작위치]
```

### 지원 타입
- `blog` — 블로그 검색
- `news` — 뉴스 검색
- `kin` — 지식iN 검색
- `image` — 이미지 검색

## 예시

```bash
# 블로그 검색
./search.sh blog "서울 맛집"

# 뉴스 검색 (상위 5개)
./search.sh news "AI 기술" 5

# 지식iN 검색
./search.sh kin "파이썬 설치 방법"

# 이미지 검색
./search.sh image "제주도 풍경" 10
```

## 참고

- 일일 호출 제한: 25,000회
- API 문서: https://developers.naver.com/docs/serviceapi/search/blog/blog.md
