# Org-Flow: A Web Frontend For Org-Mode

Org-Flow is a frontend for working with Org-Mode.
Inspired by [org-roam-ui](https://github.com/org-roam/org-roam-ui) Org-Flow aims to provide an alternative interface for Org-Mode.

## Installation

``` sh
$ (add-to-list 'load-path "path/to/org-flow")
(require 'org-flow)
```

## Usage
Start `org-flow` using `M-x org-flow-mode`.

## Current Limitations
Currently only `TODO`s from `~/org/inbox.org` are loaded.
Change the `org-flow-inbox`, `M-: (setq org-flow-inbox "path/to/your/file.org")` to load your org file.
