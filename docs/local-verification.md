# 로컬 실행 결과

2026-10-07 · `/Users/sungwoo/lean_project/autoformalization_lab`

## 확인한 환경

| 항목 | 실제 값 |
|---|---|
| OS | macOS / Apple Silicon (`arm64`) |
| Lean | `leanprover/lean4:v4.35.0-rc4` |
| Lean commit | `c29b6dda4f7c20e3eeaa717c4e565663c5cfa364` |
| Mathlib | `e6bbacd0e1b7307ff6e17da09cd2455f60804fa6` |
| Mathlib 선택 | 조회 당시 `master`의 HEAD를 exact commit으로 고정 |
| VS Code extension | `leanprover.lean4@0.0.240` 설치 확인 |

기존 elan을 재사용해 필요한 새 toolchain을 설치했습니다. WSL을 설치하거나 Ubuntu 명령을 macOS에서 실행하지 않았습니다. 기존 프로젝트의 toolchain과 dependency는 바꾸지 않았습니다.

## 실행과 결과

1. `lake +leanprover-community/mathlib4:lean-toolchain new autoformalization_lab math` — 성공. Lean toolchain, 프로젝트, Mathlib 및 초기 cache 다운로드.
2. template이 선택한 Mathlib release tag 대신 조회 당시 최신 commit을 `lakefile.toml`에 지정.
3. `MATHLIB_NO_CACHE_ON_UPDATE=1 lake update mathlib` — 성공. toolchain이 이미 일치함을 확인. 해당 변수는 이 실행에서 cache 자동 다운로드만 미루기 위해 사용.
4. `lake exe cache get`에 실제 모듈 이름을 전달 — 테스트에 필요한 최신 compiled cache 확보. 전체 cache 명령도 설치 안내에 포함.
5. `bash scripts/check.sh` — exit code 0. 전체 `lake build` 성공 후 테스트 두 파일을 직접 실행.
6. VS Code CLI로 extension 목록 확인 및 프로젝트·SmokeTest 열기 — exit code 0.

빌드의 `857 jobs`는 dependency와 cache된 job을 포함하는 Lake 보고값입니다. 857개 파일을 새로 모두 컴파일했다는 뜻이 아닙니다.

테스트 파일 직접 실행 출력:

```text
2
ℚ : Type
'AutoformalizationLab.smoke_arithmetic' depends on axioms: [propext]
'AutoformalizationLab.smoke_order' depends on axioms: [propext, Classical.choice, Quot.sound]
```

검색 테스트 직접 실행 출력:

```text
Try this:
  [apply] exact Nat.add_comm a b
Try this:
  [apply] exact Nat.add_comm a b
Try this:
  [apply] rw [Nat.add_eq_left]
  -- no goals
```

위 lemma 이름은 기억으로 작성한 안내가 아니라 이 환경에서 나온 실제 제안입니다. 최종 설치 테스트 파일에 `sorry`는 없으며, 두 named theorem의 실제 공리 출력에도 `sorryAx`가 없습니다.

## 발견하고 수정한 막힘

- `code`가 PATH에 없어 앱 내부 CLI 경로를 사용했습니다.
- 초기 import 경로 세 개가 현재 Mathlib에 없어 checkout의 파일 목록과 Lean source를 검색해 수정했습니다.
- 초기 `exact?` 예제에서 검색된 proof의 제안 tactic 재실행이 실패했습니다. 설치 확인에는 통과하는 예제를 사용하고, 실패의 종류는 [feedback-workflow.md](feedback-workflow.md)에 기록했습니다.
- Mathlib template의 header style linter는 학습 파일에서만 끄고 proof 검사는 유지했습니다.

## 화면 확인 완료

최초에는 Mac이 잠겨 GUI를 읽을 수 없었습니다. 사용자가 잠금을 해제한 뒤 VS Code에서 `SmokeTest.lean`을 열고 20행의 `norm_num` 위치로 이동했습니다. Lean Infoview가 `1 goal`, `⊢ 2 + 3 = 5`를 표시하고, Messages에 `Goals accomplished!`가 나오는 것을 직접 확인했습니다. CLI 컴파일 검증, extension 설치, Infoview 화면 확인을 모두 완료했습니다.

새 toolchain과 전체 초기 cache 설치 후 현재 여유 공간은 약 2.8 GiB입니다. 이후 여러 Mathlib 환경을 추가할 때는 디스크 공간을 먼저 확인하는 편이 좋습니다. 기존 toolchain이나 공유 cache는 삭제하지 않았습니다.
