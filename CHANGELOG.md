## 0.0.61

- Use `identical` for state machine equality checks
- Add state transformations to StateReaderTaskEither

## 0.0.60

- Use `Future.sync` for tryCatch

## 0.0.59

- Use unit instead of void where it makes sense

## 0.0.58

- Add `memo` function helpers, for memoizing functions.

## 0.0.57

- Add `pure` and `call` to more monads

## 0.0.56

- Use `Future.sync` where possible

## 0.0.55

- Add equality checks to state machines

## 0.0.54

- Improve riverpod helpers

## 0.0.53

- Rename `call` to `replace`

## 0.0.52

- Add `tapLeft`

## 0.0.51

- State machine docs and internal refactor

## 0.0.50

- Add riverpod helpers for state machines

## 0.0.49

- `StateRTEMachine` refactor

## 0.0.48

- Expose context / env in `StateRTEMachine`

## 0.0.47

- Add `fromPredicate`\* functions to more monads

## 0.0.46

- Add `mapLeft` to either variants

## 0.0.45

- Add `UnwrapException` to either

## 0.0.44

- Add `flatMapS` to `StateReaderTaskEither`

## 0.0.43

- Add traversal to `ReaderTaskEither`

## 0.0.42

- Add more Reader\* constructors

## 0.0.41

- Clean up `ReaderTaskEither` API

## 0.0.40

- Clean up `StateReaderTaskEither` API

## 0.0.39

- Add `filter` to `StateReaderTaskEither`

## 0.0.38

- Add `delay` method to more monads

## 0.0.37

- Add `State`
- Add `Reader`
- Add `ReaderTask`
- Add `ReaderTaskEither`
- Add `StateReaderTaskEither`
- Add `StateMachine`
- Add `StateRTEMachine`

## 0.0.36

- Add traverse functions, and improve `sequence` for `TaskEither`.

## 0.0.35+1

- Relax fast_immutable_collections version constraint
- Give credit in README for fast_immutable_collections

## 0.0.35

- Add and export `fast_immutable_collections`

## 0.0.34

- Add `firstWhereOption` to iterable extension

## 0.0.33+1

- Document `TaskOption`

## 0.0.33

- Fix `Option.fromJson`

## 0.0.32

- Fix TaskEither `fromNullable` variants

## 0.0.31

- Add library barrel file which exports common types and functions

## 0.0.30

- More docs and small refactor

## 0.0.29+1

- Docs for function methods

## 0.0.29

- Add `p` as an alias for `chain`
- Add `c` as an alias for `compose`

## 0.0.28

- Add `flatMapFirst` to tasks.

## 0.0.27

- Fix `alt` type issues

## 0.0.26

- Fix `None` stripping away type information

## 0.0.25

- Add json_serializable support

## 0.0.24

- Add `MapExtension`

## 0.0.23

- Add `lazy` to `function.dart`.

## 0.0.22

- Add `tryCatchK2` for `TaskEither`.

## 0.0.20+1

- Update README and add CHANGELOG ;)
