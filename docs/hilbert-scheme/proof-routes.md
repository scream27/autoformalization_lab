# Fogarty 경로가 최선인가?

2026-10-07 갱신: 고정 Mathlib의 API 확인과 작은 prototype 결과를 반영해 **commuting operators + explicit basis charts**를 우선 구현 경로로 추천한다. smoothness에는 algebraic rank-one ADHM bridge를 시험하며, Hilbert–Burch는 비교 후보로 유지한다. [실제 소스·컴파일 근거와 상세 비교](library-route-audit.md)를 참고한다. 아래는 후보들의 수학적 비교이며 전체 formalization 비용이 실측되었다는 뜻은 아니다.

## 후보 비교

| 경로 | 핵심 아이디어 | 우리 작업에서의 장점 | 구현에서 확인할 것 |
|---|---|---|---|
| Fogarty: tangent bound + global geometry | local Hom length를 제어하고 dimension 및 connectedness와 결합 | tangent space와 dimension의 관계를 이해하기 좋음 | resolution, local duality 특수형, Hilbert–Chow, connectedness, dimension theory |
| Hilbert–Burch + lifting | ideal을 matrix의 maximal minors로 표현하고 matrix를 lift하여 flat family를 lift | smoothness에 직접 접근하며 global connectedness 논증을 피할 수 있음 | 상대적 Hilbert–Burch, exactness/grade, flatness criterion, deformation functor와 scheme의 bridge |
| explicit affine charts | quotient의 basis를 고정하고 multiplication matrices에 대한 방정식으로 moduli chart 구성 | 작은 n에서 직접 계산·설명·검증하기 좋음; representability 구현 후보 | 모든 chart의 covering과 gluing, functoriality, smoothness의 별도 증명, 일반 surface로의 locality |

### Hilbert–Burch 경로의 논리

1. finite flat family의 ideal을 적절한 rectangular matrix의 maximal minors로 표현한다.
2. 작은 Artinian thickening 위로 그 matrix의 entries를 lift한다.
3. lifted minors로 quotient를 만들고, 필요한 grade/exactness 조건과 flatness를 증명한다.
4. 모든 필요한 작은 변형이 lift된다는 결론을 Hilbert functor의 formal smoothness로 연결한다.
5. representability 및 필요한 finite-presentation 조건으로 scheme의 smoothness를 얻는다.

이것은 tangent vector만 계산하는 것보다 강한 lifting 논증이다. matrix entry를 lift할 수 있다는 사실만으로 3번의 flatness가 자동으로 증명된 것은 아니다. obstruction space가 존재하더라도 개별 obstruction이 사라질 수 있으므로 `Ext¹ = 0`을 근거 없이 주장하지 않는다.

이 경로로 smoothness를 얻더라도 dimension 2n이나 irreducibility까지 자동으로 얻었다고 보고하지 않는다. 각각 필요한 tangent 계산 또는 별도 geometry를 제공해야 한다.

## 현재 Lean 근거와 한계

고정 Mathlib의 `Mathlib/RingTheory/Smooth/Basic.lean` source에서 `Algebra.FormallySmooth`와 square-zero quotient에 대한 lifting 결과, 그리고 formal smoothness와 finite presentation을 요구하는 `Algebra.Smooth` 정의를 읽었다. 후속 `RouteAudit.lean`에서 관련 API의 `#check`와 standard smooth → smooth instance 사용을 확인했다. Hilbert functor 자체의 lifting proof는 아직 구현하지 않았다.

전체 source에서 `Hilbert.?Burch`, `local duality`, `LocalDuality` 문자열을 검색했으나 결과가 없었다. 이는 다른 이름의 구현까지 배제하는 완전한 audit은 아니다. 현재 어떤 경로도 “Mathlib에서 바로 적용 가능한 완성된 정리”로 확인되지 않았다.

## 결정 방법

공통 첫 예제 `(x,y)`의 quotient/cotangent 계산을 유지한다. 그다음 길이 3의 fat point ideal `(x²,xy,y²)`를 후보 prototype으로 삼아 matrix/minors 설명과 lifting/flatness proof에 필요한 API를 조사한다. 결과를 Fogarty의 local Hom bound에 필요한 API와 비교한다. 구현이 짧아 보여도 theorem의 의미를 연결하는 bridge가 빠졌다면 더 저렴한 경로로 계산하지 않는다.

현재 추천은 **구체적인 cyclic representation과 matrix 예제로 시작하고, basis chart의 smoothness bridge를 먼저 시험하는 것**이다. Fogarty는 tangent/dimension 설명의 참고로 유지한다. Hilbert–Burch/lifting의 우선 검토 제안은 위 소스 audit 결과에 따라 수정했다.

## 읽을 자료

- [Fogarty (1968)](https://pi.math.cornell.edu/~mike/7670-fa20/references/fogarty-1968.pdf): 기존 baseline의 원논문.
- [Ekedahl–Skjelnes, Recovering the good component of the Hilbert scheme, Proposition 7.27, 출판본 pp. 835–836](https://annals.math.princeton.edu/wp-content/uploads/annals-v179-n3-p01-p.pdf): Hilbert–Burch와 infinitesimal lifting을 통한 smoothness 증명. arXiv v2의 번호 7.26과 출판본의 번호 7.27을 구분한다. 이 proposition을 읽기 위해 논문의 blow-up construction 전체를 구현할 필요는 없다.
- [Johan de Jong, Burch’s theorem](https://www.math.columbia.edu/~dejong/wordpress/?p=1522): minors와 matrix deformation의 직관을 설명하는 저자의 글.
- [Gustavsen–Laksov–Skjelnes, An elementary, explicit, proof of the existence of Hilbert schemes of points](https://arxiv.org/abs/math/0506161): explicit charts를 통한 존재 구성의 참고. 존재 구성과 surface case의 smoothness 증명을 구분한다.
