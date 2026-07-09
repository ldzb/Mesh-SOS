# Mesh-SOS

## 🚀 Key Milestones & Core Architectures

본 프로젝트는 재난 상황에서의 오프라인 P2P 통신 및 로컬-서버 데이터 동기화를 핵심 가치로 삼고 있으며, 최신 모바일 OS의 생명주기와 비동기 통신 아키텍처를 고려하여 다음과 같은 핵심 기술을 구현했습니다.

### 📱 1. Cross-Platform Native P2P Bridge
중앙 서버나 기지국이 없는 환경에서 격리된 단말 간의 거미줄형(Mesh) 데이터 레이어를 형성하기 위해 양대 OS의 최하단 네이티브 API를 `MethodChannel`로 통합했습니다.
- **iOS (Swift)**: 최신 `UISceneDelegate` 마이그레이션 환경에서 플러터 엔진의 중복 인보크(Invoked) 경고 및 디버거 소켓 거부 문제를 방지하기 위해, `window?.rootViewController` 접근을 지양하고 플랫폼 공식 `PluginRegistry` API를 기반으로 안정적인 `FlutterMethodChannel` 통신망을 구축했습니다. (`MultipeerConnectivity` 적용)
- **Android (Kotlin)**: 구형 보급형 기기부터 최신 플래그십 기기까지 범용적인 하위 호환성을 확보하기 위해 `minSdkVersion 23` 기반의 `Google Nearby Connections API`를 이식했습니다. 중앙 방장 노드가 존재하지 않는 완벽한 분산 거미줄망 구현을 위해 `Strategy.P2P_CLUSTER` 오프라인 메쉬 토폴로지를 채택했습니다.

### 📡 2. Local Queue & Bulk Server Synchronization
- **오프라인 영속화**: P2P를 통해 주변 노드로부터 릴레이(Relay) 수신된 SOS 메시지는 단말 내 고성능 가벼운 임베디드 데이터베이스인 `SQLite`에 로컬 큐(Queue) 형태로 즉시 적재됩니다.
- **네트워크 자가 치유 동기화**: `connectivity_plus`를 통해 단말의 네트워크 연결(Cellular/Wi-Fi) 상태를 실시간 모니터링하며, 인터넷 가용 상태가 감지되는 즉시 로컬 큐의 미동기화 데이터를 압축하여 백엔드 서버(`Spring Boot`) 및 `Docker MySQL`로 벌크(`Bulk HTTP POST`) 업로드하는 트랜잭션 보장형 동기화 엔진을 구현하여 데이터 무결성을 검증했습니다.

### 🛡️ 3. Strict Permission & Sandbox Policy Security
애플의 엄격한 개인정보 보호 정책 및 샌드박스 규정을 준수하기 위해 인프라 레벨의 보안 가이드를 수립했습니다.
- `Info.plist` 내에 블루투스 및 위치 기반 백그라운드 탐색 명분(`Usage Description`)을 명시하여 OS 차원의 차단을 방어했습니다.
- 컴파일 타임 최적화를 위해 iOS `Podfile` 내 `GCC_PREPROCESSOR_DEFINITIONS` 빌드 설정을 커스텀하여 권한 에이전트(`permission_handler`)가 컴파일 단계에서 필요한 네이티브 스위치(`PERMISSION_LOCATION=1`, `PERMISSION_BLUETOOTH=1`)만 안전하게 품고 빌드되도록 인프라 파이프라인을 정교화했습니다.

### 🤖 4. AI Pair Programming Control Environment
급변하는 생성형 AI 개발 패러다임 속에서 개발 생산성을 극대화하되 소스코드와 아키텍처의 품질 저하를 막기 위해 **시스템적 통제 환경**을 구축했습니다.
- `.cursorrules` / `gemini.md` / `RULES.md` 가이드라인을 레포지토리에 선제적으로 자산화하여 AI 보조 도구가 모노레포 환경 속에서 디렉토리 컨벤션(`cd frontend`, `cd backend`) 및 커밋 메시지 규칙을 강제하도록 설정하여 팀 단위 협업 가치를 실험했습니다.
