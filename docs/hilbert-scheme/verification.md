# 내가 직접 확인하는 방법

현재 Hilbert scheme의 geometric smoothness 증명은 아직 구현하지 않았다. 경로 비교를 위한 작은 algebra prototype은 `RouteAudit.lean`에서 검증했다. 이 문서는 이후 각 결과를 검증할 절차다. 설치 확인이나 algebra 보조정리의 성공을 Fogarty 정리의 성공으로 보고하지 않는다.

## 1. 수학과 statement를 비교한다

코드를 실행하기 전에 theorem의 가정과 결론을 읽는다. 예를 들어 “dimension 2인 regular local ring”과 “아무 commutative ring”은 다르다. ideal이 proper인지, quotient의 length가 유한한지, 기하학의 tangent space와 algebra의 Hom을 연결했는지 확인한다.

Lean은 작성된 명제를 검증한다. 우리가 의도한 정리를 제대로 작성했는지는 별도의 수학적 검토가 필요하다.

## 2. 고정 환경에서 실행한다

프로젝트 terminal에서:

```bash
cd /Users/sungwoo/lean_project/autoformalization_lab
cat lean-toolchain
lake env lean --version
lake build
```

새 증명 파일은 실제 생성한 경로로 `lake env lean <파일 경로>`를 실행한다. 현재 존재하는 환경 확인 예시는 다음과 같다.

```bash
lake env lean AutoformalizationLab/SmokeTest.lean
```

완성된 HilbertScheme 모듈은 root library에서 import하여 `lake build`와 CI에 포함한다. root가 import하지 않는 파일은 이 build만으로 확인됐다고 말할 수 없다.

## 3. proof hole과 axiom을 확인한다

`sorry`가 있는 Lean 파일도 warning과 함께 실행에 성공할 수 있다. exit code 0만으로 완전한 증명을 판정하지 않는다.

source에서 `sorry`, `admit`, 새 `axiom` 선언을 살펴보고, audit용 Lean 파일에서 실제 theorem의 이름으로 `#print axioms`를 실행한다. source 검색은 comment나 문자열도 잡으므로 결과를 읽어야 하고, imported dependency의 가정은 axiom audit으로 확인한다.

이미 존재하는 작은 예제로 실행 방법을 재현할 수 있다.

```bash
cat > /tmp/autoformalization-lab-axiom-audit.lean <<'EOF'
import AutoformalizationLab.SmokeTest
#check AutoformalizationLab.smoke_arithmetic
#print axioms AutoformalizationLab.smoke_arithmetic
EOF
lake env lean /tmp/autoformalization-lab-axiom-audit.lean
```

`propext`, `Classical.choice`, `Quot.sound`는 일반적인 Lean/Mathlib 기반에서 등장할 수 있다. `sorryAx`나 설명되지 않은 별도 mathematical axiom은 완성된 proof라는 주장과 양립하지 않는다.

2026-10-07 위 audit 명령을 로컬에서 실행하여 exit code 0을 확인했다. `smoke_arithmetic : 2 + 3 = 5`의 axiom 출력은 `[propext]`였다. 이는 검증 절차의 실행 확인이며 Hilbert scheme 정리의 검증은 아니다.

그러나 `#print axioms`도 theorem의 **가정**을 없애주지는 않는다. “Hilbert scheme의 representability를 가정하면 …”이라는 theorem은 가정 아래에서 검증된 결과다. 전체 정리를 완성하려면 그 가정도 실제 결과로 제공해야 한다.

## 4. 결과 보고를 구분한다

| 보고 | 의미 |
|---|---|
| statement checked | 타입과 정의가 맞지만 proof가 완성됐다는 뜻은 아님 |
| conditional proof verified | 명시한 미해결 입력 가정 아래 proof가 검증됨 |
| unconditional proof verified | 목표 가정 외에 새 미해결 입력 없이 proof와 dependency가 검증됨 |
| source reviewed only | 코드를 읽었으나 실행하지 않음 |

VS Code에서 마지막 tactic 뒤의 “Goals accomplished!”를 보고, terminal의 컴파일 결과와 axiom audit을 함께 확인하면 된다. 자연어 해설에는 각 Lean 결과가 전체 outline의 어느 단계를 해결하는지도 표시한다.
