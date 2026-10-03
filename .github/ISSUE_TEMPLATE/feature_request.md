---
name: 'Feature Request'
about: 'Suggest an idea, enhancement, new device support, or automation workflow'
title: '[FEATURE] '
labels: 'enhancement'
assignees: ''
---

## Motivation & Problem Statement

Describe the problem, missing feature, or workflow you would like to see supported.

## Proposed Solution

Describe the proposed improvement, new loader, or feature.

## Category

Select all that apply:

- [ ] Device & Hardware Support (New Qualcomm SoC, Firehose programmer, udev rule, hardware quirks)
- [ ] Docker Container Enhancement (Image size optimization, multi-arch support, dependencies)
- [ ] Entrypoint & Script Automation (Dump post-processing, automated flashing workflows)
- [ ] Make Tooling & CLI Shortcuts (`.make/`, new command targets)
- [ ] Documentation & Community Guides

## Proposed Command or Usage Syntax

```bash
# Example of how the new feature or command should be invoked
make edl-run <new-feature-args>
# or: docker run --rm -it --privileged --net=host -v /dev/bus/usb:/dev/bus/usb ghcr.io/boardport/edl <args>
```

## Additional Context

Add any background information, hardware datasheets, links, or device specifications.
