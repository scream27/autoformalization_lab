# Lean에서 마찰이 적은 증명 경로: 소스와 prototype 비교

2026-10-07. 고정 환경: Lean `v4.35.0-rc4`, Mathlib `e6bbacd0e1b7307ff6e17da09cd2455f60804fa6`.

## 판단

현재 환경에서는 **commuting operators의 algebra → explicit basis charts → algebraic smoothness → 일반 surface의 locality** 경로를 우선 추천한다. Nakajima 책의 모든 infrastructure를 그대로 구현한다는 뜻은 아니다. 특히 일반 GIT/Luna slice theorem 대신 이 moduli problem의 구체적인 charts를 구성하는 방향이다.

smoothness proof는 아직 선택을 확정할 수 없는 세부 단계가 있다. 단순 commutator의 constant-rank 계산을 바로 smoothness로 바꾸는 것보다, rank-one ADHM 방정식의 surjective differential을 기존 standard-smooth API에 연결하는 후보를 먼저 시험한다. 이 추천은 아래 API 확인과 작은 prototype에 근거한 engineering 판단이다. 전체 Hilbert scheme이나 ADHM smoothness를 이미 구현해서 비교한 결과는 아니다.

Fogarty original은 GIT에 의존하지 않는 classical algebraic proof지만, 우리에게 더 primitive한 구현은 아니다. regular local ring의 homological dimension, Ext, local duality, connectedness를 동시에 잇는 기반이 필요하기 때문이다.

## 무엇까지 실제 확인했나?

[RouteAudit.lean](RouteAudit.lean)을 다음 명령으로 실행했다.

```bash
cd /Users/sungwoo/lean_project/autoformalization_lab
lake env lean docs/hilbert-scheme/RouteAudit.lean
```

결과: exit code 0, error와 warning 없음. 이 파일은 독립 실행하는 API audit/prototype이며 root library나 CI의 Hilbert scheme 완료 목표가 아니다.

| 항목 | 확인 수준 | 결과 |
|---|---|---|
| trace pairing이 matrix를 구분함 | `#check` + proof 컴파일 | `Matrix.ext_iff_trace_mul_left` 사용 |
| trace cyclicity | `#check` | `Matrix.trace_mul_cycle` |
| rank-nullity, quotient dimension | `#check` | `LinearMap.finrank_range_add_finrank_ker`, `Submodule.finrank_quotient_add_finrank` |
| cyclic representation에서 commuting endomorphism의 유일성 | proof 컴파일 | `cyclic_endomorphism_ext`; `LinearMap.ext_on_range` 사용 |
| noncommutative algebra의 commuting operators에 polynomial 대입 | definition 컴파일 | `commutingEvaluation`; commutative adjoin을 통해 대입 |
| square-zero lifting과 formal smoothness | `#check` | `Algebra.FormallySmooth.iff_comp_surjective` |
| Jacobian으로 standard smoothness 구성 | `#check` | `SubmersivePresentation.isStandardSmooth`, `PreSubmersivePresentation.isUnit_jacobian_iff_aevalDifferential_bijective` |
| standard smooth → smooth | instance 사용 컴파일 | `inferInstance` 성공 |
| regular local ring의 cotangent dimension characterization | `#check` | `IsRegularLocalRing.iff_finrank_cotangentSpace` |

두 prototype theorem에 대한 `#print axioms` 결과:

- `cyclic_endomorphism_ext`: `propext`, `Quot.sound`.
- `trace_pairing_separates`: `propext`, `Classical.choice`, `Quot.sound`.

이 결과는 두 보조정리를 검증한다. centralizer의 dimension, differential의 rank, geometric quotient의 smoothness는 아직 검증하지 않았다.

## 실제 마찰 하나: polynomial을 matrix에 대입하기

`MvPolynomial.aeval`의 target에는 `CommSemiring`이 필요하다. 전체 matrix algebra나 `Module.End k V`는 일반적으로 noncommutative라서 그대로 넣을 수 없다.

하지만 새 multivariate polynomial evaluation 이론을 만들 필요는 없다. `Algebra.isMulCommutative_adjoin`으로 commuting operators가 생성하는 subalgebra의 commutativity를 얻고, 그 안에서 `aeval`한 다음 원래 algebra로 포함시키면 된다. 이 adapter는 prototype에서 컴파일됐다.

구현 표현도 역할에 맞춰 고른다. cyclic module 논증에는 `Module.End`와 `AlgHom`, 좌표 방정식과 Jacobian에는 `Matrix`를 사용하고 필요한 곳에서 basis로 연결한다. 모든 논증을 index 계산으로 펼칠 필요는 없다.

## 경로별 새 기반의 부담

아래 평가는 예상 개발 부담이다. 숫자로 측정한 실행 시간이나 완성 기간은 아니다.

| 단계 | Matrix + explicit charts | Fogarty original | Hilbert–Burch lifting |
|---|---|---|---|
| 첫 algebra 결과 | 낮음: 기존 linear algebra를 직접 사용 | 중간: finite length 및 Hom API 연결 | 중간: minors/complex 구성 |
| smoothness의 핵심 | 중간~높음: rank 계산과 presentation bridge | 높음: regularity와 homological algebra의 연결 | 높음: relative Hilbert–Burch와 flat lifting |
| 매개 공간 구성 | 높음: charts·gluing·universal family | 높음: Hilbert scheme의 존재가 별도로 필요 | 높음: Hilbert scheme의 존재가 별도로 필요 |
| 추가 global geometry | 평면 이후 locality 필요 | Hilbert–Chow·connectedness·dimension 필요 | local-to-global deformation 연결 필요 |
| 당장 검증 가능한 유용한 결과 | 많음: cyclic modules, centralizers, trace duality | length 관련 결과는 가능, 핵심 bridge는 미확인 | determinant 관련 결과는 가능, 핵심 theorem은 미확인 |

Matrix 경로는 algebra와 moduli construction이 같은 좌표 데이터를 사용한다는 장점도 있다. 반면 Fogarty 경로에서는 매개 공간을 먼저 별도 방식으로 확보하고 그 tangent space를 Hom으로 식별하는 작업이 필요하다.

## Fogarty 쪽에서 확인한 의존성 공백

`RingTheory/RegularLocalRing/Defs.lean`에는 regularity 정의와 cotangent dimension characterization이 있다. `RingTheory/Regular/ProjectiveDimension.lean`에는 regular sequence에 따른 projective dimension 결과가 있다. 하지만 **regular local ring에서 이 결과들을 출발시키는 연결**은 검색에서 찾지 못했다. 이름이 비슷하다고 연결이 완성된 것은 아니다.

전체 Mathlib source에서 `HilbertScheme`, `Hilbert.?Chow`, `Hilbert.?Burch`, `Luna`, `Serre duality`, `local duality`, `Auslander.Buchsbaum`, `geometric quotient`를 검색했다. 추가로 regular-local-ring 사용처와 Krull dimension/projective dimension 조합, Gorenstein/Matlis 이름을 검색했다. 필요한 완성된 bridge를 찾지 못했다. 다른 이름으로 구현되었거나 여러 기존 결과로 짧게 유도될 가능성까지 배제한 것은 아니다.

따라서 `Ext` 일반 이론이나 regular local ring 정의가 있다는 이유만으로 Fogarty proof의 기반이 거의 준비되었다고 판단할 수 없다. 원논문의 local duality 사용은 짧게 적혀 있지만 큰 dependency다.

## Matrix proof의 두 가지 함정과 대안

### 1. constant rank와 scheme smoothness 사이

commuting pair의 선형화는

`D(u,w) = [u,B₂] + [B₁,w]`

이다. cyclic locus에서 목표 rank는 n²−n이며, n²개 방정식 전체에 대한 full rank가 아니다. 따라서 이 rank만 계산하고 곧바로 “Jacobian이 invertible이므로 smooth”라고 할 수 없다. 선택한 방정식들이 scheme을 국소적으로 제대로 정의한다는 증명이나 dimension 논증이 더 필요하다.

일반적으로 zero fibre 위에서 Jacobian rank가 일정하다는 것만으로 scheme smoothness는 성립하지 않는다. `k[t]/(t²)`가 가장 작은 반례다. 이 관찰은 책의 압축된 단계를 formalization에서 풀어 써야 한다는 뜻이다.

구현 후보: ℂ 위에서 rank-one ADHM equation

`μ(B₁,B₂,i,j) = [B₁,B₂] + i j = 0`

를 사용한다. 안정성 조건 아래 derivative의 annihilator를 trace pairing으로 계산하면, 그 원소 ξ는 두 B와 commute하고 ξi = 0을 만족한다. cyclicity로 ξ = 0을 얻어 derivative의 surjectivity를 보이는 전략이다. n²개 방정식에 full rank가 되므로 standard-smooth presentation과 더 직접적으로 연결될 가능성이 있다.

이때 rank-one stable solution에서 j = 0임을 필요한 base-ring/family 수준으로 증명해야 한다. ℂ-valued points의 bijection만으로 scheme isomorphism을 주장하지 않는다. full-rank 계산에서 invertible minor를 선택하고 localization으로 presentation을 만드는 bridge도 아직 구현해야 한다.

### 2. orbit set과 geometric quotient 사이

free action이라는 사실만으로 scheme quotient의 존재·smoothness가 저절로 나오지는 않는다. 책의 Luna 의존성을 그대로 추가하면 matrix 경로의 장점이 약해진다.

대안은 `p₁(B₁,B₂)i, …, pₙ(B₁,B₂)i`가 basis가 되는 open chart를 잡고 그 basis로 matrices를 normalize하는 것이다. basis-change matrix가 구체적이므로 chart 간 transition을 계산할 수 있다. construction은 arbitrary base algebra에 대해 수행하여 families와 맞춰야 한다.

기존 `AlgebraicGeometry/Gluing.lean`에는 scheme gluing이 있다. `RingTheory/Etale/Descent.lean`과 `AlgebraicGeometry/Morphisms/LocalFlatDescent.lean`에는 smoothness의 faithfully-flat base-change descent 기반도 있다(이 부분은 source review). 다만 base-change descent와 quotient map의 source에서 smoothness를 내리는 문제는 구분해야 한다. chart의 product trivialization/section 등을 이용해 정확히 필요한 명제로 연결해야 한다.

## 전체 surface까지의 남은 단계

평면의 Hilbert scheme을 완성해도 일반 surface 정리는 끝나지 않는다. 유한 support의 분해, étale local coordinates가 Hilbert functor에 유도하는 map, 그 map의 적절한 étale/local 성질을 증명해야 한다. algebraic Lean 프로젝트에서는 책의 복소해석적 좌표 논증을 그대로 도입하기보다 이 algebraic bridge를 목표로 한다.

또한 smoothness, dimension 2n, irreducibility를 서로 다른 완료 항목으로 기록한다. smoothness를 위해 original Fogarty의 connectedness를 구현하지 않았다고 해서 irreducibility까지 얻은 것은 아니다.

## 권장 순서와 선택을 바꿀 조건

1. `commutingEvaluation`, cyclicity, centralizer를 일반 algebra API로 정리한다.
2. 길이 3 예제 `(x²,xy,y²)`를 multiplication operators로 표현하고 자연어와 Lean을 대응시킨다.
3. trace duality를 이용해 commutator/ADHM differential의 선형대수 명제를 완성한다.
4. 작은 n의 basis chart 하나에서 coordinate presentation과 smoothness 연결을 끝까지 시험한다.
5. 그 뒤 arbitrary n의 chart covering, gluing, representing property로 확장한다.
6. 일반 surface의 locality를 구현한다.

4번의 bridge가 예상보다 큰 경우에는 Hilbert–Burch의 local lifting prototype과 다시 비교한다. 이 선택 과정에서도 1–3의 결과는 독립적인 algebra 기여로 남는다. local duality나 regular local ring의 homological API가 다른 이유로 이미 대폭 보강된다면 Fogarty의 상대적인 비용도 달라진다.

## 근거 자료

- [Nakajima, Lectures on Hilbert Schemes of Points on Surfaces, §1.2 및 Chapters 2–3](https://www.scribd.com/document/783940511/University-Lecture-Series-018-Hiraku-Nakajima-Lectures-on-Hilbert-schemes-of-points-on-surfaces-American-Mathematical-Society-1999): matrix description, quotient, rank-one ADHM 관점. 제안한 Lean architecture 전체가 책에 그대로 쓰여 있다는 뜻은 아니다.
- [Gustavsen–Laksov–Skjelnes, explicit construction](https://arxiv.org/pdf/math/0506161): basis를 지정한 quotient functor와 affine charts, 특히 §§1, 5–6.
- [Fogarty original](https://pi.math.cornell.edu/~mike/7670-fa20/references/fogarty-1968.pdf): Theorem 2.4, Lemma 2.5.
- [Ekedahl–Skjelnes](https://annals.math.princeton.edu/wp-content/uploads/annals-v179-n3-p01-p.pdf): Proposition 7.27의 Hilbert–Burch lifting 대안.

Mathlib 존재 여부에 대한 근거는 외부 최신 문서가 아니라 위 pinned checkout이다. API 확인 파일을 다시 실행하면 positive evidence를 재현할 수 있다.
