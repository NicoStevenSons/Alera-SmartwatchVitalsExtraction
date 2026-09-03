# Alera Caregiver UI Design References

Figma source:

https://www.figma.com/design/biePwqVocjqt927LqrXMS2/Alera---Digital-Health-Monitor?node-id=218-1099&t=PUqsauo6RaOKo7mT-0

## Included references

- `design-references/caregiver-home.png` — selected-patient dashboard and health overview
- `design-references/caregiver-people.png` — caregiver patient list
- `design-references/caregiver-alerts.png` — alert filters, active alerts, and grouped history
- `design-references/caregiver-alert-detail.png` — alert details, context, devices, timeline, notes, and caregiver actions

## Implementation notes

- Treat the PNG for the current milestone as the visual source of truth.
- Inspect the PNG before editing Flutter files.
- Implement one screen at a time.
- The Alerts export contains a vertically scrolling screen. The bottom navigation is fixed to the viewport in the real application; it should not interrupt the scrollable alert history.
- Do not infer missing screens from these references. Request a design before implementing an unsupported final layout.
- Two supplied Home PNGs were byte-for-byte identical, so only one copy is included.

## Suggested Codex wording

```text
Inspect design-references/caregiver-home.png before implementing the caregiver Home screen. Treat it as the visual source of truth. Preserve the elderly companion interface and all watch ingestion, upload queue, background synchronization, and FastAPI upload behavior.
```
