# Step 1 — Lean 4 + Mathlib

아래 설치 명령은 **WSL/Ubuntu용**입니다. 이번 실제 검증은 macOS에서 수행했습니다. 현재 프로젝트의 정확한 환경은 [로컬 결과](local-verification.md)에 기록합니다.

## 1. WSL 준비

Windows의 관리자 PowerShell에서, WSL이 없다면:

```powershell
wsl --install -d Ubuntu
```

설치 안내대로 재시작하고 Ubuntu를 열어 계정을 만듭니다. 이후 설치 명령은 **Ubuntu terminal**에서 실행합니다. 이미 Ubuntu를 사용하는 경우 이 단계는 생략합니다.

## 2. elan 설치

```bash
sudo apt update
sudo apt install -y curl git build-essential ca-certificates
curl -sSfL https://elan.lean-lang.org/elan-init.sh -o /tmp/elan-init.sh
sh /tmp/elan-init.sh -y --default-toolchain none
source "$HOME/.elan/env"
elan --version
```

`elan`은 Lean 버전 관리자입니다. Lean toolchain에 `lean`과 `lake`가 함께 있으므로 Lake를 따로 설치하지 않습니다. `--default-toolchain none`은 전역 버전을 정하지 않고 프로젝트에 필요한 버전을 사용하게 합니다. [Lean 공식 설치 문서](https://lean-lang.org/install/manual/)

## 3. Mathlib 프로젝트 생성

```bash
mkdir -p "$HOME/lean-work"
cd "$HOME/lean-work"
lake +leanprover-community/mathlib4:lean-toolchain new autoformalization_lab math
cd autoformalization_lab
lake exe cache get
lake env lean --version
lake --version
```

`+…:lean-toolchain`은 Mathlib가 지정한 Lean으로 Lake를 실행합니다. `math` template은 Mathlib 의존성을 추가하며, 생성 과정에서 cache를 받을 수도 있습니다. `cache get`은 빌드된 dependency를 받아 긴 전체 소스 빌드를 줄입니다. [Mathlib 프로젝트 안내](https://leanprover-community.github.io/install/project.html)

프로젝트 파일의 역할:

| 파일 | 역할 |
|---|---|
| `lean-toolchain` | 프로젝트에서 사용할 Lean 버전 |
| `lakefile.toml` | 라이브러리와 Mathlib 의존성 설정 |
| `lake-manifest.json` | 실제 선택된 dependency commit |
| `.lake/` | 내려받은 dependency 및 build 결과 |

생성 template은 Lean에 맞는 Mathlib release tag를 고를 수 있습니다. 최신 `master`를 쓰고 싶다면 다음 절차로 **Mathlib와 Lean을 함께** 갱신합니다.

## 4. 최신 Mathlib와 toolchain 맞추기

새 프로젝트의 `lakefile.toml`에서 `[[require]]`의 Mathlib `rev`를 `"master"`로 바꿉니다. Ubuntu에서는 새로 생성한 이 파일에 다음 명령을 사용할 수 있습니다.

```bash
sed -i 's/^rev = .*/rev = "master"/' lakefile.toml
curl -fsSL https://raw.githubusercontent.com/leanprover-community/mathlib4/master/lean-toolchain -o lean-toolchain
lake update mathlib
lake exe cache get
lake env lean --version
lake build
```

`sed -i`는 여기서 Ubuntu 문법입니다. 기존 프로젝트에 여러 `rev` 항목이 있다면 전체 치환 대신 Mathlib 항목만 직접 수정합니다. `elan default stable`만 바꾸면 Mathlib와의 호환성이 보장되지 않습니다. 이번 로컬 환경에는 실행 당시 최신 commit을 `rev`로 고정해 재현성을 확보했습니다. [공식 갱신 절차](https://lean-lang.org/install/manual/)

갱신 중 upstream이 바뀌어 mismatch가 나면, 선택된 checkout의 toolchain으로 다시 맞춥니다.

```bash
cp .lake/packages/mathlib/lean-toolchain lean-toolchain
lake exe cache get
lake build
```

학습과 agent 실험을 시작한 뒤에는 `lean-toolchain`, `lakefile.toml`, `lake-manifest.json`을 보관하고 자동으로 최신화하지 않습니다. 환경이 달라지면 같은 tactic의 성공 여부도 달라질 수 있습니다.

## 5. VS Code + Lean 4 extension

WSL에서는 VS Code를 **Windows 쪽**에 설치하고 `ms-vscode-remote.remote-wsl` extension을 설치합니다. Ubuntu의 프로젝트 루트에서:

```bash
code .
```

좌측 아래가 `WSL: Ubuntu`인지 확인합니다. Extensions에서 **Lean 4** (`leanprover.lean4`)를 찾아 **Install in WSL: Ubuntu**를 선택합니다. Windows에만 설치된 extension과 WSL에 설치된 extension은 구별해야 합니다. [VS Code WSL 안내](https://code.visualstudio.com/docs/remote/wsl)

일반 Ubuntu desktop에서는 VS Code Linux 버전을 설치한 뒤:

```bash
code --install-extension leanprover.lean4
code .
```

프로젝트 루트를 Open Folder로 열고, 다음 테스트 파일을 엽니다. Lean Infoview가 안 보이면 `Ctrl+Shift+Enter`를 누릅니다. macOS에서는 `Cmd+Shift+Enter`입니다. [Infoview 안내](https://leanprover-community.github.io/install/project.html)

macOS에서 `code`가 PATH에 없다면 VS Code Command Palette의 **Shell Command: Install 'code' command in PATH**를 사용하거나, 이번처럼 앱 내부 CLI를 사용합니다.

```bash
"/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" .
```

## 6. 완전한 설치 테스트 파일

프로젝트 루트에서 `AutoformalizationLab/SmokeTest.lean`을 만들고 아래 전체 내용을 넣습니다. 최신 환경에서 확인한 module 경로를 사용합니다.

```lean
module

public import Mathlib.Data.Nat.Basic
public import Mathlib.Algebra.Order.Field.Rat
public import Mathlib.Tactic.NormNum
public import Mathlib.Tactic.Linarith

set_option linter.style.header false

public section

namespace AutoformalizationLab

#eval (1 + 1 : Nat)
#check ℚ

theorem smoke_arithmetic : (2 : ℕ) + 3 = 5 := by
  norm_num

theorem smoke_order (a b : ℚ) (h : a + 1 ≤ b) : a ≤ b := by
  linarith

#print axioms smoke_arithmetic
#print axioms smoke_order

end AutoformalizationLab
```

```bash
lake env lean AutoformalizationLab/SmokeTest.lean
```

`2`와 `ℚ`의 타입, 공리 목록이 나오고 exit code가 0이면 CLI 테스트 성공입니다. 이 파일에는 `sorry`가 없습니다. 프로젝트 전체 build에도 넣으려면 `AutoformalizationLab.lean`을 다음처럼 작성합니다. 이 저장소에는 SearchDemo까지 이미 연결되어 있습니다.

```lean
module

public import AutoformalizationLab.Basic
public import AutoformalizationLab.SmokeTest
```

```bash
lake build
```

`linter.style.header`만 학습 파일에서 끕니다. Mathlib의 파일 헤더 형식 경고를 생략하며, proof 검사나 타입 검사를 생략하지 않습니다.

## 7. 이후에 다시 실행할 명령

이번에 만든 로컬 프로젝트에서는:

```bash
bash scripts/check.sh
```

`lake build`는 source가 그대로면 cache된 결과를 사용할 수 있습니다. 스크립트의 후반부는 테스트 파일을 직접 다시 실행하여 계산 결과와 search 제안을 확인합니다.

모든 lemma 이름은 실제 환경의 검색 출력 또는 소스에서 확인합니다. [SearchDemo.lean](../AutoformalizationLab/SearchDemo.lean)에 완전한 `exact?`, `apply?`, `rw?` 예제를 두었습니다. 제안을 찾았으면 학습용 최종 proof에는 구체적인 tactic으로 옮기고 다시 검증합니다. 검색 성공이 모든 새로운 goal의 해결을 보장하지는 않습니다.
