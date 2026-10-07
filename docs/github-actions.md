# GitHub Actions의 검증과 문서 생성

이 프로젝트에서 문서 생성은 Lean API 문서 웹사이트를 만드는 작업입니다. 정의·정리의 이름, 타입/명제, Lean docstring, 소스 링크 등을 찾아보는 용도입니다. 학습용 설명을 자동으로 작성하거나 미완성 proof를 대신 완성하는 기능이 아닙니다.

## 자동으로 실행되는 흐름

`git push → GitHub runner → Lean/Mathlib 준비 → lake build → doc-gen4 → GitHub Pages`

검증은 [lean_action_ci.yml](../.github/workflows/lean_action_ci.yml), 문서 배포는 [documentation.yml](../.github/workflows/documentation.yml)로 분리했습니다. `leanprover/lean-action@v1`은 Lean 프로젝트 검증을, `leanprover-community/docgen-action@v1`은 문서 생성과 배포를 담당합니다. 문서는 main의 라이브러리 root, 최상위 Lean 모듈 또는 환경 설정 변경을 push할 때 생성합니다. 격리된 Exercises 파일과 Markdown 노트만 수정하면 문서 생성은 시작하지 않습니다. 완성한 연습을 root에 import하면 root 변경으로 문서 생성이 시작됩니다.

Lean CI는 20분, 문서 workflow는 40분의 timeout을 두었습니다. 각 workflow의 새 실행은 같은 group의 이전 실행을 취소합니다. 분리 전에 시작한 옛 workflow에는 새 설정이 소급 적용되지 않습니다.

## 세 종류의 문서를 구분하기

| 종류 | 작성/생성 방법 | 현재 위치 |
|---|---|---|
| 학습 노트 | 사람이 작성한 Markdown | 저장소의 `docs/*.md` |
| API 문서 | Lean 선언과 docstring에서 doc-gen4가 생성 | GitHub Pages의 `/docs/` |
| Blueprint | 자연어 수학 전개와 Lean 선언을 연결하는 별도 문서 | 현재 미사용 |

API 문서의 설명을 늘리려면 Lean 파일에서 선언 앞에 `/-- … -/` docstring을 쓰고, 모듈 설명은 `/-! … -/`로 작성합니다. 일반 `--` 주석과 문서 주석을 구별합니다. 최종 내용을 수정한 뒤 같은 프로젝트 환경에서 빌드합니다. API 문서는 논리 구조를 설명하는 개인 학습 노트를 대신하지 않습니다.

## 처음 한 번 확인할 GitHub 설정

1. 저장소의 **Settings → Pages**를 엽니다.
2. **Build and deployment → Source**를 **GitHub Actions**로 선택합니다.
3. **Settings → Actions → General**에서 이 workflow의 action들을 실행할 수 있도록 허용합니다.

**Allow GitHub Actions to create and approve pull requests**는 dependency update workflow가 PR을 만들기 위한 설정입니다. Pages의 publishing source 설정과는 다른 항목입니다. 문서 workflow에는 `contents: read`, `pages: write`, `id-token: write`가 선언되어 있습니다. Lean CI에는 `contents: read`만 필요합니다.

## 일상적인 사용

프로젝트 루트에서:

```bash
bash scripts/check.sh
git add AutoformalizationLab.lean AutoformalizationLab docs
git diff --cached
git commit -m "Add a formalization exercise"
git push
```

위 `git add`는 해당 폴더의 변경을 포함하므로 `git diff --cached`로 실제 올릴 내용을 확인합니다. Step 2를 진행하면서 proof를 완성했을 때 사용합니다. 미완성 proof에 `sorry`가 있으면 빌드 성공만으로 완성을 판정하면 안 됩니다.

[Actions 목록](https://github.com/scream27/autoformalization_lab/actions)에서 **Lean Action CI**의 최신 commit 실행을 열고 `build` job을 선택하면 코드 검증 결과를 볼 수 있습니다. **API Documentation**의 `docs` job은 문서 생성과 Pages 배포입니다. 실패하면 해당 단계의 첫 실제 error를 확인합니다. 문서 workflow가 실패해도 Lean CI의 성공 결과는 별도로 남습니다.

배포가 성공하면 API 문서 주소는 다음입니다.

[Autoformalization Lab API 문서](https://scream27.github.io/autoformalization_lab/docs/)

404이면 아직 배포가 안 됐거나 실패했을 수 있으므로 Actions의 결과와 Pages 설정을 확인합니다. 배포 성공은 실제 workflow 결과로 판정하며 URL만 있다는 것으로 성공했다고 간주하지 않습니다.

## 이 프로젝트의 폴더 설정

`docgen-action@v1`은 `homepage` 폴더가 이미 있으면 Jekyll 사이트로 취급합니다. 기본값 `docs`를 그대로 쓰면 우리 Markdown 학습 폴더를 Jekyll 사이트로 오해합니다. 따라서 `homepage: generated-site`로 바꾸어 API 문서 출력 폴더를 분리했습니다. 그 폴더는 저장소에 넣지 않고 action이 생성합니다.

이 설정은 GitHub Pages URL의 `/docs/`를 바꾸지 않습니다. 우리 `docs/*.md`가 별도의 학습 웹사이트로 자동 배포된다는 뜻도 아닙니다. 현재 학습 노트는 GitHub 파일 보기로 읽습니다.

## Step 2와의 관계

Step 2는 로컬 CLI와 VS Code Infoview로 바로 시작할 수 있습니다. GitHub 문서 생성은 검색과 공유를 돕는 부가 작업이며, 형식화 연습을 시작하기 위한 필수 조건이 아닙니다. 처음 생성할 때 문서 도구와 dependency 문서를 빌드하므로 일반 Lean 검증보다 오래 걸릴 수 있습니다.

2026-10-07 확인한 이전 실행은 약 15분 동안 의존성 문서를 포함한 2,766개 build job을 처리해 API 문서 생성을 완료했습니다. 이후 Jekyll 단계에서 `Could not locate Gemfile or .bundle/ directory`로 실패했습니다. `generated-site` 분리 설정은 이 폴더 오인 문제를 해결하기 위해 반영한 것입니다. 최종 Pages 배포의 성공은 별도의 실제 실행 결과로 확인해야 합니다.

근거: [현재 사용하는 action 소스](https://github.com/leanprover-community/docgen-action/blob/v1/action.yml), [문서 빌드 스크립트](https://github.com/leanprover-community/docgen-action/blob/v1/scripts/build_docs.sh), [GitHub Pages publishing 설정](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).
