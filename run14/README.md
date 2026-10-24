# run14 — shared-prefix checkpoint

**Conditional follow-up of V2.** Parent is [run5](../run5/README.md): prefix caching on, MTP off.

**Single change:** `--enable-mamba-shared-prefix-checkpoint`.

vLLM's hybrid prefix-caching notes describe this as a way to checkpoint a shared-prefix boundary in `align` mode, which is the case for multi-turn agent prompts. It is worth trying only when run5 beat run6 but the hit rate on those repeated prefixes stayed low.

**Before launch:** `./run14/flag-check.sh` must print `[PASS]` for this flag. It was not confirmed against the deployed image when this profile was written. If the check fails, do not launch and do not rename the flag to something the help text does not list.

MTP stays off. Do not combine this with a budget or MTP change.

`start.sh` refuses without `CONFIRM_SHARED_PREFIX=1`.

```bash
./run14/flag-check.sh
CONFIRM_SHARED_PREFIX=1 ./run14/start.sh
```
