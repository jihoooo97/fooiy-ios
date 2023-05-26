# fooiy(v1.2.0) 포트폴리오
* 앱스토어 링크: [`푸이 - 내 손안의 음식점`](https://apps.apple.com/us/app/푸이-내-손안의-모든-음식점/id1640024571)  
* fooiy 웹사이트: [`fooiy.com`](https://fooiy.com)
<br>

## ⚠️ 현재 창업팀이 서비스 중이어서 민감한 코드들은 삭제했습니다
<br>

<img src="https://user-images.githubusercontent.com/49361214/221785257-d651ada8-b333-49cc-8b6a-fa26ebe555f1.png" width="80%" height="50%">   

<br>

## 문제 정의
<img src="https://user-images.githubusercontent.com/49361214/221785875-21571d1a-50c8-443b-8173-757692f528a2.png" width="80%" height="100%">

푸이는 경험한 음식점에 대한 평가를 기록할 수 있고, 이를 토대로 입맛의 MBTI인 FooiyTi를 통해 자신의 입맛에 맞는 음식점을 추천해주는 서비스 입니다.  
  
여러 경험과 관찰을 통해 큰 서비스가 되기 위해서, 사람이 살아가는데 필수적 3요소인 “의, 식, 주” 중 하나여야 한다고 생각했습니다.  
살아가는데 있어 큰 행복을 차지하는 요소가 하루 한 끼라도 맛있는 음식을 먹는 것이었고, 특히 연애를 하면서 정말 중요하다는 것을 깨닫게 되었습니다.

따라서, 이 중대한 문제를 해결하기 위해 푸이를 시작하게되었습니다.  

<br>

## 푸이티아이 [`검사하기`](https://fooiy.com/examine)
<img src="https://user-images.githubusercontent.com/49361214/221786854-e906b620-d717-44fe-8278-f8fa2d12ca49.png" width="80%" height="100%">  


<br><br>

## Tech
| 언어 | Swift |
|:---:|:---:|
| 구조 | `UIKit` + `MVVM` + `Clean Architecture` |
| 비동기 | `RxSwift`, `RxCocoa` |
| 네트워크 | `Moya` |
| 이미지 | `Kingfisher` |
| 라이브러리 | `NaverMaps`, `Firebase`<br>  `Lottie`, `Then` |
| 협업 | `Jira`, `Slack`, `Git-flow` |
               
<br><br>
  
## 기능
| [`푸이티아이`](https://github.com/jihoooo97/fooiy-ios/tree/main/Feature/Feed) | [`피드`](https://github.com/jihoooo97/fooiy-ios/tree/main/Feature/Feed) | [`개척/기록`](https://github.com/jihoooo97/fooiy-ios/tree/main/Feature/Pioneer) | [`지도`](https://github.com/jihoooo97/fooiy-ios/tree/main/Feature/Map) |
|:---:|:---:|:---:|:---:|
| <img src="https://user-images.githubusercontent.com/49361214/221782883-e5319299-3da5-42ca-b32d-33d8f124e5e8.png"> | <img src="https://user-images.githubusercontent.com/49361214/221782838-455e5678-3d47-4e3a-898a-52abcc6db9b7.png"> | <img src="https://user-images.githubusercontent.com/49361214/221782875-f525674b-bcd3-49c3-9c57-2e6ce59371ed.png"> | <img src="https://user-images.githubusercontent.com/49361214/221782879-4bec60ea-522a-4a44-8219-48ae0059ff30.png"> |

<br><br>

## 담당 기능
* 푸이 iOS 앱 개발 및 유지보수
  - `온보딩`: 버전 체크 및 FCM토큰 갱신 페이지 개발
  - `로그인/회원가입`: KakaoSDK 활용하여 개발
  - `음식점 지도`: NaverMap을 활용한 음식점 조회 기능 개발
  - `음식점 기록`: 음식 사진 업로드 기능 개발
  - `게시물 수정`: 게시물 수정 기능 개발
  - `유저 검색`: 유저 검색 기능 개발
  - `내 정보`: 자신이 게시한 음식 사진을 Instagram처럼 볼 수 있는 기능 개발

<br><br>

## 배운 점
* `Co-Work`
  - `기획/스펙회의 - 스프린트 - QA 및 회고`의 애자일 프로세스를 경험
  - FooiyTI 기획 과정을 통해 팀원과 의견을 조율하는 과정을 경험
  - PR, Code Review를 통한 협업 경험
  - Git-Flow를 활용하여 코드를 효율적으로 관리하는 경험
* `Tech`
  - RxSwift, Moya
  - Clean Architecture 경험
  - 모듈화를 통해 UI와 비즈니스 코드를 재사용하는 경험
  - 효율적인 데이터 처리를 위한 ScrollView Pagenation
  - Code-Based UI
  - UI가 자주 변동되는 부분에서는 Server Driven UI와 A/B Test 개념을 활용하여 
변동이 잦은 UI를 효율적으로 개발하는 경험
  - Navermap marker custom

<br><br>
        
## 아쉬운 점
- MVP배포 일정에 밀려 CI/CD를 구축해보지 못함
- UnitTest의 부재

<br><br>

## 성과
> <img src="https://user-images.githubusercontent.com/49361214/221795398-72c52ba5-72ba-4cd4-b2c3-3426734dbddf.png" width="40%" height=""><img src="https://user-images.githubusercontent.com/49361214/221795406-f85dd5ef-0ccc-46b4-8bcb-d59308b98398.png" width="40%" height="">
> <img src="https://user-images.githubusercontent.com/49361214/221795419-7a04b296-39dd-4e67-a7c7-563f96e2c0d5.png" width="80%" height="">

<br><br>
