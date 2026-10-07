# Step 2 — statement부터 직접 형식화하기

완전한 연습 파일 세 개를 만들었습니다. proof/definition 자리의 `sorry`는 의도적인 연습용 placeholder입니다. 파일의 import·타입·statement가 컴파일된다는 것과 proof가 완성됐다는 것은 다릅니다. 이 파일들은 완성된 라이브러리의 root import에 넣지 않았습니다.

힌트와 정답은 아직 공개하지 않습니다. 시도한 코드와 Lean 오류/goal을 보내면 **hint → 현재 환경에서 확인한 Mathlib lemma 또는 검색 방법 → proof sketch** 순으로 제공합니다. `exact?`, `apply?`, `rw?`를 쓸 수 있으며, 최종 proof에서는 제안을 구체적인 코드로 옮겨 다시 검사합니다.

## 1. 논리 — AND의 순서 바꾸기

[Logic.lean](../AutoformalizationLab/Exercises/Logic.lean)

자연어: P와 Q가 둘 다 참이면, Q와 P도 둘 다 참이다.

목표 statement: `P ∧ Q → Q ∧ P`.

학습할 것: 가정과 goal을 구별하기, compound proposition을 다루기, Infoview에서 tactic 하나씩 시도하기.

```bash
lake env lean AutoformalizationLab/Exercises/Logic.lean
```

먼저 이 파일의 `sorry`를 지우고 직접 시도합니다. proof가 비어 있으면 `unsolved goals`가 나오는 것이 정상적인 학습 피드백입니다. 완성 후 위 명령으로 다시 확인합니다.

## 2. 유한합 — 처음 n개의 홀수의 합

[NaturalSums.lean](../AutoformalizationLab/Exercises/NaturalSums.lean)

자연어: `1 + 3 + … + (2n−1) = n²`. n=0에서는 빈 합이 0이다.

정확한 범위는 `Finset.range n = {0, …, n−1}`이므로 항을 `2*k+1`로 썼습니다. 문제를 이해하기 위해 n=0, 1, 2, 3을 손으로 확인합니다.

학습할 것: 유한합 notation, index 경계, 구조적인 추론과 산술 정리의 분리. 구체적인 lemma와 proof skeleton은 요청할 때 제공합니다.

```bash
lake env lean AutoformalizationLab/Exercises/NaturalSums.lean
```

## 3. MacMahon function — 정의를 Lean으로 옮기기

[MacMahon.lean](../AutoformalizationLab/Exercises/MacMahon.lean)

Plane partition은 칸마다 높이가 적혀 있고 행과 열 방향으로 높이가 증가하지 않는 유한 블록 더미라고 생각할 수 있습니다. 전체 블록 수가 n인 배치의 개수를 pp(n)이라고 하면, 알려진 generating function은 다음입니다.

`M(q) = ∏_{j≥1} (1−q^j)^(-j) = ∑_{n≥0} pp(n) q^n`.

참고: [NIST DLMF, Plane Partitions](https://dlmf.nist.gov/26.12#ii). 이번 문제는 **곱으로 정의된 series를 표현하는 것**까지입니다. 계수가 실제 plane partition의 개수와 같다는 MacMahon theorem 자체는 증명 과제가 아닙니다.

### 표현의 선택

- 타입은 `PowerSeries ℚ`입니다. q는 수치가 아니라 formal variable입니다.
- 따라서 특정 실수 q에서의 analytic convergence를 가정하지 않습니다.
- inverse 연산을 사용하기 위해 계수 타입을 ℚ로 선택합니다. series 전체가 field라는 뜻은 아닙니다. 이 문제의 `1−X^j`는 상수항이 1이라 역원을 갖는 대상입니다.
- 무한곱을 바로 `tprod`로 쓰는 대신, degree n의 계수를 유한곱에서 가져옵니다. topology 설정을 먼저 해야 하는 부담을 피합니다.

### 세 선언의 계약

1. `macMahonFactor k`: j=k+1인 factor `(1−X^j)^(-j)`를 작성합니다. negative natural power 대신 inverse와 natural power를 조합합니다.
2. `macMahonPartial N`: 앞의 N개 factor, 즉 j=1,…,N을 곱합니다. N=0이면 1입니다.
3. `macMahon`: degree n의 계수가 `macMahonPartial n`의 degree n 계수인 formal series를 작성합니다.

degree n에서 j>n인 factor는 영향을 주지 않는다는 안정성 원리가 이 계수별 정의의 수학적 근거입니다. 이번에는 그 원리를 추가 정리로 증명하지 않습니다. n=0도 빈 곱의 상수항을 통해 1을 얻도록 설계했습니다. 일반적으로 타입만 맞는 정의가 이 계약을 만족하는 것은 아니므로, 작성한 body가 계약대로 되어 있는지 함께 검토합니다.

```bash
lake env lean AutoformalizationLab/Exercises/MacMahon.lean
```

## 피드백 기록

각 시도에서 다음 네 가지를 짧게 적습니다.

| 항목 | 기록할 것 |
|---|---|
| Goal | tactic 실행 전 목표와 가정 |
| Candidate | 이번에 시도한 tactic 또는 definition body |
| Feedback | 첫 error, 남은 goals, 혹은 성공 |
| Blocker | 문법 / 타입 / lemma 탐색 / proof 전략 / 비용 |

future proof-search agent는 이 기록을 자동화하는 방향으로 발전시킬 수 있습니다. 지금은 VS Code Infoview와 파일 단위 CLI 검사를 사용합니다.

오늘 시작할 것은 **문제 1 하나**입니다. 문제가 쉬워 보여도 각 tactic 뒤에 goal이 어떻게 바뀌는지 확인해 주세요.
