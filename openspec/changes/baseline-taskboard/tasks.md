# Tasks

## 1. Implementation

- [x] 1.1 [product-manager] Turn the capability candidates and flows in `docs/legacy-map.md` into as-is scenarios; verify every scenario points at a line of existing code

## 2. Tests

- [x] 2.1 [test-engineer] Go characterization tests in `baseline_test.go` for every api/health scenario; verify `go test ./...` passes with no code change
- [x] 2.2 [test-engineer] Vitest characterization tests in `App.baseline.test.tsx` for every web/home scenario; verify `npm test` passes with no code change

## 3. Review

- [x] 3.1 [qa-engineer] Confirm no file outside tests and `openspec/` changed (`git diff --stat main`), run all checks, give VERDICT: SHIP or DO-NOT-SHIP
