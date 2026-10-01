# Present timing × low-latency pacing experiment

Relevant upstream work:

- https://github.com/doitsujin/dxvk/pull/5869
- https://github.com/doitsujin/dxvk/pull/4654

## Goal

Produce objective pacing and latency data for DXVK present-timing and low-latency paths.

## Variables

Start from one deterministic D3D11 workload and change one factor at a time.

- `dxvk.enablePresentTiming = True/False`
- `dxvk.latencySleep = Auto/True/False`
- `dxvk.disableNvLowLatency2 = Auto/True/False` where supported
- `dxvk.latencyTolerance` sweep
- fixed refresh vs VRR where available

After identifying a candidate effect, confirm with randomized or ABBA run order.

## Record

- DXVK commit
- Wine/Proton version
- kernel
- NVIDIA driver
- compositor/session
- display refresh
- VRR state
- exact `dxvk.conf`
- frame-time `p50/p95/p99/p99.9`
- CPU frame-start -> submit
- submit -> GPU start if observable
- GPU end
- present request -> observed presentation if observable
- queue depth / frames in flight
- missed deadlines
- CPU/GPU clocks and utilization

## Hypotheses

These are deliberately falsifiable:

1. present timing improves cadence without increasing frame information age;
2. `VK_NV_low_latency2` and DXVK's custom latency sleep may differ mainly in tail behavior;
3. extra latency tolerance may improve deadline-hit rate at the cost of freshness.

## Analysis rule

Do not call a lower frame-time variance result a latency win unless information age or an appropriate latency proxy also improves.

## Deliverables

- [ ] stable baseline
- [ ] single-variable sweeps
- [ ] ABBA confirmation
- [ ] raw CSV / traces
- [ ] exact environment receipt
- [ ] upstream-ready evidence note for `#5869` or `#4654`
