# Lean 피드백을 분류하기

나중에 만들 proof-search agent의 기본 루프는 다음과 같습니다.

`statement + 현재 goal → tactic 제안 → Lean 실행 → 진단/남은 goal → 다음 제안`

지금은 환경과 완전한 파일을 CLI로 확인하는 단계입니다. 매 tactic 후 goal state를 구조적으로 얻는 LSP/RPC 연동은 다음 개발 단계에서 다룹니다.

| 오류 종류 | 예시 | 먼저 확인할 것 |
|---|---|---|
| 환경/import | bad import, unknown module prefix | 프로젝트 루트, toolchain, 실제 파일 경로, cache |
| statement/type | unknown identifier, type mismatch | 타입·namespace·표기와 자연어 명제의 대응 |
| proof/tactic | unsolved goals, tactic failed | 현재 goal과 가설, tactic 적용 방향 |
| 자원 | maximum heartbeats, timeout | 검색 범위·예산; 수학적 실패와 별도 기록 |

이번 초기 실패는 import 경로였습니다. `Mathlib.Data.Rat.Basic`, `Mathlib.Tactic.LibrarySearch`, `Mathlib.Tactic.Rewrites`를 사용할 수 있다고 가정했으나 현재 checkout에는 존재하지 않았습니다. 소스를 검색해 각각 ordered field의 실제 모듈과 Lean 내부 search tactic 모듈로 수정했습니다. 최종 파일만 컴파일 성공본으로 남깁니다.

검색 도구도 제안을 그대로 믿으면 안 됩니다. 로컬 가설에서 `p`를 얻는 초기 예제의 `exact?`는 proof를 찾았지만 제안 tactic 실행에 실패한다는 진단을 냈습니다. 이는 import 오류와 다른 **검색/제안 재검증 실패**입니다. 설치 확인용 최종 예제는 실제로 통과하는 Nat goal로 바꿨으며, 앞으로 agent도 제안이 아니라 Lean의 검증 결과로 성공을 판정해야 합니다.

## 에러를 공유할 때

완전한 파일 또는 수정 부분과 함께 다음 정보를 붙이면 원인을 빠르게 구분할 수 있습니다.

```bash
lake env lean --version
cat lean-toolchain
lake env lean AutoformalizationLab/SmokeTest.lean
```

에러의 첫 줄부터 마지막 `unsolved goals` 내용까지 포함합니다. 마지막 메시지만 보면 import 실패 뒤에 생긴 연쇄 오류를 tactic 문제로 오해할 수 있습니다.

연습 문제에서는 곧바로 정답을 제공하지 않습니다. 먼저 hint, 다음으로 실제 환경에서 확인한 lemma 또는 `exact?`·`apply?`·`rw?` 검색 방법, 마지막으로 proof sketch를 제공합니다.

## agent 성공 판정

exit code 0은 필요하지만 `sorry`가 들어간 파일도 컴파일될 수 있습니다. 완성 판정에는 대상 정리의 `#print axioms`를 확인해 `sorryAx`가 없는지도 포함해야 합니다. 문법 오류·진단·시간·환경 revision을 따로 기록합니다. 이번 SmokeTest는 실제 공리 출력까지 확인합니다.
