(steen markdown)
================

A portable R7RS Scheme library to parse (a subset of) markdown.

It doesn't support a lot of the markdown standard, and doesn't deal well with malformed input.

It's called "steen" because it only supports my own subset of markdown. I'll rename it to something less egotistic once I improve the parser.

## How to use it

Stick the `steen` directory where your scheme can see it. In the case of chibi-scheme, you can put it in the same directory as your main scheme file, in `lib/` or where it loads all the other libraries from.

It exports one procedure: `markdown->sxml`. It takes an input port and emits sxml.

```Scheme
(import (scheme small)
        (steen markdown)
        (chibi sxml))

(call-with-output-file "out.html"
  (lambda (output)
    (call-with-input-file "in.md"
      (lambda (input)
        (display (sxml->xml (markdown->sxml input)) output)))))
```

## What it currently supports

You can use italics, bold, code and links, images on a new line and line separators. Use `\` to escape a special character (\_, \*, \` and \[ anywhere in a line and \! or \- after two newlines).

I might add more as I go along.
