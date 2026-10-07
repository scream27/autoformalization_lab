# Autoformalization Lab

[![Lean Action CI](https://github.com/scream27/autoformalization_lab/actions/workflows/lean_action_ci.yml/badge.svg)](https://github.com/scream27/autoformalization_lab/actions/workflows/lean_action_ci.yml)

Lean 4 + Mathlib로 자연어 증명을 형식화하고 검증하는 학습 프로젝트입니다. 현재 주 목표는 smooth surface의 Hilbert scheme of points의 smoothness입니다.

- [Hilbert scheme 전체 증명·구현 outline](docs/hilbert-scheme/outline.md)
- [증명을 직접 검증하는 방법](docs/hilbert-scheme/verification.md)
- [Commuting matrices와 Fogarty: 실제 Mathlib API·prototype 비교](docs/hilbert-scheme/library-route-audit.md)
- [에이전트 작업 지침](AGENTS.md)

- [WSL/Ubuntu 설치 순서](docs/step-1-setup.md)
- [설치 확인 파일](AutoformalizationLab/SmokeTest.lean)
- [검색 tactic 확인 파일](AutoformalizationLab/SearchDemo.lean)
- [로컬 실행 결과](docs/local-verification.md)
- [오류를 분류하는 기준](docs/feedback-workflow.md)
- [GitHub Actions와 API 문서 사용법](docs/github-actions.md)
- [Step 2 연습 문제 — 답안 없이 시작](docs/step-2-exercises.md)

로컬에서 다시 확인:

```bash
cd /Users/sungwoo/lean_project/autoformalization_lab
bash scripts/check.sh
```

현재 학습 방식은 에이전트가 자연어 증명을 Lean으로 구현하고, 사용자가 해설과 검증 절차를 읽는 방식입니다. 우선 구현 경로는 commuting operators와 explicit basis charts이며, 다음 학습 예제는 `(x²,xy,y²)`의 quotient와 multiplication operators입니다. 작은 algebra prototype은 검증했지만 Hilbert scheme 전체 정리는 아직 구현되지 않았습니다.

이전 Step 2의 `AutoformalizationLab/Exercises/`는 선택적인 연습 자료로 남겨 둡니다. 연습용 `sorry`는 미완성 표시이며 완성된 라이브러리와 분리되어 있습니다.

## GitHub

원격 저장소: [scream27/autoformalization_lab](https://github.com/scream27/autoformalization_lab)

- Push / Pull Request: Lean 검증 workflow 실행.
- main의 라이브러리·환경 설정 변경: 별도의 API Documentation workflow에서 문서 생성·배포.
- Dependency update: Actions에서 수동 실행하며, 성공한 업데이트는 Pull Request로 제안.
- `lean-toolchain` 변경: Lean release tag 생성 workflow 실행.

실험 재현을 위해 Lean/Mathlib 버전은 고정합니다. `.lake/`의 dependency와 build 결과는 Git에 포함하지 않습니다.
