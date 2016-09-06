# XBitsy

XBitsy is an interpreter for the [Bitsy](https://github.com/apbendi/bitsyspec)
language implemented in Elixir.

🚨 NOTE: This project is a work in progress, and is currently very much incomplete

## Bitsy

[Bitsy](https://github.com/apbendi/bitsyspec) is a programming language which
aims to be the best language to implement
when building your first compiler or interpreter. It is a resource for
programmers learning about language design.

To learn more about Bitsy or to try implementing it yourself, in your favorite
language, check out the runnable, test based language specification,
[BitsySpec](https://github.com/apbendi/bitsyspec).

You can read more about the motivation behind creating Bitsy on the
[ScopeLift Blog](http://www.scopelift.co/blog/introducing-bitsy-the-first-language-youll-implement-yourself).

For a complete, functioning implementation of Bitsy, check out the
[BitsySwift](https://github.com/apbendi/bitsy-swift) compiler.

I'll be speaking about creating Bitsy and implementing it in Swift at
[360iDev](http://360idev.com/sessions/300-compilers-arent-magic-lets-build-one-swift/)
and
[Indie DevStock](http://indiedevstock.com/speakers/ben-difrancesco/).
If you're attending either, be sure to say hello!

## Requirements

This project is being developed with Elixir 1.3.2 on OS X El Capitant (10.11.5).
No other configurations have yet been tested.

## Installation and Usage

To try out XBitsy in its current state, clone the repo and run  the tests.
No command line interface has yet been exposed.

```bash
git clone https://github.com/apbendi/xbitsy.git
cd xbitsy
mix test
```
