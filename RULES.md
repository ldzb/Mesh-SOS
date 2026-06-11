# 📋 Mesh-SOS 모노레포 개발 그라운드 룰

## 1. 초기 설정 및 작업 시 주의사항 (Pitfalls)
* **터미널 위치 엄수**: 패키지 설치나 빌드 명령어(`flutter run`, `./gradlew build`)를 실행할 때는 반드시 해당 하위 폴더(`cd frontend` 또는 `cd backend`)로 이동한 뒤에 실행해야 한다. 최상위 폴더(`Mesh-SOS`)에서 실행하면 경로 에러가 발생한다.
* **IDE 완벽 분리**:
    * 프론트엔드(Flutter) 작업 시: VS Code에서 `Mesh-SOS/frontend` 폴더만 단독으로 연다.
    * 백엔드(Spring Boot) 작업 시: IntelliJ에서 `Mesh-SOS/backend/build.gradle`을 선택하여 연다.
    * (경고: 최상위 `Mesh-SOS` 폴더를 IDE로 통째로 열면 인덱싱 충돌로 시스템이 멈출 수 있음)
* **Git 명령어 위치**: 반대로 `git add`, `git commit`, `git push` 등 버전 관리 명령어는 반드시 최상위 폴더(`Mesh-SOS`)에서 실행하여 하나의 레포지토리로 관리한다.

## 2. 브랜치(Branch) 생성 규칙
브랜치 이름만 봐도 프론트엔드 작업인지, 백엔드 작업인지 한눈에 알 수 있도록 스코프(Scope)를 명시한다.
* **형식**: `타입/스코프-작업내용`
* **타입(Type)**: `feat` (새 기능), `fix` (버그 수정), `refactor` (코드 리팩토링), `docs` (문서 작업)
* **예시**:
    * `feat/frontend-method-channel` (프론트엔드 네이티브 통신 세팅)
    * `feat/backend-sync-api` (백엔드 데이터 수신 API 세팅)
    * `fix/frontend-ui-overflow` (프론트엔드 화면 깨짐 수정)

## 3. 커밋(Commit) 메시지 규칙
모노레포의 핵심은 커밋 로그를 깔끔하게 유지하는 것이다.
* **형식**: `타입(스코프): 작업 내용 요약`
* **예시**:
    * `feat(frontend): SOS 발신용 메인 화면 UI 구현`
    * `feat(backend): SosMessage 엔티티 및 JPA 레포지토리 생성`
    * `chore(root): 모노레포 초기 세팅 및 .gitignore 업데이트`

## 4. 파일 작성 및 네이밍 규칙
언어별 공식 네이밍 컨벤션을 철저히 따른다.
* **Frontend (Dart/Flutter)**:
    * 파일/폴더명: 스네이크 케이스 (`snake_case.dart`) (예: `sos_message_screen.dart`)
    * 클래스명: 파스칼 케이스 (`PascalCase`) (예: `class SosMessageScreen`)
    * 변수/함수명: 카멜 케이스 (`camelCase`) (예: `void sendMessage()`)
* **Backend (Java/Spring Boot)**:
    * 파일/클래스/인터페이스명: 파스칼 케이스 (`PascalCase.java`) (예: `SosSyncController.java`)
    * 변수/메서드명: 카멜 케이스 (`camelCase`) (예: `public void saveMessage()`)
    * 패키지명: 모두 소문자로 작성 (예: `com.ldzb.backend.controller`)
