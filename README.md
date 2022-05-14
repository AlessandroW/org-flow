# Org-Flow: A Web Frontend For Org-Mode
<img src="https://raw.githubusercontent.com/AlessandroW/org-flow/assets/logo.png" align="right" alt="Org-Flow Logo" width="256">
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

## Image License
Image created by [hotpot.ai](https://hotpot.ai/s/art-maker/8-HvRKoW7BInG322j) licensed under [CC BY-NC](https://creativecommons.org/licenses/by-nc/4.0/).
