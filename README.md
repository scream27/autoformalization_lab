# Autoformalization Lab

[![Lean Action CI](https://github.com/scream27/autoformalization_lab/actions/workflows/lean_action_ci.yml/badge.svg)](https://github.com/scream27/autoformalization_lab/actions/workflows/lean_action_ci.yml)

Step 1: Lean 4 + Mathlib 환경과 피드백 경로를 확인하는 학습 프로젝트입니다.

- [WSL/Ubuntu 설치 순서](docs/step-1-setup.md)
- [설치 확인 파일](AutoformalizationLab/SmokeTest.lean)
- [검색 tactic 확인 파일](AutoformalizationLab/SearchDemo.lean)
- [로컬 실행 결과](docs/local-verification.md)
- [오류를 분류하는 기준](docs/feedback-workflow.md)

로컬에서 다시 확인:

```bash
cd /Users/sungwoo/lean_project/autoformalization_lab
bash scripts/check.sh
```

Step 2 연습문제와 MacMahon function 정의는 다음 단계에서 진행합니다. 연습은 statement부터 제공하고, 막힌 경우 hint → 실제 환경에서 확인한 lemma → proof sketch 순으로 진행합니다.

## GitHub

원격 저장소: [scream27/autoformalization_lab](https://github.com/scream27/autoformalization_lab)

- Push / Pull Request: Lean build와 문서 생성 workflow 실행.
- Dependency update: Actions에서 수동 실행하며, 성공한 업데이트는 Pull Request로 제안.
- `lean-toolchain` 변경: Lean release tag 생성 workflow 실행.

실험 재현을 위해 Lean/Mathlib 버전은 고정합니다. `.lake/`의 dependency와 build 결과는 Git에 포함하지 않습니다.
